" Copyright (c) Pim Snel 2019-2024


function! linny_notebook#init()
  let g:linny_path_wiki_content = expand(g:linny_open_notebook_path . '/content' )
  let g:linny_path_wiki_config = expand(g:linny_open_notebook_path . '/lindenConfig')
  let g:linny_index_path = expand(g:linny_open_notebook_path . '/lindenIndex')
endfunction

function! linny_notebook#open()
  call inputsave()
  let path = input('Enter path to notebook: ')
  call inputrestore()

  if(!empty(path))
    echo path
    if isdirectory(expand(path))

      let g:linny_open_notebook_path = expand(path)

      call linny#Init()
      call linny_menu#start()
    else
      echom 'ERR: ' . path .' does not exist'
      return 0
    end

  else
    return 0
  endif

endfunction


