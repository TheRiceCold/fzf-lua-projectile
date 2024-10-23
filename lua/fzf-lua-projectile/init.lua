local fzf = require 'fzf-lua'

local M = {}

M.config = {
	projects_directory = vim.fn.getcwd(), -- Default to current working directory
	path_level_label = 1, -- Default to show the first level
}

M.projects = {}
M.project_map = {} -- Maps labels to paths for quick lookup

function M.setup(opts)
	if opts then
		if opts.projects_directory then
			M.config.projects_directory = opts.projects_directory
		end
		if opts.path_level_label then
			M.config.path_level_label = opts.path_level_label
		end
	end

	M.preload_projects()
end

function M.preload_projects()
	local cwd = M.config.projects_directory
	local handle = io.popen('find ' .. cwd .. " -type d -name '.git' -exec dirname {} \\;")
	local result = handle:read '*a'
	handle:close()

	M.projects = {}
	M.project_map = {}

	for project in string.gmatch(result, '[^\r\n]+') do
		local segments = {}
		for segment in string.gmatch(project, '[^/]+') do
			table.insert(segments, segment)
		end

		local level = M.config.path_level_label
		local start_index = math.max(#segments - level + 1, 1)
		local formatted_label = table.concat(segments, '/', start_index)

		table.insert(M.projects, { path = project, label = formatted_label })
		M.project_map[formatted_label] = project -- Add to the map for quick lookup
	end
end

function M.find_projects()
	local project_labels = {}

	for _, project in ipairs(M.projects) do
		table.insert(project_labels, project.label)
	end

	fzf.fzf_exec(project_labels, {
		prompt = 'Choose a project  ',
		actions = {
			['default'] = function(selected)
				if selected and #selected > 0 then
					local project_path = M.project_map[selected[1]] -- Direct lookup using the map
					if project_path then
						vim.cmd('cd ' .. project_path)
						print('Changed directory to ' .. project_path)

						fzf.git_files {
							cwd = project_path,
							prompt = 'Select a file  ',
						}
					end
				end
			end,
		},
	})
end

vim.api.nvim_create_user_command('FzfProjectile', function()
	M.find_projects()
end, {})

vim.api.nvim_create_user_command('FzfProjectileRefresh', function()
	M.preload_projects()
end, {})

return M
