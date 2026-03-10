-- linny/menu/window.lua - Window/buffer management for linny menu
-- Handles menu window creation, rendering, and file opening

local M = {}

--- Check if menu window exists
--- @return boolean
function M.exist()
  if vim.t.linny_menu_bid == nil then
    vim.t.linny_menu_bid = -1
    return false
  end

  return vim.t.linny_menu_bid > 0 and vim.fn.bufexists(vim.t.linny_menu_bid) == 1
end

--- Close menu window
function M.close_window()
  if vim.t.linny_menu_bid == nil then
    return 0
  end

  -- If last window, first create new one
  if vim.fn.winbufnr(2) == -1 then
    vim.cmd('below vnew')
  end

  if vim.bo.buftype == 'nofile' and vim.bo.filetype == 'linny_menu' then
    if vim.fn.bufname('%') == vim.t.linny_menu_name then
      vim.cmd('silent close!')
      vim.t.linny_menu_bid = -1
    end
  end

  if vim.t.linny_menu_bid > 0 and vim.fn.bufexists(vim.t.linny_menu_bid) == 1 then
    vim.cmd('silent bwipeout ' .. vim.t.linny_menu_bid)
    vim.t.linny_menu_bid = -1
  end

  vim.cmd('redraw | echo "" | redraw')
end

--- Open menu window with specified size
--- @param size number Window width
--- @return number 1 on success, 0 on failure
function M.open_window(size)
  if M.exist() then
    M.close_window()
  end

  -- Clamp size
  if size < 4 then
    size = 4
  end
  if size > vim.g.linny_menu_max_width then
    size = vim.g.linny_menu_max_width
  end
  if size > vim.fn.winwidth(0) then
    size = vim.fn.winwidth(0) - 1
    if size < 4 then
      size = 4
    end
  end

  local savebid = vim.fn.bufnr('%')
  local menu_name = vim.t.linny_menu_name or '[linny_menu]'

  if string.find(vim.g.linny_menu_options or '', 'T') == nil then
    vim.cmd('silent! rightbelow ' .. size .. 'vne ' .. menu_name)
  else
    vim.cmd('silent! leftabove ' .. size .. 'vne ' .. menu_name)
  end

  if savebid == vim.fn.bufnr('%') then
    return 0
  end

  vim.cmd('setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable')
  vim.cmd('setlocal noshowcmd noswapfile nowrap nonumber')
  vim.cmd('setlocal nolist colorcolumn= nocursorline nocursorcolumn')
  vim.cmd('setlocal noswapfile norelativenumber')

  if vim.fn.has('signs') == 1 and vim.fn.has('patch-7.4.2210') == 1 then
    vim.cmd('setlocal signcolumn=no')
  end

  if vim.fn.has('spell') == 1 then
    vim.cmd('setlocal nospell')
  end

  if vim.fn.has('folding') == 1 then
    vim.cmd('setlocal fdc=0')
  end

  vim.t.linny_menu_bid = vim.fn.bufnr('%')
  return 1
end

--- Render items to window
--- @param items table Array of menu items
function M.render(items)
  vim.cmd('setlocal modifiable')
  local ln = 2

  -- Build menu table locally (vim.t tables are copies, not references)
  local menu = {
    padding_size = vim.g.linny_menu_padding_left,
    option_lines = {},
    section_lines = {},
    text_lines = {},
    header_lines = {},
    footer_lines = {},
  }

  for _, item in ipairs(items) do
    item.ln = ln
    vim.fn.append('$', item.text)
    if item.mode == 0 then
      table.insert(menu.option_lines, ln)
    elseif item.mode == 1 then
      table.insert(menu.text_lines, ln)
    elseif item.mode == 2 then
      table.insert(menu.section_lines, ln)
    elseif item.mode == 3 then
      table.insert(menu.header_lines, ln)
    elseif item.mode == 4 then
      table.insert(menu.footer_lines, ln)
    end
    ln = ln + 1
  end

  vim.cmd('setlocal nomodifiable readonly')

  -- Store items and assign to tab variable BEFORE setting filetype
  -- (syntax/linny_menu.vim reads t:linny_menu when ft is set)
  menu.items = items
  vim.t.linny_menu = menu

  vim.cmd('setlocal ft=linny_menu')

  local opt = vim.g.linny_menu_options or ''
  if string.find(opt, 'L') then
    vim.cmd('setlocal cursorline')
  end
end

--- Start menu
function M.start()
  require('linny.menu.state').tab_init()
  vim.fn['linny_menu#openterm']('', '')
end

--- Open menu if closed
function M.open()
  if not M.exist() then
    require('linny.menu.state').tab_init()
    vim.fn['linny_menu#openandshow']()
  end
end

--- Close menu if open
function M.close()
  if M.exist() then
    M.close_window()
    return 0
  end
end

--- Toggle menu visibility
--- @return number 0 if closed, 1 if opened
function M.toggle()
  if M.exist() then
    M.close_window()
    return 0
  end

  -- Select and arrange menu
  local items = vim.fn.Select_items()
  local content = {}
  local maxsize = 8

  -- Calculate max width
  for _, item in ipairs(items) do
    local hr = vim.fn.Menu_expand(item)
    for _, outline in ipairs(hr) do
      local text = outline.text or ''
      local width = vim.fn.strdisplaywidth(text)
      if width > maxsize then
        maxsize = width
      end
    end
    for _, h in ipairs(hr) do
      table.insert(content, h)
    end
  end

  maxsize = maxsize + vim.g.linny_menu_padding_right

  M.open_window(maxsize)
  M.render(content)
  vim.fn.Setup_keymaps(content)

  return 1
end

--- Refresh menu with Hugo index rebuild (skipped if watch mode is active)
function M.refresh()
  local hugo = require('linny.hugo')

  -- Only rebuild manually if not in watch mode (watch handles rebuilds automatically)
  if not hugo.is_watching() then
    local detection = hugo.detect()
    if detection.found then
      local notebook_path = vim.g.linny_open_notebook_path
      if notebook_path and notebook_path ~= '' then
        vim.api.nvim_echo({{'Rebuilding index...', 'Normal'}}, false, {})
        vim.cmd('redraw')
        local result = hugo.build_index(notebook_path)
        if not result.ok then
          vim.api.nvim_echo({{'Index rebuild warning: ' .. (result.error or 'unknown error'), 'WarningMsg'}}, true, {})
        end
      end
    end
  end

  -- Always refresh the menu view
  vim.fn['linny#Init']()
  vim.fn['linny#make_index']()
  vim.fn['linny_menu#openandshow']()
end

--- Try to auto-start Hugo watch mode on first menu open (if enabled)
--- Called by any menu open function
local function try_hugo_watch_autostart()
  local hugo = require('linny.hugo')
  if not hugo.watch_auto_started() then
    hugo.mark_watch_auto_started()
    local watch_enabled = vim.g.linny_hugo_watch_enabled or 0
    if watch_enabled == 1 then
      local notebook_path = vim.g.linny_open_notebook_path
      if notebook_path and notebook_path ~= '' then
        local detection = hugo.detect()
        if detection.found then
          local result = hugo.start_watch(notebook_path)
          if result.ok then
            vim.api.nvim_echo({{'Hugo watch mode started', 'Normal'}}, false, {})
          end
        end
      end
    end
  end
end

--- Open menu at root view (resets state)
--- Used by LinnyStart
function M.open_home()
  require('linny.menu.state').tab_init()
  try_hugo_watch_autostart()
  vim.fn['linny_menu#openterm']('', '')
end

--- Open menu restoring last state (or root if no state)
--- Used by LinnyMenuOpen
function M.open_restore()
  -- Initialize tab state only if not already initialized
  if vim.t.linny_menu_name == nil then
    require('linny.menu.state').tab_init()
  end

  try_hugo_watch_autostart()

  -- Use current state variables (may be empty = root view)
  vim.fn['linny_menu#openandshow']()
end

--- Navigate to home view (requires menu to be open)
function M.navigate_home()
  if vim.t.linny_menu_name == nil then
    vim.api.nvim_echo({{'ERROR No Linny Menu opened. Are you in Linny?', 'ErrorMsg'}}, true, {})
    return
  end
  vim.fn['linny_menu#openterm']('', '')
end

--- Open file in menu preserving layout
--- @param filepath string Path to file
function M.open_file(filepath)
  if vim.bo.buftype == 'nofile' and vim.bo.filetype == 'linny_menu' then
    local currentwidth = vim.t.linny_menu_lastmaxsize
    local currentWindow = vim.fn.winnr()

    vim.cmd('only')
    vim.cmd('botright vs ' .. filepath)

    local newWindow = vim.fn.winnr()

    vim.cmd(currentWindow .. 'wincmd w')
    vim.fn['linny_menu#openandshow']()

    vim.cmd('setlocal foldcolumn=0')

    vim.cmd('vertical resize ' .. currentwidth)
    vim.cmd(newWindow .. 'wincmd w')
  else
    vim.cmd('e ' .. filepath)
  end
end

return M
