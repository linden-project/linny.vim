-- linny/menu/actions.lua - Action execution and job helpers for linny menu
-- Handles content menu actions and external command execution

local M = {}

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

return M
