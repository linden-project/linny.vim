" Copyright (c) Pim Snel 2019-2021

" FILE PRIMARY
function! linny_wikitags#file(innertag)
  silent execute "!open " . a:innertag
endfunction

function! linny_wikitags#mkdir_if_not_exist(innertag)
  if(isdirectory(expand(a:innertag)) != 1)
    silent execute "!mkdir " . fnameescape(a:innertag)
  endif
endfunction

" DIR PRIMARY
function! linny_wikitags#dir1st(innertag)
  call linny_wikitags#mkdir_if_not_exist(a:innertag)
  silent execute "!open " . a:innertag
endfunction

" DIR SECONDARY TODO check nerdtree else netrw
function! linny_wikitags#dir2nd(innertag)
  call linny_wikitags#mkdir_if_not_exist(a:innertag)
  "silent execute "!open " . a:innertag
  execute 'NERDTree ' . fnameescape(a:innertag)
endfunction

" SHELL PRIMARY
function! linny_wikitags#shell(innertag)
  execute "!". a:innertag
endfunction

" LINNY PRIMARY
function! linny_wikitags#linny(innertag)
  if stridx(a:innertag, ":") >= 0
    let parts = split(a:innertag, ":")
    if len(parts) == 2
      call linny_menu#openterm(parts[0], trim(parts[1]))
    else
      echom "Invalid Wikitag"
    end
  else
      call linny_menu#openterm(trim(a:innertag),'')
  endif
endfunction

" VIM PRIMARY
function! linny_wikitags#vim(innertag)
  echo "!". a:innertag

  execute a:innertag

endfunction

