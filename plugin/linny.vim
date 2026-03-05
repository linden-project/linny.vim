" Copyright (c) Pim Snel 2019-2023

"----------------------------------------------------------------------
" LINNY.VIM INIT
"----------------------------------------------------------------------
"call linny#Init()

" SETUP AUTOCOMMANDS
if get(g:, 'linnycfg_setup_autocommands', 1)
  augroup MarkdownTasks
    autocmd BufEnter,WinEnter,BufWinEnter *.md lua require('linny.wiki').find_non_existing_links()
  augroup END

  autocmd FileType markdown nnoremap <buffer> <CR> :lua require('linny.wiki').goto_link()<CR>
endif

"----------------------------------------------------------------------
" DEFINED COMMANDS
"----------------------------------------------------------------------
command! -nargs=+ LinnyNewDoc :call linny_menu#new_document_in_leaf(<f-args>)

command! LinnyStart :call linny_menu#start()

command! LinnyMenuToggle :call linny_menu#toggle()
command! LinnyMenuOpen :call linny_menu#open()
command! LinnyMenuClose :call linny_menu#close()

command! LinnyMenuClose :call linny_menu#close()

command! LinnyWordToRegister :call linny#FilenameToWordToUnamedRegister()

command! -nargs=? LinnyOpenNotebook :call luaeval("require('linny.notebook').open(_A)", <q-args>)


"----------------------------------------------------------------------
" WIKITAG WRAPPER FUNCTIONS (call Lua implementations)
"----------------------------------------------------------------------
function! LinnyWikitag_file(innertag)
  call luaeval("require('linny.wikitags').file(_A)", a:innertag)
endfunction

function! LinnyWikitag_dir1st(innertag)
  call luaeval("require('linny.wikitags').dir1st(_A)", a:innertag)
endfunction

function! LinnyWikitag_dir2nd(innertag)
  call luaeval("require('linny.wikitags').dir2nd(_A)", a:innertag)
endfunction

function! LinnyWikitag_shell(innertag)
  call luaeval("require('linny.wikitags').shell(_A)", a:innertag)
endfunction

function! LinnyWikitag_linny(innertag)
  call luaeval("require('linny.wikitags').linny(_A)", a:innertag)
endfunction

function! LinnyWikitag_vim(innertag)
  call luaeval("require('linny.wikitags').vim_cmd(_A)", a:innertag)
endfunction

"----------------------------------------------------------------------
" REGISTER DEFAULT WIKITAGS
"----------------------------------------------------------------------
call linny#RegisterLinnyWikitag('FILE',   'LinnyWikitag_file',  'LinnyWikitag_file')
call linny#RegisterLinnyWikitag('DIR',    'LinnyWikitag_dir1st','LinnyWikitag_dir2nd')
call linny#RegisterLinnyWikitag('SHELL',  'LinnyWikitag_shell', 'LinnyWikitag_shell')
call linny#RegisterLinnyWikitag('LIN',    'LinnyWikitag_linny', 'LinnyWikitag_linny')
call linny#RegisterLinnyWikitag('VIM',    'LinnyWikitag_vim',   'LinnyWikitag_vim')
