" Copyright (c) Pim Snel 2019-2023

"----------------------------------------------------------------------
" LINNY.VIM INIT
"----------------------------------------------------------------------
"call linny#Init()

" SETUP AUTOCOMMANDS
if g:linnycfg_setup_autocommands
  augroup MarkdownTasks
    autocmd BufEnter,WinEnter,BufWinEnter *.md call linny_wiki#FindNonExistingLinks()
  augroup END

  autocmd FileType markdown nnoremap <buffer> <CR> :call linny_wiki#GotoLink()<CR>
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

command! LinnyOpenNotebook :call linny_notebook#open()


"----------------------------------------------------------------------
" REGISTER DEFAULT WIKITAGS
"----------------------------------------------------------------------
call linny#RegisterLinnyWikitag('FILE',   'linny_wikitags#file',  'linny_wikitags#file')
call linny#RegisterLinnyWikitag('DIR',    'linny_wikitags#dir1st','linny_wikitags#dir2nd')
call linny#RegisterLinnyWikitag('SHELL',  'linny_wikitags#shell', 'linny_wikitags#shell')
call linny#RegisterLinnyWikitag('LIN',    'linny_wikitags#linny', 'linny_wikitags#linny')
call linny#RegisterLinnyWikitag('VIM',    'linny_wikitags#vim',   'linny_wikitags#vim')
