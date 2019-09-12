"======================================================================
"
" wimpi_menu.vim
"
" Inspired by QuickMenu of skywind
" Last change: 2017/08/08 15:20:20
"
"======================================================================

"----------------------------------------------------------------------
" Global Options
"----------------------------------------------------------------------

call wimpi_util#initVariable("g:wimpi_menu_max_width", 50)
call wimpi_util#initVariable("g:wimpi_menu_padding_left", 3)
call wimpi_util#initVariable("g:wimpi_menu_padding_right", 3)
call wimpi_util#initVariable("g:wimpi_menu_options", 'T')
call wimpi_util#initVariable("g:wimpitabnr", 1)
call wimpi_util#initVariable("g:wimpi_debug", 0)

let t:wimpi_menu_items = []
let t:wimpi_menu_header = ''
let t:wimpi_menu_footer = ''
let t:wimpi_menu_cursor = 0
let t:wimpi_menu_line = 0
let t:wimpi_menu_lastmaxsize = 0
let t:wimpi_menu_taxo_term = ""
let t:wimpi_menu_taxo_val = ""

"----------------------------------------------------------------------
" Internal State
"----------------------------------------------------------------------
function! wimpi_menu#tabInitState()
  if !exists('t:wimpi_menu_name')
    let t:wimpi_menu_items = []
    let t:wimpi_menu_header = ''
    let t:wimpi_menu_footer = ''
    let t:wimpi_menu_cursor = 0
    let t:wimpi_menu_name = '[wimpi_menu]'.string(NewWimpiTabNr())
    let t:wimpi_menu_line = 0
    let t:wimpi_menu_lastmaxsize = 0
    let t:wimpi_menu_taxo_term = ""
    let t:wimpi_menu_taxo_val = ""
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
  if !exists('t:wimpi_menu_bid')
    let t:wimpi_menu_bid = -1
    return 0
  endif
  return t:wimpi_menu_bid > 0 && bufexists(t:wimpi_menu_bid)
endfunc

function! Window_close()

  if !exists('t:wimpi_menu_bid')
    return 0
  endif

  if &buftype == 'nofile' && &ft == 'wimpi_menu'
    if bufname('%') == t:wimpi_menu_name
      silent close!
      let t:wimpi_menu_bid = -1
    endif
  endif

  if t:wimpi_menu_bid > 0 && bufexists(t:wimpi_menu_bid)
    silent exec 'bwipeout ' . t:wimpi_menu_bid
    let t:wimpi_menu_bid = -1
  endif

  redraw | echo "" | redraw

endfunc

function! Window_open(size)

"  echom a:size

  if Window_exist()
    call Window_close()
  endif

  let size = a:size
  let size = (size < 4)? 4 : size
  let size = (size > g:wimpi_menu_max_width)? g:wimpi_menu_max_width : size
  if size > winwidth(0)
    let size = winwidth(0) - 1
    if size < 4
      let size = 4
    endif
  endif
  let savebid = bufnr('%')
  if stridx(g:wimpi_menu_options, 'T') < 0
    exec "silent! rightbelow ".size.'vne '.t:wimpi_menu_name
  else
    exec "silent! leftabove ".size.'vne '.t:wimpi_menu_name
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

  let t:wimpi_menu_bid = bufnr('%')
  return 1
endfunc

function! wimpi_menu#recent_files()
  let files = []
  let files = systemlist('ls -1t '.g:wimpi_root_path.'/wiki | grep -ve "^index.*" | head -5')
  return files
endfunction

function! wimpi_menu#starred_terms()
  let terms = wimpi#parse_json_file(g:wimpi_index_path . '/_index_term_values_starred.json', [])
  return terms
endfunction

function! wimpi_menu#starred_docs()
  let docs = wimpi#parse_json_file(g:wimpi_index_path . '/_index_docs_starred.json', [])
  return docs
endfunction

function! wimpi_menu#partialFilesListing(files_list, sort)

  let titles = wimpi#titlesForDocs(a:files_list)
  let t_sortable = {}
  let i = 0

  for k in keys(titles)

    let entry = {}
    let entry.orgTitle = k
    let entry.orgFile = titles[k]

    if a:sort == 'az'
      let t_sortable[tolower(k)] = entry
    elseif a:sort == 'date'
      let modFileTime = getftime(g:wimpi_root_path . "/wiki/".titles[k])
      let t_sortable[string(99999999999-modFileTime).k] = entry
    else
      let t_sortable[i] = entry
      let i += 1
    endif

  endfor

  let title_keys = sort(keys(t_sortable))
  for tk in title_keys
    call wimpi_menu#append("" . t_sortable[tk]['orgTitle'], ":botright vs ". g:wimpi_root_path . "/wiki/".t_sortable[tk]['orgFile'], "...")
  endfor

endfunction

function! wimpi_menu#menu_1st_level()

  call wimpi_menu#reset()

  call wimpi_menu#append("# STARRED DOCS", '')
  let starred = wimpi_menu#starred_docs()
  call wimpi_menu#partialFilesListing( starred, 'az' )

  call wimpi_menu#append("# STARRED LEAFS", '')
  let starred = wimpi_menu#starred_terms()
  let starred_list = {}

  for i in starred
    let starred_list[i['term'].','.i['val']] = i
  endfor

  for sk in sort(keys(starred_list))
    call wimpi_menu#append("" . wimpi_menu#string_capitalize(starred_list[sk]['term']) ." : " . starred_list[sk]['val'] , ":call wimpi_menu#openterm('".starred_list[sk]['term']."','".starred_list[sk]['val']."')", "...")
  endfor

  call wimpi_menu#append("# INDEX", '')
  call wimpi_menu#append("Alfabetisch", ":botright vs ". g:wimpi_root_path . "/wiki/index.md", "...")

  let index_keys_list = wimpi#parse_json_file(g:wimpi_index_path . '/_index_keys.json', [])
  for k in index_keys_list
    let term_config = wimpi#index_term_config(k)
    if has_key(term_config, 'top_level')
      let top_level = get(term_config, 'top_level')
      if top_level
        call wimpi_menu#append("Index: " . k, ":call wimpi_menu#openterm('".k."','')", "...")
      endif
    end
  endfor

  call wimpi_menu#append("# RECENT", '')
  let recent = wimpi_menu#recent_files()
  call wimpi_menu#partialFilesListing( recent , 'date' )

  call wimpi_menu#append("# CONFIGURATION", '')
  call wimpi_menu#append("index configuration", ":botright vs ". g:wimpi_root_path . "/config/wiki_indexes.yml", "...")

endfunction

function! wimpi_menu#menu_2nd_level(term)

  let term_config = wimpi#index_term_config(a:term)
  let term_plural = a:term
  if has_key(term_config, 'plural')
    let term_plural = get(term_config, 'plural')
  end

  call wimpi_menu#reset()
  call wimpi_menu#append("/  <home>" , "home", "...", '', '' ,'B')
  call wimpi_menu#append("# " . toupper(term_plural), '')
  call wimpi_menu#menu_divider()


  let group_by = ''
  let config = wimpi#termLeafConfig(a:term)

  if has_key(config, 'views')
    let views = get(config, 'views')
    let views_list = keys(views)
    if has_key(views[views_list[0]], 'group_by' )
      let group_by = get(views[views_list[0]], 'group_by')
    end
  end

  let termslistDict = wimpi#parse_json_file( wimpi#l2_index_filepath(a:term), [] )
  let termslist = keys(termslistDict)

  if group_by != ''
    let term_menu = {}

    for val in sort(termslist)
      "let tvconf = wimpi#termValueLeafConfig(a:term, val)

      if(has_key(termslistDict[val], group_by))

        let group_by_val = tolower(get(termslistDict[val], group_by))

        if !has_key(term_menu,group_by_val)
          let term_menu[group_by_val] = []
        end

        call add(term_menu[group_by_val], val)
      else
        if !has_key(term_menu,'other')
          let term_menu['other'] = []
        end
        call add(term_menu['other'], val)
      end
    endfor

    for group in sort(keys(term_menu))
      call wimpi_menu#append("### " . wimpi_menu#string_capitalize(group), '')

      for val in term_menu[group]

        let files_in_menu = wimpi#parse_json_file( wimpi#l3_index_filepath(a:term, val) ,[])
        call wimpi_menu#append( a:term. ": " . val ." (".len(files_in_menu).")" , ":call wimpi_menu#openterm('".a:term."','".val."')", "...")
      endfor

    endfor


  else

    for val in sort(termslist)

      let files_in_menu = wimpi#parse_json_file( wimpi#l3_index_filepath(a:term, val) ,[])
      call wimpi_menu#append( a:term. ": " . val ." (".len(files_in_menu).")" , ":call wimpi_menu#openterm('".a:term."','".val."')", "...")

    endfor
  end



  call wimpi_menu#append("", '')
  call wimpi_menu#menu_divider()

  call wimpi_menu#append("### " . toupper('Configuration'), '')

  if filereadable(wimpi#l2_config_filepath(a:term))
    call wimpi_menu#append("Open ". a:term." Config", ":botright vs ". wimpi#l2_config_filepath(a:term), "...")
  else
    call wimpi_menu#append("Create ". a:term." Config", "createl2config", "...")
  endif


endfunction


function! wimpi_menu#debug_info()

      call wimpi_menu#append("### " . wimpi_menu#string_capitalize('debug'), '')
      call wimpi_menu#append("t:wimpi_menu_lastmaxsize = ".t:wimpi_menu_lastmaxsize,'')
      call wimpi_menu#append("t:wimpi_menu_name = ".t:wimpi_menu_name,'')
      call wimpi_menu#append("t:wimpi_menu_taxo_term = ".t:wimpi_menu_taxo_term,'')
      call wimpi_menu#append("t:wimpi_menu_taxo_val = ".t:wimpi_menu_taxo_val,'')
      call wimpi_menu#append("Loading time = ".t:wimpi_load_time,'')

endfunction

function! wimpi_menu#termValueLeafState(term, value)

  return wimpi#parse_json_file( wimpi#l3_state_filepath(a:term, a:value), {})

endfunction

function! wimpi_menu#writeTermValueLeafState(term, value, l3_state)
  call wimpi#write_json_file(wimpi#l3_state_filepath(a:term, a:value), a:l3_state)
endfunction

function! wimpi_menu#cycle_3rd_view()

  let l3_state = wimpi_menu#termValueLeafState(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val)
  let active_view = wimpi_menu#menu_l3_get_active_view(l3_state)

  let views = wimpi_menu#get_l3_views_list(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val)

  if (active_view+1) >= len(views)
    let new_active_view = 0
    let l3_state.active_view = 0
  else
    let l3_state.active_view = active_view + 1
  end

  call wimpi_menu#writeTermValueLeafState(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val, l3_state)

endfunction

function! wimpi_menu#get_l3_views_list(term, value)

  let config = wimpi#termValueLeafConfig(a:term, a:value)
  let views_list = ["az", 'date']

  if has_key(config, 'views')
    let views = get(config,'views')

    if(type(views)==4)
      let views_list = views_list + keys(views)
    endif
  endif

  return views_list

endfunction

function! wimpi_menu#get_l3_views(term, value)

  let config = wimpi#termValueLeafConfig(a:term, a:value)

  let views_all = {}
  let views_all.az = {'sort': 'az'}
  let views_all.date = {'sort': 'date'}

  if has_key(config, 'views')
    let views = get(config,'views')

    if(type(views)==4)
      for view in keys(views)
        let views_all[view] = get(views,view)
      endfor

    endif
  endif

  return views_all

endfunction

function! wimpi_menu#menu_l3_get_active_view(l3_state)
  if has_key(a:l3_state, 'active_view')
   return get(a:l3_state, 'active_view')
  else
    return 0
  end
endfunction

function! wimpi_menu#menu_l3_current_view_props(active_view, views_list, views)
    return a:views[a:views_list[a:active_view]]
endfunction

function! wimpi_menu#termValueLeafState(term, value)
  let filePath = wimpi#l3_state_filepath(a:term, a:value)
  return wimpi#parse_json_file( filePath , {})
endfunction

function! wimpi_menu#stringOfLengthWithChar(char, length)
  let i = 0
  let padString = ""
  while a:length >= i
    let padString = padString . a:char
    let i += 1
  endwhile

  return padString
endfunction

function! wimpi_menu#calcActiveViewArrow(views_list, active_view, padding_left)

  let idx = 0
  let arrow_string = wimpi_menu#stringOfLengthWithChar(" ", a:padding_left)
  let stopb = 0

  for view in a:views_list
    if idx == a:active_view
      let padSize = round(len(view)/2)
      let filstr = wimpi_menu#stringOfLengthWithChar(" ", padSize)
      let arrow_string = arrow_string . filstr . "▲"
      let stopb = 1
    else
      if !stopb
        let arrow_string = arrow_string . wimpi_menu#stringOfLengthWithChar(" ", (len(view)+1))
      endif
    endif
    let idx += 1

  endfor
  return arrow_string

endfunction

function! wimpi_menu#menu_divider()
  call wimpi_menu#append("-----------------------------------------", '')
endfunction

function! wimpi_menu#menu_3rd_level(term, value)

  let infotext =''
  let group_by =''

  let l3_config = wimpi#termValueLeafConfig(a:term, a:value)
  let l3_state = wimpi_menu#termValueLeafState(a:term, a:value)

  let term_config = wimpi#index_term_config(a:term)
  let term_plural = a:term
  if has_key(term_config, 'plural')
    let term_plural = get(term_config, 'plural')
  end

  call wimpi_menu#reset()
  call wimpi_menu#append("/  <home>" , "home", "...", '', '' ,'B')
  call wimpi_menu#append(".. <up> ". term_plural ."" , ":call wimpi_menu#openterm('".a:term."','')", "...",'','','U')
  call wimpi_menu#append("# " . toupper(a:term) . ' : ' . toupper(a:value), '')

  call wimpi_menu#menu_divider()

  "if has_key(l3_config, 'infotext')
  "  let infotext =  get(l3_config,'infotext')
  "
  "call wimpi_menu#append(infotext, '')
  "endif

  let views_string = ""
  let views_list = wimpi_menu#get_l3_views_list(a:term, a:value)
  let views = wimpi_menu#get_l3_views(a:term, a:value)

  for view in views_list
    let views_string = views_string . "[" .view . "]"
  endfor

  let active_view = wimpi_menu#menu_l3_get_active_view(l3_state)

  let active_arrow_string = wimpi_menu#calcActiveViewArrow(views_list, active_view, 10)

  call wimpi_menu#append("", '')
  call wimpi_menu#append("VIEW  ". views_string  , "cycleview", "...", '', '', 'V')
  call wimpi_menu#append(active_arrow_string, '')
  if active_view < 2
    call wimpi_menu#append("", '')
  end

  let files_in_menu = wimpi#parse_json_file(wimpi#l3_index_filepath( a:term, a:value), [])

  let view_props = wimpi_menu#menu_l3_current_view_props(active_view, views_list, views)

  if has_key(view_props, 'sort')
    let sort = get(view_props,'sort')
  else
    let sort = "az"
  end

  if has_key(view_props, 'group_by')
    let group_by =  get(view_props,'group_by')
    let files_index = wimpi#parse_json_file(g:wimpi_index_path . '/_index_docs_with_keys.json',[])

    let files_menu = {}
    for k in files_in_menu
      let hide = 0
      if has_key(files_index[k], group_by)
        let group_by_val =  tolower(get(files_index[k], group_by))

        if !has_key(files_menu,group_by_val)
          let files_menu[group_by_val] = []
        end

        call add(files_menu[group_by_val], k)

      else
        if !has_key(files_menu,'other')
          let files_menu['other'] = []
        end

        call add(files_menu['other'], k)

      endif

    endfor

    for group in sort(keys(files_menu))
      call wimpi_menu#append("### " . wimpi_menu#string_capitalize(group), '')
      call wimpi_menu#partialFilesListing( files_menu[group], sort )
    endfor

  else
    call wimpi_menu#partialFilesListing( files_in_menu, sort )
  endif

  call wimpi_menu#append("", '')
  call wimpi_menu#menu_divider()

  if has_key(l3_config, 'locations')
    let locations = get(l3_config,'locations')
    if(type(locations)==4)
      call wimpi_menu#append("### " . toupper('Locaties'), '')

      for l in keys(locations)
        call wimpi_menu#append("" . l, ":!open '". get(locations,l)."'", "...")
      endfor
    endif
  endif

  call wimpi_menu#append("### " . toupper('Configuration'), '')

  if filereadable(wimpi#l3_config_filepath(a:term, a:value))
    call wimpi_menu#append("Open ". a:term." ".a:value." Config", ":botright vs ". wimpi#l3_config_filepath(a:term, a:value), "...",'','','C')
  else
    call wimpi_menu#append("Create ". a:term." ".a:value." Config", "createl3config", "...",'','','C')
  endif

endfunc



"----------------------------------------------------------------------
" menu operation
"----------------------------------------------------------------------

function! wimpi_menu#reset()
  let t:wimpi_menu_items = []
  let t:wimpi_menu_line = 0
  let t:wimpi_menu_cursor = 0
endfunc

function! wimpi_menu#append(text, event, ...)
  let help = (a:0 >= 1)? a:1 : ''
  let filetype = (a:0 >= 2)? a:2 : ''
  let weight = (a:0 >= 3)? a:3 : 0
  let key = (a:0 >= 4)? a:4 : ''

  let item = {}


  let item.mode = 0
  let item.event = a:event
  let item.text = a:text
  let item.key = key
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

  "if !has_key(t:wimpi_menu_items, t:wimpi_menu_mid)
  "  let t:wimpi_menu_items[t:wimpi_menu_mid] = []
  "endif

  let items = t:wimpi_menu_items
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

"function! wimpi_menu#current(mid)
" let t:wimpi_menu_mid = a:mid
"endfunc

"function! wimpi_menu#header(header)
"  let t:wimpi_menu_header = a:header
"endfunc

"function! wimpi_menu#footer(footer)
"let t:wimpi_menu_footer = a:footer
"endfunc

function! wimpi_menu#list()
  for item in t:wimpi_menu_items
    echo item
  endfor
endfunc



"----------------------------------------------------------------------
" wimpi_menu interface
"----------------------------------------------------------------------

function! wimpi_menu#openterm(taxo_term, taxo_value) abort
  let t:wimpi_menu_taxo_term = a:taxo_term
  let t:wimpi_menu_taxo_val = a:taxo_value
  call wimpi_menu#openandshow()
endfunction

function! wimpi_menu#openandshow() abort

  let t:wimpi_start_load_time = localtime()

  if t:wimpi_menu_taxo_term!="" && t:wimpi_menu_taxo_val!=""
    call wimpi_menu#menu_3rd_level(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val)

  elseif t:wimpi_menu_taxo_term!="" && t:wimpi_menu_taxo_val==""
    call wimpi_menu#menu_2nd_level(t:wimpi_menu_taxo_term)

  elseif t:wimpi_menu_taxo_term=="" && t:wimpi_menu_taxo_val==""
    call wimpi_menu#menu_1st_level()

  endif

  if g:wimpi_debug
    let t:wimpi_load_time = localtime() - t:wimpi_start_load_time
    call wimpi_menu#debug_info()
  endif

  " select and arrange menu
  let items = Select_by_ft(&ft)
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

  let maxsize += g:wimpi_menu_padding_right
  let t:wimpi_menu_lastmaxsize = maxsize

  if 1
    call Window_open(maxsize)
    call Window_render(content)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc

function! wimpi_menu#close()
  if Window_exist()
    call Window_close()
    return 0
  endif
endfunction

function! wimpi_menu#open()
  if !Window_exist()
    call wimpi_menu#tabInitState()
    call wimpi_menu#openandshow()
  endif
endfunction

function! wimpi_menu#toggle() abort
  if Window_exist()
    call Window_close()
    return 0
  endif

  " select and arrange menu
  let items = Select_by_ft(&ft)
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

  let maxsize += g:wimpi_menu_padding_right

  if 1
    call Window_open(maxsize)
    call Window_render(content)
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
function! Window_render(items) abort
  setlocal modifiable
  let ln = 2
  let t:wimpi_menu = {}
  let t:wimpi_menu.padding_size = g:wimpi_menu_padding_left
  let t:wimpi_menu.option_lines = []
  let t:wimpi_menu.section_lines = []
  let t:wimpi_menu.text_lines = []
  let t:wimpi_menu.header_lines = []
  let t:wimpi_menu.footer_lines = []
  for item in a:items
    let item.ln = ln
    call append('$', item.text)
    if item.mode == 0
      let t:wimpi_menu.option_lines += [ln]
    elseif item.mode == 1
      let t:wimpi_menu.text_lines += [ln]
    elseif item.mode == 2
      let t:wimpi_menu.section_lines += [ln]
    elseif item.mode == 3
      let t:wimpi_menu.header_lines += [ln]
    elseif item.mode == 4
      let t:wimpi_menu.footer_lines += [ln]
    endif
    let ln += 1
  endfor
  setlocal nomodifiable readonly
  setlocal ft=wimpi_menu
  let t:wimpi_menu.items = a:items
  let opt = g:wimpi_menu_options

  if stridx(opt, 'L') >= 0
    setlocal cursorline
  endif
endfunc


"----------------------------------------------------------------------
" all keys
"----------------------------------------------------------------------
function! Setup_keymaps(items)

  let ln = 0
  let cursor_pos = t:wimpi_menu_cursor
  let nowait = ''

  if v:version >= 704 || (v:version == 703 && has('patch1261'))
    let nowait = '<nowait>'
  endif

  for item in a:items
    if item.key != ''
      let cmd = ' :call <SID>wimpi_menu_execute('.ln.')<cr>'
      exec "noremap <buffer>".nowait."<silent> ".item.key. cmd
    endif
    let ln += 1
  endfor

  " noremap <silent> <buffer> 0 :call <SID>wimpi_menu_close()<cr>
  " noremap <silent> <buffer> q :call <SID>wimpi_menu_close()<cr>
  noremap <silent> <buffer> <CR> :call <SID>wimpi_menu_enter()<cr>
  let t:wimpi_menu_line = 0
  if cursor_pos > 0
    call cursor(cursor_pos, 1)
  endif
  let t:wimpi_menu.showhelp = 0
  call Set_cursor()
  augroup wimpi_menu
    autocmd CursorMoved <buffer> call Set_cursor()
    autocmd InsertEnter <buffer> call feedkeys("\<ESC>")
  augroup END

  let t:wimpi_menu.showhelp = (stridx(g:wimpi_menu_options, 'H') >= 0)? 1 : 0

endfunc


"----------------------------------------------------------------------
" reset cursor
"----------------------------------------------------------------------
function! Set_cursor() abort
  let curline = line('.')
  let lastline = t:wimpi_menu_line
  let movement = (curline < lastline)? -1 : 1
  let find = -1
  let size = len(t:wimpi_menu.items)
  while 1
    let index = curline - 2
    if index < 0 || index >= size
      break
    endif
    let item = t:wimpi_menu.items[index]
    if item.mode == 0 && item.event != ''
      let find = index
      break
    endif
    let curline += movement
  endwhile
  if find < 0
    let curline = line('.')
    let curdiff = abs(curline - t:wimpi_menu.option_lines[0])
    let select = t:wimpi_menu.option_lines[0]
    for line in t:wimpi_menu.option_lines
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
  let t:wimpi_menu_line = find + 2
  call cursor(t:wimpi_menu_line, g:wimpi_menu_padding_left + 2)

  if t:wimpi_menu.showhelp
    let help = t:wimpi_menu.items[find].help
    let key = t:wimpi_menu.items[find].key
    echohl wimpi_menuHelp
    if help != ''
      call Cmdmsg('['.key.']: '.help, 'wimpi_menuHelp')
    else
      echo ''
    endif
    echohl None
  endif
endfunc


"----------------------------------------------------------------------
" close wimpi_menu
"----------------------------------------------------------------------
function! <SID>wimpi_menu_close()
  close
  redraw | echo "" | redraw
endfunc


"----------------------------------------------------------------------
" execute selected
"----------------------------------------------------------------------
function! <SID>wimpi_menu_enter() abort
  let ln = line('.')
  call <SID>wimpi_menu_execute(ln - 2)
endfunc


"----------------------------------------------------------------------
" execute item
"----------------------------------------------------------------------
function! <SID>wimpi_menu_execute(index) abort
  if a:index < 0 || a:index >= len(t:wimpi_menu.items)
    return
  endif

  let item = t:wimpi_menu.items[a:index]

  if item.mode != 0 || item.event == ''
    return
  endif

  let t:wimpi_menu_line = a:index + 2
  let t:wimpi_menu_cursor = t:wimpi_menu_line

  redraw | echo "" | redraw

    " als event een string is
    if type(item.event) == 1

      if(item.event == 'close')
        close!

      elseif(item.event == 'refresh')
        call wimpi_menu#openandshow()

      elseif(item.event == 'cycleview')
        call wimpi_menu#cycle_3rd_view()
        call wimpi_menu#openandshow()

      elseif(item.event == 'hardrefresh')
        call wimpi#Init()
        call wimpi#make_index()
        call wimpi_menu#openandshow()

      elseif(item.event == 'home')
        call wimpi_menu#openterm('','')

      elseif(item.event == 'createl2config')

        let confFileName = wimpi#l2_config_filepath(t:wimpi_menu_taxo_term)

        let fileLines = []
        call add(fileLines, '---')
        call add(fileLines, 'title: '.wimpi_menu#string_capitalize(t:wimpi_menu_taxo_term))
        call add(fileLines, 'infotext: About '. t:wimpi_menu_taxo_term)
        call add(fileLines, 'views:')
        call add(fileLines, '  type:')
        call add(fileLines, '    group_by: type')

        if writefile(fileLines, confFileName)
          echomsg 'write error'
        else
          exec ':only'
          let currentwidth = t:wimpi_menu_lastmaxsize
          let currentWindow=winnr()
          execute ":botright vs ". confFileName
          let newWindow=winnr()

          exec currentWindow."wincmd w"
          setlocal foldcolumn=0
          exec "vertical resize " . currentwidth
          exec currentWindow."call wimpi_menu#openandshow()"
          exec newWindow."wincmd w"

        endif

      elseif(item.event == 'createl3config')

        let confFileName = wimpi#l3_config_filepath(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val)

        let fileLines = []
        call add(fileLines, '---')
        call add(fileLines, 'title: '.wimpi_menu#string_capitalize(t:wimpi_menu_taxo_val))
        call add(fileLines, 'infotext: About '. t:wimpi_menu_taxo_val)
        call add(fileLines, 'views:')
        call add(fileLines, '  type:')
        call add(fileLines, '    group_by: type')
        call add(fileLines, 'locations:')
        call add(fileLines, '  #website: https://www.'.t:wimpi_menu_taxo_val.'.vim')
        "call add(fileLines, '  #dir1: file:///Applications/')
        "call add(fileLines, '  #file1: file:///Projects/file1.someformat')

        if writefile(fileLines, confFileName)
          echomsg 'write error'
        else
          exec ':only'
          let currentwidth = t:wimpi_menu_lastmaxsize
          let currentWindow=winnr()
          execute ":botright vs ". confFileName
          let newWindow=winnr()

          exec currentWindow."wincmd w"
          setlocal foldcolumn=0
          exec "vertical resize " . currentwidth
          exec currentWindow."call wimpi_menu#openandshow()"
          exec newWindow."wincmd w"

        endif

      elseif(item.event == 'newdocingroup')

        call inputsave()
        let name = input('Enter document name: ')
        call inputrestore()

        echo name
        if(!empty(name))
          call wimpi_menu#new_document_in_leaf(name)
        else
          return 0
        endif

      elseif item.event[0] != '='
        if item.event =~ "wimpi_menu#openterm"
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

          let currentwidth = t:wimpi_menu_lastmaxsize
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


function! wimpi_menu#new_document_in_leaf(...)
  let title = join(a:000)
  let fileName = wimpi_wiki#WordFilename(title)
  let relativePath = fnameescape(g:wimpi_root_path . '/wiki/' . fileName)

  if !filereadable(relativePath)
    let taxo_term = ''
    let taxo_val = ''

    let taxoEntries = []
    if t:wimpi_menu_taxo_term != "" && t:wimpi_menu_taxo_val != ""
      let entry = {}
      let entry['term'] = t:wimpi_menu_taxo_term
      let entry['value'] = t:wimpi_menu_taxo_val
      call add(taxoEntries, entry)

      let config = wimpi#termValueLeafConfig(t:wimpi_menu_taxo_term, t:wimpi_menu_taxo_val)
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

  if bufname('%') =~ "[wimpi_menu]"
    let currentwidth = t:wimpi_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    execute ':botright vs '. relativePath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call wimpi_menu#openandshow()"
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
function! Select_by_ft(ft) abort

  " R = refresh
  " A = newdocingroup
  " H = hardrefresh

  let hint = '0123456789abdefhilmdstwxyzIOPQSX*'

  let items = []
  let index = 0
  let footer = 'Wimpi ' . wimpi#PluginVersion()
  let header = ''

  if header != ''
    let ni = {'mode':3, 'text':'', 'event':'', 'help':''}
    let ni.text = header
    let items += [ni]
    let ni = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [ni]
  endif

  let lastmode = 2
  for item in t:wimpi_menu_items

    if len(item.ft) && index(item.ft, a:ft) < 0
      continue
    endif

    " insert empty line
    if item.mode == 2 && lastmode != 2
      let ni = {'mode':1, 'text':'', 'event':''}
      let items += [ni]
    endif
    let lastmode = item.mode

    " allocate key for non-filetype specific items
    if item.mode == 0 && len(item.ft) == 0

      if item.key == ''
        let item.key = hint[index]

        let index += 1
        if index >= strlen(hint)
          let index = strlen(hint) - 1
        endif
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

      if item.key == ''
        let item.key = hint[index]
      endif

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

  if t:wimpi_menu_taxo_term !="" && t:wimpi_menu_taxo_val !=""
    let item = {}
    let item.mode = 0
    let item.text = '<new document>'
    let item.event = 'newdocingroup'
    let item.key = 'A'
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

  if footer != ''
    let ni = {'mode':1, 'text':'', 'event':'', 'help':''}
    let items += [ni]
    let ni = {'mode':4, 'text':'', 'event':'', 'help':''}
    let ni.text = footer
    let items += [ni]
  endif

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
  let padding = repeat(' ', g:wimpi_menu_padding_left)
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

function! wimpi_menu#string_capitalize(capstring)
  return toupper(strpart(a:capstring, 0, 1)).strpart(a:capstring,1)
endfunction


"----------------------------------------------------------------------
" testing case
"----------------------------------------------------------------------
if 0

  call wimpi_menu#reset()
  call wimpi_menu#append("/  <home>" , "home", "...", '', '' ,'r')
  call wimpi_menu#append('# Start', '')
  call wimpi_menu#append('test1', 'echo 1', 'help 1', '0', '2', '3')
  call wimpi_menu#append('test2', 'echo 2', 'help 2')

  call wimpi_menu#append('# Misc', '')
  call wimpi_menu#append('test3', 'echo 3')
  call wimpi_menu#append('test4', 'echo 4')
  call wimpi_menu#append("test5\nasdfafffff\njkjkj", 'echo 5')
  call wimpi_menu#append('text1', '')
  call wimpi_menu#append('text2', '')

  " nnoremap <F12> :call wimpi_menu#toggle(0)<cr>
  " imap <expr> <F11> wimpi_menu#bottom(0)
endif

