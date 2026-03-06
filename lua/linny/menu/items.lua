-- linny/menu/items.lua - Menu item construction functions
-- Provides functions for creating and managing menu item data structures

local M = {}

local util = require('linny.menu.util')

--- Create default item structure
--- @return table The default item with all fields initialized
function M.item_default()
  local item = {
    -- Mode values:
    -- 0 = option (selectable)
    -- 1 = text (display only)
    -- 2 = section header
    -- 3 = heading
    -- 4 = footer
    mode = 1,
    event = '',           -- ex-cmd or event_id
    text = '',            -- text to display
    option_type = '',     -- kind of type
    option_data = vim.empty_dict(),  -- extra data (must be dict for VimScript)
    key = '',             -- keyboard key
    weight = 0,           -- sorting weight
    help = '',            -- help text
  }
  return item
end

--- Append item to menu items list, sorted by weight
--- @param item table The item to append
function M.append(item)
  local items = vim.t.linny_menu_items or {}
  local total = #items
  local index = -1

  for i = 1, total do
    if item.weight < items[i].weight then
      index = i
      break
    end
  end

  if index < 0 then
    index = total + 1
  end

  table.insert(items, index, item)
  vim.t.linny_menu_items = items
end

--- Add an empty line to the menu
function M.add_empty_line()
  local item = M.item_default()
  M.append(item)
end

--- Add a divider line to the menu
function M.add_divider()
  local item = M.item_default()
  item.text = "-----------------------------------------"
  M.append(item)
end

--- Add a text item to the menu
--- @param text string The text to display
function M.add_text(text)
  local item = M.item_default()
  item.text = text
  M.append(item)
end

--- Add a header item to the menu (mode=3)
--- @param text string The header text (strips leading # characters)
function M.add_header(text)
  local item = M.item_default()
  item.mode = 3
  -- Extract text after leading # characters: "# Foo" -> "Foo"
  item.text = text:match('^#+ *(.*)') or text
  M.append(item)
end

--- Add a footer item to the menu (mode=4)
--- @param text string The footer text
function M.add_footer(text)
  local item = M.item_default()
  item.mode = 4
  item.text = text
  M.append(item)
end

--- Add a section header to the menu (mode=2)
--- Adds an empty line before the section
--- @param text string The section text (strips leading # characters)
function M.add_section(text)
  M.add_empty_line()

  local item = M.item_default()
  item.mode = 2
  -- Extract text after leading # characters: "## Section" -> "Section"
  item.text = text:match('^#+ *(.*)') or text
  M.append(item)
end

--- Add a document item to the menu
--- @param title string The document title
--- @param abs_path string The absolute path to the document
--- @param keyboard_key string The keyboard shortcut
--- @param doc_type string The document type
function M.add_document(title, abs_path, keyboard_key, doc_type)
  local item = M.item_default()
  item.mode = 0
  item.key = keyboard_key
  item.option_type = doc_type
  item.option_data = { abs_path = abs_path }
  item.text = title
  item.event = ":keepalt botright vs " .. abs_path
  M.append(item)
end

--- Add a taxonomy key navigation item
--- @param taxo_key string The taxonomy key
function M.add_document_taxo_key(taxo_key)
  local item = M.item_default()
  item.mode = 0

  local taxo_count = ""
  if vim.g.linny_menu_display_taxo_count then
    local filepath = vim.fn['linny#l1_index_filepath'](taxo_key)
    local files_in_menu = vim.fn['linny#parse_json_file'](filepath, {})
    local count = 0
    -- Count keys in the dictionary
    for _ in pairs(files_in_menu) do
      count = count + 1
    end
    taxo_count = " (" .. count .. ")"
  end

  item.text = util.string_capitalize(taxo_key) .. taxo_count
  item.event = ":call linny_menu#openterm('" .. taxo_key .. "','')"
  M.append(item)
end

--- Add a taxonomy term navigation item
--- @param taxo_key string The taxonomy key
--- @param taxo_term string The taxonomy term
--- @param display_taxonomy_in_menu boolean Whether to display the taxonomy prefix
function M.add_document_taxo_key_val(taxo_key, taxo_term, display_taxonomy_in_menu)
  local item = M.item_default()
  item.option_type = 'taxo_key_val'
  item.option_data = { taxo_key = taxo_key, taxo_term = taxo_term }
  item.mode = 0

  local tax_text = ''
  if display_taxonomy_in_menu then
    tax_text = util.string_capitalize(taxo_key) .. ': '
  end

  local docs_count = ""
  if vim.g.linny_menu_display_docs_count then
    local filepath = vim.fn['linny#l2_index_filepath'](taxo_key, taxo_term)
    local files_in_menu = vim.fn['linny#parse_json_file'](filepath, {})
    docs_count = " (" .. #files_in_menu .. ")"
  end

  item.text = tax_text .. taxo_term .. docs_count
  item.event = ":call linny_menu#openterm('" .. taxo_key .. "','" .. taxo_term .. "')"
  M.append(item)
end

--- Add a special event item to the menu
--- @param title string The item title
--- @param event_id string The event identifier
--- @param keyboard_key string The keyboard shortcut
function M.add_special_event(title, event_id, keyboard_key)
  local item = M.item_default()
  item.text = title
  item.mode = 0
  item.key = keyboard_key
  item.event = event_id
  M.append(item)
end

--- Add an ex command event item to the menu
--- @param title string The item title
--- @param ex_event string The ex command to execute
--- @param keyboard_key string The keyboard shortcut
function M.add_ex_event(title, ex_event, keyboard_key)
  local item = M.item_default()
  item.text = title
  item.mode = 0
  item.key = keyboard_key
  item.event = ex_event
  M.append(item)
end

--- Add an external location item to the menu
--- @param title string The item title
--- @param location string The external location (URL, path, etc.)
function M.add_external_location(title, location)
  local item = M.item_default()
  item.text = title
  item.mode = 0
  item.event = "openexternal " .. location
  M.append(item)
end

--- List all items in the menu (debug function)
function M.list()
  local items = vim.t.linny_menu_items or {}
  for _, item in ipairs(items) do
    print(vim.inspect(item))
  end
end

--- Get item at specified index from t:linny_menu.items
--- @param index number The 0-indexed position
--- @return table|nil The item at the index, or nil if invalid
function M.get_by_index(index)
  local menu = vim.t.linny_menu
  if not menu or not menu.items then
    return nil
  end

  -- Convert 0-indexed to 1-indexed for Lua
  local lua_index = index + 1
  if lua_index < 1 or lua_index > #menu.items then
    return nil
  end

  return menu.items[lua_index]
end

return M
