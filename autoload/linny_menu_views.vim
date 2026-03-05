" linny_menu_views.vim - View management functions for linny menu

" Render a view with its widgets
function! linny_menu_views#render(view_name)
  let view_config = linny#view_config(a:view_name)
  if has_key(view_config, 'widgets')
    let widgets = get(view_config,'widgets')
    for widget in widgets

      if has_key(widget, 'hidden') && widget['hidden']
        continue
      endif

      call linny_menu_items#add_section("# ". widget['title'])
      if widget['type'] == "starred_documents"
        call linny_menu_widgets#starred_documents(widget)
      elseif widget['type'] == "menu"
        call linny_menu_widgets#menu(widget)
      elseif widget['type'] == "starred_terms"
        call linny_menu_widgets#starred_terms(widget)
      elseif widget['type'] == "starred_taxonomies"
        call linny_menu_widgets#starred_taxonomies(widget)
      elseif widget['type'] == "all_taxonomies"
        call linny_menu_widgets#all_taxonomies(widget)
      elseif widget['type'] == "recently_modified_documents"
        call linny_menu_widgets#recently_modified_documents(widget)
      elseif widget['type'] == "all_level0_views"
        call linny_menu_widgets#all_level0_views(widget)
      else
        call linny_menu_items#add_section("## ERROR unsupported widget type: ". widget['type'])
      endif

    endfor
  endif

  call linny_menu_items#add_section("# Configuration")
  call linny_menu_items#add_document("Edit this view", g:linny_path_wiki_config ."/views/".a:view_name.".yml", 'c', 'file')
endfunction

" Cycle L1 view (taxonomy level)
function! linny_menu_views#cycle_l1(direction)
  let state = linny_menu_state#term_leaf_state(t:linny_menu_taxonomy)
  let active_view = linny_menu_views#get_active(state)
  let config = linny#tax_config(t:linny_menu_taxonomy)
  let views = linny_menu_views#get_list(config)

  let newstate = linny_menu_views#new_active(state, views, a:direction, active_view)
  call linny_menu_state#write_term_leaf_state(t:linny_menu_taxonomy, newstate)
endfunction

" Cycle L2 view (term level)
function! linny_menu_views#cycle_l2(direction)
  let state = linny_menu_state#term_value_leaf_state(t:linny_menu_taxonomy, t:linny_menu_term)

  let active_view = linny_menu_views#get_active(state)
  let config = linny#term_config(t:linny_menu_taxonomy, t:linny_menu_term)
  let views = linny_menu_views#get_list(config)

  let newstate = linny_menu_views#new_active(state, views, a:direction, active_view)
  call linny_menu_state#write_term_value_leaf_state(t:linny_menu_taxonomy, t:linny_menu_term, newstate)
endfunction

" Dropdown L1 view callback
function! linny_menu_views#dropdown_l1_callback(id, result)
  if a:result != -1
    let state = linny_menu_state#term_leaf_state(t:linny_menu_taxonomy)
    let state.active_view = a:result-1

    call linny_menu_state#write_term_leaf_state(t:linny_menu_taxonomy, state)
    call linny_menu#openandshow()
  endif
endfunction

" Show L1 view dropdown
function! linny_menu_views#dropdown_l1()
  let state = linny_menu_state#term_leaf_state(t:linny_menu_taxonomy)
  let active_view = linny_menu_views#get_active(state)
  let config = linny#tax_config(t:linny_menu_taxonomy)
  let views = linny_menu_views#get_list(config)

  call linny_menu#create_popup(views, #{
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
        \ callback: 'linny_menu_views#dropdown_l1_callback',
        \ })
endfunction

" Dropdown L2 view callback
function! linny_menu_views#dropdown_l2_callback(id, result)
  if a:result != -1
    let state = linny_menu_state#term_value_leaf_state(t:linny_menu_taxonomy, t:linny_menu_term)
    let state.active_view = a:result-1
    call linny_menu_state#write_term_value_leaf_state(t:linny_menu_taxonomy, t:linny_menu_term, state)
    call linny_menu#openandshow()
  endif
endfunction

" Show L2 view dropdown
function! linny_menu_views#dropdown_l2()
  let state = linny_menu_state#term_value_leaf_state(t:linny_menu_taxonomy, t:linny_menu_term)
  let active_view = linny_menu_views#get_active(state)
  let config = linny#term_config(t:linny_menu_taxonomy, t:linny_menu_term)
  let views = linny_menu_views#get_list(config)

  call linny_menu#create_popup(views, #{
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
        \ callback: 'linny_menu_views#dropdown_l2_callback',
        \ })
endfunction

" Calculate new active view after cycling
function! linny_menu_views#new_active(state, views, direction, active_view)
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

" Get list of view names from config
function! linny_menu_views#get_list(config)
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

" Get views dictionary from config
function! linny_menu_views#get_views(config)
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

" Get active view index from state
function! linny_menu_views#get_active(state)
  if has_key(a:state, 'active_view')
   return get(a:state, 'active_view')
  else
    return 0
  end
endfunction

" Get current view properties
function! linny_menu_views#current_props(active_view, views_list, views)
  if len(a:views_list) > a:active_view
    return a:views[a:views_list[a:active_view]]
  else
    return a:views[a:views_list[0]]
  endif
endfunction
