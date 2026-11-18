local M = {}

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

  local detection = require('linny.indexer').detect()
  result.indexer = {
    backend = detection.backend,
    available = detection.available,
    version = detection.version,
  }

  if detection.backend == 'hugo' then
    local hugo = require('linny.hugo')
    result.hugo_config = hugo.validate_notebook_config(base)
  end

  return result
end

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

  vim.health.start('Indexer')

  local detection = require('linny.indexer').detect()
  if detection.available then
    vim.health.ok(string.format(
      '%s available: %s', detection.backend, detection.version or 'unknown version'
    ))
    if detection.backend == 'hugo' then
      vim.health.warn('lindexer is recommended for faster indexing', {
        'https://github.com/linden-project/linden-index',
      })
    end
  else
    vim.health.warn('No index backend found (index rebuilds disabled)', {
      'Install lindexer: https://github.com/linden-project/linden-index',
    })
  end

  if detection.backend == 'hugo' then
    vim.health.start('Hugo Configuration')
    local config_result = require('linny.hugo').validate_notebook_config(base)
    if config_result.ok then
      vim.health.ok('Hugo configuration valid')
    else
      for _, err in ipairs(config_result.errors) do
        vim.health.error('Hugo config: ' .. err, {
          'Check your Hugo configuration',
          'Reference: https://github.com/linden-project/linny-notebook-template',
        })
      end
    end

    for _, warn in ipairs(config_result.warnings or {}) do
      vim.health.warn('Hugo config: ' .. warn, {
        'Some index features may not work correctly',
        'Reference: https://github.com/linden-project/linny-notebook-template',
      })
    end
  end
end

return M
