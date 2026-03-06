" linny_menu_actions.vim - Dropdown menu action callbacks for linny menu
" NOTE: Core logic migrated to lua/linny/menu/actions.lua
" Popup callbacks must remain in VimScript (Vim popup API requirement)

" Show action dropdown for current item - delegates to Lua
function! linny_menu_actions#dropdown_item()
  call luaeval("require('linny.menu.actions').dropdown_item()")
endfunction

" Handle dropdown selection (must remain in VimScript for Vim popup API)
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

" Handle taxonomy selection (must remain in VimScript for Vim popup API)
function! linny_menu_actions#dropdown_taxo_item_callback(id, result)
  if a:result != -1
    let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])
    let t:linny_menu_set_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

    let termslistDict = linny#parse_json_file(linny#l1_index_filepath(t:linny_menu_set_taxo), [])
    let terms = sort(keys(termslistDict))

    " Delegate popup creation to Lua
    call luaeval("require('linny.menu.actions').show_term_selection(_A[1], _A[2], _A[3], _A[4])", [name, t:linny_menu_set_taxo, terms, t:linny_menu_line])
  endif
endfunction

" Handle taxonomy removal (must remain in VimScript for Vim popup API)
function! linny_menu_actions#dropdown_remove_taxo_item_callback(id, result)
  if a:result != -1
    let item = t:linny_menu_item_for_dropdown
    let unset_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

    call luaeval("require('linny.menu.actions').job_start(_A)", ["fred", "unset_key", item.option_data.abs_path, unset_taxo])

    echo "Removed ". unset_taxo . " from " . item.option_data.abs_path
  endif
endfunction

" Handle term selection (must remain in VimScript for Vim popup API)
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
      let name = luaeval("require('linny.menu.actions').get_item_name(_A)", t:linny_menu_item_for_dropdown)
      call luaeval("require('linny.menu.actions').show_set_taxonomy(_A[1], _A[2])", [name, t:linny_menu_line])
      return

    elseif a:action == "remove taxonomy"
      let name = luaeval("require('linny.menu.actions').get_item_name(_A)", t:linny_menu_item_for_dropdown)
      call luaeval("require('linny.menu.actions').show_remove_taxonomy(_A[1], _A[2])", [name, t:linny_menu_line])
      return
    endif
  endif
endfunction
