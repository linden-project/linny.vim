local M = {}

local MIN_INDEX_FORMAT_VERSION = 1

local _cache = nil
local _fallback_notified = false
local _format_warned = false
local _watch_job_id = nil
local _watch_auto_started = false

local function parse_version(output)
  if not output then return nil end
  return output:match("(%d+%.%d+%.%d+)")
end

function M._run_command(command)
  local output = vim.fn.system(command)
  return output, vim.v.shell_error
end

local function probe(name)
  local path = vim.fn.exepath(name)
  if path == '' then return nil end

  local command = name == 'lindexer' and 'lindexer version' or 'hugo version'
  local output, code = M._run_command(command)
  if code ~= 0 then return nil end
  return { path = path, version = parse_version(output) }
end

function M.detect(force)
  if _cache and not force then return _cache end

  local result = { backend = nil, available = false, path = nil, version = nil }

  local lindexer = probe('lindexer')
  if lindexer then
    result.backend = 'lindexer'
    result.available = true
    result.path = lindexer.path
    result.version = lindexer.version
    _cache = result
    return result
  end

  local hugo = probe('hugo')
  if hugo then
    result.backend = 'hugo'
    result.available = true
    result.path = hugo.path
    result.version = hugo.version
    if not _fallback_notified then
      _fallback_notified = true
      vim.notify(
        'linny: using Hugo as the index backend. Install lindexer for faster indexing.',
        vim.log.levels.WARN
      )
    end
  end

  _cache = result
  return result
end

function M.clear_cache()
  _cache = nil
  _fallback_notified = false
  _format_warned = false
  require('linny.hugo').clear_cache()
end

function M.hook_enabled()
  local value = vim.g.linny_index_hook_enabled
  if value == nil then value = vim.g.linny_hugo_hook_enabled end
  if value == nil then value = 1 end
  return value == 1 or value == true
end

function M.watch_enabled()
  local value = vim.g.linny_index_watch_enabled
  if value == nil then value = vim.g.linny_hugo_watch_enabled end
  if value == nil then value = 0 end
  return value == 1 or value == true
end

local function index_info_path(notebook)
  return notebook .. '/lindenIndex/_indexer_info.json'
end

function M.check_format(notebook, backend)
  local path = index_info_path(notebook)
  local file = io.open(path, 'r')
  if not file then
    local warning = string.format(
      'Index metadata missing (%s): %s was not written',
      tostring(backend or 'unknown'), path
    )
    if not _format_warned then
      _format_warned = true
      vim.notify('linny: ' .. warning, vim.log.levels.WARN)
    end
    return { ok = false, warning = warning }
  end

  local content = file:read('*a')
  file:close()

  local decoded_ok, info = pcall(vim.fn.json_decode, content)
  if not decoded_ok or type(info) ~= 'table' then
    local warning = string.format(
      'Index metadata unreadable (%s): %s is not valid JSON',
      tostring(backend or 'unknown'), path
    )
    if not _format_warned then
      _format_warned = true
      vim.notify('linny: ' .. warning, vim.log.levels.WARN)
    end
    return { ok = false, warning = warning }
  end

  local version = tonumber(info.index_format_version)
  if version == nil then
    local warning = string.format(
      'Index format unknown (%s): _indexer_info.json has no index_format_version',
      tostring(backend or 'unknown')
    )
    if not _format_warned then
      _format_warned = true
      vim.notify('linny: ' .. warning, vim.log.levels.WARN)
    end
    return { ok = false, warning = warning }
  end

  if version < MIN_INDEX_FORMAT_VERSION then
    local warning = string.format(
      'Index format %d is older than the minimum supported %d (%s)',
      version, MIN_INDEX_FORMAT_VERSION, tostring(backend or 'unknown')
    )
    if not _format_warned then
      _format_warned = true
      vim.notify('linny: ' .. warning, vim.log.levels.WARN)
    end
    return { ok = false, warning = warning }
  end

  return { ok = true, version = version }
end

function M.build(notebook)
  if not notebook or notebook == '' then
    return { ok = false, error = 'No notebook path provided' }
  end

  if vim.fn.isdirectory(notebook) == 0 then
    return { ok = false, error = 'Notebook path does not exist' }
  end

  local detection = M.detect()
  if not detection.available then
    return { ok = false, error = 'No index backend found' }
  end

  local result
  if detection.backend == 'lindexer' then
    local command = string.format(
      'lindexer build --corpus %s --index %s',
      vim.fn.shellescape(notebook),
      vim.fn.shellescape(notebook .. '/lindenIndex')
    )
    local output, code = M._run_command(command)
    if code ~= 0 then
      result = { ok = false, error = output }
    else
      result = { ok = true, output = output }
    end
  else
    local hugo_result = require('linny.hugo').build_index(notebook)
    result = { ok = hugo_result.ok, output = hugo_result.output, error = hugo_result.error }
  end

  result.backend = detection.backend

  if result.ok then
    M.check_format(notebook, detection.backend)
  end

  return result
end

function M.watch_cache_dir(notebook)
  local name = vim.fn.fnamemodify(notebook, ':t')
  local dir = vim.fn.stdpath('cache') .. '/linny/' .. name
  vim.fn.mkdir(dir, 'p')
  return dir
end

function M.is_watching()
  if _watch_job_id ~= nil then return true end
  return require('linny.hugo').is_watching()
end

function M.status()
  if _watch_job_id ~= nil then
    return { watching = true, backend = 'lindexer' }
  end
  if require('linny.hugo').is_watching() then
    return { watching = true, backend = 'hugo' }
  end
  return { watching = false, backend = nil }
end

function M.get_watch_status()
  return M.is_watching() and 'watching' or 'stopped'
end

function M.start_watch(notebook)
  if not notebook or notebook == '' then return {} end

  local detection = M.detect()
  if not detection.available then
    return { ok = false, error = 'No index backend found (lindexer or hugo)' }
  end

  if M.is_watching() then
    local status = M.status()
    return { ok = true, already = true, job_id = _watch_job_id, backend = status.backend }
  end

  if detection.backend == 'hugo' then
    local hugo_result = require('linny.hugo').start_watch(notebook)
    hugo_result.backend = 'hugo'
    return hugo_result
  end

  local job_id = vim.fn.jobstart({
    'lindexer', 'watch',
    '--corpus', notebook,
    '--state-dir', M.watch_cache_dir(notebook),
    '--index', notebook .. '/lindenIndex',
  }, {
    on_exit = function()
      _watch_job_id = nil
    end,
    on_stderr = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        if line and line ~= '' then
          vim.schedule(function()
            vim.api.nvim_echo({ { 'Index watch: ' .. line, 'WarningMsg' } }, true, {})
          end)
        end
      end
    end,
    detach = false,
  })

  if job_id <= 0 then
    return { ok = false, error = 'Failed to start index watch process' }
  end

  _watch_job_id = job_id
  return { ok = true, job_id = job_id, backend = 'lindexer' }
end

function M.stop_watch()
  if _watch_job_id ~= nil then
    vim.fn.jobstop(_watch_job_id)
    _watch_job_id = nil
    return { stopped = true }
  end

  local hugo_result = require('linny.hugo').stop_watch()
  return { stopped = hugo_result.ok == true, error = hugo_result.error }
end

function M.watch_auto_started()
  return _watch_auto_started
end

function M.auto_start_watch()
  if _watch_auto_started then return nil end
  _watch_auto_started = true

  if not M.watch_enabled() then return nil end
  if not M.detect().available then return nil end

  local notebook = vim.g.linny_open_notebook_path
  if not notebook or notebook == '' then return nil end

  return M.start_watch(notebook)
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    if _watch_job_id ~= nil then
      vim.fn.jobstop(_watch_job_id)
      _watch_job_id = nil
    end
  end,
})

M.MIN_INDEX_FORMAT_VERSION = MIN_INDEX_FORMAT_VERSION
M._parse_version = parse_version

return M
