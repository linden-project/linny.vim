" linny_menu_popup.vim - Cross-platform popup/floating window abstraction

" Create popup (vim) or floating window (nvim)
function! linny_menu_popup#create(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction

" Close popup with result
function! linny_menu_popup#close(id, result = 0) abort
    if has('popupwin')
        call popup_close(a:id, a:result)
    elseif has('nvim')
        call linny_menu_popup#setoptions(a:id, #{result: a:result})
        call nvim_win_close(a:id, v:true)
    endif
endfunction

" Get popup options
function! linny_menu_popup#getoptions(id) abort
    if has('popupwin')
        return popup_getoptions(a:id)
    elseif has('nvim')
        return getbufvar(winbufnr(a:id), 'popup_options', {})
    endif
endfunction

" Set popup options
function! linny_menu_popup#setoptions(id, options) abort
    if has('popupwin')
        return popup_setoptions(a:id, a:options)
    elseif has('nvim')
        call setbufvar(winbufnr(a:id), 'popup_options',
            \ extend(linny_menu_popup#getoptions(a:id), a:options))
    endif
endfunction

" ============================================================================
" Neovim-only helper functions (wrapped in has('nvim') guard)
" ============================================================================

if has('nvim')

function! s:num2bool(key, dict) abort
  if has_key(a:dict, a:key)
    if a:dict[a:key] == 0
      let a:dict[a:key] = v:false
    elseif a:dict[a:key] == 1
      let a:dict[a:key] = v:true
    endif
  endif
  return a:dict
endfunction

function! s:options(opts, useropts) abort

    let useropts = s:num2bool('wrap',a:useropts)
    let useropts = s:num2bool('cursorline',a:useropts)

    call extend(extend(a:opts, a:useropts), #{
        \ line: 0, col: 0, pos: 'topleft', posinvert: v:true, textprop: '',
        \ textpropwin: 0, textpropid: 0, fixed: v:false, flip: v:true, maxheight: 999,
        \ minheight: 0, maxwidth: 999, minwidth: 0, firstline: 0, hidden: v:false,
        \ tabpage: 0, title: '', wrap: v:true, drag: v:false, resize: v:false,
        \ close: 'none', highlight: '', padding: [0, 0, 0, 0], border: [0, 0, 0, 0],
        \ borderhighlight: [], borderchars: [], scrollbar: v:true,
        \ scrollbarhighlight: '', thumbhighlight: '', zindex: 50, mask: [], time: 0,
        \ moved: [0, 0, 0], mousemoved: [0, 0, 0], cursorline: v:false, filter: {},
        \ mapping: v:true, filtermode: 'a', callback: v:null, box: 0, result: 0
        \ }, 'keep')

    " set defaults suitable for Neovim
    if a:opts.pos is# 'center'
        let a:opts.line = 0
        let a:opts.col = 0
    endif
    let a:opts.highlight = empty(a:opts.highlight) ?
        \ 'EndOfBuffer:,CursorLine:PMenuSel' :
        \ printf('NormalFloat:%s,EndOfBuffer:,CursorLine:PMenuSel', a:opts.highlight)
    let a:opts.padding += [1, 1, 1, 1]
    let a:opts.border += [1, 1, 1, 1]
    if len(a:opts.borderchars) == 1
        let a:opts.borderchars = repeat(a:opts.borderchars, 8)
    elseif len(a:opts.borderchars) == 2
        let a:opts.borderchars = repeat(a:opts.borderchars[0:0], 4) +
            \ repeat(a:opts.borderchars[1:1], 4)
    elseif len(a:opts.borderchars) < 8
        let a:opts.borderchars += [nr2char(0x2550), nr2char(0x2551), nr2char(0x2550),
            \ nr2char(0x2551), nr2char(0x2554), nr2char(0x2557), nr2char(0x255D),
            \ nr2char(0x255A)][len(a:opts.borderchars) : ]
    endif
    if a:opts.filter is# 'popup_filter_menu'
        let a:opts.filter = {'<Space>': '.', '<CR>': '.', '<kEnter>': '.',
            \ '<2-LeftMouse>': '.', 'x': -1, '<Esc>': -1, '<C-C>': -1}
    elseif a:opts.filter is# 'popup_filter_yesno'
        let a:opts.filter = {'y': 1, 'Y': 1, 'n': 0, 'N': 0, 'x': 0, '<Esc>': 0,
            \ '<C-C>': -1}
    elseif type(a:opts.filter) != v:t_dict
        let a:opts.filter = {}
    endif
    if a:opts.filtermode is# 'a'
        let a:opts.filtermode = ''
    endif
    if a:opts.close is# 'button'
        let a:opts.borderchars[5] = 'X'
    elseif a:opts.close is# 'click'
        let a:opts.filter['<LeftMouse>'] = -2
    endif

    return a:opts
endfunction

function! s:to_list(what) abort
    if type(a:what) == v:t_number
        return getbufline(a:what, 1, '$')
    elseif type(a:what) == v:t_list
        return copy(a:what)
    else
        return [a:what]
    endif
endfunction

function! s:floatwin(lines, opts) abort
    " extra vertical and horizontal space for menu box
    let l:extraV = a:opts.border[0] + a:opts.padding[0] +
        \ a:opts.padding[2] + a:opts.border[2]
    let l:extraH = a:opts.border[3] + a:opts.padding[3] +
        \ a:opts.padding[1] + a:opts.border[1]

    " calc height and width
    let l:height = max([len(a:lines), a:opts.minheight, 1])
    let l:height = min([l:height, a:opts.maxheight, &lines - &cmdheight - l:extraV])
    let l:height += l:extraV
    let l:width = max(extend(map(a:lines[:], 'strwidth(v:val)'), [a:opts.minwidth,
        \ strwidth(a:opts.title) - a:opts.padding[3] - a:opts.padding[1]]))
    let l:width = min([l:width, a:opts.maxwidth, &columns - l:extraH])
    let l:width += l:extraH

    " floatwin config
    let l:config = {'anchor': get({'topright': 'NE', 'botleft': 'SW', 'botright': 'SE'},
        \ a:opts.pos, 'NW'), 'height': l:height, 'width': l:width, 'relative': 'editor',
        \ 'focusable': v:false, 'style': 'minimal'}
    let l:config.row = a:opts.line ? a:opts.line - 1 : s:centered(l:height,
        \ &lines - &cmdheight, l:config.anchor[0] is# 'S')
    let l:config.col = a:opts.col ? a:opts.col - 1 : s:centered(l:width, &columns,
        \ l:config.anchor[1] is# 'E')

    " show menu box
    let a:opts.box = s:get_buffer('popup_box', v:true)
    call s:set_lines(a:opts.box, s:draw_box(l:config.height, l:config.width, a:opts))
    call nvim_open_win(a:opts.box, v:false, l:config)
    call s:set_winopts(bufwinid(a:opts.box), {'winhighlight': a:opts.highlight})

    " shift menu items inside the box
    let l:config.focusable = v:true
    let [l:config.height, l:config.width] -= [l:extraV, l:extraH]
    let [l:config.row, l:config.col] += s:shift_inside(l:config.anchor, a:opts)

    " show menu items
    let l:items = s:get_buffer('popup_options', a:opts)
    call s:set_lines(l:items, a:lines)
    let l:id = nvim_open_win(l:items, v:true, l:config)
    mapclear <buffer>
    autocmd! BufLeave <buffer> call s:bufleave(str2nr(expand('<abuf>')))
    call s:set_winopts(l:id, {'cursorline': a:opts.cursorline, 'scrolloff': 0,
        \ 'sidescrolloff': 0, 'winhighlight': a:opts.highlight, 'wrap': a:opts.wrap})
    call s:set_keymaps(l:id, a:opts.filtermode, a:opts.filter)
    if a:opts.firstline
        call nvim_win_set_cursor(l:id, [a:opts.firstline, 0])
    endif
    if a:opts.time
        call timer_start(a:opts.time, {-> win_getid() == l:id && linny_menu_popup#close(l:id)})
    endif

    return l:id
endfunction

function! s:bufleave(buf) abort
    let l:opts = getbufvar(a:buf, 'popup_options')
    if !empty(l:opts.callback)
        " delay callback until another buffer entered
        let s:callback = function(l:opts.callback, [bufwinid(a:buf),
            \ type(l:opts.result) == v:t_string ? line(l:opts.result) : l:opts.result])
        autocmd BufEnter * ++once ++nested call call(remove(s:, 'callback'), [])
    endif
    execute bufwinnr(a:buf) 'hide'
    execute bufwinnr(l:opts.box) 'hide'
endfunction

function! s:centered(size, total, far) abort
    return (a:far ? a:total + a:size : a:total - a:size) / 2
endfunction

function! s:draw_box(height, width, opts) abort
    let l:border31 = a:opts.border[3] + a:opts.border[1]
    let l:contents = repeat([printf('%.*S%*S%.*S',
        \ a:opts.border[3], a:opts.borderchars[3], a:width - l:border31, '',
        \ a:opts.border[1], a:opts.borderchars[1])],
        \ a:height - a:opts.border[0] - a:opts.border[2])
    if a:opts.border[0]
        call insert(l:contents, printf('%.*S%S%S%.*S',
            \ a:opts.border[3], a:opts.borderchars[4], a:opts.title,
            \ repeat(a:opts.borderchars[0],
            \   a:width - l:border31 - strwidth(a:opts.title)),
            \ a:opts.border[1], a:opts.borderchars[5]))
    endif
    if a:opts.border[2]
        call add(l:contents, printf('%.*S%S%.*S',
            \ a:opts.border[3], a:opts.borderchars[7],
            \ repeat(a:opts.borderchars[2], a:width - l:border31),
            \ a:opts.border[1], a:opts.borderchars[6]))
    endif
    return l:contents
endfunction

" find hidden buffer by looking up variable
" create new if not found
function! s:get_buffer(varname, value) abort
    let l:match = filter(getbufinfo({'bufloaded': v:true}),
        \ {_, v -> empty(v.windows) && has_key(v.variables, a:varname) &&
        \ type(v.variables[a:varname]) == type(a:value)})
    let l:buf = empty(l:match) ? nvim_create_buf(v:false, v:true) : l:match[0].bufnr
    call nvim_buf_set_option(l:buf, 'undolevels', -1)
    call setbufvar(l:buf, a:varname, a:value)
    return l:buf
endfunction

function! s:set_keymaps(window, mode, keymaps) abort
    for [l:lhs, l:result] in items(a:keymaps)
        call nvim_buf_set_keymap(winbufnr(a:window), a:mode, l:lhs,
            \ printf('<Cmd>call linny_menu_popup#close(%d, %s)<CR>', a:window, string(l:result)),
            \ {'noremap': v:true, 'nowait': v:true})
    endfor
endfunction

function! s:set_lines(buf, lines) abort
    call nvim_buf_set_option(a:buf, 'modifiable', v:true)
    call nvim_buf_set_lines(a:buf, 0, -1, 1, a:lines)
    call nvim_buf_set_option(a:buf, 'modifiable', v:false)
endfunction

function! s:set_winopts(window, winopts) abort
    for [l:name, l:value] in items(a:winopts)
        call nvim_win_set_option(a:window, l:name, l:value)
    endfor
endfunction

function! s:shift_inside(anchor, opts) abort
    if a:anchor is# 'NE'
        return [a:opts.border[0] + a:opts.padding[0],
            \ -a:opts.border[1] - a:opts.padding[1]]
    elseif a:anchor is# 'SE'
        return [-a:opts.border[2] - a:opts.padding[2],
            \ -a:opts.border[1] - a:opts.padding[1]]
    elseif a:anchor is# 'SW'
        return [-a:opts.border[2] - a:opts.padding[2],
            \ a:opts.border[3] + a:opts.padding[3]]
    else "NW
        return [a:opts.border[0] + a:opts.padding[0],
            \ a:opts.border[3] + a:opts.padding[3]]
    endif
endfunction

endif " has('nvim')
