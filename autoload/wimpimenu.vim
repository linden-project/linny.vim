"======================================================================
"
" wimpimenu.vim -
"
" Created by skywind on 2017/07/08
" Last change: 2017/08/08 15:20:20
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" Global Options
"----------------------------------------------------------------------
if !exists('g:wimpimenu_max_width')
  let g:wimpimenu_max_width = 40
endif

if !exists('g:wimpimenu_disable_nofile')
  let g:wimpimenu_disable_nofile = 1
endif

if !exists('g:wimpimenu_ft_blacklist')
  let g:wimpimenu_ft_blacklist = ['netrw', 'nerdtree', 'startify']
endif

if !exists('g:wimpimenu_padding_left')
  let g:wimpimenu_padding_left = 3
endif

if !exists('g:wimpimenu_padding_right')
  let g:wimpimenu_padding_right = 3
endif

if !exists('g:wimpimenu_options')
  let g:wimpimenu_options = 'T'
endif


"----------------------------------------------------------------------
" Internal State
"----------------------------------------------------------------------
let s:wimpimenu_items = {}
let s:wimpimenu_mid = 0
let s:wimpimenu_header = {}
let s:wimpimenu_cursor = {}
let s:wimpimenu_version = 'wimpimenu 1.3.4'
let s:wimpimenu_name = '[wimpimenu]'
let s:wimpimenu_line = 0


"----------------------------------------------------------------------
" popup window management
"----------------------------------------------------------------------
function! s:window_exist()
  if !exists('s:wimpimenu_bid')
    let s:wimpimenu_bid = -1
    return 0
  endif
  return s:wimpimenu_bid > 0 && bufexists(s:wimpimenu_bid)
endfunc

function! s:window_close()
  if !exists('s:wimpimenu_bid')
    return 0
  endif
  if &buftype == 'nofile' && &ft == 'wimpimenu'
    if bufname('%') == s:wimpimenu_name
      silent close!
      let s:wimpimenu_bid = -1
    endif
  endif
  if s:wimpimenu_bid > 0 && bufexists(s:wimpimenu_bid)
    silent exec 'bwipeout ' . s:wimpimenu_bid
    let s:wimpimenu_bid = -1
  endif
  redraw | echo "" | redraw
endfunc

function! s:window_open(size)
  if s:window_exist()
    call s:window_close()
  endif
  let size = a:size
  let size = (size < 4)? 4 : size
  let size = (size > g:wimpimenu_max_width)? g:wimpimenu_max_width : size
  if size > winwidth(0)
    let size = winwidth(0) - 1
    if size < 4
      let size = 4
    endif
  endif
  let savebid = bufnr('%')
  if stridx(g:wimpimenu_options, 'T') < 0
    exec "silent! rightbelow ".size.'vne '.s:wimpimenu_name
  else
    exec "silent! leftabove ".size.'vne '.s:wimpimenu_name
  endif
  if savebid == bufnr('%')
    return 0
  endif
  setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable
  setlocal noshowcmd noswapfile nowrap nonumber
  setlocal nolist colorcolumn= nocursorline nocursorcolumn
  setlocal noswapfile norelativenumber
  if has('signs') && has('patch-7.4.2210')
    setlocal signcolumn=no
  endif
  if has('spell')
    setlocal nospell
  endif
  if has('folding')
    setlocal fdc=0
  endif
  let s:wimpimenu_bid = bufnr('%')
  return 1
endfunc


"----------------------------------------------------------------------
" menu operation
"----------------------------------------------------------------------

function! wimpimenu#reset()
  let s:wimpimenu_items[s:wimpimenu_mid] = []
  let s:wimpimenu_line = 0
  let s:wimpimenu_cursor[s:wimpimenu_mid] = 0
endfunc

function! wimpimenu#append(text, event, ...)
  let help = (a:0 >= 1)? a:1 : ''
  let filetype = (a:0 >= 2)? a:2 : ''
  let weight = (a:0 >= 3)? a:3 : 0
  let item = {}
  let item.mode = 0
  let item.event = a:event
  let item.text = a:text
  let item.key = ''
  let item.ft = []
  let item.weight = weight
  let item.help = help
  if a:event != ''
    let item.mode = 0
  elseif a:text[0] != '#'
    let item.mode = 1
  else
    let item.mode = 2
    let item.text = matchstr(a:text, '^#\+\s*\zs.*')
  endif
  for ft in split(filetype, ',')
    let item.ft += [substitute(ft, '^\s*\(.\{-}\)\s*$', '\1', '')]
  endfor
  let index = -1
  if !has_key(s:wimpimenu_items, s:wimpimenu_mid)
    let s:wimpimenu_items[s:wimpimenu_mid] = []
  endif
  let items = s:wimpimenu_items[s:wimpimenu_mid]
  let total = len(items)
  for i in range(0, total - 1)
    if weight < items[i].weight
      let index = i
      break
    endif
  endfor
  if index < 0
    let index = total
  endif
  call insert(items, item, index)
  return index
endfunc


function! wimpimenu#current(mid)
  let s:wimpimenu_mid = a:mid
endfunc


function! wimpimenu#header(header)
  let s:wimpimenu_header[s:wimpimenu_mid] = a:header
endfunc


function! wimpimenu#list()
  for item in s:wimpimenu_items[s:wimpimenu_mid]
    echo item
  endfor
endfunc


"----------------------------------------------------------------------
" wimpimenu interface
"----------------------------------------------------------------------

function! wimpimenu#openterm(mid, term,value) abort
  if g:wimpimenu_disable_nofile
    if &buftype == 'nofile' || &buftype == 'quickfix'
      return 0
    endif

    if &modifiable == 0
      if index(g:wimpimenu_ft_blacklist, &ft) >= 0
        return 0
      endif
    endif
  endif

  call wimpimenu#reset()
  call wimpimenu#append("# " . a:term . ' : ' . a:value, '')

  let s:relativePath = fnameescape($HOME . '/Dropbox/Apps/KiwiApp/index/index_'.a:term.'_'.a:value.'.json' )
  if filereadable(s:relativePath)
    let s:lines = readfile(s:relativePath)
    let s:json = join(s:lines)
    let s:dict = json_decode(s:json)
    for k in s:dict
      "  echom k
      let s:index_filename = wimpi#MdwiWordFilename("index " . k)
      call wimpimenu#append("" . k, ":botright vs ". $HOME ."/Dropbox/Apps/KiwiApp/wiki/".k, "...")
    endfor
  endif

  " select and arrange menu
  let items = s:select_by_ft(a:mid, &ft)
  "let items = s:select_by_ft_term(a:mid, &ft, a:term, a:value)
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = s:menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:wimpimenu_padding_right

  if 1
    call s:window_open(maxsize)
    call s:window_render(content, a:mid)
    call s:setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc



function! wimpimenu#toggle(mid) abort
  if s:window_exist()
    call s:window_close()
    return 0
  endif
  if g:wimpimenu_disable_nofile
    if &buftype == 'nofile' || &buftype == 'quickfix'
      return 0
    endif
    if &modifiable == 0
      if index(g:wimpimenu_ft_blacklist, &ft) >= 0
        return 0
      endif
    endif
  endif

  " select and arrange menu
  let items = s:select_by_ft(a:mid, &ft)
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = s:menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:wimpimenu_padding_right

  if 1
    call s:window_open(maxsize)
    call s:window_render(content, a:mid)
    call s:setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc



"----------------------------------------------------------------------
" render text
"----------------------------------------------------------------------
function! s:window_render(items, mid) abort
  setlocal modifiable
  let ln = 2
  let b:wimpimenu = {}
  let b:wimpimenu.mid = a:mid
  let b:wimpimenu.padding_size = g:wimpimenu_padding_left
  let b:wimpimenu.option_lines = []
  let b:wimpimenu.section_lines = []
  let b:wimpimenu.text_lines = []
  let b:wimpimenu.header_lines = []
  for item in a:items
    let item.ln = ln
    call append('$', item.text)
    if item.mode == 0
      let b:wimpimenu.option_lines += [ln]
    elseif item.mode == 1
      let b:wimpimenu.text_lines += [ln]
    elseif item.mode == 2
      let b:wimpimenu.section_lines += [ln]
    else
      let b:wimpimenu.header_lines += [ln]
    endif
    let ln += 1
  endfor
  setlocal nomodifiable readonly
  setlocal ft=wimpimenu
  let b:wimpimenu.items = a:items
  let opt = g:wimpimenu_options

  if stridx(opt, 'L') >= 0
    setlocal cursorline
  endif
endfunc


"----------------------------------------------------------------------
" all keys
"----------------------------------------------------------------------
function! s:setup_keymaps(items)
  let ln = 0
  let mid = b:wimpimenu.mid
  let cursor_pos = get(s:wimpimenu_cursor, mid, 0)
  let nowait = ''
  if v:version >= 704 || (v:version == 703 && has('patch1261'))
    let nowait = '<nowait>'
  endif
  for item in a:items
    if item.key != ''
      let cmd = ' :call <SID>wimpimenu_execute('.ln.')<cr>'
      exec "noremap <buffer>".nowait."<silent> ".item.key. cmd
    endif
    let ln += 1
  endfor
  noremap <silent> <buffer> 0 :call <SID>wimpimenu_close()<cr>
  noremap <silent> <buffer> q :call <SID>wimpimenu_close()<cr>
  noremap <silent> <buffer> <CR> :call <SID>wimpimenu_enter()<cr>
  let s:wimpimenu_line = 0
  if cursor_pos > 0
    call cursor(cursor_pos, 1)
  endif
  let b:wimpimenu.showhelp = 0
  call s:set_cursor()
  augroup wimpimenu
    autocmd CursorMoved <buffer> call s:set_cursor()
    autocmd InsertEnter <buffer> call feedkeys("\<ESC>")
  augroup END
  let b:wimpimenu.showhelp = (stridx(g:wimpimenu_options, 'H') >= 0)? 1 : 0
endfunc


"----------------------------------------------------------------------
" reset cursor
"----------------------------------------------------------------------
function! s:set_cursor() abort
  let curline = line('.')
  let lastline = s:wimpimenu_line
  let movement = (curline < lastline)? -1 : 1
  let find = -1
  let size = len(b:wimpimenu.items)
  while 1
    let index = curline - 2
    if index < 0 || index >= size
      break
    endif
    let item = b:wimpimenu.items[index]
    if item.mode == 0 && item.event != ''
      let find = index
      break
    endif
    let curline += movement
  endwhile
  if find < 0
    let curline = line('.')
    let curdiff = abs(curline - b:wimpimenu.option_lines[0])
    let select = b:wimpimenu.option_lines[0]
    for line in b:wimpimenu.option_lines
      let newdiff = abs(curline - line)
      if newdiff < curdiff
        let curdiff = newdiff
        let select = line
      endif
    endfor
    let find = select - 2
  endif
  if find < 0
    echohl ErrorMsg
    echo "fatal error in set_cursor() ".find
    echohl None
    return
  endif
  let s:wimpimenu_line = find + 2
  call cursor(s:wimpimenu_line, g:wimpimenu_padding_left + 2)
  if b:wimpimenu.showhelp
    let help = b:wimpimenu.items[find].help
    let key = b:wimpimenu.items[find].key
    echohl wimpimenuHelp
    if help != ''
      call s:cmdmsg('['.key.']: '.help, 'wimpimenuHelp')
    else
      echo ''
    endif
    echohl None
  endif
endfunc


"----------------------------------------------------------------------
" close wimpimenu
"----------------------------------------------------------------------
function! <SID>wimpimenu_close()
  close
  redraw | echo "" | redraw
endfunc


"----------------------------------------------------------------------
" execute selected
"----------------------------------------------------------------------
function! <SID>wimpimenu_enter() abort
  let ln = line('.')
  call <SID>wimpimenu_execute(ln - 2)
endfunc


"----------------------------------------------------------------------
" execute item
"----------------------------------------------------------------------
function! <SID>wimpimenu_execute(index) abort
  if a:index < 0 || a:index >= len(b:wimpimenu.items)
    return
  endif
  let item = b:wimpimenu.items[a:index]
  if item.mode != 0 || item.event == ''
    return
  endif

  " this is the last window
  "if winnr('$') == 1
  "  close!
  "  return
  "endif
  "
  let s:wimpimenu_line = a:index + 2
  let s:wimpimenu_cursor[b:wimpimenu.mid] = s:wimpimenu_line

  "close!

  redraw | echo "" | redraw
  if item.key != '0'
    if type(item.event) == 1
      if item.event[0] != '='

        let currentwidth = winwidth(0)
        let currentWindow=winnr()
        "winwidth({nr})						*winwidth()*

        exec ':only'
        exec item.event
        let newWindow=winnr()

        exec currentWindow."wincmd w"
        setlocal foldcolumn=0
        exec "vertical resize " . currentwidth
        exec newWindow."wincmd w"
      else
        let script = matchstr(item.event, '^=\s*\zs.*')
      endif
    elseif type(item.event) == 2
      call item.event()

    endif
  endif
endfunc

function! s:select_by_ft_term(mid, ft, term, value) abort
  let hint = '123456789abcdefhilmnoprstuvwxyzACDIOPQRSUX*'
  " let hint = '12abcdefhlmnoprstuvwxyz*'
  let items = []
  let index = 0
  let header = get(s:wimpimenu_header, a:mid, s:wimpimenu_version)
  "let header = "Index " . a:term . ' ' . a:value
  if header != ''
    let ni = {'mode':3, 'text':'', 'event':'', 'help':''}
    let ni.text = header
    let items += [ni]
    let ni = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [ni]
  endif
  let lastmode = 2
  for item in get(s:wimpimenu_items, a:mid, [])
    if len(item.ft) && index(item.ft, a:ft) < 0
      continue
    endif
    if item.mode == 2 && lastmode != 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
    let lastmode = item.mode
    " allocate key for non-filetype specific items
    if item.mode == 0 && len(item.ft) == 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
    let items += [item]
    if item.mode == 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
  endfor
  " allocate key for filetype specific items
  for item in items
    if item.mode == 0 && len(item.ft) > 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
  endfor
  if len(items)
    let item = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [item]
  endif
  let item = {}
  let item.mode = 0
  let item.text = '<close>'
  let item.event = 'close'
  let item.key = '0'
  let item.help = ''
  let items += [item]
  return items
endfunc
"----------------------------------------------------------------------
" select items by &ft, generate keymap and add some default items
"----------------------------------------------------------------------
function! s:select_by_ft(mid, ft) abort
  let hint = '123456789abcdefhilmnoprstuvwxyzACDIOPQRSUX*'
  " let hint = '12abcdefhlmnoprstuvwxyz*'
  let items = []
  let index = 0
  let header = get(s:wimpimenu_header, a:mid, s:wimpimenu_version)
  if header != ''
    let ni = {'mode':3, 'text':'', 'event':'', 'help':''}
    let ni.text = header
    let items += [ni]
    let ni = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [ni]
  endif
  let lastmode = 2
  for item in get(s:wimpimenu_items, a:mid, [])
    if len(item.ft) && index(item.ft, a:ft) < 0
      continue
    endif
    if item.mode == 2 && lastmode != 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
    let lastmode = item.mode
    " allocate key for non-filetype specific items
    if item.mode == 0 && len(item.ft) == 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
    let items += [item]
    if item.mode == 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
  endfor
  " allocate key for filetype specific items
  for item in items
    if item.mode == 0 && len(item.ft) > 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
  endfor
  if len(items)
    let item = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [item]
  endif
  let item = {}
  let item.mode = 0
  let item.text = '<close>'
  let item.event = 'close'
  let item.key = '0'
  let item.help = ''
  let items += [item]
  return items
endfunc


"----------------------------------------------------------------------
" expand menu items
"----------------------------------------------------------------------
function! s:menu_expand(item) abort
  let items = []
  let text = s:expand_text(a:item.text)
  let help = ''
  let index = 0
  let padding = repeat(' ', g:wimpimenu_padding_left)
  if a:item.mode == 0
    let help = s:expand_text(get(a:item, 'help', ''))
  endif
  for curline in split(text, "\n", 1)
    let item = {}
    let item.mode = a:item.mode
    let item.text = curline
    let item.event = ''
    let item.key = ''
    if item.mode == 0
      if index == 0
        let item.text = '[' . a:item.key.']  '.curline
        let index += 1
        let item.key = a:item.key
        let item.event = a:item.event
        let item.help = help
      else
        let item.text = '     '.curline
      endif
    endif
    if len(item.text)
      let item.text = padding . item.text
    endif
    let items += [item]
  endfor
  return items
endfunc


"----------------------------------------------------------------------
" eval & expand: '%{script}' in string
"----------------------------------------------------------------------
function! s:expand_text(string) abort
  let partial = []
  let index = 0
  while 1
    let pos = stridx(a:string, '%{', index)
    if pos < 0
      let partial += [strpart(a:string, index)]
      break
    endif
    let head = ''
    if pos > index
      let partial += [strpart(a:string, index, pos - index)]
    endif
    let endup = stridx(a:string, '}', pos + 2)
    if endup < 0
      let partial += [strpart(a:stirng, index)]
      break
    endif
    let index = endup + 1
    if endup > pos + 2
      let script = strpart(a:string, pos + 2, endup - (pos + 2))
      let script = substitute(script, '^\s*\(.\{-}\)\s*$', '\1', '')
      let result = eval(script)
      let partial += [result]
    endif
  endwhile
  return join(partial, '')
endfunc


"----------------------------------------------------------------------
" string limit
"----------------------------------------------------------------------
function! s:slimit(text, limit, col)
  if a:limit <= 1
    return ""
  endif
  let size = strdisplaywidth(a:text, a:col)
  if size < a:limit
    return a:text
  endif
  if strlen(a:text) == size || has('patch-7.4.2000') == 0
    return strpart(a:text, 0, a:limit - 1)
  endif
  let text = strcharpart(a:text, 0, a:limit)
  let size = strchars(text)
  while 1
    if strdisplaywidth(text, a:col) < a:limit
      return text
    endif
    let step = size / 8
    let test = size - step
    if step > 3 && test > 16
      let demo = strcharpart(text, 0, test)
      if strdisplaywidth(demo, a:col) > a:limit
        let text = demo
        let size = test
        continue
      endif
    endif
    let size = size - 1
    let text = strcharpart(text, 0, size)
  endwhile
endfunc


"----------------------------------------------------------------------
" show cmd message
"----------------------------------------------------------------------
function! s:cmdmsg(content, highlight)
  let wincols = &columns
  let statusline = (&laststatus==1 && winnr('$')>1) || (&laststatus==2)
  let reqspaces_lastline = (statusline || !&ruler) ? 12 : 29
  let width = strdisplaywidth(a:content)
  let limit = wincols - reqspaces_lastline
  let l:content = a:content
  if width >= limit
    let l:content = s:slimit(l:content, limit, 0)
    let width = strdisplaywidth(l:content)
  endif
  redraw
  if a:highlight != ''
    exec "echohl ". a:highlight
    echo l:content
    echohl NONE
  else
    echo l:content
  endif
endfunc


"----------------------------------------------------------------------
" echo a error msg
"----------------------------------------------------------------------
function! s:errmsg(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunc


"----------------------------------------------------------------------
" echo highlight
"----------------------------------------------------------------------
function! s:highlight(standard, startify)
  exec "echohl ". (hlexists(a:startify)? a:startify : a:standard)
endfunc


"----------------------------------------------------------------------
" bottom up
"----------------------------------------------------------------------
function! wimpimenu#bottom(mid)
  if g:wimpimenu_disable_nofile
    if &buftype == 'nofile' || &buftype == 'quickfix'
      return ""
    endif
    if &modifiable == 0
      if index(g:wimpimenu_ft_blacklist, &ft) >= 0
        return ""
      endif
    endif
  endif

  if &columns < (g:wimpimenu_padding_left + 25)
    return ""
  endif

  let items = []
  let keymap = {}
  let maxsize = 4
  let header = get(s:wimpimenu_header, a:mid, s:wimpimenu_version)
  let header = (header == '')? s:wimpimenu_version : header

  " select and arrange menu
  for item in s:select_by_ft(a:mid, &ft)
    if item.mode == 0
      if item.key != '0' && item.key != '*'
        let ni = deepcopy(item)
        let ni.text = s:expand_text(item.text)
        let ni.help = s:expand_text(item.help)
        let ni.text = substitute(ni.text, '[\n\t]', ' ', 'g')
        let ni.help = substitute(ni.help, '[\n\t]', ' ', 'g')
        let items += [ni]
        let keymap[ni.key] = ni
        if strdisplaywidth(ni.text) > maxsize
          let maxsize = strdisplaywidth(ni.text)
        endif
      endif
    endif
  endfor

  " exit when items is empty
  if empty(items)
    return ""
  endif

  " normalize size
  for item in items
    let ds = strdisplaywidth(item.text)
    if ds < maxsize
      let item.text = item.text . repeat(' ', maxsize - ds)
    endif
  endfor

  " loop menu
  let c = s:bottom_popup(items, header)

  " remove alt and convert to char
  if has('nvim')
    let cc = (type(c) != 0)?  split(c, '.\zs')[-1] : nr2char(c)
  else
    let cc = (type(c) == 0 && c > 127)? nr2char(c - 128) : nr2char(c)
  endif

  let item = get(keymap, cc, {})

  echo ""
  redraw

  if empty(item)
    return ""
  endif

  if type(item.event) == 1
    if item.event[0] != '='
      exec item.event
    else
      let script = matchstr(item.event, '^=\zs.*')
      return script
    endif
  elseif type(item.event) == 2
    return item.event()
  endif

  return ""
endfunc


"----------------------------------------------------------------------
" render menu at cmdline
"----------------------------------------------------------------------
function! s:bottom_render(items, header)
  echo ""
  let &cmdheight = len(a:items) + 2
  let maxcount = &cmdheight - 2
  let maxcount = (maxcount < len(a:items))? maxcount : len(a:items)
  let columns = &columns - 2
  let padding = repeat(' ', g:wimpimenu_padding_left)
  let header = padding . a:header . ':'
  let header = s:slimit(header, columns - 29, 0)
  let start = g:wimpimenu_padding_left + 7
  call s:highlight('Statement', 'StartifySection')
  echon header. "\n"
  for index in range(maxcount)
    let item = a:items[index]
    call s:highlight('Delimiter', 'StartifyBracket')
    echon padding. "  ["
    call s:highlight('Number', 'StartifyNumber')
    echon item.key
    call s:highlight('Delimiter', 'StartifyBracket')
    echon "]  "
    call s:highlight('Identifier', 'StartifyFile')
    let text = s:slimit(item.text, columns - start, start)
    echon text
    let next = start + strdisplaywidth(text)
    let help = item.help
    if help == '' && type(item.event) == 1
      let help = item.event
    endif
    if next < columns - 8 && help != ''
      call s:highlight('Comment', 'StartifySpecial')
      let help = '    : '.strtrans(help)
      let help = s:slimit(help, columns - next, next)
      echon help
    endif
    echon "\n"
  endfor
  call s:highlight('Comment', 'StartifySelect')
  echon padding. "press (space to exit): "
  echohl None
endfunc


"----------------------------------------------------------------------
" show menu info and select one
"----------------------------------------------------------------------
function! s:bottom_popup(items, header)
  " store options
  let [lz, ch, ut] = [&lz, &ch, &ut]
  set nolazyredraw
  set ut=100000000

  " display items
  call s:bottom_render(a:items, a:header)

  " wait for input
  try
    let c = getchar()
  catch
    let c = ''
  endtry

  " restore options
  let [&lz, &ch, &ut] = [lz, ch, ut]

  " remove old echos
  redraw

  return c
endfunc


"----------------------------------------------------------------------
" testing case
"----------------------------------------------------------------------
if 1


  call wimpimenu#reset()
  call wimpimenu#append('# Start', '')
  call wimpimenu#append('test1', 'echo 1', 'help 1')
  call wimpimenu#append('test2', 'echo 2', 'help 2')

  call wimpimenu#append('# Misc', '')
  call wimpimenu#append('test3', 'echo 3')
  call wimpimenu#append('test4', 'echo 4')
  call wimpimenu#append("test5\nasdfafffff\njkjkj", 'echo 5')
  call wimpimenu#append('text1', '')
  call wimpimenu#append('text2', '')

  " nnoremap <F12> :call wimpimenu#toggle(0)<cr>
  imap <expr> <F11> wimpimenu#bottom(0)
endif






