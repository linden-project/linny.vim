-- linny/hugo.lua - Hugo integration module for linny
-- Provides Hugo detection, version checking, index building, and config validation

local M = {}

-- Required directory settings for Linny notebooks
-- Note: Hugo config output uses lowercase keys
local REQUIRED_DIRS = {
  contentdir = "content",
  datadir = "lindenConfig",
  publishdir = "lindenIndex",
}

-- Required output formats for Linny index files
local REQUIRED_OUTPUT_FORMATS = {
  "starred",
  "docs_with_props",
  "docs_with_title",
  "indexer_info",
  "taxonomies",
  "taxonomies_starred",
  "terms_starred",
}

-- Required output formats for home page
local REQUIRED_HOME_OUTPUTS = {
  "html",
  "starred",
  "docs_with_props",
  "docs_with_title",
  "indexer_info",
  "taxonomies",
  "taxonomies_starred",
  "terms_starred",
}

-- Module-local cache for detection result
local _cache = nil

-- Module-local cache for config validation results (keyed by notebook path)
local _config_cache = {}

-- Watch mode state
local _watch_job_id = nil
local _watch_started = false  -- Track if auto-start has occurred this session

--- Parse version string from Hugo output
--- @param output string Hugo version output
--- @return string|nil version Semantic version (e.g., "0.155.3") or nil
local function parse_version(output)
  if not output then return nil end
  -- Match "v" followed by semver pattern (e.g., "v0.155.3")
  local version = output:match("v(%d+%.%d+%.%d+)")
  return version
end

--- Detect Hugo executable and get version
--- @param force boolean|nil Force re-detection (bypass cache)
--- @return table {found: boolean, path: string|nil, version: string|nil}
function M.detect(force)
  if _cache and not force then
    return _cache
  end

  local result = { found = false, path = nil, version = nil }

  -- Try to find hugo in PATH
  local path = vim.fn.exepath('hugo')
  if path == '' then
    _cache = result
    return result
  end

  result.path = path

  -- Get version
  local output = vim.fn.system('hugo version')
  if vim.v.shell_error == 0 then
    result.found = true
    result.version = parse_version(output)
  end

  _cache = result
  return result
end

--- Clear the detection cache
function M.clear_cache()
  _cache = nil
end

--- Build index for a notebook using Hugo
--- @param notebook_path string|nil Path to the notebook directory
--- @return table {ok: boolean, output: string|nil, error: string|nil}
function M.build_index(notebook_path)
  -- Validate notebook path
  if not notebook_path or notebook_path == '' then
    return { ok = false, error = "No notebook path provided" }
  end

  -- Check if directory exists
  if vim.fn.isdirectory(notebook_path) == 0 then
    return { ok = false, error = "Notebook path does not exist" }
  end

  -- Check if Hugo is available
  local detection = M.detect()
  if not detection.found then
    return { ok = false, error = "Hugo not found" }
  end

  -- Run Hugo with --source option
  local cmd = string.format('hugo --source %s', vim.fn.shellescape(notebook_path))
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return { ok = false, error = output }
  end

  return { ok = true, output = output }
end

--- Get Hugo configuration for a notebook
--- @param notebook_path string Path to the notebook directory
--- @return table {ok: boolean, config: table|nil, error: string|nil}
function M.get_config(notebook_path)
  -- Check if Hugo is available
  local detection = M.detect()
  if not detection.found then
    return { ok = false, error = "Hugo not found" }
  end

  -- Validate notebook path
  if not notebook_path or notebook_path == '' then
    return { ok = false, error = "No notebook path provided" }
  end

  if vim.fn.isdirectory(notebook_path) == 0 then
    return { ok = false, error = "Notebook path does not exist" }
  end

  -- Run hugo config --format json
  local cmd = string.format('hugo config --source %s --format json', vim.fn.shellescape(notebook_path))
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    return { ok = false, error = output }
  end

  -- Parse JSON output
  local ok, config = pcall(vim.fn.json_decode, output)
  if not ok then
    return { ok = false, error = "Failed to parse Hugo config JSON: " .. tostring(config) }
  end

  return { ok = true, config = config }
end

--- Validate directory settings in Hugo config
--- @param config table Hugo configuration table
--- @return table List of error messages
local function validate_directories(config)
  local errors = {}

  for key, expected in pairs(REQUIRED_DIRS) do
    local actual = config[key]
    if actual ~= expected then
      table.insert(errors, string.format("%s must be '%s', got '%s'", key, expected, tostring(actual)))
    end
  end

  return errors
end

--- Validate taxonomies in Hugo config
--- @param config table Hugo configuration table
--- @return table List of error messages
local function validate_taxonomies(config)
  local errors = {}

  local taxonomies = config.taxonomies
  if not taxonomies then
    table.insert(errors, "At least one taxonomy must be defined")
    return errors
  end

  -- Check if taxonomies table has at least one entry
  local count = 0
  for _ in pairs(taxonomies) do
    count = count + 1
    break
  end

  if count == 0 then
    table.insert(errors, "At least one taxonomy must be defined")
  end

  return errors
end

--- Validate output formats in Hugo config
--- @param config table Hugo configuration table
--- @return table List of error messages (warnings)
local function validate_output_formats(config)
  local errors = {}

  local formats = config.outputformats
  if not formats then
    for _, name in ipairs(REQUIRED_OUTPUT_FORMATS) do
      table.insert(errors, "Missing required output format: " .. name)
    end
    return errors
  end

  for _, name in ipairs(REQUIRED_OUTPUT_FORMATS) do
    if not formats[name] then
      table.insert(errors, "Missing required output format: " .. name)
    end
  end

  return errors
end

--- Validate outputs configuration in Hugo config
--- @param config table Hugo configuration table
--- @return table List of error messages
local function validate_outputs(config)
  local errors = {}

  local outputs = config.outputs
  if not outputs then
    table.insert(errors, "outputs configuration is missing")
    return errors
  end

  -- Check home outputs
  local home = outputs.home
  if home then
    -- Convert to lookup table for easier checking
    local home_set = {}
    for _, v in ipairs(home) do
      home_set[v:lower()] = true
    end

    for _, name in ipairs(REQUIRED_HOME_OUTPUTS) do
      if not home_set[name:lower()] then
        table.insert(errors, "Missing output for home: " .. name)
      end
    end
  else
    table.insert(errors, "outputs.home is not configured")
  end

  -- Check page outputs for json
  local page = outputs.page
  if page then
    local has_json = false
    for _, v in ipairs(page) do
      if v:lower() == "json" then
        has_json = true
        break
      end
    end
    if not has_json then
      table.insert(errors, "outputs.page must include 'json'")
    end
  else
    table.insert(errors, "outputs.page is not configured")
  end

  return errors
end

--- Validate Hugo configuration against Linny requirements
--- @param config table Hugo configuration table
--- @return table {ok: boolean, errors: table, warnings: table}
function M.validate_config(config)
  local errors = {}
  local warnings = {}

  -- Directory errors are blocking
  for _, err in ipairs(validate_directories(config)) do
    table.insert(errors, err)
  end

  -- Taxonomy errors are blocking
  for _, err in ipairs(validate_taxonomies(config)) do
    table.insert(errors, err)
  end

  -- Output format issues are warnings (index may still partially work)
  for _, err in ipairs(validate_output_formats(config)) do
    table.insert(warnings, err)
  end

  -- Output config issues are warnings
  for _, err in ipairs(validate_outputs(config)) do
    table.insert(warnings, err)
  end

  return {
    ok = #errors == 0,
    errors = errors,
    warnings = warnings,
  }
end

--- Validate notebook Hugo configuration (combines get_config and validate_config)
--- @param notebook_path string Path to the notebook directory
--- @param force boolean|nil Force re-validation (bypass cache)
--- @return table {ok: boolean, errors: table, warnings: table}
function M.validate_notebook_config(notebook_path, force)
  -- Check cache first
  if not force and _config_cache[notebook_path] then
    return _config_cache[notebook_path]
  end

  -- Get config from Hugo
  local config_result = M.get_config(notebook_path)
  if not config_result.ok then
    local result = {
      ok = false,
      errors = { config_result.error },
      warnings = {},
    }
    _config_cache[notebook_path] = result
    return result
  end

  -- Validate the config
  local validation = M.validate_config(config_result.config)
  _config_cache[notebook_path] = validation
  return validation
end

--- Check if Hugo watch mode is active
--- @return boolean
function M.is_watching()
  return _watch_job_id ~= nil
end

--- Get watch status string for display
--- @return string "watching" or "stopped"
function M.get_watch_status()
  return M.is_watching() and "watching" or "stopped"
end

--- Start Hugo in watch mode for a notebook
--- @param notebook_path string Path to the notebook directory
--- @return table {ok: boolean, job_id: number|nil, error: string|nil}
function M.start_watch(notebook_path)
  -- Check if already watching
  if _watch_job_id then
    return { ok = false, error = "Watch already running" }
  end

  -- Validate notebook path
  if not notebook_path or notebook_path == '' then
    return { ok = false, error = "No notebook path provided" }
  end

  if vim.fn.isdirectory(notebook_path) == 0 then
    return { ok = false, error = "Notebook path does not exist" }
  end

  -- Check if Hugo is available
  local detection = M.detect()
  if not detection.found then
    return { ok = false, error = "Hugo not found" }
  end

  -- Build command
  local cmd = { 'hugo', '--source', notebook_path, '--watch' }

  -- Start Hugo in background with jobstart
  local job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code, _)
      _watch_job_id = nil
    end,
    on_stderr = function(_, data, _)
      -- Only log actual errors (non-empty lines)
      if data then
        for _, line in ipairs(data) do
          if line and line ~= '' then
            vim.schedule(function()
              vim.api.nvim_echo({{'Hugo watch: ' .. line, 'WarningMsg'}}, true, {})
            end)
          end
        end
      end
    end,
    detach = false,
  })

  if job_id <= 0 then
    return { ok = false, error = "Failed to start Hugo watch process" }
  end

  _watch_job_id = job_id
  return { ok = true, job_id = job_id }
end

--- Stop Hugo watch mode
--- @return table {ok: boolean, error: string|nil}
function M.stop_watch()
  if not _watch_job_id then
    return { ok = false, error = "No watch process running" }
  end

  vim.fn.jobstop(_watch_job_id)
  _watch_job_id = nil
  return { ok = true }
end

--- Check if auto-start has occurred this session
--- @return boolean
function M.watch_auto_started()
  return _watch_started
end

--- Mark auto-start as attempted (call after first menu open)
function M.mark_watch_auto_started()
  _watch_started = true
end

--- Clear all caches (detection and config validation)
function M.clear_cache()
  _cache = nil
  _config_cache = {}
end

-- Export internal functions for testing
M._parse_version = parse_version
M._validate_directories = validate_directories
M._validate_taxonomies = validate_taxonomies
M._validate_output_formats = validate_output_formats
M._validate_outputs = validate_outputs

-- Register cleanup autocmd to stop watch on Neovim exit
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    if _watch_job_id then
      vim.fn.jobstop(_watch_job_id)
      _watch_job_id = nil
    end
  end,
  desc = 'Stop Hugo watch process on Neovim exit',
})

return M
