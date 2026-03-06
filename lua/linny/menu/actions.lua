-- linny/menu/actions.lua - Action execution and job helpers for linny menu
-- Handles content menu actions and external command execution

local M = {}

local popup = require('linny.menu.popup')

--- Execute external command asynchronously (cross-platform)
--- @param command table Command array to execute
function M.job_start(command)
  if vim.fn.has('nvim') == 1 then
    vim.fn.jobstart(command)
  else
    vim.fn.job_start(command)
  end
end

--- Build dropdown action list based on item type
--- @param item table The menu item
--- @return table List of action strings for dropdown
function M.build_dropdown_views(item)
  if item.option_type == 'taxo_key_val' then
    return { "archive" }
  elseif item.option_type == 'document' then
    local views = { "copy", "------", "archive", "set taxonomy", "remove taxonomy", "open docdir" }

    -- Add repeat action if available
    local repeat_last = vim.t.linny_menu_repeat_last_taxo_term
    if repeat_last and #repeat_last > 0 then
      table.insert(views, "set " .. repeat_last[1] .. ": " .. repeat_last[2])
    end

    return views
  end

  return {}
end

--- Get display name from item for dropdown title
--- @param item table The menu item
--- @return string The display name
function M.get_item_name(item)
  if item.option_type == 'taxo_key_val' then
    return item.option_data.taxo_term
  elseif item.option_type == 'document' then
    -- Extract name from text like "[key] Document Title"
    local parts = vim.split(item.text, ']')
    if #parts > 1 then
      return vim.trim(parts[2])
    end
    return item.text
  end
  return ""
end

--- Execute content menu action
--- @param action string The action to execute
--- @param item table The menu item to act on
--- @return boolean Whether action was handled
function M.exec_content_menu(action, item)
  if item.option_type == 'taxo_key_val' then
    if action == "archive" then
      vim.fn['linny_menu_documents#archive_l2_config'](
        item.option_data.taxo_key,
        item.option_data.taxo_term
      )
      return true
    end

  elseif item.option_type == 'document' then
    if action == "set archive" then
      M.job_start({ "fred", "set_bool_val", item.option_data.abs_path, "archive", "true" })
      return true

    elseif action == "toggle starred" then
      M.job_start({ "fred", "toggle_bool_val", item.option_data.abs_path, "starred" })
      return true

    elseif action == "copy" then
      -- Extract old title from text
      local text = item.text
      local old_title = text
      if text:find('%[') and text:find('%]') then
        local parts = vim.split(vim.split(text, '%[')[2], '%]')
        if #parts > 1 then
          old_title = vim.trim(parts[2])
        end
      end

      vim.fn.inputsave()
      local name = vim.fn.input('Enter document name: ', old_title .. ' COPY')
      vim.fn.inputrestore()

      if name and name ~= '' then
        vim.fn['linny_menu_documents#copy'](item.option_data.abs_path, name)
      end
      return true

    elseif action == "open docdir" then
      local newdocdir = item.option_data.abs_path:sub(1, -4) .. ".docdir"
      require('linny.fs').dir_create_if_not_exist(newdocdir)
      require('linny.fs').os_open_with_filemanager(newdocdir)
      return true

    elseif action == "set taxonomy" or action == "remove taxonomy" then
      -- These require popup interaction, handled by VimScript callbacks
      return false

    elseif action:match("^set ") then
      -- Handle repeat action like "set category: work"
      local taxo_and_term = action:sub(5) -- Remove "set " prefix
      local parts = vim.split(taxo_and_term, ': ')
      if #parts == 2 then
        M.job_start({ "fred", "set_string_val", item.option_data.abs_path, parts[1], parts[2] })
      end
      return true
    end
  end

  return false
end

--- Show dropdown for current item
--- Creates popup with available actions
function M.dropdown_item()
  local item = vim.t.linny_menu_item_for_dropdown
  local dropdown_views = M.build_dropdown_views(item)

  if #dropdown_views == 0 then
    return
  end

  -- Store for callback
  vim.t.linny_menu_dropdownviews = dropdown_views

  local name = M.get_item_name(item)
  local line = vim.t.linny_menu_line or 1

  popup.create(dropdown_views, {
    zindex = 200,
    drag = 0,
    line = line + 1,
    title = 'Action for ' .. name,
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_item_callback',
  })
end

--- Show set taxonomy popup
--- @param name string Display name for the item
--- @param line number Line number for popup position
function M.show_set_taxonomy(name, line)
  local index_keys_list = vim.fn['linny#parse_json_file'](
    vim.g.linny_index_path .. '/_index_taxonomies.json', {}
  )

  -- Convert to list if it's a dict, then sort
  local taxo_list = {}
  if vim.islist(index_keys_list) then
    taxo_list = index_keys_list
  else
    for k, _ in pairs(index_keys_list) do
      table.insert(taxo_list, k)
    end
  end
  table.sort(taxo_list)

  -- Store for callback
  vim.t.linny_menu_taxo_items_for_dropdown = taxo_list

  popup.create(taxo_list, {
    zindex = 300,
    drag = 0,
    line = line + 1,
    title = name .. ': Set Taxonomy',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_taxo_item_callback',
  })
end

--- Show remove taxonomy popup
--- @param name string Display name for the item
--- @param line number Line number for popup position
function M.show_remove_taxonomy(name, line)
  local index_keys_list = vim.fn['linny#parse_json_file'](
    vim.g.linny_index_path .. '/_index_taxonomies.json', {}
  )

  -- Convert to list if it's a dict, then sort
  local taxo_list = {}
  if vim.islist(index_keys_list) then
    taxo_list = index_keys_list
  else
    for k, _ in pairs(index_keys_list) do
      table.insert(taxo_list, k)
    end
  end
  table.sort(taxo_list)

  -- Store for callback
  vim.t.linny_menu_taxo_items_for_dropdown = taxo_list

  popup.create(taxo_list, {
    zindex = 300,
    drag = 0,
    line = line + 1,
    title = name .. ': Remove Taxonomy',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_remove_taxo_item_callback',
  })
end

--- Show term selection popup for a taxonomy
--- @param name string Display name for the item
--- @param taxo string The taxonomy name
--- @param terms table List of terms
--- @param line number Line number for popup position
function M.show_term_selection(name, taxo, terms, line)
  -- Store for callback
  vim.t.linny_menu_term_items_for_dropdown = terms

  popup.create(terms, {
    zindex = 400,
    drag = 0,
    line = line + 1,
    title = name .. ': ' .. taxo .. ' > Set Term',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_term_item_callback',
  })
end

return M
