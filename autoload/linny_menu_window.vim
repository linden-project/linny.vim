" linny_menu_window.vim - Window/buffer management for linny menu

" Check if menu window exists
function! linny_menu_window#exist()
  if !exists('t:linny_menu_bid')
    let t:linny_menu_bid = -1
    return 0
  endif

  return t:linny_menu_bid > 0 && bufexists(t:linny_menu_bid)
endfunc

" Close menu window
function! linny_menu_window#close_window()
  if !exists('t:linny_menu_bid')
    return 0
  endif

  " IF LAST WINDOW, FIRST CREATE NEW ONE
  if winbufnr(2) == -1
    exec "below vnew"
  endif

  if &buftype == 'nofile' && &ft == 'linny_menu'
    if bufname('%') == t:linny_menu_name
      silent close!
      let t:linny_menu_bid = -1
    endif
  endif

  if t:linny_menu_bid > 0 && bufexists(t:linny_menu_bid)
    silent exec 'bwipeout ' . t:linny_menu_bid
    let t:linny_menu_bid = -1
  endif

  redraw | echo "" | redraw
endfunc

" Open menu window with specified size
function! linny_menu_window#open_window(size)
  if linny_menu_window#exist()
    call linny_menu_window#close_window()
  endif

  let size = a:size
  let size = (size < 4)? 4 : size
  let size = (size > g:linny_menu_max_width)? g:linny_menu_max_width : size
  if size > winwidth(0)
    let size = winwidth(0) - 1
    if size < 4
      let size = 4
    endif
  endif
  let savebid = bufnr('%')
  if stridx(g:linny_menu_options, 'T') < 0
    exec "silent! rightbelow ".size.'vne '.t:linny_menu_name
  else
    exec "silent! leftabove ".size.'vne '.t:linny_menu_name
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

  let t:linny_menu_bid = bufnr('%')
  return 1
endfunc

" Render items to window
function! linny_menu_window#render(items) abort
  setlocal modifiable
  let ln = 2
  let t:linny_menu = {}
  let t:linny_menu.padding_size = g:linny_menu_padding_left

  let t:linny_menu.option_lines = []
  let t:linny_menu.section_lines = []
  let t:linny_menu.text_lines = []
  let t:linny_menu.header_lines = []
  let t:linny_menu.footer_lines = []
  for item in a:items
    let item.ln = ln
    call append('$', item.text)
    if item.mode == 0
      let t:linny_menu.option_lines += [ln]
    elseif item.mode == 1
      let t:linny_menu.text_lines += [ln]
    elseif item.mode == 2
      let t:linny_menu.section_lines += [ln]
    elseif item.mode == 3
      let t:linny_menu.header_lines += [ln]
    elseif item.mode == 4
      let t:linny_menu.footer_lines += [ln]
    endif
    let ln += 1
  endfor
  setlocal nomodifiable readonly
  setlocal ft=linny_menu
  let t:linny_menu.items = a:items
  let opt = g:linny_menu_options

  if stridx(opt, 'L') >= 0
    setlocal cursorline
  endif
endfunc

" Start menu
function! linny_menu_window#start()
  call linny_menu_state#tab_init()
  call linny_menu#openterm('','')
endfunction

" Open menu
function! linny_menu_window#open()
  if !linny_menu_window#exist()
    call linny_menu_state#tab_init()
    call linny_menu#openandshow()
  endif
endfunction

" Close menu
function! linny_menu_window#close()
  if linny_menu_window#exist()
    call linny_menu_window#close_window()
    return 0
  endif
endfunction

" Toggle menu
function! linny_menu_window#toggle() abort
  if linny_menu_window#exist()
    call linny_menu_window#close_window()
    return 0
  endif

  " select and arrange menu
  let items = Select_items()
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = Menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:linny_menu_padding_right

  if 1
    call linny_menu_window#open_window(maxsize)
    call linny_menu_window#render(content)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc

" Refresh menu
function! linny_menu_window#refresh()
  call linny#Init()
  call linny#make_index()
  call linny_menu#openandshow()
endfunction

" Open home view
function! linny_menu_window#open_home()
  if !exists('t:linny_menu_name')
    echomsg 'ERROR No Linny Menu opened. Are you in Linny?'
    return
  endif

  call linny_menu#openterm('','')
endfunction

" Open file in menu
function! linny_menu_window#open_file(filepath)
  if &buftype == 'nofile' && &ft == 'linny_menu'

    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    exec ':botright vs '. a:filepath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"

    setlocal foldcolumn=0

    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute ':e '. a:filepath
  endif
endfunction
