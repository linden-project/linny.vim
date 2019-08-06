"======================================================================
"
" wimpimenu.vim -
"
" Inspired by QuickMenu of skywind
" Last change: 2017/08/08 15:20:20
"
"======================================================================

" vim: set noet fenc=utf-8 ff=unix sts=4 sw=4 ts=4 :


"----------------------------------------------------------------------
" Global Options
"----------------------------------------------------------------------
if !exists('g:wimpimenu_max_width')
  let g:wimpimenu_max_width = 50
endif

if !exists('g:wimpimenu_padding_left')
  let g:wimpimenu_padding_left = 3
endif

if !exists('g:wimpimenu_padding_right')
  let g:wimpimenu_padding_right = 3
endif

if !exists('g:wimpimenu_options')
  let g:wimpimenu_options = 'T'
endif

if !exists('g:wimpitabnr')
  let g:wimpitabnr = 1
endif

if !exists('g:wimpi_debug')
  let g:wimpi_debug = 0
endif

let g:wimpimenu_version = 'Wimpi ' . wimpi#PluginVersion()

let t:wimpimenu_items = {}
let t:wimpimenu_mid = 0
let t:wimpimenu_header = {}
let t:wimpimenu_cursor = {}
"let t:wimpimenu_name = ''
let t:wimpimenu_line = 0
let t:wimpimenu_lastmaxsize = 0
let t:wimpimenu_taxo_term = ""
let t:wimpimenu_taxo_val = ""

"augroup WimpiMenuTabInit
"  autocmd!
"  autocmd VimEnter,TabEnter * call wimpimenu#tabInitState()
"augroup END


"----------------------------------------------------------------------
" Internal State
"----------------------------------------------------------------------
function! wimpimenu#tabInitState()
  if !exists('t:wimpimenu_name')
    let t:wimpimenu_items = {}
    let t:wimpimenu_mid = 0
    let t:wimpimenu_header = {}
    let t:wimpimenu_cursor = {}
    let t:wimpimenu_name = '[wimpimenu]'.string(NewWimpiTabNr())
    let t:wimpimenu_line = 0
    let t:wimpimenu_lastmaxsize = 0
    let t:wimpimenu_taxo_term = ""
    let t:wimpimenu_taxo_val = ""
  endif
endfunction

function! NewWimpiTabNr()
  let g:wimpitabnr = g:wimpitabnr + 1
  return g:wimpitabnr
endfunction


"----------------------------------------------------------------------
" popup window management
"----------------------------------------------------------------------
function! Window_exist()
  if !exists('t:wimpimenu_bid')
    let t:wimpimenu_bid = -1
    return 0
  endif
  return t:wimpimenu_bid > 0 && bufexists(t:wimpimenu_bid)
endfunc

function! Window_close()

  if !exists('t:wimpimenu_bid')
    return 0
  endif

  if &buftype == 'nofile' && &ft == 'wimpimenu'
    if bufname('%') == t:wimpimenu_name
      silent close!
      let t:wimpimenu_bid = -1
    endif
  endif

  if t:wimpimenu_bid > 0 && bufexists(t:wimpimenu_bid)
    silent exec 'bwipeout ' . t:wimpimenu_bid
    let t:wimpimenu_bid = -1
  endif

  redraw | echo "" | redraw

endfunc

function! Window_open(size)

  echom a:size

  if Window_exist()
    call Window_close()
  endif

  let size = a:size
  let size = (size < 4)? 4 : size
  let size = (size > g:wimpimenu_max_width)? g:wimpimenu_max_width : size
  if size > winwidth(0)
    let size = winwidth(0) - 1
    if size < 4
      let size = 4
    endif
  endif
  let savebid = bufnr('%')
  if stridx(g:wimpimenu_options, 'T') < 0
    exec "silent! rightbelow ".size.'vne '.t:wimpimenu_name
  else
    exec "silent! leftabove ".size.'vne '.t:wimpimenu_name
  endif
  if savebid == bufnr('%')
    return 0
  endif

  setlocal buftype=nofile bufhidden=wipe nobuflisted nomodifiable
  setlocal noshowcmd noswapfile nowrap nonumber
  setlocal nolist colorcolumn= nocursorline nocursorcolumn
  setlocal noswapfile norelativenumber

  if has('signs') && has('patch-7.4.2210')
    setlocal signcolumn=no
  endif

  if has('spell')
    setlocal nospell
  endif

  if has('folding')
    setlocal fdc=0
  endif

  let t:wimpimenu_bid = bufnr('%')
  return 1
endfunc

function! wimpimenu#recent_files()
  let files = []
  let files = systemlist('ls -1t ~/Dropbox/Apps/KiwiApp/wiki | grep -ve "^index.*" | head -5')
  return files
endfunction

function! wimpimenu#starred_terms()
  let terms = wimpi#parse_json_file(g:wimpi_index_path . '/_index_term_values_starred.json', [])
  return terms
endfunction

function! wimpimenu#starred_docs()
  let docs = wimpi#parse_json_file(g:wimpi_index_path . '/_index_docs_starred.json', [])
  return docs
endfunction

function! wimpimenu#partialFilesListing(files_list, sort)

  let titles = wimpi#titlesForDocs(a:files_list)

  if a:sort
    let title_keys = sort(keys(titles))
  else
    let title_keys = keys(titles)
  endif

  for tk in title_keys
    call wimpimenu#append("" . tk, ":botright vs ". $HOME ."/Dropbox/Apps/KiwiApp/wiki/".titles[tk], "...")
  endfor

endfunction

function! wimpimenu#menu_1st_level()

  call wimpimenu#reset()

  call wimpimenu#append("# STARRED DOCS", '')
  let starred = wimpimenu#starred_docs()
  call wimpimenu#partialFilesListing( starred, 1 )

  call wimpimenu#append("# STARRED LEAFS", '')
  let starred = wimpimenu#starred_terms()
  let starred_list = {}

  for i in starred
    let starred_list[i['term'].','.i['val']] = i
  endfor

  for sk in sort(keys(starred_list))
    call wimpimenu#append("" . wimpimenu#string_capitalize(starred_list[sk]['term']) ." : " . starred_list[sk]['val'] , ":call wimpimenu#openterm(0,'".starred_list[sk]['term']."','".starred_list[sk]['val']."')", "...")
  endfor

  call wimpimenu#append("# INDEX", '')
  call wimpimenu#append("Alfabetisch", ":botright vs ". $HOME ."/Dropbox/Apps/KiwiApp/wiki/index.md", "...")

  let index_keys_list = wimpi#parse_json_file(g:wimpi_index_path . '/_index_keys.json', [])
  for k in index_keys_list
    let term_config = wimpimenu#index_term_config(k)
    if has_key(term_config, 'top_level')
      let top_level = get(term_config, 'top_level')
      if top_level
        call wimpimenu#append("Index: " . k, ":call wimpimenu#openterm(0,'".k."','')", "...")
      endif
    end
  endfor

  call wimpimenu#append("# RECENT", '')
  let recent = wimpimenu#recent_files()
  call wimpimenu#partialFilesListing( recent , 0 )

  call wimpimenu#append("# CONFIGURATION", '')
  call wimpimenu#append("index configuration", ":botright vs ". $HOME ."/Dropbox/Apps/KiwiApp/config/wiki_indexes.yml", "...")

endfunction

function! wimpimenu#menu_2nd_level(term)

  call wimpimenu#reset()
  call wimpimenu#append("# " . toupper(a:term), '')

  call wimpimenu#append(".." , ":call wimpimenu#openterm(0,'','')", "...")

  let termslist = wimpi#parse_json_file(g:wimpi_index_path . '/index_'.a:term.'.json', [])

  for k in sort(termslist)

    call wimpimenu#append( a:term. ": " . k, ":call wimpimenu#openterm(0,'".a:term."','".k."')", "...")
  endfor
endfunction


function! wimpimenu#index_term_config(term)
  if has_key(g:wimpi_index_config, 'index_keys')
    let index_keys = get(g:wimpi_index_config,'index_keys')
    if has_key(index_keys, a:term)
      let term_config = get(index_keys, a:term)
      return term_config
    endif
  endif

  return {}

endfunction

function! wimpimenu#debug_info()

      call wimpimenu#append("### " . wimpimenu#string_capitalize('debug'), '')
      call wimpimenu#append("t:wimpimenu_lastmaxsize = ".t:wimpimenu_lastmaxsize,'')
      call wimpimenu#append("t:wimpimenu_mid = ".t:wimpimenu_mid,'')
      call wimpimenu#append("t:wimpimenu_name = ".t:wimpimenu_name,'')
      call wimpimenu#append("t:wimpimenu_taxo_term = ".t:wimpimenu_taxo_term,'')
      call wimpimenu#append("t:wimpimenu_taxo_val = ".t:wimpimenu_taxo_val,'')

endfunction


function! wimpimenu#menu_3rd_level(term, value)

  let term_plural = a:term
  let infotext =''
  let group_by =''

  let term_config = wimpimenu#index_term_config(a:term)
  if has_key(term_config, 'plural')
    let term_plural = get(term_config, 'plural')
  end


"  let confFileName = $HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".a:term.'_'.a:value.'.yml'
"  let config = wimpi#parse_yaml_to_dict(confFileName)

  call wimpimenu#reset()
  call wimpimenu#append("# " . toupper(a:term) . ' : ' . toupper(a:value), '')

  let config = wimpimenu#termValueLeafConfig(a:term, a:value)
  if has_key(config, 'infotext')
    let infotext =  get(config,'infotext')
    call wimpimenu#append(infotext, '')
    call wimpimenu#append("", '')
  endif

  call wimpimenu#append(".. (". term_plural .")" , ":call wimpimenu#openterm(0,'".a:term."','')", "...")

  let files_in_menu = wimpi#parse_json_file(g:wimpi_index_path . '/index_'.a:term.'_'.a:value.'.json',[])

  if has_key(config, 'group_by')
    let group_by =  get(config,'group_by')
    let files_index = wimpi#parse_json_file(g:wimpi_index_path . '/_index_docs_with_keys.json',[])

    let files_menu = {}
    for k in files_in_menu
      if has_key(files_index[k], group_by)
        let group_by_val =  tolower(get(files_index[k], group_by))

        if !has_key(files_menu,group_by_val)
          let files_menu[group_by_val] = []
        end

        call add(files_menu[group_by_val], k)
        call add(files_menu[group_by_val], k)

      else
        if !has_key(files_menu,'other')
          let files_menu['other'] = []
        end

        call add(files_menu['other'], k)

      endif

    endfor

    for group in sort(keys(files_menu))
      call wimpimenu#append("### " . wimpimenu#string_capitalize(group), '')
      call wimpimenu#partialFilesListing( files_menu[group], 1 )
    endfor

  else

    call wimpimenu#partialFilesListing( files_in_menu, 1 )
  endif

  if has_key(config, 'locations')
    let locations = get(config,'locations')
    if(type(locations)==4)
      call wimpimenu#append("### " . toupper('Locaties'), '')

      for l in keys(locations)
        call wimpimenu#append("" . l, ":!open '". get(locations,l)."'", "...")
      endfor
    endif

  endif

  call wimpimenu#append("### " . toupper('Configuration'), '')
  if has_key(config, 'config')
    call wimpimenu#append("Open ". a:term." ".a:value." Config", ":botright vs ". $HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".a:term.'_'.a:value.'.yml', "...")
  else
    call wimpimenu#append("Create ". a:term." ".a:value." Config", "createtaxoqualiconfig", "...")
  endif

endfunc



"----------------------------------------------------------------------
" menu operation
"----------------------------------------------------------------------

function! wimpimenu#reset()
  let t:wimpimenu_items[t:wimpimenu_mid] = []
  let t:wimpimenu_line = 0
  let t:wimpimenu_cursor[t:wimpimenu_mid] = 0
endfunc

function! wimpimenu#append(text, event, ...)
  let help = (a:0 >= 1)? a:1 : ''
  let filetype = (a:0 >= 2)? a:2 : ''
  let weight = (a:0 >= 3)? a:3 : 0
  let item = {}
  let item.mode = 0
  let item.event = a:event
  let item.text = a:text
  let item.key = ''
  let item.ft = []
  let item.weight = weight
  let item.help = help
  if a:event != ''
    let item.mode = 0
  elseif a:text[0] != '#'
    let item.mode = 1
  else
    let item.mode = 2
    let item.text = matchstr(a:text, '^#\+\s*\zs.*')
  endif
  for ft in split(filetype, ',')
    let item.ft += [substitute(ft, '^\s*\(.\{-}\)\s*$', '\1', '')]
  endfor
  let index = -1
  if !has_key(t:wimpimenu_items, t:wimpimenu_mid)
    let t:wimpimenu_items[t:wimpimenu_mid] = []
  endif
  let items = t:wimpimenu_items[t:wimpimenu_mid]
  let total = len(items)
  for i in range(0, total - 1)
    if weight < items[i].weight
      let index = i
      break
    endif
  endfor
  if index < 0
    let index = total
  endif
  call insert(items, item, index)
  return index
endfunc


function! wimpimenu#current(mid)
  let t:wimpimenu_mid = a:mid
endfunc


function! wimpimenu#header(header)
  let t:wimpimenu_header[t:wimpimenu_mid] = a:header
endfunc


function! wimpimenu#list()
  for item in t:wimpimenu_items[t:wimpimenu_mid]
    echo item
  endfor
endfunc



"----------------------------------------------------------------------
" wimpimenu interface
"----------------------------------------------------------------------

function! wimpimenu#openterm(mid, taxo_term, taxo_value) abort
  let t:wimpimenu_taxo_term = a:taxo_term
  let t:wimpimenu_taxo_val = a:taxo_value
  call wimpimenu#openandshow(a:mid)
endfunction

function! wimpimenu#openandshow(mid) abort

  if t:wimpimenu_taxo_term!="" && t:wimpimenu_taxo_val!=""
    call wimpimenu#menu_3rd_level(t:wimpimenu_taxo_term, t:wimpimenu_taxo_val)

  elseif t:wimpimenu_taxo_term!="" && t:wimpimenu_taxo_val==""
    call wimpimenu#menu_2nd_level(t:wimpimenu_taxo_term)

  elseif t:wimpimenu_taxo_term=="" && t:wimpimenu_taxo_val==""
    call wimpimenu#menu_1st_level()

  endif

  if g:wimpi_debug
    call wimpimenu#debug_info()
  endif

  " select and arrange menu
  let items = Select_by_ft(a:mid, &ft)
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = Menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:wimpimenu_padding_right
  let t:wimpimenu_lastmaxsize = maxsize

  if 1
    call Window_open(maxsize)
    call Window_render(content, a:mid)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc

function! wimpimenu#close()
  if Window_exist()
    call Window_close()
    return 0
  endif
endfunction

function! wimpimenu#open()
  if !Window_exist()
    call wimpimenu#tabInitState()
    call wimpimenu#openandshow(0)
  endif
endfunction

function! wimpimenu#toggle(mid) abort
  if Window_exist()
    call Window_close()
    return 0
  endif

  " select and arrange menu
  let items = Select_by_ft(a:mid, &ft)
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = Menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:wimpimenu_padding_right

  if 1
    call Window_open(maxsize)
    call Window_render(content, a:mid)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc



"----------------------------------------------------------------------
" render text
"----------------------------------------------------------------------
function! Window_render(items, mid) abort
  setlocal modifiable
  let ln = 2
  let t:wimpimenu = {}
  let t:wimpimenu.mid = a:mid
  let t:wimpimenu.padding_size = g:wimpimenu_padding_left
  let t:wimpimenu.option_lines = []
  let t:wimpimenu.section_lines = []
  let t:wimpimenu.text_lines = []
  let t:wimpimenu.header_lines = []
  for item in a:items
    let item.ln = ln
    call append('$', item.text)
    if item.mode == 0
      let t:wimpimenu.option_lines += [ln]
    elseif item.mode == 1
      let t:wimpimenu.text_lines += [ln]
    elseif item.mode == 2
      let t:wimpimenu.section_lines += [ln]
    else
      let t:wimpimenu.header_lines += [ln]
    endif
    let ln += 1
  endfor
  setlocal nomodifiable readonly
  setlocal ft=wimpimenu
  let t:wimpimenu.items = a:items
  let opt = g:wimpimenu_options

  if stridx(opt, 'L') >= 0
    setlocal cursorline
  endif
endfunc


"----------------------------------------------------------------------
" all keys
"----------------------------------------------------------------------
function! Setup_keymaps(items)

  let ln = 0
  let mid = t:wimpimenu.mid
  let cursor_pos = get(t:wimpimenu_cursor, mid, 0)
  let nowait = ''

  if v:version >= 704 || (v:version == 703 && has('patch1261'))
    let nowait = '<nowait>'
  endif

  for item in a:items
    if item.key != ''
      let cmd = ' :call <SID>wimpimenu_execute('.ln.')<cr>'
      exec "noremap <buffer>".nowait."<silent> ".item.key. cmd
    endif
    let ln += 1
  endfor

  " noremap <silent> <buffer> 0 :call <SID>wimpimenu_close()<cr>
  " noremap <silent> <buffer> q :call <SID>wimpimenu_close()<cr>
  noremap <silent> <buffer> <CR> :call <SID>wimpimenu_enter()<cr>
  let t:wimpimenu_line = 0
  if cursor_pos > 0
    call cursor(cursor_pos, 1)
  endif
  let t:wimpimenu.showhelp = 0
  call Set_cursor()
  augroup wimpimenu
    autocmd CursorMoved <buffer> call Set_cursor()
    autocmd InsertEnter <buffer> call feedkeys("\<ESC>")
  augroup END

  let t:wimpimenu.showhelp = (stridx(g:wimpimenu_options, 'H') >= 0)? 1 : 0

endfunc


"----------------------------------------------------------------------
" reset cursor
"----------------------------------------------------------------------
function! Set_cursor() abort
  let curline = line('.')
  let lastline = t:wimpimenu_line
  let movement = (curline < lastline)? -1 : 1
  let find = -1
  let size = len(t:wimpimenu.items)
  while 1
    let index = curline - 2
    if index < 0 || index >= size
      break
    endif
    let item = t:wimpimenu.items[index]
    if item.mode == 0 && item.event != ''
      let find = index
      break
    endif
    let curline += movement
  endwhile
  if find < 0
    let curline = line('.')
    let curdiff = abs(curline - t:wimpimenu.option_lines[0])
    let select = t:wimpimenu.option_lines[0]
    for line in t:wimpimenu.option_lines
      let newdiff = abs(curline - line)
      if newdiff < curdiff
        let curdiff = newdiff
        let select = line
      endif
    endfor
    let find = select - 2
  endif
  if find < 0
    echohl ErrorMsg
    echo "fatal error in Set_cursor() ".find
    echohl None
    return
  endif
  let t:wimpimenu_line = find + 2
  call cursor(t:wimpimenu_line, g:wimpimenu_padding_left + 2)

  if t:wimpimenu.showhelp
    let help = t:wimpimenu.items[find].help
    let key = t:wimpimenu.items[find].key
    echohl wimpimenuHelp
    if help != ''
      call Cmdmsg('['.key.']: '.help, 'wimpimenuHelp')
    else
      echo ''
    endif
    echohl None
  endif
endfunc


"----------------------------------------------------------------------
" close wimpimenu
"----------------------------------------------------------------------
function! <SID>wimpimenu_close()
  close
  redraw | echo "" | redraw
endfunc


"----------------------------------------------------------------------
" execute selected
"----------------------------------------------------------------------
function! <SID>wimpimenu_enter() abort
  let ln = line('.')
  call <SID>wimpimenu_execute(ln - 2)
endfunc


"----------------------------------------------------------------------
" execute item
"----------------------------------------------------------------------
function! <SID>wimpimenu_execute(index) abort
  if a:index < 0 || a:index >= len(t:wimpimenu.items)
    return
  endif
  let item = t:wimpimenu.items[a:index]

  if item.mode != 0 || item.event == ''
    return
  endif

  let t:wimpimenu_line = a:index + 2
  let t:wimpimenu_cursor[t:wimpimenu.mid] = t:wimpimenu_line

  redraw | echo "" | redraw

    " als event een string is
    if type(item.event) == 1

      if(item.event == 'close')
        close!

      elseif(item.event == 'refresh')
        call wimpimenu#openandshow(0)

      elseif(item.event == 'hardrefresh')
        call wimpi#Init()
        call wimpi#make_index()
        call wimpimenu#openandshow(0)

      elseif(item.event == 'home')
        call wimpimenu#openterm(0,'','')

      elseif(item.event == 'createtaxoqualiconfig')

        let confFileName = $HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".t:wimpimenu_taxo_term.'_'.t:wimpimenu_taxo_val.'.yml'

        let fileLines = []
        call add(fileLines, '---')
        call add(fileLines, 'config: true')
        call add(fileLines, 'infotext: About '. t:wimpimenu_taxo_val)
        call add(fileLines, 'group_by: type')
        call add(fileLines, 'locations:')
        call add(fileLines, '  #website: https://www.'.t:wimpimenu_taxo_val.'.vim')
        call add(fileLines, '  #dir1: file:///Applications/')
        call add(fileLines, '  #file1: file:///Projects/file1.someformat')

        if writefile(fileLines, confFileName)
          echomsg 'write error'
        else
          exec ':only'
          let currentwidth = t:wimpimenu_lastmaxsize
          let currentWindow=winnr()
          execute ":botright vs ". confFileName
          let newWindow=winnr()

          exec currentWindow."wincmd w"
          setlocal foldcolumn=0
          exec "vertical resize " . currentwidth
          exec currentWindow."call wimpimenu#openandshow(0)"
          exec newWindow."wincmd w"

        endif

"      elseif(item.event == 'newdiringroup')
"
"        call inputsave()
"        let name = input('Enter directory name: ', t:wimpimenu_taxo_term .'_'. t:wimpimenu_taxo_val)
"        call inputrestore()
"
"        echo name
"
"        if(!empty(name))
"
"          let newdir = wimpi#new_dir(name)
"
"          if(!empty(newdir))
""            let confFileName = $HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".t:wimpimenu_taxo_term.'_'.t:wimpimenu_taxo_val.'.yml'
""            let config = wimpi#parse_yaml_to_dict(confFileName)
"            let config = wimpimenu#termValueLeafConfig(t:wimpimenu_taxo_term, t:wimpimenu_taxo_val)
"
"            if has_key(config, 'locations')
"              let locations = get(config,'locations')
"              if(type(locations)!=4)
"              let locations = {}
"              endif
"              let locations['dir'] = "file://".newdir
"              let config['locations'] = locations
"
"              let vimjson = []
"              call add(vimjson, json_encode(config))
"
"              if writefile(vimjson, '/tmp/vimjsonconvert')
"                echomsg 'write error'
"              endif
"
"              call system("ruby -ryaml -rjson -e 'puts YAML.dump(JSON.load(ARGF))' < /tmp/vimjsonconvert > " . confFileName)
"
"            endif
"          else
"            echo "could not create directory"
"
"          endif
"
"        else
"          return 0
"        endif

      elseif(item.event == 'newdocingroup')

        call inputsave()
        let name = input('Enter document name: ')
        call inputrestore()

        echo name
        if(!empty(name))
          call wimpimenu#new_document_in_leaf(name)
        else
          return 0
        endif

      elseif item.event[0] != '='
        if item.event =~ "wimpimenu#openterm"
          exec item.event
        elseif item.event =~ "!open"
          if item.event =~ "file:///"
            let dirstring = split(item.event, "file://")

            if !filereadable(dirstring[1])
              exe  "!mkdir -p '".dirstring[1]
            endif
          endif

          silent exec item.event
        else

          let currentwidth = t:wimpimenu_lastmaxsize
          let currentWindow=winnr()

          exec ':only'
          exec item.event
          let newWindow=winnr()

          exec currentWindow."wincmd w"
          setlocal foldcolumn=0
          exec "vertical resize " . currentwidth
          exec newWindow."wincmd w"

        endif
      else
      "  let script = matchstr(item.event, '^=\s*\zs.*')
      endif

    " als event een functie is
    elseif type(item.event) == 2

      call item.event()

    endif

endfunc

function! wimpimenu#termValueLeafConfig(term, val)
  let config = wimpi#parse_yaml_to_dict($HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".a:term.'_'.a:val.'.yml')
  return config
endfunction

function! wimpimenu#new_document_in_leaf(...)
  let title = join(a:000)
  let fileName = wimpi#MdwiWordFilename(title)
  let relativePath = fnameescape($HOME . '/Dropbox/Apps/KiwiApp/wiki/' . fileName)

  if !filereadable(relativePath)
    let taxo_term = ''
    let taxo_val = ''

    let taxoEntries = []
    if t:wimpimenu_taxo_term != "" && t:wimpimenu_taxo_val != ""
      let entry = {}
      let entry['term'] = t:wimpimenu_taxo_term
      let entry['value'] = t:wimpimenu_taxo_val
      call add(taxoEntries, entry)

      let config = wimpimenu#termValueLeafConfig(t:wimpimenu_taxo_term, t:wimpimenu_taxo_val)
      if has_key(config, 'frontmatter_template')
        let fm_template = get(config,'frontmatter_template')
        if(type(fm_template)==4)
          for fm_key in keys(fm_template)
            let entry = {}
            let entry['term'] = fm_key
            let entry['value'] = get(fm_template,fm_key)
            call add(taxoEntries, entry)
          endfor
        endif
      endif
    endif

    let fileLines = wimpi#generate_first_content(title, taxoEntries)
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


"----------------------------------------------------------------------
" select items by &ft, generate keymap and add some default items
"----------------------------------------------------------------------
function! Select_by_ft(mid, ft) abort
  " R = refresh
  " A = newdocingroup
  " U = hardrefresh

  let hint = '123456789abcdefhilmnoprstuvwxyzCIOPQSUX*'

  let items = []
  let index = 0
  let header = get(t:wimpimenu_header, a:mid, g:wimpimenu_version)

  if header != ''
    let ni = {'mode':3, 'text':'', 'event':'', 'help':''}
    let ni.text = header
    let items += [ni]
    let ni = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [ni]
  endif

  let lastmode = 2
  for item in get(t:wimpimenu_items, a:mid, [])
    if len(item.ft) && index(item.ft, a:ft) < 0
      continue
    endif
    if item.mode == 2 && lastmode != 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
    let lastmode = item.mode
    " allocate key for non-filetype specific items
    if item.mode == 0 && len(item.ft) == 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
    let items += [item]
    if item.mode == 2
      " insert empty line
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
  endfor

  " allocate key for filetype specific items
  for item in items
    if item.mode == 0 && len(item.ft) > 0
      let item.key = hint[index]
      let index += 1
      if index >= strlen(hint)
        let index = strlen(hint) - 1
      endif
    endif
  endfor

  if len(items)
    let item = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [item]
  endif

  if t:wimpimenu_taxo_term !="" && t:wimpimenu_taxo_val !=""
    let item = {}
    let item.mode = 0
    let item.text = '<new document>'
    let item.event = 'newdocingroup'
    let item.key = 'A'
    let item.help = ''
    let items += [item]

"    let ni = {'mode':1, 'text':'', 'event':''}

"   let confFileName = $HOME ."/Dropbox/Apps/KiwiApp/config/cnf_idx_".t:wimpimenu_taxo_term.'_'.t:wimpimenu_taxo_val.'.yml'
"   if filereadable(confFileName)
"     let item = {}
"     let item.mode = 0
"     let item.text = '<new directory>'
"     let item.event = 'newdiringroup'
"     let item.key = 'D'
"     let item.help = ''
"     let items += [item]
"   endif

  endif

  if t:wimpimenu_taxo_term != ""
    let item = {}
    let item.mode = 0
    let item.text = '<home>'
    let item.event = 'home'
    let item.key = '0'
    let item.help = ''
    let items += [item]
  endif

  let item = {}
  let item.mode = 0
  let item.text = '<hard refresh>'
  let item.event = 'hardrefresh'
  let item.key = 'H'
  let item.help = ''
  let items += [item]

  let item = {}
  let item.mode = 0
  let item.text = '<refresh>'
  let item.event = 'refresh'
  let item.key = 'R'
  let item.help = ''
  let items += [item]

  return items

endfunc

"----------------------------------------------------------------------
" expand menu items
"----------------------------------------------------------------------
function! Menu_expand(item) abort
  let items = []
  let text = Expand_text(a:item.text)
  let help = ''
  let index = 0
  let padding = repeat(' ', g:wimpimenu_padding_left)
  if a:item.mode == 0
    let help = Expand_text(get(a:item, 'help', ''))
  endif
  for curline in split(text, "\n", 1)
    let item = {}
    let item.mode = a:item.mode
    let item.text = curline
    let item.event = ''
    let item.key = ''
    if item.mode == 0
      if index == 0
        let item.text = '[' . a:item.key.']  '.curline
        let index += 1
        let item.key = a:item.key
        let item.event = a:item.event
        let item.help = help
      else
        let item.text = '     '.curline
      endif
    endif
    if len(item.text)
      let item.text = padding . item.text
    endif
    let items += [item]
  endfor
  return items
endfunc


"----------------------------------------------------------------------
" eval & expand: '%{script}' in string
"----------------------------------------------------------------------
function! Expand_text(string) abort
  let partial = []
  let index = 0
  while 1
    let pos = stridx(a:string, '%{', index)
    if pos < 0
      let partial += [strpart(a:string, index)]
      break
    endif
    let head = ''
    if pos > index
      let partial += [strpart(a:string, index, pos - index)]
    endif
    let endup = stridx(a:string, '}', pos + 2)
    if endup < 0
      let partial += [strpart(a:stirng, index)]
      break
    endif
    let index = endup + 1
    if endup > pos + 2
      let script = strpart(a:string, pos + 2, endup - (pos + 2))
      let script = substitute(script, '^\s*\(.\{-}\)\s*$', '\1', '')
      let result = eval(script)
      let partial += [result]
    endif
  endwhile
  return join(partial, '')
endfunc


"----------------------------------------------------------------------
" string limit
"----------------------------------------------------------------------
function! Slimit(text, limit, col)
  if a:limit <= 1
    return ""
  endif
  let size = strdisplaywidth(a:text, a:col)
  if size < a:limit
    return a:text
  endif
  if strlen(a:text) == size || has('patch-7.4.2000') == 0
    return strpart(a:text, 0, a:limit - 1)
  endif
  let text = strcharpart(a:text, 0, a:limit)
  let size = strchars(text)
  while 1
    if strdisplaywidth(text, a:col) < a:limit
      return text
    endif
    let step = size / 8
    let test = size - step
    if step > 3 && test > 16
      let demo = strcharpart(text, 0, test)
      if strdisplaywidth(demo, a:col) > a:limit
        let text = demo
        let size = test
        continue
      endif
    endif
    let size = size - 1
    let text = strcharpart(text, 0, size)
  endwhile
endfunc


"----------------------------------------------------------------------
" show cmd message
"----------------------------------------------------------------------
function! Cmdmsg(content, highlight)
  let wincols = &columns
  let statusline = (&laststatus==1 && winnr('$')>1) || (&laststatus==2)
  let reqspaces_lastline = (statusline || !&ruler) ? 12 : 29
  let width = strdisplaywidth(a:content)
  let limit = wincols - reqspaces_lastline
  let l:content = a:content
  if width >= limit
    let l:content = Slimit(l:content, limit, 0)
    let width = strdisplaywidth(l:content)
  endif
  redraw
  if a:highlight != ''
    exec "echohl ". a:highlight
    echo l:content
    echohl NONE
  else
    echo l:content
  endif
endfunc


"----------------------------------------------------------------------
" echo a error msg
"----------------------------------------------------------------------
function! Errmsg(msg)
  echohl ErrorMsg
  echo a:msg
  echohl None
endfunc


"----------------------------------------------------------------------
" echo highlight
"----------------------------------------------------------------------
function! Highlight(standard, startify)
  exec "echohl ". (hlexists(a:startify)? a:startify : a:standard)
endfunc

function! wimpimenu#string_capitalize(capstring)
  return toupper(strpart(a:capstring, 0, 1)).strpart(a:capstring,1)
endfunction


"----------------------------------------------------------------------
" testing case
"----------------------------------------------------------------------
if 1

  call wimpimenu#reset()
  call wimpimenu#append('# Start', '')
  call wimpimenu#append('test1', 'echo 1', 'help 1')
  call wimpimenu#append('test2', 'echo 2', 'help 2')

  call wimpimenu#append('# Misc', '')
  call wimpimenu#append('test3', 'echo 3')
  call wimpimenu#append('test4', 'echo 4')
  call wimpimenu#append("test5\nasdfafffff\njkjkj", 'echo 5')
  call wimpimenu#append('text1', '')
  call wimpimenu#append('text2', '')

  " nnoremap <F12> :call wimpimenu#toggle(0)<cr>
  " imap <expr> <F11> wimpimenu#bottom(0)
endif






