-- linny/menu/state.lua - Tab state management for linny menu
-- Manages per-tab menu state via vim.t variables

local M = {}

--- Generate unique tab number
--- @return number The new unique tab number
function M.new_tab_nr()
  vim.g.linnytabnr = vim.g.linnytabnr + 1
  return vim.g.linnytabnr
end

--- Initialize tab-local state
--- Creates all linny_menu_* tab variables if not already set
function M.tab_init()
  if vim.t.linny_menu_name == nil then
    vim.t.linny_menu_items = {}
    vim.t.linny_tasks_count = {}
    vim.t.linny_menu_cursor = 0
    vim.t.linny_menu_name = '[linny_menu]' .. tostring(M.new_tab_nr())
    vim.t.linny_menu_line = 0
    vim.t.linny_menu_lastmaxsize = 0
    vim.t.linny_menu_view = ''
    vim.t.linny_menu_taxonomy = ''
    vim.t.linny_menu_term = ''
  end
end

--- Read L1 state (taxonomy term)
--- @param term string The taxonomy term
--- @return table The parsed state or empty dict
function M.term_leaf_state(term)
  local filepath = vim.fn['linny#l1_state_filepath'](term)
  local result = vim.fn['linny#parse_json_file'](filepath, vim.empty_dict())
  -- Ensure we return a dict, not a list (empty tables become lists in Vim)
  if vim.tbl_isempty(result) then
    return vim.empty_dict()
  end
  return result
end

--- Read L2 state (taxonomy term value)
--- @param term string The taxonomy term
--- @param value string The term value
--- @return table The parsed state or empty dict
function M.term_value_leaf_state(term, value)
  local filepath = vim.fn['linny#l2_state_filepath'](term, value)
  local result = vim.fn['linny#parse_json_file'](filepath, vim.empty_dict())
  -- Ensure we return a dict, not a list (empty tables become lists in Vim)
  if vim.tbl_isempty(result) then
    return vim.empty_dict()
  end
  return result
end

--- Write L1 state
--- @param term string The taxonomy term
--- @param state table The state to write
function M.write_term_leaf_state(term, state)
  local filepath = vim.fn['linny#l1_state_filepath'](term)
  vim.fn['linny#write_json_file'](filepath, state)
end

--- Write L2 state
--- @param term string The taxonomy term
--- @param value string The term value
--- @param l2_state table The state to write
function M.write_term_value_leaf_state(term, value, l2_state)
  local filepath = vim.fn['linny#l2_state_filepath'](term, value)
  vim.fn['linny#write_json_file'](filepath, l2_state)
end

--- Reset menu state
--- Clears menu items, line, and cursor position
function M.reset()
  vim.t.linny_menu_items = {}
  vim.t.linny_menu_line = 0
  vim.t.linny_menu_cursor = 0
end

return M
