" linny_menu_actions.vim - Dropdown menu actions and content menu execution
" NOTE: Core logic migrated to lua/linny/menu/actions.lua
" Popup callbacks must remain in VimScript (Vim popup API requirement)

" Show action dropdown for current item
function! linny_menu_actions#dropdown_item()
  let t:linny_menu_dropdownviews = luaeval("require('linny.menu.actions').build_dropdown_views(_A)", t:linny_menu_item_for_dropdown)

  if len(t:linny_menu_dropdownviews) == 0
    return
  endif

  let name = luaeval("require('linny.menu.actions').get_item_name(_A)", t:linny_menu_item_for_dropdown)

  call luaeval("require('linny.menu.popup').create(_A[1], _A[2])", [t:linny_menu_dropdownviews, #{
        \ zindex: 200,
        \ drag: 0,
        \ line: t:linny_menu_line + 1,
        \ title: 'Action for '.name,
        \ col: 10,
        \ wrap: 0,
        \ border: [],
        \ cursorline: 1,
        \ padding: [0,1,0,1],
        \ filter: 'popup_filter_menu',
        \ mapping: 0,
        \ callback: 'linny_menu_actions#dropdown_item_callback',
        \ }])

endfunction

" Handle dropdown selection
function! linny_menu_actions#dropdown_item_callback(id, result)
  if a:result != -1
    let action = t:linny_menu_dropdownviews[a:result-1]
    " Try Lua first, fall back to VimScript for popup-dependent actions
    let handled = luaeval("require('linny.menu.actions').exec_content_menu(_A[1], _A[2])", [action, t:linny_menu_item_for_dropdown])
    if !handled
      call linny_menu_actions#exec_content_menu(action, t:linny_menu_item_for_dropdown)
    endif
  else
    let t:linny_menu_item_for_dropdown = 0
  endif
endfunction

" Handle taxonomy selection
function! linny_menu_actions#dropdown_taxo_item_callback(id, result)

  if a:result != -1

      let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])
      let t:linny_menu_set_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

      let termslistDict = linny#parse_json_file(linny#l1_index_filepath(t:linny_menu_set_taxo), [] )
      let t:linny_menu_term_items_for_dropdown = sort(keys(termslistDict))

      call luaeval("require('linny.menu.popup').create(_A[1], _A[2])", [t:linny_menu_term_items_for_dropdown, #{
            \ zindex: 400,
            \ drag: 0,
            \ line: t:linny_menu_line + 1,
            \ title: name . ': ' . t:linny_menu_set_taxo . ' > Set Term',
            \ col: 10,
            \ wrap: 0,
            \ border: [],
            \ cursorline: 1,
            \ padding: [0,1,0,1],
            \ filter: 'popup_filter_menu',
            \ mapping: 0,
            \ callback: 'linny_menu_actions#dropdown_term_item_callback',
            \ }])
    return
  endif
  return
endfunction

" Handle taxonomy removal
function! linny_menu_actions#dropdown_remove_taxo_item_callback(id, result)
  if a:result != -1
    let item = t:linny_menu_item_for_dropdown
    let unset_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

    call luaeval("require('linny.menu.actions').job_start(_A)", ["fred", "unset_key", item.option_data.abs_path, unset_taxo])

    echo "Removed ". unset_taxo . " from " . item.option_data.abs_path
  endif
endfunction

" Handle term selection
function! linny_menu_actions#dropdown_term_item_callback(id, result)
  if a:result != -1
    let item = t:linny_menu_item_for_dropdown
    let taxo_item = t:linny_menu_set_taxo
    let term_item = t:linny_menu_term_items_for_dropdown[a:result-1]

    call luaeval("require('linny.menu.actions').job_start(_A)", ["fred", "set_string_val", item.option_data.abs_path, taxo_item, term_item])
    let t:linny_menu_repeat_last_taxo_term = [taxo_item, term_item]
  endif
endfunction

" Execute content menu action (popup-dependent actions only)
" Most actions are handled by Lua - this handles only popup-creating actions
function! linny_menu_actions#exec_content_menu(action, item)
  if a:item.option_type == 'document'

    if a:action == "set taxonomy"
      let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])

      let t:linny_menu_taxo_items_for_dropdown = sort(index_keys_list)
      let name = luaeval("require('linny.menu.actions').get_item_name(_A)", t:linny_menu_item_for_dropdown)

      call luaeval("require('linny.menu.popup').create(_A[1], _A[2])", [t:linny_menu_taxo_items_for_dropdown, #{
            \ zindex: 300,
            \ drag: 0,
            \ line: t:linny_menu_line + 1,
            \ title: name . ': Set Taxonomy',
            \ col: 10,
            \ wrap: 0,
            \ border: [],
            \ cursorline: 1,
            \ padding: [0,1,0,1],
            \ filter: 'popup_filter_menu',
            \ mapping: 0,
            \ callback: 'linny_menu_actions#dropdown_taxo_item_callback',
            \ }])
      return

    elseif a:action == "remove taxonomy"
      let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])

      let t:linny_menu_taxo_items_for_dropdown = sort(index_keys_list)
      let name = luaeval("require('linny.menu.actions').get_item_name(_A)", t:linny_menu_item_for_dropdown)

      call luaeval("require('linny.menu.popup').create(_A[1], _A[2])", [t:linny_menu_taxo_items_for_dropdown, #{
            \ zindex: 300,
            \ drag: 0,
            \ line: t:linny_menu_line + 1,
            \ title: name . ': Remove Taxonomy',
            \ col: 10,
            \ wrap: 0,
            \ border: [],
            \ cursorline: 1,
            \ padding: [0,1,0,1],
            \ filter: 'popup_filter_menu',
            \ mapping: 0,
            \ callback: 'linny_menu_actions#dropdown_remove_taxo_item_callback',
            \ }])
      return

    endif

  endif
endfunction
