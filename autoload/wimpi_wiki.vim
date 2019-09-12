function! s:initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
    return 1
  endif
  return 0
endfunction

"Initialize variables
"call s:initVariable("s:footer", "_Footer")
"call s:initVariable("s:sidebar", "_Sidebar")
call s:initVariable("s:startWord", '[[')
call s:initVariable("s:endWord", ']]')
call s:initVariable("s:startLink", '(')
call s:initVariable("s:endLink", ')')
call s:initVariable("s:spaceReplaceChar", '_')

call s:initVariable("s:lastPosLine", 0)
call s:initVariable("s:lastPosCol", 0)


function! wimpi_wiki#wikiWordHasPrefix(word, prefix)
  if a:word =~ "^".a:prefix."*"
    return 1
  else
    return 0
  endif
endfunction

function! wimpi_wiki#wikiWordWithPrefix(word, prefix)
  if a:word =~ "^".a:prefix."*"
    return trim(a:word[len(a:prefix):-1])
  else
    return ""
  endif
endfunction

function! wimpi_wiki#FindNonExistingLinks()

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

        if wimpi_wiki#wikiWordHasPrefix(word, "DIR") || wimpi_wiki#wikiWordHasPrefix(word, "FILE") || wimpi_wiki#wikiWordHasPrefix(word, "SHELL")
        else
          let fileName = wimpi_wiki#WordFilename(word)
          if(wimpi_wiki#FileExist(wimpi_wiki#FilePath(fileName)) != 1)
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

" *********************************************************************
" *                      Utilities
" *********************************************************************

function! wimpi_wiki#FileExist(relativePath)

  if filereadable(a:relativePath)
    return 1
  endif

  return 0

endfunction

function! wimpi_wiki#WordFilename(word)
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

function! wimpi_wiki#StrBetween(startStr, endStr)
  let str = ''

  "Get string between <startStr> and <endStr>
  let origPos = getpos('.')
  let endPos = searchpos(a:endStr, 'W', line('.'))
  let startPos = searchpos(a:startStr, 'bW', line('.'))
  let ok = cursor(origPos[1], origPos[2]) "Return to the original position

  if (startPos[1] < origPos[2])
    let ll = getline(line('.'))
    let str = strpart(ll, startPos[1] + strlen(a:startStr) - 1, endPos[1] - strlen(a:endStr) - startPos[1])
  endif
  return str
endfunction

"YAML functions"

function! wimpi_wiki#GetIndentationStep()
  call cursor(1,1)
  call search('^\s')
  return indent(".")
endfunction

function! wimpi_wiki#AddParentKeys()
  let goToLineCmd = ':' . s:inputLineNumber
  :exec goToLineCmd

  let l:parentIndent = s:currentIndent - s:indentationStep
  while l:parentIndent >= 0

    if l:parentIndent == 0
      :call search('^\S', 'b')
    else
      :call search('^\s\{'.l:parentIndent.'}\S', 'b')
    endif

    let parentKey = matchstr(getline("."), '\s*\zs.\+\ze:')
    :call add(s:keys, parentKey)
    let s:currentIndent = indent(".")
    if l:parentIndent >= 0
      let l:parentIndent = s:currentIndent - s:indentationStep
    endif
  endwhile
endfunction

function! wimpi_wiki#YamlKeyUnderCursor()
  let s:inputLineCol = col('.')
  let s:inputLineNumber = line('.')

  let currentLine = getline(s:inputLineNumber)
  if !empty(currentLine)
    let currentKey = matchstr(currentLine, '\s*\zs.\+\ze:')
    return currentKey
  else
    return ""
  endif

  "later we'll support nested keys
  "    let s:keys = [currentKey]
  "
  "    if !empty(currentLine)
  "        let s:indentationStep = wimpi_wiki#GetIndentationStep()
  "        let s:currentIndent = indent(s:inputLineNumber)
  "
  "        :call wimpi_wiki#AddParentKeys()
  "        :call reverse(s:keys)
  "
  "        :call cursor(s:inputLineNumber, s:inputLineCol)
  "        return join(s:keys, " > ")
  "    else
  "        return ""
  "    endif
endfunction

function! wimpi_wiki#YamlValUnderCursor()
  let inputLineNumber = line('.')

  let currentLine = getline(inputLineNumber)
  let currentVal = matchstr(currentLine, '\s*:\s*\zs.\+\ze')

  if !empty(currentLine)
    return currentVal
  else
    return ""
  endif
endfunction

function! wimpi_wiki#CursorInFrontMatter()

  let origPos = getpos('.')

  if(getline(1) == '---' && line('.') > 1)
    let ok = cursor(1, 1)

    let frontmatterEnd = search('---', '', line("w$"))
    let ok = cursor(origPos[1], origPos[2]) "Return to the original position
    if frontmatterEnd > 0 && frontmatterEnd > line('.')
      return 1
    endif
  end

  return 0

endfunction

function! wimpi_wiki#CallFrontMatterLink()

  let yamlKey = wimpi_wiki#YamlKeyUnderCursor()
  let yamlVal = wimpi_wiki#YamlValUnderCursor()

  let indexFileTitle = 'index ' . yamlKey . ' ' . yamlVal
  let fileName = wimpi_wiki#WordFilename(indexFileTitle)

  let relativePath = wimpi#l3_index_filepath(yamlKey, yamlVal)

  if filereadable(relativePath)
    call wimpi_menu#openterm(0, yamlKey, yamlVal)
  else
    echomsg "Can't open, does not exist"
  endif
endfunction

function! wimpi_wiki#FilePath(fileName)
  let cur_file_name = bufname("%")
  let dir = fnamemodify(cur_file_name, ":h")
  if !empty(dir)
    if (dir == ".")
      let dir = ""
    else
      let dir = dir."/"
    endif
  endif
  let file_path = dir.a:fileName
  return file_path
endfunction

" *********************************************************************
" *                      Words
" *********************************************************************

function! wimpi_wiki#FindWordPos()
  let origPos = getpos('.')
  let newPos = origPos
  let endPos = searchpos(s:endWord, 'W', line('.'))
  let startPos = searchpos(s:startWord, 'bW', line('.'))

  if (startPos[0] != 0 )
    let newcolpos = col('.') + 1
    if (newcolpos == origPos[2])
      let newcolpos = newcolpos + 1
    endif
    let newPos = [origPos[0], line('.'), newcolpos, origPos[3]]
  endif

  let ok = cursor(origPos[1], origPos[2]) "Return to the original position
  return newPos
endfunction

function! wimpi_wiki#GetWord()
  let word = ''
  let wordPos = wimpi_wiki#FindWordPos()
  if (wordPos != getpos('.'))
    let ok = cursor(wordPos[1], wordPos[2])
    let word = wimpi_wiki#StrBetween(s:startWord, s:endWord)
  endif
  return word
endfunction

" *********************************************************************
" *                      Links
" *********************************************************************
function! wimpi_wiki#FindLinkPos()
  let origPos = getpos('.')
  let newPos = origPos
  let startPos = searchpos(s:startWord, 'bW', line('.'))
  let endPos = searchpos(s:endWord, 'W', line('.'))

  if (startPos[0] != 0)
    let nextchar = matchstr(getline('.'), '\%' . (col('.')+1) . 'c.')
    if (nextchar == s:startLink)
      let newcolpos = col('.') + 2
      if (newcolpos == origPos[2])
        let newcolpos = newcolpos + 1
      endif
      let newPos = [origPos[0], line('.'), newcolpos, origPos[3]]
    endif
  endif

  let ok = cursor(origPos[1], origPos[2]) "Return to the original position
  return newPos
endfunction

function! wimpi_wiki#GetLink()
  let link = ''
  "Is there a link defined ?
  let linkPos = wimpi_wiki#FindLinkPos()
  if (linkPos != getpos('.'))
    let ok = cursor(linkPos[1], linkPos[2])
    let link = wimpi_wiki#StrBetween(s:startLink, s:endLink)
  endif
  return link
endfunction

" ******** CHECK FOR SPECIALE LINKS *****************

" ******** Go to link *****************
function! wimpi_wiki#GotoLink()
  call wimpi_wiki#GotoLinkMain(0,0)
endfunction

" ******** Go to link in new tab *************
function! wimpi_wiki#GotoLinkInNewTab()
  call wimpi_wiki#GotoLinkMain(0,1)
endfunction

" ******** Go to link main executer *****************
function! wimpi_wiki#GotoLinkWithCTRL()
  call wimpi_wiki#GotoLinkMain(1,0)
endfunction

function! wimpi_wiki#GenerateFirstContent(wikiTitle,fileLinesIn)

  if len(a:fileLinesIn) > 0
    let fileLines = a:fileLinesIn
  else
    let fileLines = []
    call add(fileLines, '---')
    call add(fileLines, 'title: "'.a:wikiTitle.'"')
    call add(fileLines, '---')
    call add(fileLines, '')
  endif

  return fileLines

endfunction

function! wimpi_wiki#GotoLinkMain(withCTRL, openInNewTab)

  if wimpi_wiki#CursorInFrontMatter()
    call wimpi_wiki#CallFrontMatterLink()
  end


  let s:lastPosLine = line('.')
  let s:lastPosCol = col('.')

  let word = wimpi_wiki#GetWord()

  if !empty(word)

    if(wimpi_wiki#wikiWordHasPrefix(word , "DIR"))

      if(wimpi_wiki#FileExist(wimpi_wiki#FilePath(wimpi_wiki#wikiWordWithPrefix(word, "DIR"))) != 1)
        silent execute "!mkdir " . fnameescape(wimpi_wiki#wikiWordWithPrefix(word, "DIR"))
      endif

      " If clicked with CTRL open in NerdTee
      if(a:withCTRL)
        execute 'NERDTree ' . fnameescape(wimpi_wiki#wikiWordWithPrefix(word, "DIR"))
      else
        silent execute "!open " . fnameescape(wimpi_wiki#wikiWordWithPrefix(word, "DIR"))
      endif

    elseif(wimpi_wiki#wikiWordHasPrefix(word , "FILE"))
      silent execute "!open " . fnameescape(wimpi_wiki#wikiWordWithPrefix(word, "FILE"))

    elseif(wimpi_wiki#wikiWordHasPrefix(word , "SHELL"))
      execute "!" . wimpi_wiki#wikiWordWithPrefix(word, "SHELL")
    else

      let strCmd = ""
      let fileLines = []

      " If clicked with CTRL Copy FrontMatter
      if(a:withCTRL)
        if(getline(1) == '---')
          let ok = cursor(1, 1)

          let frontmatterEnd = search('---', '', line("w$"))
          if (frontmatterEnd > 0)
            let fileLines = getbufline(bufnr('%'), 1, frontmatterEnd)
            call add(fileLines, "")
          endif
        end
      endif

      let fileName = wimpi_wiki#GetLink()
      if (empty(fileName))

        let fileName = wimpi_wiki#WordFilename(word)

        "Write title to the new document if file not exist
        if(wimpi_wiki#FileExist(wimpi_wiki#FilePath(fileName)) != 1)

          let fileLines = wimpi_wiki#GenerateFirstContent(word,fileLines)

          if writefile(fileLines, wimpi_wiki#FilePath(fileName))
            echomsg 'write error'
          endif

          "let strCmd = 'normal!\ a'.escape(word, ' \').'\<esc>yypv$r=o\<cr>'
        endif
      endif

      let link = wimpi_wiki#FilePath(fileName)

      let openCmd='edit'
      if(a:openInNewTab)
        let openCmd='tabnew'
      end
      exec openCmd . ' +execute\ "' . escape(strCmd, ' "\') . '" ' . link

    endif
  endif

endfunction

"Shift+Return to return to the previous buffer
function! wimpi_wiki#Return()
  exec 'buffer #'
  let ok = cursor(s:lastPosLine, s:lastPosCol)
endfunction
