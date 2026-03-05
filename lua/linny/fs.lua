local M = {}

function M.dir_create_if_not_exist(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

function M.os_open_with_filemanager(path)
  local cmd = vim.fn.has("unix") == 1 and "xdg-open" or "open"
  vim.fn.jobstart({cmd, path}, {detach = true})
end

return M
