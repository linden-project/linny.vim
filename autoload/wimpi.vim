function! wimpi#PluginVersion()
    return '0.2.4'
endfunction

function! s:initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
    return 1
  endif
  return 0
endfunction

call s:initVariable("s:spaceReplaceChar", '_')

function! wimpi#MdwiWordFilename(word)
  let file_name = ''
  "Same directory and same extension as the current file
  if !empty(a:word)
    " strip leading and trailing spaces
    let word = substitute(a:word, '^\s*\(.\{-}\)\s*$', '\1', '')
    "substitute spaces by spaceReplaceChar
    let word = substitute(word, '\s', s:spaceReplaceChar, 'g')

    "substitute other illegal chars
    let word = substitute(word, '\/', s:spaceReplaceChar, 'g')
    let word = substitute(word, ':', s:spaceReplaceChar, 'g')

    let cur_file_name = bufname("%")
    let extension = 'md'
    let file_name = tolower(word).".".extension
  endif
  return file_name
endfunction

function! wimpi#new_dir(...)

  let dir_name = join(a:000)

  if !isdirectory(g:wimpi_dirs_root)
    echo "g:wimpi_dirs_root is not a valid directory"
    return
  endif

  let relativePath = fnameescape(g:wimpi_dirs_root .'/'.dir_name )
  if filereadable(relativePath)
    echo "directory name already exist"
    return
  endif

  exec "!mkdir ". relativePath
  return g:wimpi_dirs_root .'/'.dir_name
endfunction

function! wimpi#make_index()
  if exists('g:wimpi_index_cli_command')
    execute "!". g:wimpi_index_cli_command
  else
    echo "Error: g:wimpi_index_cli_command not set"
  endif
endfunction

func! wimpi#browsetaxovals()

  let currentKey = MdwiYamlKeyUnderCursor()
  let relativePath = fnameescape($HOME . '/Dropbox/Apps/KiwiApp/index/index_' . currentKey .'.json' )

  if filereadable(relativePath)

    let lines = readfile(relativePath)
    let json = join(lines)
    let dict = json_decode(json)
    call setline('.', currentKey .": ")
    call cursor(line('.'), strlen(currentKey)+3)
    call complete(strlen(currentKey)+3, sort(dict))
  endif

  return ''
endfunc

function! wimpi#grep(...)
  let awkWimpiGrep = "grep -nri ".'"'.join(a:000).'"'." ~/Dropbox/Apps/KiwiApp/wiki | awk -F".'"'.":".'"'." {'gsub(/^[ \t]/, ".'""'.", $3);print $1".'"'.'|"$2"| "$3'."'}"
  execute 'AsyncRun! '. awkWimpiGrep
endfunction

function! wimpi#move_to(dest)
  let relativePath = fnameescape($HOME . '/Dropbox/Apps/KiwiApp/wiki/')
  exec "!mkdir -p ". relativePath ."/".a:dest
  exec "!mv '%' " . relativePath . "/".a:dest."/"
  exec "bdelete"
endfunction

function! wimpi#new_document(...)
  let title = join(a:000)
  let fileName = wimpi#MdwiWordFilename(title)
  let relativePath = fnameescape($HOME . '/Dropbox/Apps/KiwiApp/wiki/' . fileName)

  if !filereadable(relativePath)
    let taxo_term = ''
    let taxo_val = ''
    if t:wimpimenu_taxo_term != "" && t:wimpimenu_taxo_val != ""
      let taxo_term = t:wimpimenu_taxo_term
      let taxo_val =  t:wimpimenu_taxo_val
    endif

    let fileLines = wimpi#generate_first_content(title, taxo_term, taxo_val)
    if writefile(fileLines, relativePath)
      echomsg 'write error'
    endif
  endif

  if bufname('%') =~ "[wimpimenu]"
    let currentwidth = t:wimpimenu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    execute ':botright vs '. relativePath

    let newWindow=winnr()


    exec currentWindow."wincmd w"
    exec currentWindow."call wimpimenu#openandshow(0)"
    setlocal foldcolumn=0
    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute 'e '. relativePath
  end

endfunction

function! wimpi#generate_first_content(title,taxo_term, taxo_value)

  let fileLines = []

  call add(fileLines, '---')
  call add(fileLines, 'title: "'.a:title.'"')
  call add(fileLines, a:taxo_term . ': '.a:taxo_value)
  call add(fileLines, '---')
  call add(fileLines, '')

  return fileLines

endfunction

