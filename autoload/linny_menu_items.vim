" linny_menu_items.vim - Menu item construction functions

" Create default item structure
function! linny_menu_items#item_default()
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

function! linny_menu_items#add_empty_line()
  let item = linny_menu_items#item_default()
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_divider()
  let item = linny_menu_items#item_default()
  let item.text = "-----------------------------------------"
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_header(text)
  let item = linny_menu_items#item_default()
  let item.mode = 3
  let item.text = matchstr(a:text, '^#\+\s*\zs.*')
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_footer(text)
  let item = linny_menu_items#item_default()
  let item.mode = 4
  let item.text = a:text
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_section(text)
  call linny_menu_items#add_empty_line()

  let item = linny_menu_items#item_default()
  let item.mode = 2
  let item.text = matchstr(a:text, '^#\+\s*\zs.*')

  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_text(text)
  let item = linny_menu_items#item_default()
  let item.text = a:text
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_document(title, abs_path, keyboard_key, type)
  let item = linny_menu_items#item_default()
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.option_type = a:type
  let item.option_data.abs_path = a:abs_path
  let item.text = a:title
  let item.event = ":keepalt botright vs ". a:abs_path
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_document_taxo_key(taxo_key)
  let item = linny_menu_items#item_default()
  let item.mode = 0

  if g:linny_menu_display_taxo_count
    let files_in_menu = linny#parse_json_file( linny#l1_index_filepath(a:taxo_key) ,[])
    let taxo_count = " (".len(files_in_menu).")"
  else
    let taxo_count = ""
  endif

  let item.text = "" . linny_menu_util#string_capitalize(a:taxo_key) . taxo_count
  let item.event = ":call linny_menu#openterm('". a:taxo_key ."','')"
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_document_taxo_key_val(taxo_key, taxo_term, display_taxonomy_in_menu)
  let item = linny_menu_items#item_default()
  let item.option_type = 'taxo_key_val'
  let item.option_data.taxo_key = a:taxo_key
  let item.option_data.taxo_term = a:taxo_term
  let item.mode = 0

  if a:display_taxonomy_in_menu
    let tax_text = linny_menu_util#string_capitalize(a:taxo_key) . ': '
  else
    let tax_text = ''
  end

  if g:linny_menu_display_docs_count
    let files_in_menu = linny#parse_json_file( linny#l2_index_filepath(a:taxo_key,a:taxo_term) ,[])
    let docs_count = " (".len(files_in_menu).")"
  else
    let docs_count = ""
  endif

  let item.text = tax_text . a:taxo_term . docs_count
  let item.event = ":call linny_menu#openterm('". a:taxo_key ."','" .a:taxo_term."')"
  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_special_event(title, event_id, keyboard_key)
  let item = linny_menu_items#item_default()
  let item.text = a:title
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.event = a:event_id

  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_ex_event(title, ex_event, keyboard_key )
  let item = linny_menu_items#item_default()
  let item.text = a:title
  let item.mode = 0
  let item.key = a:keyboard_key
  let item.event = a:ex_event

  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#add_external_location(title, location)
  let item = linny_menu_items#item_default()
  let item.text = a:title
  let item.mode = 0
  let item.event = "openexternal ". a:location

  call linny_menu_items#append(item)
endfunction

function! linny_menu_items#append(item)
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

function! linny_menu_items#list()
  for item in t:linny_menu_items
    echo item
  endfor
endfunc

function! linny_menu_items#get_by_index(index)
  if a:index < 0 || a:index >= len(t:linny_menu.items)
    return
  endif

  let item = t:linny_menu.items[a:index]

  return item
endfunction
