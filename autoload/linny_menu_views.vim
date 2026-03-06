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

      call luaeval("require('linny.menu.items').add_section(_A)", "# ". widget['title'])
      if widget['type'] == "starred_documents"
        call luaeval("require('linny.menu.widgets').starred_documents(_A)", widget)
      elseif widget['type'] == "menu"
        call luaeval("require('linny.menu.widgets').menu(_A)", widget)
      elseif widget['type'] == "starred_terms"
        call luaeval("require('linny.menu.widgets').starred_terms(_A)", widget)
      elseif widget['type'] == "starred_taxonomies"
        call luaeval("require('linny.menu.widgets').starred_taxonomies(_A)", widget)
      elseif widget['type'] == "all_taxonomies"
        call luaeval("require('linny.menu.widgets').all_taxonomies(_A)", widget)
      elseif widget['type'] == "recently_modified_documents"
        call luaeval("require('linny.menu.widgets').recently_modified_documents(_A)", widget)
      elseif widget['type'] == "all_level0_views"
        call luaeval("require('linny.menu.widgets').all_level0_views(_A)", widget)
      else
        call luaeval("require('linny.menu.items').add_section(_A)", "## ERROR unsupported widget type: ". widget['type'])
      endif

    endfor
  endif

  call luaeval("require('linny.menu.items').add_section(_A)", "# Configuration")
  call luaeval("require('linny.menu.items').add_document(_A[1], _A[2], _A[3], _A[4])", ["Edit this view", g:linny_path_wiki_config ."/views/".a:view_name.".yml", 'c', 'file'])
endfunction

" Cycle L1 view (taxonomy level) - delegates to Lua
function! linny_menu_views#cycle_l1(direction)
  call luaeval("require('linny.menu.views').cycle_l1(_A)", a:direction)
endfunction

" Cycle L2 view (term level) - delegates to Lua
function! linny_menu_views#cycle_l2(direction)
  call luaeval("require('linny.menu.views').cycle_l2(_A)", a:direction)
endfunction

" Dropdown L1 view callback
function! linny_menu_views#dropdown_l1_callback(id, result)
  if a:result != -1
    let state = luaeval("require('linny.menu.state').term_leaf_state(_A)", t:linny_menu_taxonomy)
    let state.active_view = a:result-1

    call luaeval("require('linny.menu.state').write_term_leaf_state(_A[1], _A[2])", [t:linny_menu_taxonomy, state])
    call linny_menu#openandshow()
  endif
endfunction

" Show L1 view dropdown
function! linny_menu_views#dropdown_l1()
  let state = luaeval("require('linny.menu.state').term_leaf_state(_A)", t:linny_menu_taxonomy)
  let active_view = luaeval("require('linny.menu.views').get_active(_A)", state)
  let config = linny#tax_config(t:linny_menu_taxonomy)
  let views = luaeval("require('linny.menu.views').get_list(_A)", config)

  call linny_menu_popup#create(views, #{
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
    let state = luaeval("require('linny.menu.state').term_value_leaf_state(_A[1], _A[2])", [t:linny_menu_taxonomy, t:linny_menu_term])
    let state.active_view = a:result-1
    call luaeval("require('linny.menu.state').write_term_value_leaf_state(_A[1], _A[2], _A[3])", [t:linny_menu_taxonomy, t:linny_menu_term, state])
    call linny_menu#openandshow()
  endif
endfunction

" Show L2 view dropdown
function! linny_menu_views#dropdown_l2()
  let state = luaeval("require('linny.menu.state').term_value_leaf_state(_A[1], _A[2])", [t:linny_menu_taxonomy, t:linny_menu_term])
  let active_view = luaeval("require('linny.menu.views').get_active(_A)", state)
  let config = linny#term_config(t:linny_menu_taxonomy, t:linny_menu_term)
  let views = luaeval("require('linny.menu.views').get_list(_A)", config)

  call linny_menu_popup#create(views, #{
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
