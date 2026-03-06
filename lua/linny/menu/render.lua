-- linny/menu/render.lua - Menu rendering functions for different levels
-- Handles rendering of root, taxonomy, and term level menus

local M = {}

local state = require('linny.menu.state')
local items = require('linny.menu.items')
local views = require('linny.menu.views')
local util = require('linny.menu.util')
local widgets = require('linny.menu.widgets')

--- Test file against display expression
--- @param file_dict table File metadata dictionary
--- @param expr table Expression to test {key: value}
--- @return boolean
function M.test_file_with_display_expression(file_dict, expr)
  local keyName = vim.fn.keys(expr)[1]
  local keyVal = expr[keyName]

  if keyVal == 'IS_SET' then
    if file_dict[keyName] ~= nil then
      return true
    else
      return false
    end
  elseif keyVal == 'IS_NOT_SET' then
    if file_dict[keyName] ~= nil then
      return false
    else
      return true
    end
  else
    if file_dict[keyName] ~= nil then
      if file_dict[keyName] == keyVal then
        return true
      else
        return false
      end
    else
      return false
    end
  end

  return true
end

--- Check if file should be displayed based on view properties
--- @param view_props table View properties with except/only rules
--- @param file_dict table File metadata dictionary
--- @return boolean
function M.display_file_ask_view_props(view_props, file_dict)
  if view_props.except then
    for _, except_dict in ipairs(view_props.except) do
      if M.test_file_with_display_expression(file_dict, except_dict) then
        return false
      end
    end
  end

  if view_props.only then
    local onlycount = 0
    for _, only_dict in ipairs(view_props.only) do
      if M.test_file_with_display_expression(file_dict, only_dict) then
        onlycount = onlycount + 1
      end
    end

    if onlycount == #view_props.only then
      return true
    else
      return false
    end
  end

  return true
end

--- Render level 0 (root/view level)
--- @param view_name string Name of the view to render
function M.level0(view_name)
  vim.t.linny_menu_current_menu_type = "menu_level0"
  state.reset()
  views.render(view_name)
end

--- Render level 1 (taxonomy level)
--- @param tax string Taxonomy name
function M.level1(tax)
  vim.t.linny_menu_current_menu_type = "menu_level1"

  local tax_config = vim.fn['linny#tax_config'](tax)

  local tax_plural = tax
  if tax_config and tax_config.plural then
    tax_plural = tax_config.plural
  end

  state.reset()
  items.add_special_event("/  <home>", "home", '0')
  items.add_special_event(".. <up>", "home", 'u')
  items.add_section("# " .. string.upper(tax_plural))
  items.add_divider()

  local views_list = views.get_list(tax_config)
  local views_dict = views.get_views(tax_config)

  local l1_state = state.term_leaf_state(tax)
  local active_view = views.get_active(l1_state)

  if #views_list < 3 and not views_dict['NONE'] then
    local views_string = ""
    for _, view in ipairs(views_list) do
      views_string = views_string .. "[" .. view .. "]"
    end

    local active_arrow_string = util.calc_active_view_arrow(views_list, active_view, 4)

    items.add_section("### VIEW")
    items.add_special_event(views_string, "cycle_l1_view", 'v')
    items.add_text(active_arrow_string)
    items.add_divider()

  elseif #views_list > 1 then
    local views_string = "[" .. views_list[active_view + 1] .. " ▼]"

    items.add_section("### VIEW")
    items.add_special_event(views_string, "dropdown_l1_view", 'v')
    items.add_divider()
  end

  local view_props = views.current_props(active_view, views_list, views_dict)

  local sort = "az"
  if view_props and view_props.sort then
    sort = view_props.sort
  end

  local termslistDict = vim.fn['linny#parse_json_file'](vim.fn['linny#l1_index_filepath'](tax), {})
  local termslist = vim.fn.keys(termslistDict)

  local term_menu = {}

  for _, val in ipairs(vim.fn.sort(termslist)) do
    if M.display_file_ask_view_props(view_props, termslistDict[val]) then
      if view_props and view_props.group_by then
        local group_by = view_props.group_by

        if termslistDict[val][group_by] then
          local group_by_val = string.gsub(string.lower(termslistDict[val][group_by]), '-', ' ')

          if not term_menu[group_by_val] then
            term_menu[group_by_val] = {}
          end

          table.insert(term_menu[group_by_val], val)
        else
          if not term_menu['other'] then
            term_menu['other'] = {}
          end
          table.insert(term_menu['other'], val)
        end
      else
        if not term_menu['Terms'] then
          term_menu['Terms'] = {}
        end
        table.insert(term_menu['Terms'], val)
      end
    end
  end

  -- Get sorted list of groups using Lua-native operations
  local groups = {}
  for group, _ in pairs(term_menu) do
    table.insert(groups, group)
  end
  table.sort(groups)

  for _, group in ipairs(groups) do
    items.add_section("### " .. util.string_capitalize(string.gsub(group, '-', ' ')))

    for _, val in ipairs(term_menu[group]) do
      items.add_document_taxo_key_val(tax, val, 0)
    end
  end

  items.add_empty_line()
  items.add_divider()

  items.add_section("### " .. string.upper('Configuration'))

  local l1_config_path = vim.fn['linny#l1_config_filepath'](tax)
  if vim.fn.filereadable(l1_config_path) == 1 then
    items.add_document("Open " .. tax .. " Config", l1_config_path, 'c', 'file')
  else
    items.add_special_event("Create " .. tax .. " Config", "createl1config", 'C')
  end
end

--- Render level 2 (term level)
--- @param tax string Taxonomy name
--- @param term string Term name
function M.level2(tax, term)
  vim.t.linny_menu_current_menu_type = "menu_level2"

  local l2_config = vim.fn['linny#term_config'](tax, term)
  local tax_config = vim.fn['linny#tax_config'](tax)

  local tax_plural = tax
  if tax_config and tax_config.plural then
    tax_plural = tax_config.plural
  end

  state.reset()

  items.add_special_event("/  <home>", "home", '0')
  items.add_ex_event(".. <up> " .. tax_plural, ":call linny_menu#openterm('" .. tax .. "','')", 'u')
  items.add_section("# " .. string.upper(tax) .. ': ' .. string.upper(term))

  items.add_divider()

  if l2_config and l2_config.infotext then
    items.add_text(l2_config.infotext)
  end

  local views_list = views.get_list(l2_config)
  local views_dict = views.get_views(l2_config)
  local l2_state = state.term_value_leaf_state(tax, term)
  local active_view = views.get_active(l2_state)

  if #views_list <= 3 and not views_dict['NONE'] then
    local views_string = ""
    for _, view in ipairs(views_list) do
      views_string = views_string .. "[" .. view .. "]"
    end

    local active_arrow_string = util.calc_active_view_arrow(views_list, active_view, 4)

    items.add_section("### VIEW")
    items.add_special_event(views_string, "cycle_l2_view", 'v')
    items.add_text(active_arrow_string)
    items.add_divider()

  elseif #views_list > 1 then
    local views_string = "[" .. views_list[active_view + 1] .. " ▼]"

    items.add_section("### VIEW")
    items.add_special_event(views_string, "dropdown_l2_view", 'v')
    items.add_divider()
  end

  local files_in_menu = vim.fn['linny#parse_json_file'](vim.fn['linny#l2_index_filepath'](tax, term), {})
  local view_props = views.current_props(active_view, views_list, views_dict)
  local files_index = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_docs_with_props.json', {})

  vim.t.linny_tasks_count = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_docs_tasks_count.json', {})

  local files_menu = {}

  for _, file_in_menu in ipairs(files_in_menu) do
    if files_index[file_in_menu] then
      if M.display_file_ask_view_props(view_props, files_index[file_in_menu]) then
        local file_in_menu_dict = {
          file = file_in_menu,
          fm = files_index[file_in_menu]
        }

        if view_props and view_props.group_by then
          local group_by = view_props.group_by

          if files_index[file_in_menu][group_by] then
            local group_by_val = string.gsub(string.lower(files_index[file_in_menu][group_by]), '-', ' ')

            if not files_menu[group_by_val] then
              files_menu[group_by_val] = {}
            end

            table.insert(files_menu[group_by_val], file_in_menu_dict)
          else
            if not files_menu['other'] then
              files_menu['other'] = {}
            end

            table.insert(files_menu['other'], file_in_menu_dict)
          end
        else
          if not files_menu['Documents'] then
            files_menu['Documents'] = {}
          end

          table.insert(files_menu['Documents'], file_in_menu_dict)
        end
      end
    end
  end

  for _, group in ipairs(vim.fn.sort(vim.fn.keys(files_menu))) do
    items.add_section("### " .. util.string_capitalize(group))
    widgets.partial_files_listing(files_menu[group], view_props, 1)
  end

  items.add_empty_line()
  items.add_divider()

  if l2_config and l2_config.mounts then
    local mounts = l2_config.mounts
    if type(mounts) == 'table' then
      for m, mount_config in pairs(mounts) do
        items.add_section("### MOUNT: " .. m)
        local mountfiles = vim.fn.glob(mount_config.source .. "/*.md", false, true)
        local excludes = {}
        if mount_config.exclude then
          excludes = mount_config.exclude
        end
        for _, mfile in ipairs(mountfiles) do
          local filename = vim.fn.split(mfile, "/")
          filename = filename[#filename]
          if vim.fn.index(excludes, filename) ~= 0 then
            items.add_document(filename, mfile, '', 'file')
          end
        end
      end
    end

    items.add_empty_line()
    items.add_divider()
  end

  if l2_config and l2_config.locations then
    local locations = l2_config.locations
    if type(locations) == 'table' then
      items.add_section("### " .. string.upper('Locations'))

      for l, loc_url in pairs(locations) do
        items.add_external_location(l, loc_url)
      end
    end
  end

  items.add_section("### " .. string.upper('Configuration'))

  local l2_config_path = vim.fn['linny#l2_config_filepath'](tax, term)
  if vim.fn.filereadable(l2_config_path) == 1 then
    items.add_document("Open config: " .. term, l2_config_path, 'c', 'file')
  else
    items.add_special_event("Create config: " .. term .. " Config", "createl2config", 'c')
  end

  items.add_section("### " .. string.upper('hot keys'))
  items.add_special_event("<new document>", "newdocingroup", 'A')
  items.add_special_event("<open context menu>", "opencontextmenu", 'm')
  items.add_special_event("<copy all paths>", "copyallpaths", 'Y')
end

--- Render debug info partial
function M.partial_debug_info()
  items.add_section("### " .. util.string_capitalize('debug'))
  items.add_text("t:linny_menu_lastmaxsize = " .. (vim.t.linny_menu_lastmaxsize or ''))
  items.add_text("t:linny_menu_name = " .. (vim.t.linny_menu_name or ''))
  items.add_text("t:linny_menu_taxonomy = " .. (vim.t.linny_menu_taxonomy or ''))
  items.add_text("t:linny_menu_term = " .. (vim.t.linny_menu_term or ''))
  items.add_text("t:linny_menu_view = " .. (vim.t.linny_menu_view or ''))
  items.add_text("g:linny_index_version = " .. (vim.g.linny_index_version or ''))
  items.add_text("g:linny_index_path = " .. (vim.g.linny_index_path or ''))
  items.add_text("Loading time = " .. (vim.t.linny_load_time or ''))
end

--- Render footer items partial
function M.partial_footer_items()
  items.add_special_event("<refresh>", "refresh", 'R')
  items.add_special_event("<home>", "home", 'H')
  items.add_special_event("<online book>", "onlinebook", '?')
  items.add_empty_line()

  local fred_version = vim.fn.system('fred version')
  if vim.v.shell_error ~= 0 then
    fred_version = "not installed"
  end

  local version = require('linny.version')
  items.add_footer('linny: ' .. version.plugin_version())
  items.add_footer('fred:  ' .. fred_version)
end

return M
