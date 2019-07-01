function! wimpi#PluginVersion()
    return '0.2.1'
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
  "  echom "MdwiWordFilename"
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


