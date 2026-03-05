local M = {}

function M.init()
  local base = vim.fn.expand(vim.g.linny_open_notebook_path)
  vim.g.linny_path_wiki_content = base .. '/content'
  vim.g.linny_path_wiki_config = base .. '/lindenConfig'
  vim.g.linny_index_path = base .. '/lindenIndex'
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
  if vim.fn.isdirectory(expanded) == 1 then
    vim.g.linny_open_notebook_path = expanded
    vim.fn['linny#Init']()
    vim.fn['linny_menu#start']()
    return true
  else
    vim.api.nvim_echo({{'ERR: ' .. path .. ' does not exist', 'ErrorMsg'}}, true, {})
    return false
  end
end

return M
