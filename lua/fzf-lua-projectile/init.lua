local fzf = require 'fzf-lua'

local M = {}

-- Default configuration
M.config = {
	search_directory = vim.fn.getcwd(), -- Default to current working directory
	path_level_label = 1, -- Default to show the first level
}

-- Store found projects
M.projects = {}

-- Function to setup the plugin with user configuration
function M.setup(opts)
	if opts then
		if opts.search_directory then
			M.config.search_directory = opts.search_directory
		end
		if opts.path_level_label then
			M.config.path_level_label = opts.path_level_label
		end
	end

	-- Preload Git projects
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
		-- Store the full path
		table.insert(M.projects, project)
	end
end

-- Function to search for Git projects
function M.find_projects()
	fzf.fzf_exec(M.projects, {
		prompt = 'Choose a project  ',
		actions = {
			['default'] = function(selected)
				if selected and #selected > 0 then
					local project_path = selected[1] -- Get the full path from the selected table
					-- Change to the selected project directory
					vim.cmd('cd ' .. project_path)
					print('Changed directory to ' .. project_path)

					-- Run fzf-lua's built-in git_files command
					fzf.git_files {
						prompt = 'Select a file: ',
						cwd = project_path, -- Ensure it searches in the correct directory
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
