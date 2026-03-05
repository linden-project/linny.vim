" linny_menu_render.vim - Menu rendering functions for different levels

" Render level 0 (root/view level)
function! linny_menu_render#level0(view_name)
  let t:linny_menu_current_menu_type = "menu_level0"
  call linny_menu_state#reset()
  call linny_menu_views#render(a:view_name)
endfunction

" Render level 1 (taxonomy level)
function! linny_menu_render#level1(tax)

  let t:linny_menu_current_menu_type = "menu_level1"

  let tax_config = linny#tax_config(a:tax)

  let tax_plural = a:tax
  if has_key(tax_config, 'plural')
    let tax_plural = get(tax_config, 'plural')
  end

  call linny_menu_state#reset()
  call linny_menu_items#add_special_event("/  <home>", "home", '0')
  call linny_menu_items#add_special_event(".. <up>", "home", 'u')
  call linny_menu_items#add_section("# " . toupper(tax_plural) )
  call linny_menu_items#add_divider()

  let views_string = ""
  let views_list = linny_menu_views#get_list(tax_config)
  let views = linny_menu_views#get_views(tax_config)

  let l1_state = linny_menu_state#term_leaf_state(a:tax)
  let active_view = linny_menu_views#get_active(l1_state)

  if len(views) < 3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = linny_menu_util#calc_active_view_arrow(views_list, active_view, 4)

    call linny_menu_items#add_section("### VIEW")
    call linny_menu_items#add_special_event("". views_string  , "cycle_l1_view", 'v')
    call linny_menu_items#add_text(active_arrow_string)
    call linny_menu_items#add_divider()

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call linny_menu_items#add_section("### VIEW")
    call linny_menu_items#add_special_event("". views_string  , "dropdown_l1_view", 'v')
    call linny_menu_items#add_divider()

  endif


  let view_props = linny_menu_views#current_props(active_view, views_list, views)

  if has_key(view_props, 'sort')
    let sort = get(view_props,'sort')
  else
    let sort = "az"
  end

  let group_by = ''

  if has_key(tax_config, 'views')
    let views = get(tax_config, 'views')
    let views_list = keys(views)
    if has_key(views[views_list[0]], 'group_by' )
      let group_by = get(views[views_list[0]], 'group_by')
    end
  end

  let termslistDict = linny#parse_json_file( linny#l1_index_filepath(a:tax), [] )
  let termslist = keys(termslistDict)

  let term_menu = {}

  for val in sort(termslist)

    if linny_menu_render#display_file_ask_view_props(view_props, termslistDict[val])

      if has_key(view_props, 'group_by')
        let group_by = get(view_props,'group_by')

        if(has_key(termslistDict[val], group_by))

          let group_by_val = substitute(tolower(get(termslistDict[val], group_by)), '-', ' ', 'g')

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

        if !has_key(term_menu,'Terms')
          let term_menu['Terms'] = []
        end
        call add(term_menu['Terms'], val)

      endif
    endif

  endfor

  for group in sort(keys(term_menu))
    call linny_menu_items#add_section("### " . linny_menu_util#string_capitalize( substitute(group, '-', ' ', 'g') ) )

    for val in term_menu[group]
      call linny_menu_items#add_document_taxo_key_val(a:tax, val, 0)
    endfor

  endfor

  call linny_menu_items#add_empty_line()
  call linny_menu_items#add_divider()

  call linny_menu_items#add_section("### " . toupper('Configuration'))

  if filereadable(linny#l1_config_filepath(a:tax))
    call linny_menu_items#add_document("Open ". a:tax." Config", linny#l1_config_filepath(a:tax),'c', 'file')
  else
    call linny_menu_items#add_special_event("Create ". a:tax." Config", "createl1config", 'C')
  endif

endfunction

" Render debug info partial
function! linny_menu_render#partial_debug_info()
  call linny_menu_items#add_section("### " . linny_menu_util#string_capitalize('debug'))
  call linny_menu_items#add_text("t:linny_menu_lastmaxsize = ".t:linny_menu_lastmaxsize)
  call linny_menu_items#add_text("t:linny_menu_name = ".t:linny_menu_name)
  call linny_menu_items#add_text("t:linny_menu_taxonomy = ".t:linny_menu_taxonomy)
  call linny_menu_items#add_text("t:linny_menu_term = ".t:linny_menu_term)
  call linny_menu_items#add_text("t:linny_menu_view = ".t:linny_menu_view)
  call linny_menu_items#add_text("g:linny_index_version = ".g:linny_index_version)
  call linny_menu_items#add_text("g:linny_index_path = ".g:linny_index_path)
  call linny_menu_items#add_text("Loading time = ".t:linny_load_time)
endfunction

" Render level 2 (term level)
function! linny_menu_render#level2(tax, term)

  let t:linny_menu_current_menu_type = "menu_level2"

  let infotext =''
  let group_by =''

  let l2_config = linny#term_config(a:tax, a:term)

  let tax_config = linny#tax_config(a:tax)

  let tax_plural = a:tax
  if has_key(tax_config, 'plural')
    let tax_plural = get(tax_config, 'plural')
  end

  call linny_menu_state#reset()

  call linny_menu_items#add_special_event("/  <home>", "home", '0')
  call linny_menu_items#add_ex_event(".. <up> ". tax_plural, ":call linny_menu#openterm('".a:tax."','')", 'u')
  call linny_menu_items#add_section("# " . toupper(a:tax) . ': ' . toupper(a:term))

  call linny_menu_items#add_divider()

  if has_key(l2_config, 'infotext')
    let infotext =  get(l2_config,'infotext')
    call linny_menu_items#add_text(infotext)
  endif

  let views_string = ""
  let views_list = linny_menu_views#get_list(l2_config)
  let views = linny_menu_views#get_views(l2_config)
  let l2_state = linny_menu_state#term_value_leaf_state(a:tax, a:term)
  let active_view = linny_menu_views#get_active(l2_state)

  if len(views) <=3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = linny_menu_util#calc_active_view_arrow(views_list, active_view, 4)

    call linny_menu_items#add_section("### VIEW")
    call linny_menu_items#add_special_event("". views_string  , "cycle_l2_view", 'v')

    call linny_menu_items#add_text(active_arrow_string)
    call linny_menu_items#add_divider()

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call linny_menu_items#add_section("### VIEW")
    call linny_menu_items#add_special_event("". views_string  , "dropdown_l2_view", 'v')
    call linny_menu_items#add_divider()

  endif

  let files_in_menu = linny#parse_json_file(linny#l2_index_filepath( a:tax, a:term), [])
  let view_props = linny_menu_views#current_props(active_view, views_list, views)
  let files_index = linny#parse_json_file(g:linny_index_path . '/_index_docs_with_props.json',[])

  let t:linny_tasks_count = linny#parse_json_file(g:linny_index_path . '/_index_docs_tasks_count.json',{})

  let files_menu = {}

  for file_in_menu in files_in_menu
    let hide = 0

    if has_key(files_index, file_in_menu)
      if linny_menu_render#display_file_ask_view_props(view_props, files_index[file_in_menu])

        let file_in_menu_dict = {}
        let file_in_menu_dict.file = file_in_menu
        let file_in_menu_dict.fm = files_index[file_in_menu]

        if has_key(view_props, 'group_by')
          let group_by = get(view_props,'group_by')

          if has_key(files_index[file_in_menu], group_by)
            "let group_by_val = tolower(get(files_index[file_in_menu], group_by))
            let group_by_val = substitute(tolower(get(files_index[file_in_menu], group_by)), '-', ' ', 'g')

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

      endif
    endif

  endfor

  for group in sort(keys(files_menu))
    call linny_menu_items#add_section("### " . linny_menu_util#string_capitalize(group))
    call linny_menu_widgets#partial_files_listing( files_menu[group], view_props , 1)
  endfor

  call linny_menu_items#add_empty_line()
  call linny_menu_items#add_divider()

  if has_key(l2_config, 'mounts')
    let mounts = get(l2_config,'mounts')
    if(type(mounts)==4)
      for m in keys(mounts)
        call linny_menu_items#add_section("### MOUNT: " . m)
        let mountfiles = glob(mounts[m].source . "/*.md",0, 1)
        let excludes = []
        if has_key(mounts[m], 'exclude')
          let excludes = mounts[m].exclude
        endif
        for mfile in mountfiles
          let filename = split(mfile,"/")[-1]
          if index(excludes, filename) != 0
            call linny_menu_items#add_document(filename, mfile, '', 'file')
          endif
        endfor
      endfor
    endif

    call linny_menu_items#add_empty_line()
    call linny_menu_items#add_divider()

  endif

  if has_key(l2_config, 'locations')
    let locations = get(l2_config,'locations')
    if(type(locations)==4)
      call linny_menu_items#add_section("### " . toupper('Locations'))

      for l in keys(locations)
        call linny_menu_items#add_external_location(l, get(locations,l))
      endfor
    endif
  endif

  call linny_menu_items#add_section("### " . toupper('Configuration'))

  if filereadable(linny#l2_config_filepath(a:tax, a:term))
    call linny_menu_items#add_document("Open config: ".a:term."", linny#l2_config_filepath(a:tax, a:term),'c', 'file')
  else
    call linny_menu_items#add_special_event("Create config: ". a:term." Config", "createl2config", 'c')
  endif

  call linny_menu_items#add_section("### " . toupper('hot keys'))
  call linny_menu_items#add_special_event("<new document>", "newdocingroup", 'A')
  call linny_menu_items#add_special_event("<open context menu>", "opencontextmenu", 'm')
endfunc

" Render footer items partial
function! linny_menu_render#partial_footer_items()
  call linny_menu_items#add_special_event("<refresh>", "refresh", 'R')
  call linny_menu_items#add_special_event("<home>", "home", 'H')
  call linny_menu_items#add_special_event("<online book>", "onlinebook", '?')
  call linny_menu_items#add_empty_line()

  let fred_version = system('fred version')
  if v:shell_error != 0
    let fred_version = "not installed"
  endif

  call linny_menu_items#add_footer('linny: ' . luaeval("require('linny.version').plugin_version()"))
  call linny_menu_items#add_footer('fred:  ' . fred_version)
endfunction

" Check if file should be displayed based on view properties
function! linny_menu_render#display_file_ask_view_props(view_props, file_dict)

  if has_key(a:view_props, 'except')
    for except_dict in a:view_props.except
      if linny_menu_render#test_file_with_display_expression(a:file_dict, except_dict)
        return 0
      endif
    endfor
  endif

  if has_key(a:view_props, 'only')
    let onlycount = 0
    for only_dict in a:view_props.only
      if linny_menu_render#test_file_with_display_expression(a:file_dict, only_dict)
        let onlycount += 1
      endif
    endfor

    if onlycount == len(a:view_props.only)
      return 1
    else
      return 0
    endif

  endif

  return 1

endfunction

" Test file against display expression
function! linny_menu_render#test_file_with_display_expression(file_dict, expr)

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
