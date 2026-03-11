-- linny/menu/views.lua - View management functions for linny menu
-- Handles view cycling, state, and configuration extraction

local M = {}

local state = require('linny.menu.state')
local items = require('linny.menu.items')
local widgets = require('linny.menu.widgets')
local popup = require('linny.menu.popup')

--- Get list of view names from config
--- @param config table The configuration table
--- @return table List of view names (sorted for consistent ordering)
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
  else
    -- Sort for consistent ordering across restarts
    table.sort(views_list)
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

--- Render a view with its widgets
--- @param view_name string The name of the view to render
function M.render(view_name)
  local view_config = vim.fn['linny#view_config'](view_name)

  if view_config and view_config.widgets then
    local widget_list = view_config.widgets
    for _, widget in ipairs(widget_list) do
      -- Skip hidden widgets
      if not (widget.hidden and widget.hidden == true) then
        -- Add section header
        items.add_section("# " .. (widget.title or ""))

        -- Dispatch to appropriate widget renderer
        local widget_type = widget.type
        if widget_type == "starred_documents" then
          widgets.starred_documents(widget)
        elseif widget_type == "menu" then
          widgets.menu(widget)
        elseif widget_type == "starred_terms" then
          widgets.starred_terms(widget)
        elseif widget_type == "starred_taxonomies" then
          widgets.starred_taxonomies(widget)
        elseif widget_type == "all_taxonomies" then
          widgets.all_taxonomies(widget)
        elseif widget_type == "recently_modified_documents" then
          widgets.recently_modified_documents(widget)
        elseif widget_type == "all_level0_views" then
          widgets.all_level0_views(widget)
        elseif widget_type == "configured_notebooks" then
          widgets.configured_notebooks(widget)
        else
          items.add_section("## ERROR unsupported widget type: " .. (widget_type or "nil"))
        end
      end
    end
  end

  -- Add configuration section
  items.add_section("# Configuration")
  local config_path = vim.g.linny_path_wiki_config .. "/views/" .. view_name .. ".yml"
  items.add_document("Edit this view", config_path, 'c', 'file')
end

--- Show L1 view dropdown
function M.dropdown_l1()
  local taxonomy = vim.t.linny_menu_taxonomy
  local current_state = state.term_leaf_state(taxonomy)
  local active_view = M.get_active(current_state)
  local config = vim.fn['linny#tax_config'](taxonomy)
  local views = M.get_list(config)

  popup.create(views, {
    zindex = 200,
    drag = 0,
    line = 10,
    title = views[active_view + 1] or views[1],  -- Lua is 1-indexed
    col = 9,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_views#dropdown_l1_callback',
  })
end

--- Show L2 view dropdown
function M.dropdown_l2()
  local taxonomy = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term
  local current_state = state.term_value_leaf_state(taxonomy, term)
  local active_view = M.get_active(current_state)
  local config = vim.fn['linny#term_config'](taxonomy, term)
  local views = M.get_list(config)

  popup.create(views, {
    zindex = 200,
    drag = 0,
    line = 10,
    title = views[active_view + 1] or views[1],  -- Lua is 1-indexed
    col = 9,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_views#dropdown_l2_callback',
  })
end

return M
