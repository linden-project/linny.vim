" linny_menu_actions.vim - Dropdown menu actions and content menu execution

" Helper for job execution (cross-platform)
function! s:job_start(command)
  if has('nvim')
    call jobstart(a:command)
  else
    call job_start(a:command)
  endif
endfunction

" Show action dropdown for current item
function! linny_menu_actions#dropdown_item()

  if t:linny_menu_item_for_dropdown.option_type == 'taxo_key_val'
    let t:linny_menu_dropdownviews = ["archive"]
    let name = t:linny_menu_item_for_dropdown.option_data.taxo_term
  elseif t:linny_menu_item_for_dropdown.option_type == 'document'

    let t:linny_menu_dropdownviews = ["copy", "------", "archive", "set taxonomy", "remove taxonomy", "open docdir"]

    if len(t:linny_menu_repeat_last_taxo_term) > 0
      let t:linny_menu_dropdownviews += ["set " . t:linny_menu_repeat_last_taxo_term[0] .": ". t:linny_menu_repeat_last_taxo_term[1]]
    endif

    let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])
  else
    return
  endif

  call linny_menu_popup#create(t:linny_menu_dropdownviews, #{
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
        \ })

endfunction

" Handle dropdown selection
function! linny_menu_actions#dropdown_item_callback(id, result)

  if a:result != -1
    call linny_menu_actions#exec_content_menu(t:linny_menu_dropdownviews[a:result-1],t:linny_menu_item_for_dropdown)
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

      call linny_menu_popup#create(t:linny_menu_term_items_for_dropdown, #{
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
            \ })
    return
  endif
  return
endfunction

" Handle taxonomy removal
function! linny_menu_actions#dropdown_remove_taxo_item_callback(id, result)

  if a:result != -1

    let item = t:linny_menu_item_for_dropdown
    let unset_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

    call s:job_start(["fred" ,'unset_key', item.option_data.abs_path, unset_taxo])

    echo "Removed ". unset_taxo . " from " . item.option_data.abs_path

    return
  endif
  return
endfunction

" Handle term selection
function! linny_menu_actions#dropdown_term_item_callback(id, result)

  if a:result != -1

    let item = t:linny_menu_item_for_dropdown
    let taxo_item = t:linny_menu_set_taxo
    let term_item = t:linny_menu_term_items_for_dropdown[a:result-1]

    call s:job_start(["fred" ,'set_string_val', item.option_data.abs_path, taxo_item, term_item])
    let t:linny_menu_repeat_last_taxo_term = [taxo_item, term_item]
  endif

endfunction

" Execute content menu action
function! linny_menu_actions#exec_content_menu(action, item)
  if a:item.option_type == 'taxo_key_val'

    if a:action == "archive"
      call linny_menu_documents#archive_l2_config(a:item.option_data.taxo_key, a:item.option_data.taxo_term)
      return
    endif

  elseif a:item.option_type == 'document'

    if a:action == "set archive"
      call s:job_start(["fred" ,'set_bool_val', a:item.option_data.abs_path, 'archive', 'true'])
      return

    elseif a:action == "toggle starred"
      call s:job_start(["fred" ,'toggle_bool_val', a:item.option_data.abs_path, 'starred'])
      return

    elseif a:action == "copy"
      call inputsave()
      let oldtitle = trim(split(split(a:item.text,'[')[1],']')[1])
      let name = input('Enter document name: ', oldtitle.' COPY')
      call inputrestore()
      call linny_menu_documents#copy(a:item.option_data.abs_path, name)
      return

    elseif a:action == "open docdir"
      let newdocdir = a:item.option_data.abs_path[:-3]."docdir"
      call luaeval("require('linny.fs').dir_create_if_not_exist(_A)", newdocdir)
      call luaeval("require('linny.fs').os_open_with_filemanager(_A)", newdocdir)

    elseif a:action == "set taxonomy"

      let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])
      for k in sort(index_keys_list)
        call linny_menu_items#add_document_taxo_key(k)
      endfor

      let t:linny_menu_taxo_items_for_dropdown = sort(index_keys_list)
      let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])

      call linny_menu_popup#create(t:linny_menu_taxo_items_for_dropdown, #{
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
            \ })

      return

    elseif a:action == "remove taxonomy"

      let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])
      for k in sort(index_keys_list)
        call linny_menu_items#add_document_taxo_key(k)
      endfor

      let t:linny_menu_taxo_items_for_dropdown = sort(index_keys_list)
      let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])

      call linny_menu_popup#create(t:linny_menu_taxo_items_for_dropdown, #{
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
            \ })

      return

    elseif a:action =~ "set "

      let taxo_and_term = split(a:action[4:-1],': ')
      call s:job_start(["fred" ,'set_string_val', a:item.option_data.abs_path, taxo_and_term[0], taxo_and_term[1]])

    endif

  endif

endfunction
