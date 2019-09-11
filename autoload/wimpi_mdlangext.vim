function! wimpi_mdlangext#wikiWordHasPrefix(word, prefix)
  if a:word =~ "^".a:prefix."*"
    return 1
  else
    return 0
  endif
endfunction

function! wimpi_mdlangext#wikiWordWithPrefix(word, prefix)
  if a:word =~ "^".a:prefix."*"
    return trim(a:word[len(a:prefix):-1])
  else
    return ""
  endif
endfunction

function! wimpi_mdlangext#FindNonExistingLinks()

  let pat='\[\[.*\]\]'
  let filelines=getline(1, '$')
  let lst = []

  for expr in filelines

    let start = 0
    let cnt = 1

    try
      let found = match(expr, pat, start, cnt)

      while found != -1
        let mstr = matchstr(expr, pat, start, cnt)

        let word = mstr[2:-3]

        if wimpi_mdlangext#wikiWordHasPrefix(word, "DIR") || wimpi_mdlangext#wikiWordHasPrefix(word, "FILE") || wimpi_mdlangext#wikiWordHasPrefix(word, "SHELL")
        else
          let fileName = wimpi#MdwiWordFilename(word)
          if(MdwiFileExist(MdwiFilePath(fileName)) != 1)
            call matchadd('Todo', '\[\['.word.'\]\]')
          endif
        end

        let cnt += 1
        let found = match(expr, pat, start, cnt)

      endwhile

    catch
      "TODO do something with errors
    endtry

  endfor

endfunction
