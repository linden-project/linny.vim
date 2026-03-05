local M = {}

local fs = require('linny.fs')

function M.file(innertag)
  fs.os_open_with_filemanager(vim.fn.expand(innertag))
end

function M.mkdir_if_not_exist(innertag)
  local path = vim.fn.expand(innertag)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.fn.mkdir(path, "p")
  end
end

function M.dir1st(innertag)
  M.mkdir_if_not_exist(innertag)
  fs.os_open_with_filemanager(vim.fn.expand(innertag))
end

function M.dir2nd(innertag)
  M.mkdir_if_not_exist(innertag)
  local path = vim.fn.expand(innertag)
  if vim.fn.exists(":NERDTree") == 2 then
    vim.cmd('NERDTree ' .. vim.fn.fnameescape(path))
  end
end

function M.shell(innertag)
  vim.cmd('!' .. innertag)
end

function M.linny(innertag)
  if innertag:find(":") then
    local parts = vim.split(innertag, ":")
    if #parts == 2 then
      vim.fn['linny_menu#openterm'](parts[1], vim.trim(parts[2]))
    else
      vim.api.nvim_echo({{"Invalid Wikitag", "ErrorMsg"}}, false, {})
    end
  else
    vim.fn['linny_menu#openterm'](vim.trim(innertag), '')
  end
end

function M.vim_cmd(innertag)
  vim.api.nvim_echo({{"!" .. innertag, "None"}}, false, {})
  vim.cmd(innertag)
end

return M
