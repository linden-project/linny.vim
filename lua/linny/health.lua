-- linny/health.lua - Health check module for linny
-- Provides validation and Neovim :checkhealth integration

local M = {}

--- Core validation logic (single source of truth)
--- @return table {ok: boolean, errors: string[], hugo: table|nil}
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

  -- Check Hugo availability (non-blocking - just informational)
  local hugo = require('linny.hugo')
  local hugo_result = hugo.detect()
  result.hugo = hugo_result

  -- Check Hugo configuration if Hugo is available
  if hugo_result.found then
    local config_result = hugo.validate_notebook_config(base)
    result.hugo_config = config_result
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

  -- Check Hugo availability
  local hugo = require('linny.hugo')
  local hugo_result = hugo.detect()
  if hugo_result.found then
    vim.health.ok('Hugo available: ' .. (hugo_result.version or 'unknown version'))

    -- Validate Hugo configuration
    local config_result = hugo.validate_notebook_config(base)
    if config_result.ok then
      vim.health.ok('Hugo configuration valid')
    else
      -- Report errors (blocking issues)
      for _, err in ipairs(config_result.errors) do
        vim.health.error('Hugo config: ' .. err, {
          'Check your Hugo configuration',
          'Reference: https://github.com/linden-project/linny-notebook-template',
        })
      end
    end

    -- Report warnings (non-blocking issues)
    for _, warn in ipairs(config_result.warnings or {}) do
      vim.health.warn('Hugo config: ' .. warn, {
        'Some index features may not work correctly',
        'Reference: https://github.com/linden-project/linny-notebook-template',
      })
    end
  else
    vim.health.warn('Hugo not found (index rebuild features disabled)', {
      'Install Hugo to enable automatic index rebuilding',
      'https://gohugo.io/installation/',
    })
    vim.health.info('Hugo configuration validation skipped (Hugo not available)')
  end
end

return M
