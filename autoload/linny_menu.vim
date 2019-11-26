"======================================================================
"
" linny_menu.vim
"
" Inspired by QuickMenu of skywind
" Last change: 2017/08/08 15:20:20
"
"======================================================================

"----------------------------------------------------------------------
" Global Options
"----------------------------------------------------------------------

call linny_util#initVariable("g:linny_menu_max_width", 50)
call linny_util#initVariable("g:linny_menu_padding_left", 3)
call linny_util#initVariable("g:linny_menu_padding_right", 3)
call linny_util#initVariable("g:linny_menu_options", 'T')
call linny_util#initVariable("g:linny_menu_display_docs_count", 1)
call linny_util#initVariable("g:linny_menu_display_taxo_count", 1)
call linny_util#initVariable("g:linnytabnr", 1)
call linny_util#initVariable("g:linny_debug", 1)

let t:linny_menu_items = []
let t:linny_menu_cursor = 0
let t:linny_menu_line = 0
let t:linny_menu_lastmaxsize = 0
let t:linny_menu_taxonomy = ""
let t:linny_menu_term = ""
let t:linny_menu_current_menu_type = "not_set"

"----------------------------------------------------------------------
" Internal State
"----------------------------------------------------------------------
function! linny_menu#tabInitState()
  if !exists('t:linny_menu_name')
    let t:linny_menu_items = []
    let t:linny_menu_cursor = 0
    let t:linny_menu_name = '[linny_menu]'.string(NewLinnyTabNr())
    let t:linny_menu_line = 0
    let t:linny_menu_lastmaxsize = 0
    let t:linny_menu_taxonomy = ""
    let t:linny_menu_term = ""
  endif
endfunction

function! NewLinnyTabNr()
  let g:linnytabnr = g:linnytabnr + 1
  return g:linnytabnr
endfunction

"----------------------------------------------------------------------
" popup window management
"----------------------------------------------------------------------
function! Window_exist()

  if !exists('t:linny_menu_bid')
    let t:linny_menu_bid = -1
    return 0
  endif

  return t:linny_menu_bid > 0 && bufexists(t:linny_menu_bid)
endfunc

function! Window_close()

  if !exists('t:linny_menu_bid')
    return 0
  endif

  "if last window, first create new one
  if winbufnr(2) == -1
    exec "below vnew"
  endif

  if &buftype == 'nofile' && &ft == 'linny_menu'
    if bufname('%') == t:linny_menu_name
      silent close!
      let t:linny_menu_bid = -1
    endif
  endif

  if t:linny_menu_bid > 0 && bufexists(t:linny_menu_bid)
    silent exec 'bwipeout ' . t:linny_menu_bid
    let t:linny_menu_bid = -1
  endif

  redraw | echo "" | redraw

endfunc

function! Window_open(size)

  if Window_exist()
    call Window_close()
  endif

  let size = a:size
  let size = (size < 4)? 4 : size
  let size = (size > g:linny_menu_max_width)? g:linny_menu_max_width : size
  if size > winwidth(0)
    let size = winwidth(0) - 1
    if size < 4
      let size = 4
    endif
  endif
  let savebid = bufnr('%')
  if stridx(g:linny_menu_options, 'T') < 0
    exec "silent! rightbelow ".size.'vne '.t:linny_menu_name
  else
    exec "silent! leftabove ".size.'vne '.t:linny_menu_name
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

  let t:linny_menu_bid = bufnr('%')
  return 1
endfunc


function! linny_menu#recent_files()
  let files = []
  let files = systemlist('ls -1t '.g:linny_root_path.'/wiki | grep -ve "^index.*" | head -5')
  return files
endfunction

function! linny_menu#starred_terms()
  let terms = linny#parse_json_file(g:linny_index_path . '/_index_terms_starred.json', [])
  return terms
endfunction

function! linny_menu#starred_docs()
  let docs = linny#parse_json_file(g:linny_index_path . '/_index_docs_starred.json', [])
  return docs
endfunction

function! s:partial_files_listing(files_list, view_props, bool_extra_file_info)

  if has_key(a:view_props, 'sort')
    let vsort = get(a:view_props,'sort')
  else
    let vsort = "az"
  end

  if (a:bool_extra_file_info)

    if has_key(a:view_props, 'label')

      let titles = {}
      for filel in a:files_list

        let label_conf = a:view_props.label

        let pat = '[{]\w\+[}]'

        while match(label_conf, pat ) >= 0
          let found = matchstr(label_conf, pat )
          let found2 = substitute(found, '[{]', '', '')
          let found2 = substitute(found2, '[}]', '', '')

          let replace = ""
          if found2 == 'title'
            let replace = linny#doc_title_from_index(filel.file)
            if !replace
              let replace = ""
              let replace = filel.file
              "FIXME waarom krijg hier geen titels???
            endif
            "exec "! echo '".filel.file."'"

          else
            if has_key(filel.fm, found2)
              let replace = filel.fm[found2]
            else
              let replace = ""
            end
          end

          let label_conf = substitute(label_conf, found, replace, "")
        endwhile

        let titles[label_conf] = filel.file

      endfor

    else
      let simple_list = []
      for filel in a:files_list
        call add(simple_list,filel.file)
      endfor

      let titles = linny#titlesForDocs(simple_list)

    endif

  else
    let titles = linny#titlesForDocs(a:files_list)
  end


  let t_sortable = {}
  let i = 0

  for k in keys(titles)

    let entry = {}
    let entry.orgTitle = k
    let entry.orgFile = g:linny_root_path . "/wiki/" . titles[k]

    if vsort == 'az'
      let t_sortable[tolower(k)] = entry
    elseif vsort == 'date'
      let modFileTime = getftime(g:linny_root_path . "/wiki/".titles[k])
      let t_sortable[string(99999999999-modFileTime).k] = entry
    else
      let t_sortable[i] = entry
      let i += 1
    endif

  endfor

  let title_keys = sort(keys(t_sortable))
  for tk in title_keys
    call s:add_item_document(t_sortable[tk]['orgTitle'], t_sortable[tk]['orgFile'], '')
  endfor

endfunction

function! s:menu_level0()

  let t:linny_menu_current_menu_type = "menu_level0"

  call linny_menu#reset()

  call s:add_item_section("# Starred documents")
  let starred = linny_menu#starred_docs()

  call s:partial_files_listing( starred, {'sort':'az'}, 0)

  call s:add_item_section("# Starred terms")
  let starred = linny_menu#starred_terms()
  let starred_list = {}

  for i in starred
    let starred_list[i['taxonomy'].','.i['term']] = i
  endfor

  for sk in sort(keys(starred_list))
    call s:add_item_document_taxo_key_val(starred_list[sk]['taxonomy'], starred_list[sk]['term'], 1)
  endfor

  call s:add_item_section("# Taxonomies")

  let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])
  for k in sort(index_keys_list)
    let term_config = linny#index_tax_config(k)
    if has_key(term_config, 'top_level')
      let top_level = get(term_config, 'top_level')
      if top_level
        call s:add_item_document_taxo_key(k)
      endif
    end
  endfor

  call s:add_item_section("# All documents")
  call s:add_item_document("Sorted A-Z", g:linny_root_path ."/wiki/index.md", 'a')
  "call s:add_item_document("Sorted NEW-OLD", g:linny_root_path ."/wiki/index.md", 'a')


  call s:add_item_section("# Recently modifies documents")
  let recent = linny_menu#recent_files()
  call s:partial_files_listing( recent , {'sort':'date'}, 0)

  call s:add_item_section("# Configuration")
  call s:add_item_document("index configuration", g:linny_root_path ."/config/L0-CONF-ROOT.yml", 'c')

endfunction

function! s:menu_level1(term)

  let t:linny_menu_current_menu_type = "menu_level1"

  let term_config = linny#index_tax_config(a:term)
  let term_plural = a:term
  if has_key(term_config, 'plural')
    let term_plural = get(term_config, 'plural')
  end
  let l1_config = linny#taxConfig(a:term)

  call linny_menu#reset()
  call s:add_item_special_event("/  <home>", "home", '0')
  call s:add_item_special_event(".. <up>", "home", 'u')
  call s:add_item_section("# " . toupper(term_plural) )
  call s:add_item_divider()

  let views_string = ""
  let views_list = linny_menu#get_views_list(l1_config)
  let views = linny_menu#get_views(l1_config)

  let l1_state = linny_menu#termLeafState(a:term)
  let active_view = linny_menu#menu_get_active_view(l1_state)

  if len(views) < 3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = linny_menu#calcActiveViewArrow(views_list, active_view, 4)

    call s:add_item_section("### VIEW")
    call s:add_item_special_event("". views_string  , "cycle_l1_view", 'v')
    call s:add_item_text(active_arrow_string)
    call s:add_item_divider()

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call s:add_item_section("### VIEW")
    call s:add_item_special_event("". views_string  , "dropdown_l1_view", 'v')
    call s:add_item_divider()

  endif


  let view_props = linny_menu#menu_current_view_props(active_view, views_list, views)

  if has_key(view_props, 'sort')
    let sort = get(view_props,'sort')
  else
    let sort = "az"
  end

  let group_by = ''

  if has_key(l1_config, 'views')
    let views = get(l1_config, 'views')
    let views_list = keys(views)
    if has_key(views[views_list[0]], 'group_by' )
      let group_by = get(views[views_list[0]], 'group_by')
    end
  end

  let termslistDict = linny#parse_json_file( linny#l1_index_filepath(a:term), [] )
  let termslist = keys(termslistDict)

  let term_menu = {}

  for val in sort(termslist)

    if s:displayFileAskViewProps(view_props, termslistDict[val])

      if has_key(view_props, 'group_by')
        let group_by = get(view_props,'group_by')

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
      else

        if !has_key(term_menu,'Documents')
          let term_menu['Documents'] = []
        end
        call add(term_menu['Documents'], val)

      endif
    endif

  endfor

  for group in sort(keys(term_menu))
    call s:add_item_section("### " . linny_menu#string_capitalize(group) )

    for val in term_menu[group]
      call s:add_item_document_taxo_key_val(a:term, val, 0)
    endfor

  endfor

  call s:add_item_empty_line()
  call s:add_item_divider()

  call s:add_item_section("### " . toupper('Configuration'))

  if filereadable(linny#l1_config_filepath(a:term))
    call s:add_item_document("Open ". a:term." Config", linny#l1_config_filepath(a:term),'c')
  else
    call s:add_item_special_event("Create ". a:term." Config", "createl1config", 'C')
  endif


endfunction


function! s:partial_debug_info()
  call s:add_item_section("### " . linny_menu#string_capitalize('debug'))
  call s:add_item_text("t:linny_menu_lastmaxsize = ".t:linny_menu_lastmaxsize)
  call s:add_item_text("t:linny_menu_name = ".t:linny_menu_name)
  call s:add_item_text("t:linny_menu_taxonomy = ".t:linny_menu_taxonomy)
  call s:add_item_text("t:linny_menu_term = ".t:linny_menu_term)
  call s:add_item_text("Loading time = ".t:linny_load_time)
endfunction

function! linny_menu#termValueLeafState(term, value)
  let filePath = linny#l2_state_filepath(a:term, a:value)
  return linny#parse_json_file( filePath , {})
endfunction

function! linny_menu#termLeafState(term)
  let filePath = linny#l1_state_filepath(a:term)
  return linny#parse_json_file( filePath , {})
endfunction

"function! linny_menu#termValueLeafState(term, value)
"  return linny#parse_json_file( linny#l2_state_filepath(a:term, a:value), {})
"endfunction
"
function! linny_menu#writeTermLeafState(term, state)
  call linny#write_json_file(linny#l1_state_filepath(a:term), a:state)
endfunction

function! linny_menu#writeTermValueLeafState(term, value, l2_state)
  call linny#write_json_file(linny#l2_state_filepath(a:term, a:value), a:l2_state)
endfunction



function! linny_menu#cycle_l1_view(direction)

  let state = linny_menu#termLeafState(t:linny_menu_taxonomy)
  let active_view = linny_menu#menu_get_active_view(state)
  let config = linny#taxConfig(t:linny_menu_taxonomy)
  let views = linny_menu#get_views_list(config)

  let newstate = linny_menu#new_active_view(state, views, a:direction, active_view)
  call linny_menu#writeTermLeafState(t:linny_menu_taxonomy, newstate)

endfunction

function! linny_menu#dropdown_l1_view_callback(id, result)
  if a:result != -1
    let state = linny_menu#termLeafState(t:linny_menu_taxonomy)
    let state.active_view = a:result-1

    call linny_menu#writeTermLeafState(t:linny_menu_taxonomy, state)
    call linny_menu#openandshow()
  endif

endfunction

function! linny_menu#dropdown_l1_view()

  let state = linny_menu#termLeafState(t:linny_menu_taxonomy)
  let active_view = linny_menu#menu_get_active_view(state)
  let config = linny#taxConfig(t:linny_menu_taxonomy)
  let views = linny_menu#get_views_list(config)

  call popup_create(views, #{
        \ zindex: 200,
        \ drag: 0,
        \ line: 10,
        \ title: views[active_view],
        \ col: 9,
        \ wrap: 0,
        \ border: [],
        \ cursorline: 1,
        \ padding: [0,1,0,1],
        \ filter: 'popup_filter_menu',
        \ mapping: 0,
        \ callback: 'linny_menu#dropdown_l1_view_callback',
        \ })

endfunction


function! linny_menu#dropdown_l2_view_callback(id, result)
  if a:result != -1
    let state = linny_menu#termValueLeafState(t:linny_menu_taxonomy, t:linny_menu_term)
    let state.active_view = a:result-1
    call linny_menu#writeTermValueLeafState(t:linny_menu_taxonomy, t:linny_menu_term, state)
    call linny_menu#openandshow()
  endif

endfunction

function! linny_menu#dropdown_l2_view()

  let state = linny_menu#termValueLeafState(t:linny_menu_taxonomy, t:linny_menu_term)
  let active_view = linny_menu#menu_get_active_view(state)
  let config = linny#termConfig(t:linny_menu_taxonomy, t:linny_menu_term)
  let views = linny_menu#get_views_list(config)

  call popup_create(views, #{
        \ zindex: 200,
        \ drag: 0,
        \ line: 10,
        \ title: views[active_view],
        \ col: 9,
        \ wrap: 0,
        \ border: [],
        \ cursorline: 1,
        \ padding: [0,1,0,1],
        \ filter: 'popup_filter_menu',
        \ mapping: 0,
        \ callback: 'linny_menu#dropdown_l2_view_callback',
        \ })

endfunction

function! linny_menu#cycle_l2_view(direction)

  let state = linny_menu#termValueLeafState(t:linny_menu_taxonomy, t:linny_menu_term)

  let active_view = linny_menu#menu_get_active_view(state)
  let config = linny#termConfig(t:linny_menu_taxonomy, t:linny_menu_term)
  let views = linny_menu#get_views_list(config)

  let newstate = linny_menu#new_active_view(state, views, a:direction, active_view)
  call linny_menu#writeTermValueLeafState(t:linny_menu_taxonomy, t:linny_menu_term, newstate)

endfunction

function! linny_menu#new_active_view(state, views, direction, active_view)
  let state = a:state
  if (a:active_view+a:direction) >= len(a:views)
    let state.active_view = 0
  elseif (a:active_view + a:direction) < 0
    let state.active_view = len(a:views)-1
  else
    let state.active_view = a:active_view + a:direction
  end

  return state

endfunction

function! linny_menu#get_views_list(config)

  let views_list = []

  if has_key(a:config, 'views')
    let views = get(a:config,'views')

    if(type(views)==4)
      let views_list = views_list + keys(views)
    endif
  else
    let views_list = ['NONE']
  endif

  return views_list

endfunction

function! linny_menu#get_views(config)

  let views_all = {}

  if has_key(a:config, 'views')
    let views = get(a:config,'views')

    if(type(views)==4)
      for view in keys(views)
        let views_all[view] = get(views,view)
      endfor

    endif
  else
    let views_all.NONE = {'sort': 'az'}
  endif

  return views_all

endfunction

function! linny_menu#menu_get_active_view(state)
  if has_key(a:state, 'active_view')
   return get(a:state, 'active_view')
  else
    return 0
  end
endfunction

function! linny_menu#menu_current_view_props(active_view, views_list, views)
  if len(a:views_list) > a:active_view
    return a:views[a:views_list[a:active_view]]
  else
    return a:views[a:views_list[0]]
  endif
endfunction

function! linny_menu#stringOfLengthWithChar(char, length)
  let i = 0
  let padString = ""
  while a:length >= i
    let padString = padString . a:char
    let i += 1
  endwhile

  return padString
endfunction

function! linny_menu#calcActiveViewArrow(views_list, active_view, padding_left)

  let idx = 0
  let arrow_string = linny_menu#stringOfLengthWithChar(" ", a:padding_left)
  let stopb = 0

  for view in a:views_list
    if idx == a:active_view
      let padSize = round(len(view)/2)
      let filstr = linny_menu#stringOfLengthWithChar(" ", padSize)
      let arrow_string = arrow_string . filstr . "▲"
      let stopb = 1
    else
      if !stopb
        let arrow_string = arrow_string . linny_menu#stringOfLengthWithChar(" ", (len(view)+1))
      endif
    endif
    let idx += 1

  endfor
  return arrow_string

endfunction

function! s:menu_level2(term, value)

  let t:linny_menu_current_menu_type = "menu_level2"

  let infotext =''
  let group_by =''

  let l2_config = linny#termConfig(a:term, a:value)

  let term_config = linny#index_tax_config(a:term)
  let term_plural = a:term
  if has_key(term_config, 'plural')
    let term_plural = get(term_config, 'plural')
  end

  call linny_menu#reset()

  call s:add_item_special_event("/  <home>", "home", '0')
  call s:add_item_ex_event(".. <up> ". term_plural, ":call linny_menu#openterm('".a:term."','')", 'u')
  call s:add_item_section("# " . toupper(a:term) . ' : ' . toupper(a:value))

  call s:add_item_divider()

  if has_key(l2_config, 'infotext')
    let infotext =  get(l2_config,'infotext')
    call s:add_item_text(infotext)
  endif

  let views_string = ""
  let views_list = linny_menu#get_views_list(l2_config)
  let views = linny_menu#get_views(l2_config)
  let l2_state = linny_menu#termValueLeafState(a:term, a:value)
  let active_view = linny_menu#menu_get_active_view(l2_state)

  if len(views) <=3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = linny_menu#calcActiveViewArrow(views_list, active_view, 4)

    call s:add_item_section("### VIEW")
    call s:add_item_special_event("". views_string  , "cycle_l2_view", 'v')

    call s:add_item_text(active_arrow_string)
    call s:add_item_divider()

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call s:add_item_section("### VIEW")
    call s:add_item_special_event("". views_string  , "dropdown_l2_view", 'v')
    call s:add_item_divider()

  endif

  let files_in_menu = linny#parse_json_file(linny#l2_index_filepath( a:term, a:value), [])
  let view_props = linny_menu#menu_current_view_props(active_view, views_list, views)
  let files_index = linny#parse_json_file(g:linny_index_path . '/_index_docs_with_props.json',[])

  let files_menu = {}

  for file_in_menu in files_in_menu
    let hide = 0

    if s:displayFileAskViewProps(view_props, files_index[file_in_menu])

      let file_in_menu_dict = {}
      let file_in_menu_dict.file = file_in_menu
      let file_in_menu_dict.fm = files_index[file_in_menu]

      if has_key(view_props, 'group_by')
        let group_by = get(view_props,'group_by')

        if has_key(files_index[file_in_menu], group_by)
          let group_by_val =  tolower(get(files_index[file_in_menu], group_by))

          if !has_key(files_menu,group_by_val)
            let files_menu[group_by_val] = []
          end

          call add(files_menu[group_by_val], file_in_menu_dict)

        else
          if !has_key(files_menu,'other')
            let files_menu['other'] = []
          end

          call add(files_menu['other'], file_in_menu_dict)

        endif

      else
        if !has_key(files_menu,'Documents')
          let files_menu['Documents'] = []
        end

        call add(files_menu['Documents'], file_in_menu_dict)
      end

    end

  endfor

  for group in sort(keys(files_menu))
    call s:add_item_section("### " . linny_menu#string_capitalize(group))
    call s:partial_files_listing( files_menu[group], view_props , 1)
  endfor

  call s:add_item_empty_line()
  call s:add_item_divider()

  if has_key(l2_config, 'locations')
    let locations = get(l2_config,'locations')
    if(type(locations)==4)
      call s:add_item_section("### " . toupper('Locaties'))

      for l in keys(locations)
        call s:add_item_external_location(l, get(locations,l))
      endfor
    endif
  endif

  call s:add_item_section("### " . toupper('Configuration'))

  if filereadable(linny#l2_config_filepath(a:term, a:value))
    call s:add_item_document("Open ". a:term." ".a:value." Config", linny#l2_config_filepath(a:term, a:value),'c')
  else
    call s:add_item_special_event("Create ". a:term." ".a:value." Config", "createl2config", 'c')
  endif

  call s:add_item_empty_line()
  call s:add_item_special_event("<new document>", "newdocingroup", 'A')

endfunc

function! s:partial_footer_items()
"  call s:add_item_empty_line()
"  call s:add_item_special_event("<hard refresh>", "hardrefresh", 'H')
  call s:add_item_special_event("<refresh>", "refresh", 'R')
  call s:add_item_empty_line()
  call s:add_item_footer('Linny ' . linny_version#PluginVersion())
endfunction

function! s:displayFileAskViewProps(view_props, file_dict)

  if has_key(a:view_props, 'except')
    for except_dict in a:view_props.except
      if s:testFileWithDisplayExpression(a:file_dict, except_dict)
        return 0
      endif
    endfor
  endif

  if has_key(a:view_props, 'only')
    let onlystatus = 0
    for only_dict in a:view_props.only
      if s:testFileWithDisplayExpression(a:file_dict, only_dict)
        let onlystatus = 1
      end
    endfor
    return onlystatus
  endif

  return 1

endfunction

function! s:testFileWithDisplayExpression(file_dict, expr )

  let keyName = keys(a:expr)[0]
  let keyVal = a:expr[keyName]

  if keyVal == 'IS_SET'
    if has_key(a:file_dict, keyName)
      return 1
    else
      return 0
    endif

  elseif  keyVal == 'IS_NOT_SET'
    if has_key(a:file_dict, keyName)
      return 0
    else
      return 1
    endif
  else

    if has_key(a:file_dict, keyName)

      if a:file_dict[keyName] == keyVal
        return 1
      else
        return 0
      endif

    else
      return 0
    endif

  endif

  return 1

endfunction

"----------------------------------------------------------------------
" menu operation
"----------------------------------------------------------------------

function! linny_menu#reset()
  let t:linny_menu_items = []
  let t:linny_menu_line = 0
  let t:linny_menu_cursor = 0
endfunc


"----------------------------------------------------------------------
" items list functions {{{
"----------------------------------------------------------------------

function! s:item_default()
  let item = {}

  " 0 = option
  " 1 = text
  " 2 = section
  " 3 = heading
  " 4 = footer
  let item.mode = 1

  let item.event = ''           " ex-cmd or event_id
  let item.text = ''            " text to display
  let item.option_type = ''     " kind of type
  let item.option_data = {}     " extra data can be stored
  let item.key = ''             " keyboard key
  let item.weight = 0           " sorting weight
  let item.help = ''            " help text
  return item
endfunction

function! s:add_item_empty_line()
  let item = s:item_default()
  call s:append_to_items(item)
endfunction

function! s:add_item_divider()
  let item = s:item_default()
  let item.text = "-----------------------------------------"
  call s:append_to_items(item)
endfunction

function! s:add_item_header(text)
  let item = s:item_default()
  let item.mode = 3
  let item.text = matchstr(a:text, '^#\+\s*\zs.*')
  call s:append_to_items(item)
endfunction

function! s:add_item_footer(text)
  let item = s:item_default()
  let item.mode = 4
  let item.text = a:text
  call s:append_to_items(item)
endfunction

function! s:add_item_section(text)
  call s:add_item_empty_line()

  let item = s:item_default()
  let item.mode = 2
  let item.text = matchstr(a:text, '^#\+\s*\zs.*')

  call s:append_to_items(item)

"  call s:add_item_empty_line()
endfunction

function! s:add_item_text(text)
  let item = s:item_default()
  let item.text = a:text
  call s:append_to_items(item)
endfunction

function! s:add_item_document(title, abs_path, keyboard_key)
  let item = s:item_default()
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.option_type = 'document'
  let item.option_data.abs_path = a:abs_path
  let item.text = a:title
  let item.event = ":botright vs ". a:abs_path
  call s:append_to_items(item)
endfunction

function! s:add_item_document_taxo_key(taxo_key)
  let item = s:item_default()
  let item.mode = 0

  if g:linny_menu_display_taxo_count
    let files_in_menu = linny#parse_json_file( linny#l1_index_filepath(a:taxo_key) ,[])
    let taxo_count = " (".len(files_in_menu).")"
  else
    let taxo_count = ""
  endif

  let item.text = "" . linny_menu#string_capitalize(a:taxo_key) . taxo_count
  let item.event = ":call linny_menu#openterm('". a:taxo_key ."','')"
  call s:append_to_items(item)

endfunction

function! s:add_item_document_taxo_key_val(taxo_key, taxo_term, display_taxonomy_in_menu)
  let item = s:item_default()
  let item.option_type = 'taxo_key_val'
  let item.option_data.taxo_key = a:taxo_key
  let item.option_data.taxo_term = a:taxo_term
  let item.mode = 0

  if a:display_taxonomy_in_menu
    let tax_text = linny_menu#string_capitalize(a:taxo_key) . ': '
  else
    let tax_text = ''
  end

  if g:linny_menu_display_docs_count
    let files_in_menu = linny#parse_json_file( linny#l2_index_filepath(a:taxo_key,a:taxo_term) ,[])
    let docs_count = " (".len(files_in_menu).")"
  else
    let docs_count = ""
  endif

"  let item.text = linny#taxTermTitle(a:taxo_key, a:taxo_term) . docs_count
  let item.text = tax_text . a:taxo_term . docs_count
  let item.event = ":call linny_menu#openterm('". a:taxo_key ."','" .a:taxo_term."')"
  call s:append_to_items(item)
endfunction

function! s:add_item_special_event(title, event_id, keyboard_key)
  let item = s:item_default()
  let item.text = a:title
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.event = a:event_id

  call s:append_to_items(item)
endfunction

function! s:add_item_ex_event(title, ex_event, keyboard_key )
  let item = s:item_default()
  let item.text = a:title
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.event = a:ex_event

  call s:append_to_items(item)
endfunction

function! s:add_item_external_location(title, location)
  let item = s:item_default()
  let item.text = a:title
  let item.mode = 0
  let item.event = ":!open '". a:location."'"

  call s:append_to_items(item)

endfunction

function s:append_to_items(item)
  let index = -1

  let items = t:linny_menu_items
  let total = len(items)

  for i in range(0, total - 1)
    if a:item.weight < items[i].weight
      let index = i
      break
    endif
  endfor

  if index < 0
    let index = total
  endif

  call insert(items, a:item, index)

endfunction

function! linny_menu#list()
  for item in t:linny_menu_items
    echo item
  endfor
endfunc

function! s:get_item_by_index(index)
  if a:index < 0 || a:index >= len(t:linny_menu.items)
    return
  endif

  let item = t:linny_menu.items[a:index]

  return item
endfunction


"}}}

"----------------------------------------------------------------------
" linny_menu interface
"----------------------------------------------------------------------

function! linny_menu#openterm(taxonomy, taxo_term) abort
  let t:linny_menu_taxonomy = a:taxonomy
  let t:linny_menu_term = a:taxo_term
  call linny_menu#openandshow()
endfunction

function! linny_menu#openandshow() abort

  let t:linny_start_load_time = localtime()

  if t:linny_menu_taxonomy!="" && t:linny_menu_term!=""
    call s:menu_level2(t:linny_menu_taxonomy, t:linny_menu_term)

  elseif t:linny_menu_taxonomy!="" && t:linny_menu_term==""
    call s:menu_level1(t:linny_menu_taxonomy)

  elseif t:linny_menu_taxonomy=="" && t:linny_menu_term==""
    call s:menu_level0()
  endif

  call s:partial_footer_items()

  if g:linny_debug
    let t:linny_load_time = localtime() - t:linny_start_load_time
    call s:partial_debug_info()
  endif

  let items = Select_items()

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

  let maxsize += g:linny_menu_padding_right
  let t:linny_menu_lastmaxsize = maxsize

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

function! linny_menu#close()
  if Window_exist()
    call Window_close()
    return 0
  endif
endfunction

function! linny_menu#open()
  if !Window_exist()
    call linny_menu#tabInitState()
    call linny_menu#openandshow()
  endif
endfunction

function! linny_menu#toggle() abort
  if Window_exist()
    call Window_close()
    return 0
  endif

  " select and arrange menu
  let items = Select_items()
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

  let maxsize += g:linny_menu_padding_right

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
  let t:linny_menu = {}
  let t:linny_menu.padding_size = g:linny_menu_padding_left

  let t:linny_menu.option_lines = []
  let t:linny_menu.section_lines = []
  let t:linny_menu.text_lines = []
  let t:linny_menu.header_lines = []
  let t:linny_menu.footer_lines = []
  for item in a:items
    let item.ln = ln
    call append('$', item.text)
    if item.mode == 0
      let t:linny_menu.option_lines += [ln]
    elseif item.mode == 1
      let t:linny_menu.text_lines += [ln]
    elseif item.mode == 2
      let t:linny_menu.section_lines += [ln]
    elseif item.mode == 3
      let t:linny_menu.header_lines += [ln]
    elseif item.mode == 4
      let t:linny_menu.footer_lines += [ln]
    endif
    let ln += 1
  endfor
  setlocal nomodifiable readonly
  setlocal ft=linny_menu
  let t:linny_menu.items = a:items
  let opt = g:linny_menu_options

  if stridx(opt, 'L') >= 0
    setlocal cursorline
  endif
endfunc

function! linny_menu#RemapGlobalKeys()

  execute "noremap " . g:linny_leader .'0'. " :call linny_menu#openHome()<CR>"
  execute "noremap " . g:linny_leader .'R'. " :call linny_menu#refreshMenu()<CR>"

  call linny_menu#RemapGlobalStarredDocs()
  call linny_menu#RemapGlobalStarredTerms()

endfunction

function! linny_menu#RemapGlobalStarredDocs()
  let starred = linny_menu#starred_docs()
  let titles = linny#titlesForDocs(starred)
  let t_sortable = {}

  for k in keys(titles)
    let t_sortable[tolower(k)] = g:linny_root_path . "/wiki/" . titles[k]
  endfor

  let title_keys = sort(keys(t_sortable))

  let i = 1
  for tk in title_keys
    execute "noremap " . g:linny_leader .'s'.i. " :call linny_menu#openFile('" . t_sortable[tk] ."')<CR>"
    let i += 1
  endfor
endfunction

function! linny_menu#RemapGlobalStarredTerms()
  let starred = linny_menu#starred_terms()
  let starred_list = {}

  for i in starred
    let starred_list[i['taxonomy'].','.i['term']] = i
  endfor

  let i = 1
  for sk in sort(keys(starred_list))
    execute "noremap " . g:linny_leader .'S'.i. " :call linny_menu#openterm('" .starred_list[sk]['taxonomy']."','".starred_list[sk]['term']."')<CR>"
    let i += 1
  endfor
endfunction

function! linny_menu#refreshMenu()
  call linny#Init()
  call linny#make_index()
  call linny_menu#openandshow()
endfunction

function! linny_menu#openHome()
  call linny_menu#openterm('','')
endfunction

function! linny_menu#openFile(filepath)

  if &buftype == 'nofile' && &ft == 'linny_menu'

    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    exec ':botright vs '. a:filepath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"

    setlocal foldcolumn=0

    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute ':e '. a:filepath
  endif

endfunction

"----------------------------------------------------------------------
" all keys
"----------------------------------------------------------------------
function! Setup_keymaps(items)

  let ln = 0
  let cursor_pos = t:linny_menu_cursor
  let nowait = ''

  if v:version >= 704 || (v:version == 703 && has('patch1261'))
    let nowait = '<nowait>'
  endif

  for item in a:items
    if item.key != ''
      let cmd = ' :call <SID>linny_menu_execute('.ln.')<cr>'
      exec "noremap <buffer>".nowait."<silent> ".item.key. cmd
    endif
    let ln += 1
  endfor

  " noremap <silent> <buffer> 0 :call <SID>linny_menu_close()<cr>
  " noremap <silent> <buffer> q :call <SID>linny_menu_close()<cr>

  if t:linny_menu_current_menu_type == "menu_level0"
    noremap <silent> <buffer> t :call linny_menu#open_document_in_new_tab()<cr>
  elseif t:linny_menu_current_menu_type == "menu_level1"
    noremap <silent> <buffer> s :call linny_menu#open_or_create_taxo_key_val()<cr>
    noremap <silent> <buffer> V :call <SID>linny_menu_execute_by_string('cycle_l1_view_reverse')<cr>
  elseif t:linny_menu_current_menu_type == "menu_level2"
    noremap <silent> <buffer> t :call linny_menu#open_document_in_new_tab()<cr>
    noremap <silent> <buffer> V :call <SID>linny_menu_execute_by_string('cycle_l2_view_reverse')<cr>
  endif


  noremap <silent> <buffer> <CR> :call <SID>linny_menu_enter()<cr>

  let t:linny_menu_line = 0
  if cursor_pos > 0
    call cursor(cursor_pos, 1)
  endif
  let t:linny_menu.showhelp = 0
  call Set_cursor()
  augroup linny_menu
    autocmd CursorMoved <buffer> call Set_cursor()
    autocmd InsertEnter <buffer> call feedkeys("\<ESC>")
  augroup END

  let t:linny_menu.showhelp = (stridx(g:linny_menu_options, 'H') >= 0)? 1 : 0

endfunc


"----------------------------------------------------------------------
" reset cursor
"----------------------------------------------------------------------
function! Set_cursor() abort
  let curline = line('.')
  let lastline = t:linny_menu_line
  let movement = (curline < lastline)? -1 : 1
  let find = -1
  let size = len(t:linny_menu.items)
  while 1
    let index = curline - 2
    if index < 0 || index >= size
      break
    endif
    let item = t:linny_menu.items[index]
    if item.mode == 0 && item.event != ''
      let find = index
      break
    endif
    let curline += movement
  endwhile
  if find < 0
    let curline = line('.')
    let curdiff = abs(curline - t:linny_menu.option_lines[0])
    let select = t:linny_menu.option_lines[0]
    for line in t:linny_menu.option_lines
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
  let t:linny_menu_line = find + 2
  call cursor(t:linny_menu_line, g:linny_menu_padding_left + 2)

  if t:linny_menu.showhelp
    let help = t:linny_menu.items[find].help
    let key = t:linny_menu.items[find].key
    echohl linny_menuHelp
    if help != ''
      call Cmdmsg('['.key.']: '.help, 'linny_menuHelp')
    else
      echo ''
    endif
    echohl None
  endif
endfunc

"----------------------------------------------------------------------
" SPECIAL 3RD LEVEL ACTIONS {{{
"----------------------------------------------------------------------
"
function! linny_menu#open_document_in_new_tab()

  let ln = line('.')
  let item = s:get_item_by_index(ln - 2)

  if has_key(item,'option_type')
    if get(item,'option_type') == 'document'
      let strCmd='tabnew'
      exec 'tabnew ' . item.option_data.abs_path
    endif
  end
endfunc


function! linny_menu#open_or_create_taxo_key_val()
  let ln = line('.')
  let item = s:get_item_by_index(ln - 2)

  if has_key(item,'option_type')
    if get(item,'option_type') == 'taxo_key_val'
      call s:createl2config(item.option_data.taxo_key, item.option_data.taxo_term)
    endif
  end
endfunction

"}}}


"----------------------------------------------------------------------
" close linny_menu
"----------------------------------------------------------------------
function! <SID>linny_menu_close()
  close
  redraw | echo "" | redraw
endfunc


"----------------------------------------------------------------------
" execute selected
"----------------------------------------------------------------------
function! <SID>linny_menu_enter() abort
  let ln = line('.')
  call <SID>linny_menu_execute(ln - 2)
endfunc


"----------------------------------------------------------------------
" execute item
"----------------------------------------------------------------------
function! <SID>linny_menu_execute_by_string(cmd) abort
  redraw | echo "" | redraw

  if(a:cmd == 'cycle_l1_view_reverse')
    call linny_menu#cycle_l1_view(-1)
    call linny_menu#openandshow()
  elseif(a:cmd == 'cycle_l2_view_reverse')
    call linny_menu#cycle_l2_view(-1)
    call linny_menu#openandshow()
  endif

endfunction

function! <SID>linny_menu_execute(index) abort

  let item = s:get_item_by_index(a:index)

  if item.mode != 0 || item.event == ''
    return
  endif

  let t:linny_menu_line = a:index + 2
  let t:linny_menu_cursor = t:linny_menu_line

  redraw | echo "" | redraw

    " als event een string is
    if type(item.event) == 1

      if(item.event == 'close')
        close!

      elseif(item.event == 'cycle_l1_view')
        call linny_menu#cycle_l1_view(1)
        call linny_menu#openandshow()

      elseif(item.event == 'dropdown_l1_view')
        call linny_menu#dropdown_l1_view()

      elseif(item.event == 'dropdown_l2_view')
        call linny_menu#dropdown_l2_view()

      elseif(item.event == 'cycle_l2_view')
        call linny_menu#cycle_l2_view(1)
        call linny_menu#openandshow()

      elseif(item.event == 'refresh')
        call linny_menu#refreshMenu()

      elseif(item.event == 'home')
        call linny_menu#openterm('','')

      elseif(item.event == 'createl1config')

        let confFileName = linny#l1_config_filepath(t:linny_menu_taxonomy)

        let fileLines = []
        call add(fileLines, '---')
        call add(fileLines, 'title: '.linny_menu#string_capitalize(t:linny_menu_taxonomy))
        call add(fileLines, 'infotext: About '. t:linny_menu_taxonomy)
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

      elseif(item.event == 'createl2config')
        call s:createl2config(t:linny_menu_taxonomy, t:linny_menu_term)

      elseif(item.event == 'newdocingroup')

        call inputsave()
        let name = input('Enter document name: ')
        call inputrestore()

        echo name
        if(!empty(name))
          call linny_menu#new_document_in_leaf(name)
        else
          return 0
        endif

      elseif item.event[0] != '='
        if item.event =~ "linny_menu#openterm"
          exec item.event
        elseif item.event =~ "!open"
          if item.event =~ "file:///"
            let dirstring = split(item.event, "file://")

            if !filereadable(dirstring[1])
              silent exe "!mkdir -p '".dirstring[1]
            endif
          endif

          silent exec item.event
        else

          let currentwidth = t:linny_menu_lastmaxsize
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

function! s:createl2config(taxonomy, taxo_term)
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
    call add(fileLines, 'title: '.linny_menu#string_capitalize(a:taxo_term))
    call add(fileLines, 'infotext: About '. a:taxo_term)
    call add(fileLines, 'views:')
    call add(fileLines, '  az:')
    call add(fileLines, '    sort: az')
    call add(fileLines, '  date:')
    call add(fileLines, '    sort: date')
    call add(fileLines, '  type:')
    call add(fileLines, '    group_by: type')
    call add(fileLines, 'locations:')
    call add(fileLines, '  #website: https://www.'.a:taxo_term.'.vim')
    "call add(fileLines, '  #dir1: file:///Applications/')
    "call add(fileLines, '  #file1: file:///Projects/file1.someformat')

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

function! linny_menu#new_document_in_leaf(...)
  let title = join(a:000)
  let fileName = linny_wiki#WordFilename(title)
  let relativePath = fnameescape(g:linny_root_path . '/wiki/' . fileName)

  if !filereadable(relativePath)
    let taxonomy = ''
    let taxo_term = ''

    let taxoEntries = []
    if t:linny_menu_taxonomy != "" && t:linny_menu_term != ""
      let entry = {}
      let entry['term'] = t:linny_menu_taxonomy
      let entry['value'] = t:linny_menu_term
      call add(taxoEntries, entry)

      let config = linny#termConfig(t:linny_menu_taxonomy, t:linny_menu_term)
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

  if bufname('%') =~ "[linny_menu]"
    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    execute ':botright vs '. relativePath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"
    setlocal foldcolumn=0
    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute 'e '. relativePath
  end

endfunction

function! PrePad(s,amt,...)
    if a:0 > 0
        let char = a:1
    else
        let char = ' '
    endif
    return repeat(char,a:amt - len(a:s)) . a:s
endfunction

"----------------------------------------------------------------------
" selectable items, generate keymap
"----------------------------------------------------------------------
function! Select_items() abort

  let items = []
  let index = 1

  let lastmode = 2
  for item in t:linny_menu_items
    if item.mode == 0
      if item.key == ''
        let item.key = PrePad(index, 1,0)
        let index += 1
      endif
    endif

    let items += [item]
  endfor

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
  let padding = repeat(' ', g:linny_menu_padding_left)

  if a:item.mode == 0
    let help = Expand_text(get(a:item, 'help', ''))
  endif

  for curline in split(text, "\n", 1)

    let item = {}
    "let item = a:item

    let item.mode = a:item.mode
    let item.text = curline
    let item.event = ''
    let item.option_type = a:item.option_type
    let item.option_data = a:item.option_data
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

function! linny_menu#string_capitalize(capstring)
  return toupper(strpart(a:capstring, 0, 1)).strpart(a:capstring,1)
endfunction


"----------------------------------------------------------------------
" testing case
"----------------------------------------------------------------------
if 0

  call linny_menu#reset()

  call linny_menu#append("/  <home>" , "home", "...", '', '' ,'0')
  call s:add_item_special_event("/  <home>", "home", '0')
  call linny_menu#append('# Start', '')
  call s:add_item_section('# Start 2')
  call linny_menu#append('test1', 'echo 1', 'help 1', '0', '2', '3')
  call linny_menu#append('test2', 'echo 2', 'help 2')

  call linny_menu#append('# Misc', '')
  call linny_menu#append('test3', 'echo 3')
  call linny_menu#append('test4', 'echo 4')
  call linny_menu#append("test5\nasdfafffff\njkjkj", 'echo 5')
  call linny_menu#append('text1', '')
  call linny_menu#append('text2', '')
  call linny_menu#append("-----------------------------------------", '')
  call linny_menu#append("some title", ":botright vs ". g:linny_root_path . "/wiki/sometitle.md", "...")

  call s:add_item_document("some title", g:linny_root_path . "/wiki/sometitle.md", '')

  call linny_menu#list()
endif


