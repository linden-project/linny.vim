" linny_menu_views.vim - View management callbacks for linny menu
" NOTE: Core logic migrated to lua/linny/menu/views.lua
" Popup callbacks must remain in VimScript (Vim popup API requirement)

" Cycle L1 view (taxonomy level) - delegates to Lua
function! linny_menu_views#cycle_l1(direction)
  call luaeval("require('linny.menu.views').cycle_l1(_A)", a:direction)
endfunction

" Cycle L2 view (term level) - delegates to Lua
function! linny_menu_views#cycle_l2(direction)
  call luaeval("require('linny.menu.views').cycle_l2(_A)", a:direction)
endfunction

" Show L1 view dropdown - delegates to Lua
function! linny_menu_views#dropdown_l1()
  call luaeval("require('linny.menu.views').dropdown_l1()")
endfunction

" Dropdown L1 view callback (must remain in VimScript for Vim popup API)
function! linny_menu_views#dropdown_l1_callback(id, result)
  if a:result != -1
    let state = luaeval("require('linny.menu.state').term_leaf_state(_A)", t:linny_menu_taxonomy)
    let state.active_view = a:result-1

    call luaeval("require('linny.menu.state').write_term_leaf_state(_A[1], _A[2])", [t:linny_menu_taxonomy, state])
    call linny_menu#openandshow()
  endif
endfunction

" Show L2 view dropdown - delegates to Lua
function! linny_menu_views#dropdown_l2()
  call luaeval("require('linny.menu.views').dropdown_l2()")
endfunction

" Dropdown L2 view callback (must remain in VimScript for Vim popup API)
function! linny_menu_views#dropdown_l2_callback(id, result)
  if a:result != -1
    let state = luaeval("require('linny.menu.state').term_value_leaf_state(_A[1], _A[2])", [t:linny_menu_taxonomy, t:linny_menu_term])
    let state.active_view = a:result-1
    call luaeval("require('linny.menu.state').write_term_value_leaf_state(_A[1], _A[2], _A[3])", [t:linny_menu_taxonomy, t:linny_menu_term, state])
    call linny_menu#openandshow()
  endif
endfunction
