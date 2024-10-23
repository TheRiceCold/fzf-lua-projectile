local fzf = require 'fzf-lua'

local M = {}

-- Default configuration
M.config = {
	search_directory = vim.fn.getcwd(), -- Default to current working directory
	path_level_label = 1, -- Default to show the first level
}

-- Store found projects
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

		-- Get the desired path level
		local level = M.config.path_level_label
		local start_index = math.max(#segments - level + 1, 1) -- Calculate starting index for display
		local formatted_project = table.concat(segments, '/', start_index) -- Join segments from start_index to the end
		table.insert(M.projects, formatted_project)
	end
end

function M.find_projects()
	fzf.fzf_exec(M.projects, {
		preview = false,
		prompt = 'Choose a project  ',
		actions = {
			['default'] = function(selected)
				if selected then
					-- Change to the selected project directory
					vim.cmd('cd ' .. selected)
					print('Changed directory to ' .. selected)

					-- Run fzf-lua's built-in git_files command
					fzf.git_files {
						prompt = 'Select a File: ',
						cwd = selected, -- Ensure it searches in the correct directory
					}
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
