" linny_menu_render.vim - Menu rendering functions for different levels

" Render level 0 (root/view level)
function! linny_menu_render#level0(view_name)
  let t:linny_menu_current_menu_type = "menu_level0"
  call luaeval("require('linny.menu.state').reset()")
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

  call luaeval("require('linny.menu.state').reset()")
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["/  <home>", "home", '0'])
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", [".. <up>", "home", 'u'])
  call luaeval("require('linny.menu.items').add_section(_A)", "# " . toupper(tax_plural))
  call luaeval("require('linny.menu.items').add_divider()")

  let views_string = ""
  let views_list = luaeval("require('linny.menu.views').get_list(_A)", tax_config)
  let views = luaeval("require('linny.menu.views').get_views(_A)", tax_config)

  let l1_state = luaeval("require('linny.menu.state').term_leaf_state(_A)", a:tax)
  let active_view = luaeval("require('linny.menu.views').get_active(_A)", l1_state)

  if len(views) < 3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = luaeval("require('linny.menu.util').calc_active_view_arrow(_A[1], _A[2], _A[3])", [views_list, active_view, 4])

    call luaeval("require('linny.menu.items').add_section(_A)", "### VIEW")
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", [views_string, "cycle_l1_view", 'v'])
    call luaeval("require('linny.menu.items').add_text(_A)", active_arrow_string)
    call luaeval("require('linny.menu.items').add_divider()")

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call luaeval("require('linny.menu.items').add_section(_A)", "### VIEW")
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", [views_string, "dropdown_l1_view", 'v'])
    call luaeval("require('linny.menu.items').add_divider()")

  endif


  let view_props = luaeval("require('linny.menu.views').current_props(_A[1], _A[2], _A[3])", [active_view, views_list, views])

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
    call luaeval("require('linny.menu.items').add_section(_A)", "### " . luaeval("require('linny.menu.util').string_capitalize(_A)", substitute(group, '-', ' ', 'g')))

    for val in term_menu[group]
      call luaeval("require('linny.menu.items').add_document_taxo_key_val(_A[1], _A[2], _A[3])", [a:tax, val, 0])
    endfor

  endfor

  call luaeval("require('linny.menu.items').add_empty_line()")
  call luaeval("require('linny.menu.items').add_divider()")

  call luaeval("require('linny.menu.items').add_section(_A)", "### " . toupper('Configuration'))

  if filereadable(linny#l1_config_filepath(a:tax))
    call luaeval("require('linny.menu.items').add_document(_A[1], _A[2], _A[3], _A[4])", ["Open ". a:tax." Config", linny#l1_config_filepath(a:tax), 'c', 'file'])
  else
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["Create ". a:tax." Config", "createl1config", 'C'])
  endif

endfunction

" Render debug info partial
function! linny_menu_render#partial_debug_info()
  call luaeval("require('linny.menu.items').add_section(_A)", "### " . luaeval("require('linny.menu.util').string_capitalize(_A)", 'debug'))
  call luaeval("require('linny.menu.items').add_text(_A)", "t:linny_menu_lastmaxsize = ".t:linny_menu_lastmaxsize)
  call luaeval("require('linny.menu.items').add_text(_A)", "t:linny_menu_name = ".t:linny_menu_name)
  call luaeval("require('linny.menu.items').add_text(_A)", "t:linny_menu_taxonomy = ".t:linny_menu_taxonomy)
  call luaeval("require('linny.menu.items').add_text(_A)", "t:linny_menu_term = ".t:linny_menu_term)
  call luaeval("require('linny.menu.items').add_text(_A)", "t:linny_menu_view = ".t:linny_menu_view)
  call luaeval("require('linny.menu.items').add_text(_A)", "g:linny_index_version = ".g:linny_index_version)
  call luaeval("require('linny.menu.items').add_text(_A)", "g:linny_index_path = ".g:linny_index_path)
  call luaeval("require('linny.menu.items').add_text(_A)", "Loading time = ".t:linny_load_time)
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

  call luaeval("require('linny.menu.state').reset()")

  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["/  <home>", "home", '0'])
  call luaeval("require('linny.menu.items').add_ex_event(_A[1], _A[2], _A[3])", [".. <up> ". tax_plural, ":call linny_menu#openterm('".a:tax."','')", 'u'])
  call luaeval("require('linny.menu.items').add_section(_A)", "# " . toupper(a:tax) . ': ' . toupper(a:term))

  call luaeval("require('linny.menu.items').add_divider()")

  if has_key(l2_config, 'infotext')
    let infotext =  get(l2_config,'infotext')
    call luaeval("require('linny.menu.items').add_text(_A)", infotext)
  endif

  let views_string = ""
  let views_list = luaeval("require('linny.menu.views').get_list(_A)", l2_config)
  let views = luaeval("require('linny.menu.views').get_views(_A)", l2_config)
  let l2_state = luaeval("require('linny.menu.state').term_value_leaf_state(_A[1], _A[2])", [a:tax, a:term])
  let active_view = luaeval("require('linny.menu.views').get_active(_A)", l2_state)

  if len(views) <=3 && !has_key(views,'NONE')
    for view in views_list
      let views_string = views_string . "[" .view . "]"
    endfor

    let active_arrow_string = luaeval("require('linny.menu.util').calc_active_view_arrow(_A[1], _A[2], _A[3])", [views_list, active_view, 4])

    call luaeval("require('linny.menu.items').add_section(_A)", "### VIEW")
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", [views_string, "cycle_l2_view", 'v'])

    call luaeval("require('linny.menu.items').add_text(_A)", active_arrow_string)
    call luaeval("require('linny.menu.items').add_divider()")

  elseif len(views) > 1

    let views_string = views_string . "[" .views_list[active_view] . " ▼]"

    call luaeval("require('linny.menu.items').add_section(_A)", "### VIEW")
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", [views_string, "dropdown_l2_view", 'v'])
    call luaeval("require('linny.menu.items').add_divider()")

  endif

  let files_in_menu = linny#parse_json_file(linny#l2_index_filepath( a:tax, a:term), [])
  let view_props = luaeval("require('linny.menu.views').current_props(_A[1], _A[2], _A[3])", [active_view, views_list, views])
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
    call luaeval("require('linny.menu.items').add_section(_A)", "### " . luaeval("require('linny.menu.util').string_capitalize(_A)", group))
    call luaeval("require('linny.menu.widgets').partial_files_listing(_A[1], _A[2], _A[3])", [files_menu[group], view_props, 1])
  endfor

  call luaeval("require('linny.menu.items').add_empty_line()")
  call luaeval("require('linny.menu.items').add_divider()")

  if has_key(l2_config, 'mounts')
    let mounts = get(l2_config,'mounts')
    if(type(mounts)==4)
      for m in keys(mounts)
        call luaeval("require('linny.menu.items').add_section(_A)", "### MOUNT: " . m)
        let mountfiles = glob(mounts[m].source . "/*.md",0, 1)
        let excludes = []
        if has_key(mounts[m], 'exclude')
          let excludes = mounts[m].exclude
        endif
        for mfile in mountfiles
          let filename = split(mfile,"/")[-1]
          if index(excludes, filename) != 0
            call luaeval("require('linny.menu.items').add_document(_A[1], _A[2], _A[3], _A[4])", [filename, mfile, '', 'file'])
          endif
        endfor
      endfor
    endif

    call luaeval("require('linny.menu.items').add_empty_line()")
    call luaeval("require('linny.menu.items').add_divider()")

  endif

  if has_key(l2_config, 'locations')
    let locations = get(l2_config,'locations')
    if(type(locations)==4)
      call luaeval("require('linny.menu.items').add_section(_A)", "### " . toupper('Locations'))

      for l in keys(locations)
        call luaeval("require('linny.menu.items').add_external_location(_A[1], _A[2])", [l, get(locations,l)])
      endfor
    endif
  endif

  call luaeval("require('linny.menu.items').add_section(_A)", "### " . toupper('Configuration'))

  if filereadable(linny#l2_config_filepath(a:tax, a:term))
    call luaeval("require('linny.menu.items').add_document(_A[1], _A[2], _A[3], _A[4])", ["Open config: ".a:term."", linny#l2_config_filepath(a:tax, a:term), 'c', 'file'])
  else
    call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["Create config: ". a:term." Config", "createl2config", 'c'])
  endif

  call luaeval("require('linny.menu.items').add_section(_A)", "### " . toupper('hot keys'))
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["<new document>", "newdocingroup", 'A'])
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["<open context menu>", "opencontextmenu", 'm'])
endfunc

" Render footer items partial
function! linny_menu_render#partial_footer_items()
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["<refresh>", "refresh", 'R'])
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["<home>", "home", 'H'])
  call luaeval("require('linny.menu.items').add_special_event(_A[1], _A[2], _A[3])", ["<online book>", "onlinebook", '?'])
  call luaeval("require('linny.menu.items').add_empty_line()")

  let fred_version = system('fred version')
  if v:shell_error != 0
    let fred_version = "not installed"
  endif

  call luaeval("require('linny.menu.items').add_footer(_A)", 'linny: ' . luaeval("require('linny.version').plugin_version()"))
  call luaeval("require('linny.menu.items').add_footer(_A)", 'fred:  ' . fred_version)
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
