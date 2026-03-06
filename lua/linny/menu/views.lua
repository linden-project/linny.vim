-- linny/menu/views.lua - View management functions for linny menu
-- Handles view cycling, state, and configuration extraction

local M = {}

local state = require('linny.menu.state')

--- Get list of view names from config
--- @param config table The configuration table
--- @return table List of view names
function M.get_list(config)
  local views_list = {}

  if config and config.views then
    local views = config.views
    if type(views) == 'table' then
      for key, _ in pairs(views) do
        table.insert(views_list, key)
      end
    end
  end

  if #views_list == 0 then
    views_list = { 'NONE' }
  end

  return views_list
end

--- Get views dictionary from config
--- @param config table The configuration table
--- @return table Dictionary of view configurations
function M.get_views(config)
  local views_all = {}

  if config and config.views then
    local views = config.views
    if type(views) == 'table' then
      for view, props in pairs(views) do
        views_all[view] = props
      end
    end
  end

  if vim.tbl_isempty(views_all) then
    views_all.NONE = { sort = 'az' }
  end

  return views_all
end

--- Get active view index from state
--- @param view_state table The state table
--- @return number The active view index (0-indexed)
function M.get_active(view_state)
  if view_state and view_state.active_view then
    return view_state.active_view
  end
  return 0
end

--- Get current view properties
--- @param active_view number The active view index (0-indexed)
--- @param views_list table List of view names
--- @param views table Dictionary of view configurations
--- @return table The properties for the active view
function M.current_props(active_view, views_list, views)
  -- Convert 0-indexed to 1-indexed for Lua
  local lua_index = active_view + 1
  if lua_index <= #views_list then
    return views[views_list[lua_index]]
  else
    return views[views_list[1]]
  end
end

--- Calculate new active view after cycling
--- @param view_state table The current state
--- @param views table List of view names
--- @param direction number The direction to cycle (1 or -1)
--- @param active_view number The current active view index (0-indexed)
--- @return table The updated state with new active_view
function M.new_active(view_state, views, direction, active_view)
  local new_state = view_state or {}
  local num_views = #views

  local new_index = active_view + direction

  if new_index >= num_views then
    new_state.active_view = 0
  elseif new_index < 0 then
    new_state.active_view = num_views - 1
  else
    new_state.active_view = new_index
  end

  return new_state
end

--- Cycle L1 (taxonomy level) view
--- @param direction number The direction to cycle (1 or -1)
function M.cycle_l1(direction)
  local taxonomy = vim.t.linny_menu_taxonomy
  local current_state = state.term_leaf_state(taxonomy)
  local active_view = M.get_active(current_state)
  local config = vim.fn['linny#tax_config'](taxonomy)
  local views = M.get_list(config)

  local new_state = M.new_active(current_state, views, direction, active_view)
  state.write_term_leaf_state(taxonomy, new_state)
end

--- Cycle L2 (term level) view
--- @param direction number The direction to cycle (1 or -1)
function M.cycle_l2(direction)
  local taxonomy = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term
  local current_state = state.term_value_leaf_state(taxonomy, term)
  local active_view = M.get_active(current_state)
  local config = vim.fn['linny#term_config'](taxonomy, term)
  local views = M.get_list(config)

  local new_state = M.new_active(current_state, views, direction, active_view)
  state.write_term_value_leaf_state(taxonomy, term, new_state)
end

return M
