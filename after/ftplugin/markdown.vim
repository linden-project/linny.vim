function! MarkdownFold()
  let line = getline(v:lnum)

  " Regular headers
  let depth = match(line, '\(^#\+\)\@<=\( .*$\)\@=')
  if depth > 0
    return ">" . depth
  endif

  " Setext style headings
  let prevline = getline(v:lnum - 1)
  let nextline = getline(v:lnum + 1)
  if (line =~ '^.\+$') && (nextline =~ '^=\+$') && (prevline =~ '^\s*$')
    return ">1"
  endif

  if (line =~ '^.\+$') && (nextline =~ '^-\+$') && (prevline =~ '^\s*$')
    return ">2"
  endif

  " frontmatter
  if (v:lnum == 1) && (line =~ '^----*$')
    return ">1"
  endif

  return "="
endfunction

function! s:initVariable(var, value)
    if !exists(a:var)
        exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
        return 1
    endif
    return 0
endfunction

"Initialize variables
call s:initVariable("s:footer", "_Footer")
call s:initVariable("s:sidebar", "_Sidebar")
call s:initVariable("s:startWord", '[[')
call s:initVariable("s:endWord", ']]')
call s:initVariable("s:startLink", '(')
call s:initVariable("s:endLink", ')')
call s:initVariable("s:lastPosLine", 0)
call s:initVariable("s:lastPosCol", 0)
call s:initVariable("s:spaceReplaceChar", '_')

" *********************************************************************
" *                      Utilities
" *********************************************************************

function! MdwiFileExist(relativePath)

  if filereadable(a:relativePath)
    return 1
  endif

  return 0

endfunction

function! MdwiStrBetween(startStr, endStr)
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

function! MdwiGetIndentationStep()
  call cursor(1,1)
  call search('^\s')
  return indent(".")
endfunction

function! MdwiAddParentKeys()
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

function! MdwiYamlKeyUnderCursor()
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
"        let s:indentationStep = MdwiGetIndentationStep()
"        let s:currentIndent = indent(s:inputLineNumber)
"
"        :call MdwiAddParentKeys()
"        :call reverse(s:keys)
"
"        :call cursor(s:inputLineNumber, s:inputLineCol)
"        return join(s:keys, " > ")
"    else
"        return ""
"    endif
endfunction

function! MdwiYamlValUnderCursor()
    let inputLineNumber = line('.')

    let currentLine = getline(inputLineNumber)
    let currentVal = matchstr(currentLine, '\s*:\s*\zs.\+\ze')

    if !empty(currentLine)
      return currentVal
    else
        return ""
    endif
endfunction

function! MdwiCursorInFrontMatter()

  let origPos = getpos('.')

  if(getline(1) == '---' && line('.') > 1)
    let ok = cursor(1, 1)

    let fmEnd = search('---', '', line("w$"))
    let ok = cursor(origPos[1], origPos[2]) "Return to the original position
    if fmEnd > 0 && fmEnd > line('.')
      return 1
    endif
  end

  return 0

endfunction

if !exists('*MdwiCallFrontMatterLink')
  function! MdwiCallFrontMatterLink()

    let yamlKey = MdwiYamlKeyUnderCursor()
    let yamlVal = MdwiYamlValUnderCursor()

    let indexFileTitle = 'index ' . yamlKey . ' ' . yamlVal
    let fileName = wimpi#MdwiWordFilename(indexFileTitle)

    call wimpimenu#openterm(0, yamlKey, yamlVal)

    "Write title to the new document if file not exist
    "let filePath = MdwiFilePath(fileName)
    "if MdwiFileExist(filePath) == 1
    "  exec 'edit ' . filePath
    "endif





    "search key in configuration
    "let ll = getline(line('.'))
    "get yaml key of current line
    "read yaml value of current line
    "check if current value has index
  endfunction
endif



function! MdwiFilePath(fileName)
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

function! MdwiFindWordPos()
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

function! MdwiGetWord()
  let word = ''
  let wordPos = MdwiFindWordPos()
  if (wordPos != getpos('.'))
    let ok = cursor(wordPos[1], wordPos[2])
    let word = MdwiStrBetween(s:startWord, s:endWord)
  endif
  return word
endfunction

" *********************************************************************
" *                      Links
" *********************************************************************
function! MdwiFindLinkPos()
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

function! MdwiGetLink()
  let link = ''
  "Is there a link defined ?
  let linkPos = MdwiFindLinkPos()
  if (linkPos != getpos('.'))
    let ok = cursor(linkPos[1], linkPos[2])
    let link = MdwiStrBetween(s:startLink, s:endLink)
  endif
  return link
endfunction

" ******** CHECK FOR FILE OR DIR *****************
function! MdwiWordHasFileSystemPathDir(word)
  if a:word =~ "^DIR.*"
    return trim(a:word[3:-1])
  else
    return ""
  endif
endfunction

function! MdwiWordHasFileSystemPathFile(word)
  if a:word =~ "^FILE.*"
    return trim(a:word[4:-1])
  else
    return ""
  endif
endfunction

" ******** Go to link *****************
if !exists('*MdwiGotoLink')
function! MdwiGotoLink()
    call MdwiGotoLinkMain(0,0)
endfunction
endif

" ******** Go to link in new tab *************
if !exists('*MdwiGotoLinkInNewTab')
function! MdwiGotoLinkInNewTab()
    call MdwiGotoLinkMain(0,1)
endfunction
endif

" ******** Go to link main executer *****************
if !exists('*MdwiGotoLinkWithCTRL')
  function! MdwiGotoLinkWithCTRL()
    call MdwiGotoLinkMain(1,0)
  endfunction
endif

function! MdwiGenerateFirstContent(wikiTitle,fileLinesIn)

  if len(a:fileLinesIn) > 0
    let fileLines = a:fileLinesIn
  else
    let fileLines = []
    call add(fileLines, '---')
    call add(fileLines, 'title: "'.a:wikiTitle.'"')
    call add(fileLines, '---')
  endif

  let i = 1
  let h1line = ""
  while i <= len(a:wikiTitle)
    let i += 1
    let h1line = h1line ."="
  endwhile

  call add(fileLines, a:wikiTitle)
  call add(fileLines, h1line)

  return fileLines

endfunction

if !exists('*MdwiGotoLinkMain')
  function! MdwiGotoLinkMain(withCTRL, openInNewTab)

    if MdwiCursorInFrontMatter()
      call MdwiCallFrontMatterLink()
    end


    let s:lastPosLine = line('.')
    let s:lastPosCol = col('.')

    let word = MdwiGetWord()

    if !empty(word)
      if(MdwiWordHasFileSystemPathDir(word)!="")

        if(MdwiFileExist(MdwiFilePath(MdwiWordHasFileSystemPathDir(word))) != 1)
          silent execute "!mkdir " . fnameescape(MdwiWordHasFileSystemPathDir(word))
        endif

        " If clicked with CTRL open in NerdTee
        if(a:withCTRL)
          execute 'NERDTree ' . fnameescape(MdwiWordHasFileSystemPathDir(word))
        else
          silent execute "!open " . fnameescape(MdwiWordHasFileSystemPathDir(word))
        endif

      elseif(MdwiWordHasFileSystemPathFile(word)!="")
          silent execute "!open " . fnameescape(MdwiWordHasFileSystemPathFile(word))
      else

        let strCmd = ""
        let fileLines = []

        " If clicked with CTRL Copy FrontMatter
        if(a:withCTRL)
          if(getline(1) == '---')
            let ok = cursor(1, 1)

            let fmEnd = search('---', '', line("w$"))
            if (fmEnd > 0)
              let fileLines = getbufline(bufnr('%'), 1, fmEnd)
              call add(fileLines, "")
            endif
          end
        endif

        let fileName = MdwiGetLink()
        if (empty(fileName))

          let fileName = wimpi#MdwiWordFilename(word)

          "Write title to the new document if file not exist
          if(MdwiFileExist(MdwiFilePath(fileName)) != 1)

            let fileLines = MdwiGenerateFirstContent(word,fileLines)

            if writefile(fileLines, MdwiFilePath(fileName))
              echomsg 'write error'
            endif

            "let strCmd = 'normal!\ a'.escape(word, ' \').'\<esc>yypv$r=o\<cr>'
          endif
        endif

        let link = MdwiFilePath(fileName)

        let openCmd='edit'
        if(a:openInNewTab)
          let openCmd='tabnew'
        end
        exec openCmd . ' +execute\ "' . escape(strCmd, ' "\') . '" ' . link

      endif
    endif

  endfunction
endif


"command! -buffer MdwiGotoLink call MdwiGotoLink()
"nnoremap <buffer> <script> <Plug>MdwiGotoLink :MdwiGotoLink<CR>
"if !hasmapto('<Plug>MdwiGotoLink')
"  nmap <buffer> <silent> <CR> <Plug>MdwiGotoLink
"endif
"
"command! -buffer MdwiGotoLinkInNewTab call MdwiGotoLinkInNewTab()
"nnoremap <buffer> <script> <Plug>MdwiGotoLinkInNewTab :MdwiGotoLinkInNewTab<CR>
"if !hasmapto('<Plug>MdwiGotoLinkInNewTab')
"  nmap <buffer> <silent> <CR> <Plug>MdwiGotoLinkInNewTab
"endif

"Shift+Return to return to the previous buffer
if !exists('*MdwiReturn')
function! MdwiReturn()
  exec 'buffer #'
  let ok = cursor(s:lastPosLine, s:lastPosCol)
endfunction
endif

command! -buffer MdwiReturn call MdwiReturn()
nnoremap <buffer> <script> <Plug>MdwiReturn :MdwiReturn<CR>
if !hasmapto('<Plug>MdwiReturn')
  nmap <buffer> <silent> <Leader><CR> <Plug>MdwiReturn
endif

