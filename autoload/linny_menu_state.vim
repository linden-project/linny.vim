" linny_menu_state.vim - Tab state management for linny menu
" Manages per-tab menu state via t: variables

" Initialize tab-local state
function! linny_menu_state#tab_init()
  if !exists('t:linny_menu_name')
    let t:linny_menu_items = []
    let t:linny_tasks_count = {}
    let t:linny_menu_cursor = 0
    let t:linny_menu_name = '[linny_menu]'.string(linny_menu_state#new_tab_nr())
    let t:linny_menu_line = 0
    let t:linny_menu_lastmaxsize = 0
    let t:linny_menu_view = ""
    let t:linny_menu_taxonomy = ""
    let t:linny_menu_term = ""
  endif
endfunction

" Generate unique tab number
function! linny_menu_state#new_tab_nr()
  let g:linnytabnr = g:linnytabnr + 1
  return g:linnytabnr
endfunction

" Read L2 state (taxonomy term value)
function! linny_menu_state#term_value_leaf_state(term, value)
  let filePath = linny#l2_state_filepath(a:term, a:value)
  return linny#parse_json_file( filePath , {})
endfunction

" Read L1 state (taxonomy term)
function! linny_menu_state#term_leaf_state(term)
  let filePath = linny#l1_state_filepath(a:term)
  return linny#parse_json_file( filePath , {})
endfunction

" Write L1 state
function! linny_menu_state#write_term_leaf_state(term, state)
  call linny#write_json_file(linny#l1_state_filepath(a:term), a:state)
endfunction

" Write L2 state
function! linny_menu_state#write_term_value_leaf_state(term, value, l2_state)
  call linny#write_json_file(linny#l2_state_filepath(a:term, a:value), a:l2_state)
endfunction

" Reset menu state
function! linny_menu_state#reset()
  let t:linny_menu_items = []
  let t:linny_menu_line = 0
  let t:linny_menu_cursor = 0
endfunc
