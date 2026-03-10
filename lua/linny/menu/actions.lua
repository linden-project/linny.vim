-- linny/menu/actions.lua - Action execution and job helpers for linny menu
-- Handles content menu actions and external command execution

local M = {}

local popup = require('linny.menu.popup')

--- Execute external command asynchronously (cross-platform)
--- @param command table Command array to execute
--- @param opts table|nil Optional settings (cwd, etc.)
function M.job_start(command, opts)
  if vim.fn.has('nvim') == 1 then
    if opts and next(opts) then
      vim.fn.jobstart(command, opts)
    else
      vim.fn.jobstart(command)
    end
  else
    if opts and next(opts) then
      vim.fn.job_start(command, opts)
    else
      vim.fn.job_start(command)
    end
  end
end

--- Reload buffer if file is currently open
--- @param path string Absolute path to the file
function M.reload_buffer_if_open(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 and vim.fn.buflisted(bufnr) == 1 then
    -- Schedule to avoid issues during popup close
    vim.schedule(function()
      local current_win = vim.api.nvim_get_current_win()
      local wins = vim.fn.win_findbuf(bufnr)
      if #wins > 0 then
        -- Buffer is visible, reload it
        vim.api.nvim_win_call(wins[1], function()
          vim.cmd('edit')
        end)
      else
        -- Buffer exists but not visible, just reload silently
        vim.fn.bufload(bufnr)
      end
    end)
  end
end

--- Execute command and reload buffer on completion
--- @param command table Command array to execute
--- @param path string Path to reload after command completes
function M.job_start_and_reload(command, path)
  if vim.fn.has('nvim') == 1 then
    vim.fn.jobstart(command, {
      on_exit = function()
        M.reload_buffer_if_open(path)
      end
    })
  else
    vim.fn.job_start(command, {
      exit_cb = function()
        M.reload_buffer_if_open(path)
      end
    })
  end
end

--- Check if a document is archived
--- @param abs_path string Absolute path to document
--- @return boolean Whether document has archive: true
local function is_document_archived(abs_path)
  local wiki_content = vim.g.linny_path_wiki_content or ""
  if wiki_content == "" or not abs_path:sub(1, #wiki_content) == wiki_content then
    return false
  end
  local rel_path = abs_path:sub(#wiki_content + 2) -- +2 to skip trailing slash
  local files_index = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_docs_with_props.json', {})
  local props = files_index[rel_path]
  return props and props.archive == true
end

--- Build dropdown action list based on item type
--- @param item table The menu item
--- @return table List of action strings for dropdown
function M.build_dropdown_views(item)
  if item.option_type == 'taxo_key_val' then
    return { "archive", "export to zip" }
  elseif item.option_type == 'document' then
    -- Check if document is already archived
    local archive_action = "archive"
    if is_document_archived(item.option_data.abs_path) then
      archive_action = "unarchive"
    end

    local views = { "copy", "copy path", "------", archive_action, "set taxonomy", "remove taxonomy", "open docdir" }

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
      require('linny.menu.documents').archive_l2_config(
        item.option_data.taxo_key,
        item.option_data.taxo_term
      )
      return true

    elseif action == "export to zip" then
      -- Set tax/term from item data for context menu usage
      vim.t.linny_menu_taxonomy = item.option_data.taxo_key
      vim.t.linny_menu_term = item.option_data.taxo_term
      -- Check if group_by is active to determine flow
      local view_props = vim.t.linny_menu_view_props or {}
      if view_props.group_by then
        M.show_export_structure_popup()
      else
        M.show_export_path_input("flat")
      end
      return true
    end

  elseif item.option_type == 'document' then
    if action == "archive" then
      M.job_start_and_reload({ "fred", "set_bool_val", item.option_data.abs_path, "archive", "true" }, item.option_data.abs_path)
      return true

    elseif action == "unarchive" then
      M.job_start_and_reload({ "fred", "set_bool_val", item.option_data.abs_path, "archive", "false" }, item.option_data.abs_path)
      return true

    elseif action == "toggle starred" then
      M.job_start_and_reload({ "fred", "toggle_bool_val", item.option_data.abs_path, "starred" }, item.option_data.abs_path)
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
        require('linny.menu.documents').copy(item.option_data.abs_path, name)
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
        M.job_start_and_reload({ "fred", "set_string_val", item.option_data.abs_path, parts[1], parts[2] }, item.option_data.abs_path)
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

--- Show path format selection popup
--- @param name string Display name for the item
--- @param line number Line number for popup position
function M.show_path_format_popup(name, line)
  local formats = { "relative", "absolute" }

  -- Store for callback
  vim.t.linny_menu_path_formats = formats

  popup.create(formats, {
    zindex = 300,
    drag = 0,
    line = line + 1,
    title = name .. ': Copy Path',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_path_format_callback',
  })
end

--- Copy a document path to clipboard
--- @param item table The menu item with option_data.abs_path
--- @param format string "absolute" or "relative"
--- @return boolean Whether the copy succeeded
function M.copy_path_to_clipboard(item, format)
  if not item or not item.option_data or not item.option_data.abs_path then
    vim.api.nvim_echo({{"No path available for this item", "ErrorMsg"}}, true, {})
    return false
  end

  local path = item.option_data.abs_path

  if format == "relative" then
    -- Use notebook root (Hugo site root) for relative paths
    local notebook_root = vim.g.linny_open_notebook_path or ""
    if notebook_root ~= "" and path:sub(1, #notebook_root) == notebook_root then
      path = path:sub(#notebook_root + 2) -- +2 to skip the trailing slash
    end
  end

  -- Check clipboard availability
  if vim.fn.has('clipboard') == 0 then
    vim.api.nvim_echo({{"Clipboard not available. Path: " .. path, "WarningMsg"}}, true, {})
    return false
  end

  vim.fn.setreg('+', path)
  vim.api.nvim_echo({{"Copied: " .. path, "Normal"}}, true, {})
  return true
end

--- Get all document paths for a taxonomy term
--- @param tax string The taxonomy name
--- @param term string The term name
--- @return table List of absolute paths
function M.get_term_document_paths(tax, term)
  local paths = {}
  local wiki_content = vim.g.linny_path_wiki_content or ""
  local index_path = vim.fn['linny#l2_index_filepath'](tax, term)
  local files_in_term = vim.fn['linny#parse_json_file'](index_path, {})

  for _, filename in ipairs(files_in_term) do
    local abs_path = wiki_content .. '/' .. filename
    table.insert(paths, abs_path)
  end

  return paths
end

--- Copy all term document paths to clipboard
--- Uses current taxonomy and term from tab variables
--- @param format string "absolute" or "relative"
--- @return boolean Whether the copy succeeded
function M.copy_term_paths_to_clipboard(format)
  local tax = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term

  if not tax or tax == "" or not term or term == "" then
    vim.api.nvim_echo({{"No taxonomy term selected", "ErrorMsg"}}, true, {})
    return false
  end

  local paths = M.get_term_document_paths(tax, term)

  if #paths == 0 then
    vim.api.nvim_echo({{"No documents in this term", "WarningMsg"}}, true, {})
    return false
  end

  -- Convert to relative if requested (relative to notebook/Hugo site root)
  if format == "relative" then
    local notebook_root = vim.g.linny_open_notebook_path or ""
    for i, path in ipairs(paths) do
      if notebook_root ~= "" and path:sub(1, #notebook_root) == notebook_root then
        paths[i] = path:sub(#notebook_root + 2)
      end
    end
  end

  -- Check clipboard availability
  if vim.fn.has('clipboard') == 0 then
    vim.api.nvim_echo({{"Clipboard not available", "WarningMsg"}}, true, {})
    return false
  end

  local content = table.concat(paths, "\n")
  vim.fn.setreg('+', content)
  vim.api.nvim_echo({{"Copied " .. #paths .. " paths to clipboard", "Normal"}}, true, {})
  return true
end

--- Show format selection popup for copying all term paths
--- Uses current taxonomy and term from tab variables
function M.show_term_paths_format_popup()
  local tax = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term

  if not tax or tax == "" or not term or term == "" then
    vim.api.nvim_echo({{"No taxonomy term selected", "ErrorMsg"}}, true, {})
    return
  end

  local formats = { "relative", "absolute" }
  local line = vim.fn.line('.') or 1

  -- Store for callback
  vim.t.linny_menu_term_path_formats = formats

  popup.create(formats, {
    zindex = 300,
    drag = 0,
    line = line + 1,
    title = term .. ': Copy All Paths',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_term_paths_format_callback',
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

--- Check if zip command is available on the system
--- @return boolean Whether zip is available
function M.check_zip_available()
  return vim.fn.executable('zip') == 1
end

--- Export all term documents to a zip archive
--- @param output_path string Path for the output zip file
--- @param structure string "flat" or "folders" for directory structure
--- @return boolean Whether export was initiated successfully
function M.export_term_to_zip(output_path, structure)
  if not M.check_zip_available() then
    vim.api.nvim_echo({{"Error: 'zip' command not found on system", "ErrorMsg"}}, true, {})
    return false
  end

  local tax = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term

  if not tax or tax == "" or not term or term == "" then
    vim.api.nvim_echo({{"No taxonomy term selected", "ErrorMsg"}}, true, {})
    return false
  end

  local paths = M.get_term_document_paths(tax, term)

  if #paths == 0 then
    vim.api.nvim_echo({{"No documents in this term", "WarningMsg"}}, true, {})
    return false
  end

  -- Expand ~ in path
  local expanded_path = vim.fn.expand(output_path)

  -- Build zip command
  local cmd = { "zip", "-j", expanded_path }

  if structure == "folders" then
    -- For folders structure, we need to handle this differently
    -- Create a temp directory, organize files, then zip
    local wiki_content = vim.g.linny_path_wiki_content or ""
    local files_index = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_docs_with_props.json', {})
    local view_props = vim.t.linny_menu_view_props or {}
    local group_by = view_props.group_by

    if group_by then
      -- Create temp dir for organized structure
      local temp_dir = vim.fn.tempname()
      vim.fn.mkdir(temp_dir, "p")

      for _, abs_path in ipairs(paths) do
        local rel_path = abs_path:sub(#wiki_content + 2)
        local props = files_index[rel_path] or {}
        local group_value = props[group_by] or "ungrouped"
        if type(group_value) == "table" then
          group_value = group_value[1] or "ungrouped"
        end

        local group_dir = temp_dir .. "/" .. group_value
        vim.fn.mkdir(group_dir, "p")

        local filename = vim.fn.fnamemodify(abs_path, ":t")
        vim.fn.system({"cp", abs_path, group_dir .. "/" .. filename})
      end

      -- Zip the organized directory
      cmd = { "zip", "-r", expanded_path, "." }
      M.job_start(cmd, { cwd = temp_dir })

      vim.api.nvim_echo({{"Exporting " .. #paths .. " files to " .. output_path .. " (with folders)", "Normal"}}, true, {})
      return true
    end
  end

  -- Flat structure: just add all files
  for _, path in ipairs(paths) do
    table.insert(cmd, path)
  end

  M.job_start(cmd)

  vim.api.nvim_echo({{"Exporting " .. #paths .. " files to " .. output_path, "Normal"}}, true, {})
  return true
end

--- Show export structure selection popup (flat vs folders)
--- Only shown when group_by view is active
function M.show_export_structure_popup()
  local tax = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term

  if not tax or tax == "" or not term or term == "" then
    vim.api.nvim_echo({{"No taxonomy term selected", "ErrorMsg"}}, true, {})
    return
  end

  if not M.check_zip_available() then
    vim.api.nvim_echo({{"Error: 'zip' command not found on system", "ErrorMsg"}}, true, {})
    return
  end

  local structures = { "flat", "preserve folders" }
  local line = vim.fn.line('.') or 1

  vim.t.linny_menu_export_structures = structures

  popup.create(structures, {
    zindex = 300,
    drag = 0,
    line = line + 1,
    title = term .. ': Export Structure',
    col = 10,
    wrap = 0,
    border = {},
    cursorline = 1,
    padding = {0, 1, 0, 1},
    filter = 'popup_filter_menu',
    mapping = 0,
    callback = 'linny_menu_actions#dropdown_export_structure_callback',
  })
end

--- Show export path input dialog
--- @param structure string "flat" or "folders"
function M.show_export_path_input(structure)
  local term = vim.t.linny_menu_term or "export"
  local default_path = "~/Downloads/" .. term .. ".zip"

  vim.fn.inputsave()
  local path = vim.fn.input('Export zip path: ', default_path)
  vim.fn.inputrestore()

  if path and path ~= '' then
    vim.cmd('redraw')
    M.export_term_to_zip(path, structure)
  end
end

--- Start export to zip flow (for Z hotkey in level 2 menu)
--- Checks if group_by is active and routes accordingly
function M.start_export_to_zip()
  local tax = vim.t.linny_menu_taxonomy
  local term = vim.t.linny_menu_term

  if not tax or tax == "" or not term or term == "" then
    vim.api.nvim_echo({{"No taxonomy term selected", "ErrorMsg"}}, true, {})
    return
  end

  if not M.check_zip_available() then
    vim.api.nvim_echo({{"Error: 'zip' command not found on system", "ErrorMsg"}}, true, {})
    return
  end

  -- Check if group_by is active
  local view_props = vim.t.linny_menu_view_props or {}
  if view_props.group_by then
    M.show_export_structure_popup()
  else
    M.show_export_path_input("flat")
  end
end

return M
