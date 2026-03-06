-- linny/menu/util.lua - Utility functions for linny menu
-- No dependencies on other linny_menu_* modules

local M = {}

--- Pad string to specified length
--- @param s string The string to pad
--- @param amt number The target length
--- @param char string|nil The padding character (default: space)
--- @return string The padded string
function M.prepad(s, amt, char)
  char = char or ' '
  local padding_needed = amt - #tostring(s)
  if padding_needed <= 0 then
    return tostring(s)
  end
  return string.rep(char, padding_needed) .. tostring(s)
end

--- Eval & expand: '%{script}' in string
--- @param str string The string containing %{script} expressions
--- @return string The expanded string
function M.expand_text(str)
  if not str or str == '' then
    return ''
  end

  local partial = {}
  local index = 1  -- Lua strings are 1-indexed

  while true do
    local pos = str:find('%%{', index, true)
    if not pos then
      table.insert(partial, str:sub(index))
      break
    end

    if pos > index then
      table.insert(partial, str:sub(index, pos - 1))
    end

    local endup = str:find('}', pos + 2, true)
    if not endup then
      table.insert(partial, str:sub(index))
      break
    end

    index = endup + 1

    if endup > pos + 2 then
      local script = str:sub(pos + 2, endup - 1)
      script = script:match('^%s*(.-)%s*$')  -- trim whitespace
      local ok, result = pcall(vim.fn.eval, script)
      if ok then
        table.insert(partial, tostring(result))
      end
    end
  end

  return table.concat(partial, '')
end

--- String limit - truncate string to fit within display width limit
--- @param text string The text to truncate
--- @param limit number The maximum display width
--- @param col number The column offset for display width calculation
--- @return string The truncated string
function M.slimit(text, limit, col)
  if limit <= 1 then
    return ''
  end

  local size = vim.fn.strdisplaywidth(text, col)
  if size < limit then
    return text
  end

  local chars = vim.fn.strchars(text)
  if chars == size then
    return vim.fn.strpart(text, 0, limit - 1)
  end

  local result = vim.fn.strcharpart(text, 0, limit)
  local result_chars = vim.fn.strchars(result)

  while true do
    if vim.fn.strdisplaywidth(result, col) < limit then
      return result
    end

    local step = math.floor(result_chars / 8)
    local test = result_chars - step

    if step > 3 and test > 16 then
      local demo = vim.fn.strcharpart(result, 0, test)
      if vim.fn.strdisplaywidth(demo, col) > limit then
        result = demo
        result_chars = test
        goto continue
      end
    end

    result_chars = result_chars - 1
    result = vim.fn.strcharpart(result, 0, result_chars)
    ::continue::
  end
end

--- Show command message with optional highlight
--- @param content string The message content
--- @param highlight string The highlight group name
function M.cmdmsg(content, highlight)
  local wincols = vim.o.columns
  local laststatus = vim.o.laststatus
  local winnr = vim.fn.winnr('$')
  local statusline = (laststatus == 1 and winnr > 1) or (laststatus == 2)
  local ruler = vim.o.ruler
  local reqspaces_lastline = (statusline or not ruler) and 12 or 29
  local width = vim.fn.strdisplaywidth(content)
  local limit = wincols - reqspaces_lastline

  local msg = content
  if width >= limit then
    msg = M.slimit(msg, limit, 0)
  end

  vim.cmd('redraw')
  if highlight and highlight ~= '' then
    vim.cmd('echohl ' .. highlight)
    vim.cmd('echo ' .. vim.fn.string(msg))
    vim.cmd('echohl NONE')
  else
    vim.cmd('echo ' .. vim.fn.string(msg))
  end
end

--- Echo error message
--- @param msg string The error message
function M.errmsg(msg)
  vim.cmd('echohl ErrorMsg')
  vim.cmd('echo ' .. vim.fn.string(msg))
  vim.cmd('echohl None')
end

--- Set highlight group
--- @param standard string The standard highlight group
--- @param startify string The preferred highlight group (if it exists)
function M.highlight(standard, startify)
  local hl = vim.fn.hlexists(startify) == 1 and startify or standard
  vim.cmd('echohl ' .. hl)
end

--- Capitalize first character of string
--- @param capstring string The string to capitalize
--- @return string The capitalized string
function M.string_capitalize(capstring)
  if not capstring or capstring == '' then
    return ''
  end
  return capstring:sub(1, 1):upper() .. capstring:sub(2)
end

--- Create a string of specified length with specified character
--- @param char string The character to repeat
--- @param length number The length of the resulting string
--- @return string The repeated character string
function M.string_of_length_with_char(char, length)
  -- Note: Original Vimscript uses >= which creates length+1 chars
  -- Keeping the same behavior for compatibility
  if length < 0 then
    return ''
  end
  return string.rep(char, length + 1)
end

--- Calculate active view arrow position for menu header
--- @param views_list table List of view names
--- @param active_view number Index of the active view (0-indexed)
--- @param padding_left number Left padding amount
--- @return string The arrow position string
function M.calc_active_view_arrow(views_list, active_view, padding_left)
  local arrow_string = M.string_of_length_with_char(' ', padding_left)
  local stopb = false

  for idx, view in ipairs(views_list) do
    local view_idx = idx - 1  -- Convert to 0-indexed to match active_view
    if view_idx == active_view then
      local pad_size = math.floor(#view / 2)
      local filstr = M.string_of_length_with_char(' ', pad_size)
      arrow_string = arrow_string .. filstr .. '▲'
      stopb = true
    else
      if not stopb then
        arrow_string = arrow_string .. M.string_of_length_with_char(' ', #view + 1)
      end
    end
  end

  return arrow_string
end

return M
