" linny_menu_documents.vim - Document and configuration file operations

" Replace a key value in root frontmatter
function! linny_menu_documents#replace_frontmatter_key(fileLines, key, newvalue)

  let frontmatter_started = 0
  let idx = 0

  let new_lines = []

  for line in a:fileLines

    if frontmatter_started == 0 && line[0:len("---")] == "---"
      let frontmatter_started = 1
    elseif line[0:len("---")] == "---"
      break
    endif

    if frontmatter_started == 1 && line[0:len(a:key.":")-1] == a:key.":"
      let a:fileLines[idx] = a:key . ": " . a:newvalue
      break
    endif

    let idx += 1

  endfor

  return a:fileLines

endfunction

" Copy a document with a new title
function! linny_menu_documents#copy(source_path, new_title)
  let fileName = luaeval("require('linny.wiki').word_to_filename(_A)", a:new_title)
  let relativePath = fnameescape(g:linny_path_wiki_content . '/' . fileName)

  if !filereadable(relativePath) && filereadable(a:source_path)

    let fileLines = readfile(a:source_path)
    let fileLines = linny_menu_documents#replace_frontmatter_key(fileLines, "title", a:new_title)

    if writefile(fileLines, relativePath)
      echomsg 'write error'
    endif

    call linny_menu_documents#open_in_right_pane(relativePath)

  else
    echom "Could not copy document with file path: " . a:source_path
  endif

endfunction

" Open document in right pane preserving menu layout
function! linny_menu_documents#open_in_right_pane(relativePath)
  if bufname('%') =~ "[linny_menu]"
    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    execute ':botright vs '. a:relativePath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"
    setlocal foldcolumn=0
    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute 'e '. a:relativePath
  end
endfunction

" Create new document in current leaf (taxonomy/term)
function! linny_menu_documents#new_in_leaf(...)
  let title = join(a:000)
  let fileName = luaeval("require('linny.wiki').word_to_filename(_A)", title)
  let relativePath = fnameescape(g:linny_path_wiki_content . '/' . fileName)

  if !filereadable(relativePath)
    let taxonomy = ''
    let taxo_term = ''

    let taxoEntries = []
    if t:linny_menu_taxonomy != "" && t:linny_menu_term != ""
      let entry = {}
      let entry['term'] = t:linny_menu_taxonomy
      let entry['value'] = t:linny_menu_term
      call add(taxoEntries, entry)

      let config = linny#term_config(t:linny_menu_taxonomy, t:linny_menu_term)
      if has_key(config, 'frontmatter_template')
        let fm_template = get(config,'frontmatter_template')
        if(type(fm_template)==4)
          for fm_key in keys(fm_template)
            let entry = {}
            let entry['term'] = fm_key
            if get(fm_template,fm_key) == 'v:null'
              let entry['value'] = ''
            else
              let entry['value'] = get(fm_template,fm_key)
            endif

            call add(taxoEntries, entry)
          endfor
        endif
      endif
    endif

    let fileLines = linny#generate_first_content(title, taxoEntries)
    if writefile(fileLines, relativePath)
      echomsg 'write error'
    endif
  endif

  call linny_menu_documents#open_in_right_pane(relativePath)

endfunction

" Archive a L2 (term) config
function! linny_menu_documents#archive_l2_config(taxonomy, taxo_term)
  let confFileName = linny#l2_config_filepath(a:taxonomy, a:taxo_term)
  let fileLines = []
  if filereadable(confFileName)
    let fileLines = readfile(confFileName)
    let fileLines = ['---','archive: true'] + fileLines[1:-1]
  else
    call add(fileLines, '---')
    call add(fileLines, 'title: '.luaeval("require('linny.menu.util').string_capitalize(_A)", a:taxo_term))
    call add(fileLines, 'infotext: About '. a:taxo_term)
    call add(fileLines, 'archive: true')
  endif
  if writefile(fileLines, confFileName)
    echomsg 'write error'
  endif
endfunction

" Create or open a L2 (term) config
function! linny_menu_documents#create_l2_config(taxonomy, taxo_term)
  let confFileName = linny#l2_config_filepath(a:taxonomy, a:taxo_term)

  if filereadable(confFileName)

      exec ':only'
      let currentwidth = t:linny_menu_lastmaxsize
      let currentWindow=winnr()
      execute ":botright vs ". confFileName
      let newWindow=winnr()

      exec currentWindow."wincmd w"
      setlocal foldcolumn=0
      exec "vertical resize " . currentwidth
      exec currentWindow."call linny_menu#openandshow()"
      exec newWindow."wincmd w"

  else
    let fileLines = []

    call add(fileLines, '---')
    call add(fileLines, 'title: '.luaeval("require('linny.menu.util').string_capitalize(_A)", a:taxo_term))
    call add(fileLines, 'infotext: About '. a:taxo_term)
    call add(fileLines, '')
    call add(fileLines, 'archive: false')
    call add(fileLines, 'starred: false')
    call add(fileLines, '')
    call add(fileLines, 'views:')
    call add(fileLines, '  az:')
    call add(fileLines, '    sort: az')
    call add(fileLines, '  date:')
    call add(fileLines, '    sort: date')
    call add(fileLines, '  type:')
    call add(fileLines, '    group_by: type')
    call add(fileLines, '')
    call add(fileLines, '#mounts:')
    call add(fileLines, '  #project docs:')
    call add(fileLines, '    #source: /home/john/projects/some-project')
    call add(fileLines, '    #exclude:')
    call add(fileLines, '      #- README.md')
    call add(fileLines, '')
    call add(fileLines, '#locations:')
    call add(fileLines, '  #website: https://www.'.a:taxo_term.'.vim')
    call add(fileLines, '')
    call add(fileLines, '#frontmatter_template:')
    call add(fileLines, '  #project: prj-x')

    if writefile(fileLines, confFileName)
      echomsg 'write error'
    else
      exec ':only'
      let currentwidth = t:linny_menu_lastmaxsize
      let currentWindow=winnr()
      execute ":botright vs ". confFileName
      let newWindow=winnr()

      exec currentWindow."wincmd w"
      setlocal foldcolumn=0
      exec "vertical resize " . currentwidth
      exec currentWindow."call linny_menu#openandshow()"
      exec newWindow."wincmd w"
    endif
  end

endfunction

" Create or open a L1 (taxonomy) config
function! linny_menu_documents#create_l1_config(taxonomy)
  let confFileName = linny#l1_config_filepath(a:taxonomy)

  let fileLines = []
  call add(fileLines, '---')
  call add(fileLines, 'title: '.luaeval("require('linny.menu.util').string_capitalize(_A)", a:taxonomy))
  call add(fileLines, 'infotext: About '. a:taxonomy)
  call add(fileLines, 'views:')
  call add(fileLines, '  type:')
  call add(fileLines, '    group_by: type')

  if writefile(fileLines, confFileName)
    echomsg 'write error'
  else
    exec ':only'
    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()
    execute ":botright vs ". confFileName
    let newWindow=winnr()

    exec currentWindow."wincmd w"
    setlocal foldcolumn=0
    exec "vertical resize " . currentwidth
    exec currentWindow."call linny_menu#openandshow()"
    exec newWindow."wincmd w"

  endif
endfunction
