-- linny/health.lua - Health check module for linny
-- Provides validation and Neovim :checkhealth integration

local M = {}

--- Core validation logic (single source of truth)
--- @return table {ok: boolean, errors: string[]}
function M.validate()
  local result = { ok = true, errors = {} }

  local notebook_path = vim.g.linny_open_notebook_path
  if not notebook_path or notebook_path == '' then
    result.ok = false
    table.insert(result.errors, 'Notebook path not configured')
    return result
  end

  local base = vim.fn.expand(notebook_path)
  if vim.fn.isdirectory(base) == 0 then
    result.ok = false
    table.insert(result.errors, 'Notebook directory does not exist: ' .. base)
    return result
  end

  for _, subdir in ipairs({'content', 'lindenConfig', 'lindenIndex'}) do
    local path = base .. '/' .. subdir
    if vim.fn.isdirectory(path) == 0 then
      table.insert(result.errors, 'Missing directory: ' .. subdir)
      result.ok = false
    end
  end

  return result
end

--- Neovim :checkhealth integration
function M.check()
  vim.health.start('linny.vim')

  local notebook_path = vim.g.linny_open_notebook_path
  if not notebook_path or notebook_path == '' then
    vim.health.error('Notebook path not configured', {
      'Set g:linny_open_notebook_path in your config',
      'Get started: https://github.com/linden-project/linny-notebook-template',
    })
    return
  end

  local base = vim.fn.expand(notebook_path)
  if vim.fn.isdirectory(base) == 0 then
    vim.health.error('Notebook directory does not exist: ' .. base)
    return
  end

  vim.health.ok('Notebook configured: ' .. base)

  for _, subdir in ipairs({'content', 'lindenConfig', 'lindenIndex'}) do
    local path = base .. '/' .. subdir
    if vim.fn.isdirectory(path) == 1 then
      vim.health.ok(subdir .. ' directory exists')
    else
      vim.health.warn(subdir .. ' directory missing: ' .. path)
    end
  end

  if vim.g.linny_initialized == 1 then
    vim.health.ok('Plugin initialized')
  else
    vim.health.warn('Plugin not initialized - call linny#Init()')
  end
end

return M
