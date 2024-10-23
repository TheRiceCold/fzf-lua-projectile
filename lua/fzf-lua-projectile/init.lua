local fzf = require('fzf-lua')

local M = {}

-- Default configuration
M.config = {
  search_directory = vim.fn.getcwd(),  -- Default to current working directory
  path_level_label = 1,                 -- Default to show the first level
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
  local result = handle:read('*a')
  handle:close()

  M.projects = {}
  for project in string.gmatch(result, '[^\r\n]+') do
    -- Split the project path into segments
    local segments = {}
    for segment in string.gmatch(project, '[^/]+') do
      table.insert(segments, segment)
    end

    -- Get the desired path level (default to the entire path if out of range)
    local level = math.min(#segments, M.config.path_level_label)
    local formatted_project = table.concat(segments, '/', 1, level)  -- Join segments up to the specified level
    table.insert(M.projects, formatted_project)
  end
end

function M.find_projects()
  fzf.fzf_exec(M.projects, {
    prompt = 'Choose a project  ',
    preview = false,
    sink = function(selected)
      if selected then
        vim.cmd('cd ' .. selected)

        fzf.git_files({
          cwd = selected,
          prompt = 'Select a file  ',
        })
      end
    end,
  })
end

vim.api.nvim_create_user_command('FzfProjectile', function()
  M.find_projects()
end, {})

vim.api.nvim_create_user_command('FzfProjectileRefresh', function()
  M.preload_projects()
end, {})

return M
