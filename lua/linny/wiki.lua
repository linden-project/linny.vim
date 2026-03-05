local M = {}

-- Module-local state for cursor position tracking
local last_pos_line = 0
local last_pos_col = 0

-- *********************************************************************
-- *                      Wikitag Functions
-- *********************************************************************

function M.wikitag_has_tag(word)
  local register = vim.g.linny_wikitags_register
  if not register then
    return ''
  end

  for tag_key, _ in pairs(register) do
    if word:match("^" .. vim.pesc(tag_key) .. " *") then
      return tag_key
    end
  end

  return ''
end

function M.execute_wikitag_action(word, tag_key)
  local inner = vim.trim(word:sub(#tag_key + 1))
  local action = "primaryAction"

  local register = vim.g.linny_wikitags_register
  if register and register[tag_key] and register[tag_key][action] then
    local func_name = register[tag_key][action]
    vim.fn[func_name](inner)
    vim.cmd('redraw!')
  end
end

-- *********************************************************************
-- *                      Utilities
-- *********************************************************************

function M.file_exists(path)
  return vim.fn.filereadable(vim.fn.expand(path)) == 1
end

function M.word_to_filename(word)
  if not word or word == '' then
    return ''
  end

  -- Strip leading and trailing spaces
  word = vim.trim(word)

  -- Get space replace character (default to underscore)
  local space_char = vim.g.spaceReplaceChar or '_'

  -- Substitute spaces by spaceReplaceChar
  word = word:gsub('%s', space_char)

  -- Substitute other illegal chars (/ and :)
  word = word:gsub('/', space_char)
  word = word:gsub(':', space_char)

  -- Lowercase and add extension
  return word:lower() .. '.md'
end

function M.file_path(filename)
  local cur_file_name = vim.fn.bufname('%')
  local dir = vim.fn.fnamemodify(cur_file_name, ':h')

  if dir and dir ~= '' then
    if dir == '.' then
      dir = ''
    else
      dir = dir .. '/'
    end
  else
    dir = ''
  end

  return dir .. filename
end

function M.str_between(start_str, end_str)
  local str = ''

  -- Get string between start_str and end_str
  local orig_pos = vim.fn.getpos('.')
  local end_pos = vim.fn.searchpos(end_str, 'W', vim.fn.line('.'))
  local start_pos = vim.fn.searchpos(start_str, 'bW', vim.fn.line('.'))
  vim.fn.cursor(orig_pos[2], orig_pos[3]) -- Return to original position

  if start_pos[2] < orig_pos[3] then
    local ll = vim.fn.getline(vim.fn.line('.'))
    -- Vim's strpart is 0-indexed: strpart(str, start, len)
    -- Lua's sub is 1-indexed and inclusive: sub(start, end)
    -- Original: strpart(ll, startPos[1] + strlen(startStr) - 1, endPos[1] - strlen(endStr) - startPos[1])
    -- In Lua: start = startPos[2] + #start_str (1-indexed, after delimiter)
    --         end = endPos[2] - 1 (1-indexed, before end delimiter)
    local start_idx = start_pos[2] + #start_str
    local end_idx = end_pos[2] - 1
    str = ll:sub(start_idx, end_idx)
  end

  return str
end

-- *********************************************************************
-- *                      YAML Functions
-- *********************************************************************

function M.yaml_key_under_cursor()
  local line_number = vim.fn.line('.')
  local current_line = vim.fn.getline(line_number)

  if current_line and current_line ~= '' then
    local key = current_line:match('%s*(.+):')
    return key or ''
  end

  return ''
end

function M.yaml_val_under_cursor()
  local line_number = vim.fn.line('.')
  local current_line = vim.fn.getline(line_number)

  if current_line and current_line ~= '' then
    local val = current_line:match('%s*:%s*(.+)')
    return val or ''
  end

  return ''
end

function M.cursor_in_frontmatter()
  local orig_pos = vim.fn.getpos('.')

  if vim.fn.getline(1) == '---' and vim.fn.line('.') > 1 then
    vim.fn.cursor(1, 1)

    local frontmatter_end = vim.fn.search('---', '', vim.fn.line('w$'))
    vim.fn.cursor(orig_pos[2], orig_pos[3]) -- Return to original position

    if frontmatter_end > 0 and frontmatter_end > vim.fn.line('.') then
      return true
    end
  end

  return false
end

function M.call_frontmatter_link()
  local yaml_key = M.yaml_key_under_cursor()
  local yaml_val = M.yaml_val_under_cursor()

  local relative_path = vim.fn['linny#l2_index_filepath'](yaml_key, yaml_val)

  if vim.fn.filereadable(relative_path) == 1 then
    vim.fn['linny_menu#openterm'](yaml_key, yaml_val)
  else
    vim.api.nvim_echo({{"Can't open, does not exist", 'WarningMsg'}}, true, {})
  end
end

-- *********************************************************************
-- *                      Words
-- *********************************************************************

function M.find_word_pos()
  local start_word = vim.g.startWord or '[['
  local end_word = vim.g.endWord or ']]'

  local orig_pos = vim.fn.getpos('.')
  local new_pos = {orig_pos[1], orig_pos[2], orig_pos[3], orig_pos[4]}

  local end_pos = vim.fn.searchpos(end_word, 'W', vim.fn.line('.'))
  local start_pos = vim.fn.searchpos(start_word, 'bW', vim.fn.line('.'))

  if start_pos[1] ~= 0 then
    local newcolpos = vim.fn.col('.') + 1
    if newcolpos == orig_pos[3] then
      newcolpos = newcolpos + 1
    end
    new_pos = {orig_pos[1], vim.fn.line('.'), newcolpos, orig_pos[4]}
  end

  vim.fn.cursor(orig_pos[2], orig_pos[3]) -- Return to original position
  return new_pos
end

function M.get_word()
  local start_word = vim.g.startWord or '[['
  local end_word = vim.g.endWord or ']]'

  local word = ''
  local word_pos = M.find_word_pos()
  local cur_pos = vim.fn.getpos('.')

  if word_pos[2] ~= cur_pos[2] or word_pos[3] ~= cur_pos[3] then
    vim.fn.cursor(word_pos[2], word_pos[3])
    word = M.str_between(start_word, end_word)
  end

  return word
end

-- *********************************************************************
-- *                      Links
-- *********************************************************************

function M.find_link_pos()
  local start_word = vim.g.startWord or '[['
  local end_word = vim.g.endWord or ']]'
  local start_link = vim.g.startLink or '('

  local orig_pos = vim.fn.getpos('.')
  local new_pos = {orig_pos[1], orig_pos[2], orig_pos[3], orig_pos[4]}

  local start_pos = vim.fn.searchpos(start_word, 'bW', vim.fn.line('.'))
  local end_pos = vim.fn.searchpos(end_word, 'W', vim.fn.line('.'))

  if start_pos[1] ~= 0 then
    local col = vim.fn.col('.')
    local nextchar = vim.fn.getline('.'):sub(col + 1, col + 1)
    if nextchar == start_link then
      local newcolpos = col + 2
      if newcolpos == orig_pos[3] then
        newcolpos = newcolpos + 1
      end
      new_pos = {orig_pos[1], vim.fn.line('.'), newcolpos, orig_pos[4]}
    end
  end

  vim.fn.cursor(orig_pos[2], orig_pos[3]) -- Return to original position
  return new_pos
end

function M.get_link()
  local start_link = vim.g.startLink or '('
  local end_link = vim.g.endLink or ')'

  local link = ''
  local link_pos = M.find_link_pos()
  local cur_pos = vim.fn.getpos('.')

  if link_pos[2] ~= cur_pos[2] or link_pos[3] ~= cur_pos[3] then
    vim.fn.cursor(link_pos[2], link_pos[3])
    link = M.str_between(start_link, end_link)
  end

  return link
end

-- *********************************************************************
-- *                      Navigation
-- *********************************************************************

function M.goto_link()
  if M.cursor_in_frontmatter() then
    M.call_frontmatter_link()
    return
  end

  last_pos_line = vim.fn.line('.')
  last_pos_col = vim.fn.col('.')

  local word = M.get_word()

  if word and word ~= '' then
    local tag = M.wikitag_has_tag(word)

    if tag ~= '' then
      M.execute_wikitag_action(word, tag)
    else
      local filename = M.get_link()

      if not filename or filename == '' then
        filename = M.word_to_filename(word)
        local filepath = M.file_path(filename)

        if not M.file_exists(filepath) then
          local file_lines = vim.fn['linny#generate_first_content'](word, {})
          if vim.fn.writefile(file_lines, filepath) ~= 0 then
            vim.api.nvim_echo({{'write error', 'ErrorMsg'}}, true, {})
          end
        end
      end

      local link = M.file_path(filename)
      vim.cmd('edit ' .. vim.fn.fnameescape(link))
    end
  end
end

function M.return_to_last()
  vim.cmd('buffer #')
  vim.fn.cursor(last_pos_line, last_pos_col)
end

-- *********************************************************************
-- *                      Highlighting
-- *********************************************************************

function M.find_non_existing_links()
  local pat = '%[%[.-%]%]'
  local filelines = vim.fn.getline(1, '$')

  for _, line in ipairs(filelines) do
    for match in line:gmatch(pat) do
      local word = match:sub(3, -3) -- Remove [[ and ]]

      if M.wikitag_has_tag(word) == '' then
        local filename = M.word_to_filename(word)
        if not M.file_exists(M.file_path(filename)) then
          -- Escape special regex chars for matchadd
          local escaped = vim.fn.escape(match, '[]')
          vim.fn.matchadd('Todo', escaped)
        end
      end
    end
  end
end

return M
