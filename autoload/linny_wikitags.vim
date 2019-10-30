
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
  "echo "!". a:innertag

  execute a:innertag

endfunction

