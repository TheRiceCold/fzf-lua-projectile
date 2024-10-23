local fzf = require 'fzf-lua'

local M = {}

-- Default configuration
M.config = {
	search_directory = vim.fn.getcwd(), -- Default to current working directory
	path_level_label = 1, -- Default to show the first level
}

M.projects = {}

function M.setup(opts)
	if opts then
		if opts.search_directory then
			M.config.search_directory = opts.search_directory
		end
		if opts.path_level_label then
			M.config.path_level_label = opts.path_level_label
		end
	end

	M.preload_projects()
end

-- Function to preload Git projects
function M.preload_projects()
	local cwd = M.config.search_directory
	local handle = io.popen('find ' .. cwd .. " -type d -name '.git' -exec dirname {} \\;")
	local result = handle:read '*a'
	handle:close()

	M.projects = {}
	for project in string.gmatch(result, '[^\r\n]+') do
		-- Split the project path into segments
		local segments = {}
		for segment in string.gmatch(project, '[^/]+') do
			table.insert(segments, segment)
		end

		-- Get the desired path level (cutting off the upper directories)
		local level = M.config.path_level_label
		local start_index = math.max(#segments - level + 1, 1) -- Calculate starting index for display
		local formatted_label = table.concat(segments, '/', start_index) -- Join segments for label

		table.insert(M.projects, { path = project, label = formatted_label })
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
					local selected_label = selected[1]
					for _, project in ipairs(M.projects) do
						if project.label == selected_label then
							local project_path = project.path
							vim.cmd('cd ' .. project_path)
							print('Changed directory to ' .. project_path)

							fzf.git_files {
								cwd = project_path,
                prompt = 'Select a file  ',
							}
							break
						end
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
