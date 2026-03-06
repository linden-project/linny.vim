-- linny/menu/popup.lua - Cross-platform popup/floating window abstraction
local M = {}

-- Store callback for deferred execution (Neovim)
local pending_callback = nil

-- ============================================================================
-- Neovim-only helper functions
-- ============================================================================

-- Convert 0/1 to boolean for specified key
local function num2bool(key, dict)
  if dict[key] ~= nil then
    if dict[key] == 0 then
      dict[key] = false
    elseif dict[key] == 1 then
      dict[key] = true
    end
  end
  return dict
end

-- Convert popup options to Neovim format
local function convert_options(opts, useropts)
  useropts = num2bool('wrap', useropts)
  useropts = num2bool('cursorline', useropts)

  -- Merge useropts into opts
  for k, v in pairs(useropts) do
    opts[k] = v
  end

  -- Set defaults (only if not already set)
  local defaults = {
    line = 0, col = 0, pos = 'topleft', posinvert = true, textprop = '',
    textpropwin = 0, textpropid = 0, fixed = false, flip = true, maxheight = 999,
    minheight = 0, maxwidth = 999, minwidth = 0, firstline = 0, hidden = false,
    tabpage = 0, title = '', wrap = true, drag = false, resize = false,
    close = 'none', highlight = '', padding = {0, 0, 0, 0}, border = {0, 0, 0, 0},
    borderhighlight = {}, borderchars = {}, scrollbar = true,
    scrollbarhighlight = '', thumbhighlight = '', zindex = 50, mask = {}, time = 0,
    moved = {0, 0, 0}, mousemoved = {0, 0, 0}, cursorline = false, filter = {},
    mapping = true, filtermode = 'a', callback = nil, box = 0, result = 0
  }

  for k, v in pairs(defaults) do
    if opts[k] == nil then
      opts[k] = v
    end
  end

  -- Ensure padding and border have 4 elements (empty arrays from VimScript become empty tables)
  opts.padding = opts.padding or {}
  opts.border = opts.border or {}
  for i = 1, 4 do
    opts.padding[i] = opts.padding[i] or 0
    opts.border[i] = opts.border[i] or 0
  end

  -- Set defaults suitable for Neovim
  if opts.pos == 'center' then
    opts.line = 0
    opts.col = 0
  end

  if opts.highlight == '' then
    opts.highlight = 'EndOfBuffer:,CursorLine:PMenuSel'
  else
    opts.highlight = string.format('NormalFloat:%s,EndOfBuffer:,CursorLine:PMenuSel', opts.highlight)
  end

  -- Note: The original VimScript does `padding += [1,1,1,1]` which CONCATENATES (not adds).
  -- The concatenated values at indices 4-7 are never used, so we don't need to replicate that.

  -- Normalize borderchars
  local default_borderchars = {
    vim.fn.nr2char(0x2550), vim.fn.nr2char(0x2551), vim.fn.nr2char(0x2550),
    vim.fn.nr2char(0x2551), vim.fn.nr2char(0x2554), vim.fn.nr2char(0x2557),
    vim.fn.nr2char(0x255D), vim.fn.nr2char(0x255A)
  }

  if #opts.borderchars == 1 then
    local char = opts.borderchars[1]
    opts.borderchars = {char, char, char, char, char, char, char, char}
  elseif #opts.borderchars == 2 then
    local c1, c2 = opts.borderchars[1], opts.borderchars[2]
    opts.borderchars = {c1, c1, c1, c1, c2, c2, c2, c2}
  elseif #opts.borderchars < 8 then
    for i = #opts.borderchars + 1, 8 do
      opts.borderchars[i] = default_borderchars[i]
    end
  end

  -- Convert filter string to keymap dict
  if opts.filter == 'popup_filter_menu' then
    opts.filter = {
      ['<Space>'] = '.', ['<CR>'] = '.', ['<kEnter>'] = '.',
      ['<2-LeftMouse>'] = '.', ['x'] = -1, ['<Esc>'] = -1, ['<C-C>'] = -1
    }
  elseif opts.filter == 'popup_filter_yesno' then
    opts.filter = {
      ['y'] = 1, ['Y'] = 1, ['n'] = 0, ['N'] = 0,
      ['x'] = 0, ['<Esc>'] = 0, ['<C-C>'] = -1
    }
  elseif type(opts.filter) ~= 'table' then
    opts.filter = {}
  end

  if opts.filtermode == 'a' then
    opts.filtermode = ''
  end

  if opts.close == 'button' then
    opts.borderchars[6] = 'X'
  elseif opts.close == 'click' then
    opts.filter['<LeftMouse>'] = -2
  end

  return opts
end

-- Normalize input content to list
local function to_list(what)
  if type(what) == 'number' then
    return vim.fn.getbufline(what, 1, '$')
  elseif type(what) == 'table' then
    return vim.deepcopy(what)
  else
    return {what}
  end
end

-- Calculate centered position
local function centered(size, total, far)
  if far then
    return math.floor((total + size) / 2)
  else
    return math.floor((total - size) / 2)
  end
end

-- Calculate shift for content inside box
local function shift_inside(anchor, opts)
  if anchor == 'NE' then
    return {opts.border[1] + opts.padding[1], -opts.border[2] - opts.padding[2]}
  elseif anchor == 'SE' then
    return {-opts.border[3] - opts.padding[3], -opts.border[2] - opts.padding[2]}
  elseif anchor == 'SW' then
    return {-opts.border[3] - opts.padding[3], opts.border[4] + opts.padding[4]}
  else -- NW
    return {opts.border[1] + opts.padding[1], opts.border[4] + opts.padding[4]}
  end
end

-- Find or create buffer by variable name
local function get_buffer(varname, value)
  local bufinfos = vim.fn.getbufinfo({bufloaded = true})
  for _, info in ipairs(bufinfos) do
    if #info.windows == 0 and info.variables[varname] ~= nil
       and type(info.variables[varname]) == type(value) then
      vim.api.nvim_buf_set_option(info.bufnr, 'undolevels', -1)
      vim.fn.setbufvar(info.bufnr, varname, value)
      return info.bufnr
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'undolevels', -1)
  vim.fn.setbufvar(buf, varname, value)
  return buf
end

-- Set buffer lines
local function set_lines(buf, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Set window options
local function set_winopts(window, winopts)
  for name, value in pairs(winopts) do
    vim.api.nvim_win_set_option(window, name, value)
  end
end

-- Set keymaps for popup
local function set_keymaps(window, mode, keymaps)
  local buf = vim.fn.winbufnr(window)
  for lhs, result in pairs(keymaps) do
    local cmd = string.format("<Cmd>lua require('linny.menu.popup').close(%d, %s)<CR>",
                              window, vim.inspect(result))
    vim.api.nvim_buf_set_keymap(buf, mode, lhs, cmd, {noremap = true, nowait = true})
  end
end

-- Draw box border
local function draw_box(height, width, opts)
  local border31 = opts.border[4] + opts.border[2]
  local contents = {}

  -- Middle rows (sides only)
  local middle_line = string.format('%s%s%s',
    string.rep(opts.borderchars[4], opts.border[4]),
    string.rep(' ', width - border31),
    string.rep(opts.borderchars[2], opts.border[2]))

  for _ = 1, height - opts.border[1] - opts.border[3] do
    table.insert(contents, middle_line)
  end

  -- Top border with title
  if opts.border[1] > 0 then
    local title_width = vim.fn.strwidth(opts.title)
    local top_line = string.format('%s%s%s%s',
      string.rep(opts.borderchars[5], opts.border[4]),
      opts.title,
      string.rep(opts.borderchars[1], width - border31 - title_width),
      string.rep(opts.borderchars[6], opts.border[2]))
    table.insert(contents, 1, top_line)
  end

  -- Bottom border
  if opts.border[3] > 0 then
    local bottom_line = string.format('%s%s%s',
      string.rep(opts.borderchars[8], opts.border[4]),
      string.rep(opts.borderchars[3], width - border31),
      string.rep(opts.borderchars[7], opts.border[2]))
    table.insert(contents, bottom_line)
  end

  return contents
end

-- Handle BufLeave for popup
local function bufleave(buf)
  local opts = vim.fn.getbufvar(buf, 'popup_options')
  if opts and opts.callback and opts.callback ~= vim.NIL then
    local winid = vim.fn.bufwinid(buf)
    local result = opts.result
    if type(result) == 'string' then
      result = vim.fn.line(result)
    end
    pending_callback = function()
      vim.fn[opts.callback](winid, result)
    end
    vim.api.nvim_create_autocmd('BufEnter', {
      once = true,
      nested = true,
      callback = function()
        if pending_callback then
          pending_callback()
          pending_callback = nil
        end
      end
    })
  end

  local box = opts and opts.box
  vim.cmd(vim.fn.bufwinnr(buf) .. ' hide')
  if box and box ~= 0 then
    local box_winnr = vim.fn.bufwinnr(box)
    if box_winnr > 0 then
      vim.cmd(box_winnr .. ' hide')
    end
  end
end

-- Create floating window (Neovim)
local function floatwin(lines, opts)
  -- Extra vertical and horizontal space for menu box
  local extraV = opts.border[1] + opts.padding[1] + opts.padding[3] + opts.border[3]
  local extraH = opts.border[4] + opts.padding[4] + opts.padding[2] + opts.border[2]

  -- Calculate height and width
  local height = math.max(#lines, opts.minheight, 1)
  height = math.min(height, opts.maxheight, vim.o.lines - vim.o.cmdheight - extraV)
  height = height + extraV

  local max_line_width = 0
  for _, line in ipairs(lines) do
    max_line_width = math.max(max_line_width, vim.fn.strwidth(line))
  end
  local title_width = vim.fn.strwidth(opts.title) - opts.padding[4] - opts.padding[2]
  local width = math.max(max_line_width, opts.minwidth, title_width)
  width = math.min(width, opts.maxwidth, vim.o.columns - extraH)
  width = width + extraH

  -- Floating window config
  local anchor_map = {topright = 'NE', botleft = 'SW', botright = 'SE'}
  local anchor = anchor_map[opts.pos] or 'NW'

  local config = {
    anchor = anchor,
    height = height,
    width = width,
    relative = 'editor',
    focusable = false,
    style = 'minimal'
  }

  if opts.line ~= 0 then
    config.row = opts.line - 1
  else
    config.row = centered(height, vim.o.lines - vim.o.cmdheight, anchor:sub(1, 1) == 'S')
  end

  if opts.col ~= 0 then
    config.col = opts.col - 1
  else
    config.col = centered(width, vim.o.columns, anchor:sub(2, 2) == 'E')
  end

  -- Show menu box
  opts.box = get_buffer('popup_box', true)
  set_lines(opts.box, draw_box(config.height, config.width, opts))
  vim.api.nvim_open_win(opts.box, false, config)
  set_winopts(vim.fn.bufwinid(opts.box), {winhighlight = opts.highlight})

  -- Shift menu items inside the box
  config.focusable = true
  config.height = config.height - extraV
  config.width = config.width - extraH
  local shift = shift_inside(config.anchor, opts)
  config.row = config.row + shift[1]
  config.col = config.col + shift[2]

  -- Show menu items
  local items_buf = get_buffer('popup_options', opts)
  set_lines(items_buf, lines)
  local id = vim.api.nvim_open_win(items_buf, true, config)

  -- Clear buffer keymaps
  vim.cmd('mapclear <buffer>')

  -- Set up BufLeave autocmd
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = items_buf,
    once = true,
    callback = function()
      bufleave(items_buf)
    end
  })

  set_winopts(id, {
    cursorline = opts.cursorline,
    scrolloff = 0,
    sidescrolloff = 0,
    winhighlight = opts.highlight,
    wrap = opts.wrap
  })
  set_keymaps(id, opts.filtermode, opts.filter)

  if opts.firstline and opts.firstline > 0 then
    vim.api.nvim_win_set_cursor(id, {opts.firstline, 0})
  end

  if opts.time and opts.time > 0 then
    vim.defer_fn(function()
      if vim.fn.win_getid() == id then
        M.close(id)
      end
    end, opts.time)
  end

  return id
end

-- ============================================================================
-- Public API
-- ============================================================================

-- Create popup (vim) or floating window (nvim)
function M.create(what, options)
  if vim.fn.has('popupwin') == 1 then
    return vim.fn.popup_create(what, options)
  elseif vim.fn.has('nvim') == 1 then
    return floatwin(to_list(what), convert_options({}, options))
  end
end

-- Close popup with result
function M.close(id, result)
  result = result or 0
  if vim.fn.has('popupwin') == 1 then
    vim.fn.popup_close(id, result)
  elseif vim.fn.has('nvim') == 1 then
    M.setoptions(id, {result = result})
    vim.api.nvim_win_close(id, true)
  end
end

-- Get popup options
function M.getoptions(id)
  if vim.fn.has('popupwin') == 1 then
    return vim.fn.popup_getoptions(id)
  elseif vim.fn.has('nvim') == 1 then
    return vim.fn.getbufvar(vim.fn.winbufnr(id), 'popup_options', {})
  end
end

-- Set popup options
function M.setoptions(id, options)
  if vim.fn.has('popupwin') == 1 then
    return vim.fn.popup_setoptions(id, options)
  elseif vim.fn.has('nvim') == 1 then
    local current = M.getoptions(id)
    for k, v in pairs(options) do
      current[k] = v
    end
    vim.fn.setbufvar(vim.fn.winbufnr(id), 'popup_options', current)
  end
end

return M
