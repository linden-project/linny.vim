-- linny/paths.lua - Path construction utilities for linny
-- Constructs file paths for indexes, configs, and state files

local M = {}

--- Normalize a term string: lowercase and replace spaces with dashes
--- @param term string The term to normalize
--- @return string The normalized term
local function normalize_term(term)
  return string.gsub(string.lower(term), ' ', '-')
end

--- Get the path to a taxonomy's L1 index file
--- @param tax string The taxonomy name
--- @return string|nil The full path to the index file, or nil if base path not set
function M.l1_index_filepath(tax)
  local base = vim.g.linny_index_path
  if not base then return nil end
  return base .. '/' .. string.lower(tax) .. '/index.json'
end

--- Get the path to a taxonomy term's L2 index file
--- @param tax string The taxonomy name
--- @param term string The term name
--- @return string|nil The full path to the index file, or nil if base path not set
function M.l2_index_filepath(tax, term)
  local base = vim.g.linny_index_path
  if not base then return nil end
  return base .. '/' .. string.lower(tax) .. '/' .. normalize_term(term) .. '/index.json'
end

--- Get the path to a view's config file
--- @param view_name string The view name
--- @return string|nil The full path to the config file, or nil if base path not set
function M.view_config_filepath(view_name)
  local base = vim.g.linny_path_wiki_config
  if not base then return nil end
  return base .. '/views/' .. string.lower(view_name) .. '.yml'
end

--- Get the path to a taxonomy's L1 config file
--- @param tax string The taxonomy name
--- @return string|nil The full path to the config file, or nil if base path not set
function M.l1_config_filepath(tax)
  local base = vim.g.linny_path_wiki_config
  if not base then return nil end
  return base .. '/L1-CONF-TAX-' .. string.lower(tax) .. '.yml'
end

--- Get the path to a taxonomy term's L2 config file
--- @param tax string The taxonomy name
--- @param term string The term name
--- @return string|nil The full path to the config file, or nil if base path not set
function M.l2_config_filepath(tax, term)
  local base = vim.g.linny_path_wiki_config
  if not base then return nil end
  return base .. '/L2-CONF-TAX-' .. string.lower(tax) .. '-TRM-' .. normalize_term(term) .. '.yml'
end

--- Get the path to a taxonomy's L1 state file
--- @param tax string The taxonomy name
--- @return string|nil The full path to the state file, or nil if base path not set
function M.l1_state_filepath(tax)
  local base = vim.g.linny_state_path
  if not base then return nil end
  return base .. '/L1-STATE-TAX-' .. string.lower(tax) .. '.json'
end

--- Get the path to a taxonomy term's L2 state file
--- @param tax string The taxonomy name
--- @param term string The term name
--- @return string|nil The full path to the state file, or nil if base path not set
function M.l2_state_filepath(tax, term)
  local base = vim.g.linny_state_path
  if not base then return nil end
  return base .. '/L2-STATE-TRM-' .. string.lower(tax) .. '-TRM-' .. string.lower(term) .. '.json'
end

return M
