local M = {}

--- Initialize notebook paths from g:linny_open_notebook_path
--- Silent operation - returns false without messages if not configured.
--- Error messages are shown by linny#require_init() when user runs commands.
--- @return boolean true if successful, false if validation failed
function M.init()
  local notebook_path = vim.g.linny_open_notebook_path
  if not notebook_path or notebook_path == '' then
    return false
  end

  local base = vim.fn.expand(notebook_path)
  if vim.fn.isdirectory(base) == 0 then
    return false
  end

  vim.g.linny_path_wiki_content = base .. '/content'
  vim.g.linny_path_wiki_config = base .. '/lindenConfig'
  vim.g.linny_index_path = base .. '/lindenIndex'
  return true
end

function M.open(path)
  -- If no path provided, prompt for it
  if not path or path == '' then
    vim.fn.inputsave()
    path = vim.fn.input('Enter path to notebook: ')
    vim.fn.inputrestore()
  end

  if path == '' then
    return false
  end

  vim.api.nvim_echo({{path, 'None'}}, false, {})

  local expanded = vim.fn.expand(path)
  if vim.fn.isdirectory(expanded) == 0 then
    vim.api.nvim_echo({{'ERR: ' .. path .. ' does not exist', 'ErrorMsg'}}, true, {})
    return false
  end

  vim.g.linny_open_notebook_path = expanded
  vim.fn['linny#Init']()

  -- Only open menu if initialization succeeded
  if vim.g.linny_initialized == 1 then
    vim.fn['linny_menu#start']()
    return true
  else
    return false
  end
end

return M
