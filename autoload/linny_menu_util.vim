" linny_menu_util.vim - Utility functions for linny menu
" No dependencies on other linny_menu_* modules

" Pad string to specified length
function! linny_menu_util#prepad(s, amt, ...)
  if a:0 > 0
    let char = a:1
  else
    let char = ' '
  endif
  return repeat(char, a:amt - len(a:s)) . a:s
endfunction

" Eval & expand: '%{script}' in string
function! linny_menu_util#expand_text(string) abort
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

" String limit - truncate string to fit within limit
function! linny_menu_util#slimit(text, limit, col)
  if a:limit <= 1
    return ""
  endif
  let size = strdisplaywidth(a:text, a:col)
  if size < a:limit
    return a:text
  endif
  if strchars(a:text) == size || has('patch-7.4.2000') == 0
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

" Show command message
function! linny_menu_util#cmdmsg(content, highlight)
  let wincols = &columns
  let statusline = (&laststatus==1 && winnr('$')>1) || (&laststatus==2)
  let reqspaces_lastline = (statusline || !&ruler) ? 12 : 29
  let width = strdisplaywidth(a:content)
  let limit = wincols - reqspaces_lastline
  let l:content = a:content
  if width >= limit
    let l:content = linny_menu_util#slimit(l:content, limit, 0)
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

" Echo error message
function! linny_menu_util#errmsg(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunc

" Echo highlight
function! linny_menu_util#highlight(standard, startify)
  exec "echohl ". (hlexists(a:startify)? a:startify : a:standard)
endfunc

" Capitalize first character of string
function! linny_menu_util#string_capitalize(capstring)
  return toupper(strpart(a:capstring, 0, 1)).strpart(a:capstring,1)
endfunction

" Create a string of specified length with specified character
function! linny_menu_util#string_of_length_with_char(char, length)
  let i = 0
  let padString = ""
  while a:length >= i
    let padString = padString . a:char
    let i += 1
  endwhile
  return padString
endfunction

" Calculate active view arrow position for menu header
function! linny_menu_util#calc_active_view_arrow(views_list, active_view, padding_left)
  let idx = 0
  let arrow_string = linny_menu_util#string_of_length_with_char(" ", a:padding_left)
  let stopb = 0

  for view in a:views_list
    if idx == a:active_view
      let padSize = round(len(view)/2)
      let filstr = linny_menu_util#string_of_length_with_char(" ", padSize)
      let arrow_string = arrow_string . filstr . "▲"
      let stopb = 1
    else
      if !stopb
        let arrow_string = arrow_string . linny_menu_util#string_of_length_with_char(" ", (len(view)+1))
      endif
    endif
    let idx += 1
  endfor
  return arrow_string
endfunction
