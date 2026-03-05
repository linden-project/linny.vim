local M = {}

function M.init_variable(var_name, default_value)
  local name = var_name:gsub("^g:", "")
  if vim.g[name] == nil then
    vim.g[name] = default_value
    return true
  end
  return false
end

return M
