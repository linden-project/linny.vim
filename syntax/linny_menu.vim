" Copyright (c) Pim Snel 2019-2021

if exists('b:current_syntax')
endif

let s:padding_left = repeat(' ', get(g:, 'linny_menu_padding_left', 3))

syntax sync fromstart

if exists('t:linny_menu.option_lines')
  let s:col = len(s:padding_left) + 4
  for line in t:linny_menu.option_lines
    exec 'syntax region LinnymenuOption start=/\%'. line .
          \ 'l'.''. '/ end=/$/'
  endfor
endif

execute 'syntax match LinnymenuBracket /.*\%'. (len(s:padding_left) + 5) .'c/ contains=
      \ LinnymenuNumber,
      \ LinnymenuSelect'

syntax match LinnymenuNumber  /^\s*\[\zs[^BSVT]\{-}\ze\]/
syntax match LinnymenuSelect  /^\s*\[\zs[BSVT]\{-}\ze\]/
syntax match LinnymenuSpecial /\V<close>\|<quit>\|<xrefresh>/


if exists('t:linny_menu.section_lines')
  for line in t:linny_menu.section_lines
    exec 'syntax region LinnymenuSection start=/\%'. line .'l/ end=/$/'
  endfor
endif

if exists('t:linny_menu.text_lines')
  for line in t:linny_menu.text_lines
    exec 'syntax region LinnymenuText start=/\%'. line .'l/ end=/$/'
  endfor
endif

if exists('t:linny_menu.header_lines')
  for line in t:linny_menu.header_lines
    exec 'syntax region LinnymenuHeader start=/\%'. line .'l/ end=/$/'
  endfor
endif

if exists('t:linny_menu.footer_lines')
  for line in t:linny_menu.footer_lines
    exec 'syntax region LinnymenuFooter start=/\%'. line .'l/ end=/$/'
  endfor
endif

function! s:hllink(name, dest, alternative)
  let tohl = a:dest
  if hlexists(a:alternative)
    let tohl = a:alternative
  endif
  if v:version < 508
    exec "hi link ".a:name.' '.tohl
  else
    exec "hi def link ".a:name.' '.tohl
  endif
endfunc

command! -nargs=* HighLink call s:hllink(<f-args>)


hi def link  LinnymenuBracket  Delimiter
hi def link  LinnymenuSection  Statement
hi def link  LinnymenuSelect   Title
hi def link  LinnymenuNumber   Number
hi def link  LinnymenuSpecial  Comment
hi def link  LinnymenuHeader   Title
hi def link  LinnymenuFooter   Comment
hi def link  LinnymenuOption   Identifier
hi def link  LinnymenuHelp     Comment

