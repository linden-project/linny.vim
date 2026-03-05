" MIT - Copyright (c) Pim Snel 2019-2023
" Orinally forked from QuickMenu by skywind3000

let t:linny_menu_items = []
let t:linny_tasks_count = {}
let t:linny_menu_cursor = 0
let t:linny_menu_line = 0
let t:linny_menu_lastmaxsize = 0
let t:linny_menu_view = ""
let t:linny_menu_taxonomy = ""
let t:linny_menu_term = ""
let t:linny_menu_current_menu_type = "not_set"
let t:linny_menu_repeat_last_taxo_term = []

" LINNY_MENU INTERFACE

function! linny_menu#openterm(taxonomy, taxo_term) abort
  let t:linny_menu_taxonomy = a:taxonomy
  let t:linny_menu_term = a:taxo_term
  let t:linny_menu_view = ''
  call linny_menu#openandshow()
endfunction

function! linny_menu#openview(view_name) abort
  let t:linny_menu_taxonomy = ''
  let t:linny_menu_term = ''
  let t:linny_menu_view = a:view_name
  call linny_menu#openandshow()
endfunction

function! linny_menu#openandshow() abort

  let t:linny_start_load_time = localtime()

  if t:linny_menu_view != ""
    call linny_menu_render#level0(t:linny_menu_view)

  elseif t:linny_menu_taxonomy!="" && t:linny_menu_term!=""
    call linny_menu_render#level2(t:linny_menu_taxonomy, t:linny_menu_term)

  elseif t:linny_menu_taxonomy!="" && t:linny_menu_term==""
    call linny_menu_render#level1(t:linny_menu_taxonomy)

  elseif t:linny_menu_taxonomy=="" && t:linny_menu_term==""
    call linny_menu_render#level0('root')
  endif

  call linny_menu_render#partial_footer_items()

  if g:linny_debug
    let t:linny_load_time = localtime() - t:linny_start_load_time
    call linny_menu_render#partial_debug_info()
  endif

  let items = Select_items()

  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = Menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:linny_menu_padding_right
  let t:linny_menu_lastmaxsize = maxsize

  if 1
    call linny_menu_window#open_window(maxsize)
    call linny_menu_window#render(content)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc

function! linny_menu#start()

  call linny_menu_state#tab_init()
  call linny_menu#openterm('','')
" exec ':only'
" call linny_menu#open()
" call s:menu_level0('root')

" let view_config = linny#view_config('root')
" if has_key(view_config, 'home_file')
"   exec ':only'
"   let currentwidth = t:linny_menu_lastmaxsize
"   let currentWindow=winnr()
"   execute ":botright vs ".  g:linny_path_wiki_content . "/" .view_config.home_file

"   let newWindow=winnr()

"   exec currentWindow."wincmd w"
"   setlocal foldcolumn=0
"   exec "vertical resize " . currentwidth
"   exec currentWindow."call linny_menu#openandshow()"
"   exec newWindow."wincmd w"

" endif


endfunction

function! linny_menu#close()
  if linny_menu_window#exist()
    call linny_menu_window#close_window()
    return 0
  endif
endfunction

function! linny_menu#open()
  if !linny_menu_window#exist()
    call linny_menu_state#tab_init()
    call linny_menu#openandshow()
  endif
endfunction

function! linny_menu#toggle() abort
  if linny_menu_window#exist()
    call linny_menu_window#close_window()
    return 0
  endif

  " select and arrange menu
  let items = Select_items()
  let content = []
  let maxsize = 8
  let lastmode = 2

  " calculate max width
  for item in items
    let hr = Menu_expand(item)
    for outline in hr
      let text = outline['text']
      if strdisplaywidth(text) > maxsize
        let maxsize = strdisplaywidth(text)
      endif
    endfor
    let content += hr
  endfor

  let maxsize += g:linny_menu_padding_right

  if 1
    call linny_menu_window#open_window(maxsize)
    call linny_menu_window#render(content)
    call Setup_keymaps(content)
  else
    for item in content
      echo item
    endfor
    return 0
  endif

  return 1
endfunc



function! linny_menu#RemapGlobalKeys()

  execute "noremap " . g:linny_leader .'0'. " :call linny_menu#openHome()<CR>"
  execute "noremap " . g:linny_leader .'R'. " :call linny_menu#refreshMenu()<CR>"

  call linny_menu#RemapGlobalStarredDocs()
  call linny_menu#RemapGlobalStarredTerms()

endfunction

function! linny_menu#RemapGlobalStarredDocs()
  let starred = linny_menu_widgets#starred_docs_list()
  let titles = linny#titlesForDocs(starred)
  let t_sortable = {}

  for k in keys(titles)
    let t_sortable[tolower(k)] = g:linny_path_wiki_content . "/" . titles[k]
  endfor

  let title_keys = sort(keys(t_sortable))

  let i = 1
  for tk in title_keys
    execute "noremap " . g:linny_leader .'s'.i. " :call linny_menu#openFile('" . t_sortable[tk] ."')<CR>"
    let i += 1
  endfor
endfunction

function! linny_menu#RemapGlobalStarredTerms()
  let starred = linny_menu_widgets#starred_terms_list()
  let starred_list = {}

  for i in starred
    let starred_list[i['taxonomy'].','.i['term']] = i
  endfor

  let i = 1
  for sk in sort(keys(starred_list))
    execute "noremap " . g:linny_leader .'S'.i. " :call linny_menu#openterm('" .starred_list[sk]['taxonomy']."','".starred_list[sk]['term']."')<CR>"
    let i += 1
  endfor
endfunction

function! linny_menu#refreshMenu()
  call linny#Init()
  call linny#make_index()
  call linny_menu#openandshow()
endfunction

function! linny_menu#openHome()

  if !exists('t:linny_menu_name')
    echomsg 'ERROR No Linny Menu opened. Are you in Linny?'
    return
  endif

  call linny_menu#openterm('','')

endfunction

function! linny_menu#openFile(filepath)

  if &buftype == 'nofile' && &ft == 'linny_menu'

    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    exec ':botright vs '. a:filepath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"

    setlocal foldcolumn=0

    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute ':e '. a:filepath
  endif

endfunction

" ALL KEYS
function! Setup_keymaps(items)

  let ln = 0
  let cursor_pos = t:linny_menu_cursor
  let nowait = ''

  if v:version >= 704 || (v:version == 703 && has('patch1261'))
    let nowait = '<nowait>'
  endif

  for item in a:items
    if item.key != ''
      let cmd = ' :call <SID>linny_menu_execute('.ln.')<cr>'
      exec "noremap <buffer>".nowait."<silent> ".item.key. cmd
    endif
    let ln += 1
  endfor

  " noremap <silent> <buffer> 0 :call <SID>linny_menu_close()<cr>
  " noremap <silent> <buffer> q :call <SID>linny_menu_close()<cr>

  if t:linny_menu_current_menu_type == "menu_level0"
    noremap <silent> <buffer> t :call linny_menu#open_document_in_new_tab()<cr>
  elseif t:linny_menu_current_menu_type == "menu_level1"
    noremap <silent> <buffer> s :call linny_menu#open_or_create_taxo_key_val()<cr>
    noremap <silent> <buffer> V :call <SID>linny_menu_execute_by_string('cycle_l1_view_reverse')<cr>
  elseif t:linny_menu_current_menu_type == "menu_level2"
    noremap <silent> <buffer> t :call linny_menu#open_document_in_new_tab()<cr>
    noremap <silent> <buffer> V :call <SID>linny_menu_execute_by_string('cycle_l2_view_reverse')<cr>
  endif


  noremap <silent> <buffer> <CR> :call <SID>linny_menu_enter()<cr>
  noremap <silent> <buffer> m :call <SID>linny_menu_hotkey('m')<cr>

  let t:linny_menu_line = 0
  if cursor_pos > 0
    call cursor(cursor_pos, 1)
  endif
  let t:linny_menu.showhelp = 0
  call Set_cursor()
  augroup linny_menu
    autocmd CursorMoved <buffer> call Set_cursor()
    autocmd InsertEnter <buffer> call feedkeys("\<ESC>")
  augroup END

  let t:linny_menu.showhelp = (stridx(g:linny_menu_options, 'H') >= 0)? 1 : 0

endfunc


" RESET CURSOR
function! Set_cursor() abort
  let curline = line('.')
  let lastline = t:linny_menu_line
  let movement = (curline < lastline)? -1 : 1
  let find = -1
  let size = len(t:linny_menu.items)
  while 1
    let index = curline - 2
    if index < 0 || index >= size
      break
    endif
    let item = t:linny_menu.items[index]
    if item.mode == 0 && item.event != ''
      let find = index
      break
    endif
    let curline += movement
  endwhile
  if find < 0
    let curline = line('.')
    let curdiff = abs(curline - t:linny_menu.option_lines[0])
    let select = t:linny_menu.option_lines[0]
    for line in t:linny_menu.option_lines
      let newdiff = abs(curline - line)
      if newdiff < curdiff
        let curdiff = newdiff
        let select = line
      endif
    endfor
    let find = select - 2
  endif
  if find < 0
    echohl ErrorMsg
    echo "fatal error in Set_cursor() ".find
    echohl None
    return
  endif
  let t:linny_menu_line = find + 2
  call cursor(t:linny_menu_line, g:linny_menu_padding_left + 2)

  if t:linny_menu.showhelp
    let help = t:linny_menu.items[find].help
    let key = t:linny_menu.items[find].key
    echohl linny_menuHelp
    if help != ''
      call linny_menu_util#cmdmsg('['.key.']: '.help, 'linny_menuHelp')
    else
      echo ''
    endif
    echohl None
  endif
endfunc

" SPECIAL 3RD LEVEL ACTIONS {{{
"
function! linny_menu#open_document_in_new_tab()

  let ln = line('.')
  let item = linny_menu_items#get_by_index(ln - 2)

  if has_key(item,'option_type')
    if get(item,'option_type') == 'document'
      let strCmd='tabnew'
      exec 'tabnew ' . item.option_data.abs_path
    endif
  end
endfunc


function! linny_menu#open_or_create_taxo_key_val()
  let ln = line('.')
  let item = linny_menu_items#get_by_index(ln - 2)

  if has_key(item,'option_type')
    if get(item,'option_type') == 'taxo_key_val'
      call s:createl2config(item.option_data.taxo_key, item.option_data.taxo_term)
    endif
  end
endfunction

"}}}


" CLOSE LINNY_MENU
function! <SID>linny_menu_close()
  close
  redraw | echo "" | redraw
endfunc

" EXECUTE SELECTED
function! <SID>linny_menu_enter() abort
  let ln = line('.')
  call <SID>linny_menu_execute(ln - 2)
endfunc


" EXECUTE ITEM
function! <SID>linny_menu_execute_by_string(cmd) abort
  redraw | echo "" | redraw

  if(a:cmd == 'cycle_l1_view_reverse')
    call linny_menu_views#cycle_l1(-1)
    call linny_menu#openandshow()
  elseif(a:cmd == 'cycle_l2_view_reverse')
    call linny_menu_views#cycle_l2(-1)
    call linny_menu#openandshow()
  endif

endfunction

function! <SID>linny_menu_hotkey(key) abort
  let index = line('.') - 2

  let item = linny_menu_items#get_by_index(index)

  if item.mode != 0 || item.event == ''
    return
  endif

  let t:linny_menu_line = index + 2
  let t:linny_menu_cursor = t:linny_menu_line
  let t:linny_menu_item_for_dropdown = item

  call linny_menu#dropdown_item()

endfunction

function! linny_menu#dropdown_item()

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

  call linny_menu#create_popup(t:linny_menu_dropdownviews, #{
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
        \ callback: 'linny_menu#dropdown_item_callcack',
        \ })

endfunction

function! linny_menu#dropdown_item_callcack(id, result)

  if a:result != -1
    call linny_menu#exec_content_menu(t:linny_menu_dropdownviews[a:result-1],t:linny_menu_item_for_dropdown)
  else
    let t:linny_menu_item_for_dropdown = 0
  endif

endfunction

function! linny_menu#dropdown_taxo_item_callcack(id, result)

  if a:result != -1

      let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])
      let t:linny_menu_set_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

      let termslistDict = linny#parse_json_file(linny#l1_index_filepath(t:linny_menu_set_taxo), [] )
      let t:linny_menu_term_items_for_dropdown = sort(keys(termslistDict))

      call linny_menu#create_popup(t:linny_menu_term_items_for_dropdown, #{
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
            \ callback: 'linny_menu#dropdown_term_item_callcack',
            \ })
    return
  endif
  return
endfunction

function! linny_menu#dropdown_remove_taxo_item_callcack(id, result)

  if a:result != -1

    let item = t:linny_menu_item_for_dropdown
    let unset_taxo = t:linny_menu_taxo_items_for_dropdown[a:result-1]

    call s:jobstart( ["fred" ,'unset_key', item.option_data.abs_path, unset_taxo])

    echo "Removed ". unset_taxo . " from " . item.option_data.abs_path

    return
  endif
  return
endfunction

function! linny_menu#dropdown_term_item_callcack(id, result)

  if a:result != -1

    let item = t:linny_menu_item_for_dropdown
    let taxo_item = t:linny_menu_set_taxo
    let term_item = t:linny_menu_term_items_for_dropdown[a:result-1]

    call s:job_start( ["fred" ,'set_string_val', item.option_data.abs_path, taxo_item, term_item])
    let t:linny_menu_repeat_last_taxo_term = [taxo_item, term_item]
  endif

endfunction

function! linny_menu#exec_content_menu(action, item)
  if a:item.option_type == 'taxo_key_val'

    if a:action == "archive"
      call linny_menu#archiveL2config(a:item.option_data.taxo_key, a:item.option_data.taxo_term)
      return
    endif

  elseif a:item.option_type == 'document'

    if a:action == "set archive"
      call s:job_start( ["fred" ,'set_bool_val', a:item.option_data.abs_path, 'archive', 'true'])
      return

    elseif a:action == "toggle starred"
      call s:job_start( ["fred" ,'toggle_bool_val', a:item.option_data.abs_path, 'starred'])
      return

    elseif a:action == "copy"
      call inputsave()
      let oldtitle = trim(split(split(a:item.text,'[')[1],']')[1])
      let name = input('Enter document name: ', oldtitle.' COPY')
      call inputrestore()
      call linny_menu#copy_document(a:item.option_data.abs_path, name)
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

      call linny_menu#create_popup(t:linny_menu_taxo_items_for_dropdown, #{
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
            \ callback: 'linny_menu#dropdown_taxo_item_callcack',
            \ })

      return

    elseif a:action == "remove taxonomy"

      let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])
      for k in sort(index_keys_list)
        call linny_menu_items#add_document_taxo_key(k)
      endfor

      let t:linny_menu_taxo_items_for_dropdown = sort(index_keys_list)
      let name = trim(split(t:linny_menu_item_for_dropdown.text,']')[1])

      call linny_menu#create_popup(t:linny_menu_taxo_items_for_dropdown, #{
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
            \ callback: 'linny_menu#dropdown_remove_taxo_item_callcack',
            \ })

      return

    elseif a:action =~ "set "

      let taxo_and_term = split(a:action[4:-1],': ')
      call s:job_start( ["fred" ,'set_string_val', a:item.option_data.abs_path, taxo_and_term[0], taxo_and_term[1]])

    endif

  endif

endfunction

function! <SID>linny_menu_execute(index) abort

  let item = linny_menu_items#get_by_index(a:index)

  if item.mode != 0 || item.event == ''
    return
  endif

  let t:linny_menu_line = a:index + 2
  let t:linny_menu_cursor = t:linny_menu_line

  redraw | echo "" | redraw

  " als event een string is
  if type(item.event) == 1

    if(item.event == 'close')
      close!

    elseif(item.event == 'cycle_l1_view')
      call linny_menu_views#cycle_l1(1)
      call linny_menu#openandshow()

    elseif(item.event == 'dropdown_l1_view')
      call linny_menu_views#dropdown_l1()

    elseif(item.event == 'dropdown_l2_view')
      call linny_menu_views#dropdown_l2()

    elseif(item.event == 'cycle_l2_view')
      call linny_menu_views#cycle_l2(1)
      call linny_menu#openandshow()

    elseif(item.event == 'refresh')
      call linny_menu#refreshMenu()

    elseif(item.event == 'onlinebook')
      if has("unix")
        call s:job_start( ["xdg-open" ,'https://linden-project.github.io'])
      else
        call s:job_start( ["open" ,'https://linden-project.github.io'])
      endif


    elseif(item.event == 'home')
      call linny_menu#start()

    elseif(item.event == 'createl1config')

      let confFileName = linny#l1_config_filepath(t:linny_menu_taxonomy)

      let fileLines = []
      call add(fileLines, '---')
      call add(fileLines, 'title: '.linny_menu_util#string_capitalize(t:linny_menu_taxonomy))
      call add(fileLines, 'infotext: About '. t:linny_menu_taxonomy)
      call add(fileLines, 'views:')
      call add(fileLines, '  type:')
      call add(fileLines, '    group_by: type')

      if writefile(fileLines, confFileName)
        echomsg 'write error'
      else
        exec ':only'
        let currentwidth = t:linny_menu_lastmaxsize
        let currentWindow=winnr()
        execute ":botright vs ". confFileName
        let newWindow=winnr()

        exec currentWindow."wincmd w"
        setlocal foldcolumn=0
        exec "vertical resize " . currentwidth
        exec currentWindow."call linny_menu#openandshow()"
        exec newWindow."wincmd w"

      endif

    elseif(item.event == 'createl2config')
      call s:createl2config(t:linny_menu_taxonomy, t:linny_menu_term)

    elseif(item.event == 'opencontextmenu')
      echo "Place cursor on item first"

    elseif(item.event == 'newdocingroup')

      call inputsave()
      let name = input('Enter document name: ')
      call inputrestore()

      if(!empty(name))
        call linny_menu#new_document_in_leaf(name)
      else
        return 0
      endif

    elseif item.event[0] != '='

      if item.event =~ "linny_menu#openterm"
        exec item.event

      elseif item.event =~ "openexternal"
        if item.event =~ "file:///"
          let dirstring = split(item.event, "file://")
          call luaeval("require('linny.fs').dir_create_if_not_exist(_A)", dirstring[1])
          call luaeval("require('linny.fs').os_open_with_filemanager(_A)", dirstring[1])

        elseif item.event =~ "https://"
          let url = 'https://' . split(item.event, "https://")[1]
          if has("unix")

            call s:job_start( ["xdg-open", url])

          else
              call s:job_start( ["open", url])
          endif

        endif
      else

        let currentwidth = t:linny_menu_lastmaxsize
        let currentWindow=winnr()

        exec ':only'
        exec item.event
        let newWindow=winnr()

        exec currentWindow."wincmd w"
        setlocal foldcolumn=0
        exec "vertical resize " . currentwidth
        exec newWindow."wincmd w"

      endif
    else
      "  let script = matchstr(item.event, '^=\s*\zs.*')
    endif

    " als event een functie is
  elseif type(item.event) == 2

    call item.event()

  endif

endfunc

function! linny_menu#archiveL2config(taxonomy, taxo_term)
  let confFileName = linny#l2_config_filepath(a:taxonomy, a:taxo_term)
  let fileLines = []
  if filereadable(confFileName)
    let fileLines = readfile(confFileName)
    let fileLines = ['---','archive: true'] + fileLines[1:-1]
  else
    call add(fileLines, '---')
    call add(fileLines, 'title: '.linny_menu_util#string_capitalize(a:taxo_term))
    call add(fileLines, 'infotext: About '. a:taxo_term)
    call add(fileLines, 'archive: true')
  endif
  if writefile(fileLines, confFileName)
    echomsg 'write error'
  endif
endfunction


function! s:createl2config(taxonomy, taxo_term)
  let confFileName = linny#l2_config_filepath(a:taxonomy, a:taxo_term)

  if filereadable(confFileName)

      exec ':only'
      let currentwidth = t:linny_menu_lastmaxsize
      let currentWindow=winnr()
      execute ":botright vs ". confFileName
      let newWindow=winnr()

      exec currentWindow."wincmd w"
      setlocal foldcolumn=0
      exec "vertical resize " . currentwidth
      exec currentWindow."call linny_menu#openandshow()"
      exec newWindow."wincmd w"

  else
    let fileLines = []

    call add(fileLines, '---')
    call add(fileLines, 'title: '.linny_menu_util#string_capitalize(a:taxo_term))
    call add(fileLines, 'infotext: About '. a:taxo_term)
    call add(fileLines, '')
    call add(fileLines, 'archive: false')
    call add(fileLines, 'starred: false')
    call add(fileLines, '')
    call add(fileLines, 'views:')
    call add(fileLines, '  az:')
    call add(fileLines, '    sort: az')
    call add(fileLines, '  date:')
    call add(fileLines, '    sort: date')
    call add(fileLines, '  type:')
    call add(fileLines, '    group_by: type')
    call add(fileLines, '')
    call add(fileLines, '#mounts:')
    call add(fileLines, '  #project docs:')
    call add(fileLines, '    #source: /home/john/projects/some-project')
    call add(fileLines, '    #exclude:')
    call add(fileLines, '      #- README.md')
    call add(fileLines, '')
    call add(fileLines, '#locations:')
    call add(fileLines, '  #website: https://www.'.a:taxo_term.'.vim')
    call add(fileLines, '')
    call add(fileLines, '#frontmatter_template:')
    call add(fileLines, '  #project: prj-x')

"    call add(fileLines, '---')
"    call add(fileLines, 'title: '.linny_menu_util#string_capitalize(a:taxo_term))
"    call add(fileLines, 'infotext: About '. a:taxo_term)
"    call add(fileLines, 'views:')
"    call add(fileLines, '  az:')
"    call add(fileLines, '    sort: az')
"    call add(fileLines, '  date:')
"    call add(fileLines, '    sort: date')
"    call add(fileLines, '  type:')
"    call add(fileLines, '    group_by: type')
"    call add(fileLines, 'locations:')
"    call add(fileLines, '  #website: https://www.'.a:taxo_term.'.vim')
    "call add(fileLines, '  #dir1: file:///Applications/')
    "call add(fileLines, '  #file1: file:///Projects/file1.someformat')

    if writefile(fileLines, confFileName)
      echomsg 'write error'
    else
      exec ':only'
      let currentwidth = t:linny_menu_lastmaxsize
      let currentWindow=winnr()
      execute ":botright vs ". confFileName
      let newWindow=winnr()

      exec currentWindow."wincmd w"
      setlocal foldcolumn=0
      exec "vertical resize " . currentwidth
      exec currentWindow."call linny_menu#openandshow()"
      exec newWindow."wincmd w"
    endif
  end

endfunction

function! linny_menu#replace_key_value_in_root_frontmatter_filelines(fileLines, key, newvalue)

  let frontmatter_started = 0
  let idx = 0

  let new_lines = []

  for line in a:fileLines

    if frontmatter_started == 0 && line[0:len("---")] == "---"
      let frontmatter_started = 1
    elseif line[0:len("---")] == "---"
      break
    endif

    if frontmatter_started == 1 && line[0:len(a:key.":")-1] == a:key.":"
      let a:fileLines[idx] = a:key . ": " . a:newvalue
      break
    endif

    let idx += 1

  endfor

  return a:fileLines

endfunction

function! linny_menu#copy_document(source_path, new_title)
  let fileName = luaeval("require('linny.wiki').word_to_filename(_A)", a:new_title)
  let relativePath = fnameescape(g:linny_path_wiki_content . '/' . fileName)

  if !filereadable(relativePath) && filereadable(a:source_path)

    let fileLines = readfile(a:source_path)
    let fileLines = linny_menu#replace_key_value_in_root_frontmatter_filelines(fileLines, "title", a:new_title)

    if writefile(fileLines, relativePath)
      echomsg 'write error'
    endif

    call linny_menu#open_document_in_right_pane(relativePath)

  else
    echom "Could not copy document with file path: " . a:source_path
  endif

endfunction

function! linny_menu#open_document_in_right_pane(relativePath)
  if bufname('%') =~ "[linny_menu]"
    let currentwidth = t:linny_menu_lastmaxsize
    let currentWindow=winnr()

    exec ':only'
    execute ':botright vs '. a:relativePath

    let newWindow=winnr()

    exec currentWindow."wincmd w"
    exec currentWindow."call linny_menu#openandshow()"
    setlocal foldcolumn=0
    exec "vertical resize " . currentwidth
    exec newWindow."wincmd w"

  else
    execute 'e '. a:relativePath
  end
endfunction

function! linny_menu#new_document_in_leaf(...)
  let title = join(a:000)
  let fileName = luaeval("require('linny.wiki').word_to_filename(_A)", title)
  let relativePath = fnameescape(g:linny_path_wiki_content . '/' . fileName)

  if !filereadable(relativePath)
    let taxonomy = ''
    let taxo_term = ''

    let taxoEntries = []
    if t:linny_menu_taxonomy != "" && t:linny_menu_term != ""
      let entry = {}
      let entry['term'] = t:linny_menu_taxonomy
      let entry['value'] = t:linny_menu_term
      call add(taxoEntries, entry)

      let config = linny#term_config(t:linny_menu_taxonomy, t:linny_menu_term)
      if has_key(config, 'frontmatter_template')
        let fm_template = get(config,'frontmatter_template')
        if(type(fm_template)==4)
          for fm_key in keys(fm_template)
            let entry = {}
            let entry['term'] = fm_key
            if get(fm_template,fm_key) == 'v:null'
              let entry['value'] = ''
            else
              let entry['value'] = get(fm_template,fm_key)
            endif

            call add(taxoEntries, entry)
          endfor
        endif
      endif
    endif

    let fileLines = linny#generate_first_content(title, taxoEntries)
    if writefile(fileLines, relativePath)
      echomsg 'write error'
    endif
  endif

  call linny_menu#open_document_in_right_pane(relativePath)

endfunction

" SELECTABLE ITEMS, GENERATE KEYMAP
function! Select_items() abort

  let items = []
  let index = 1

  let lastmode = 2
  for item in t:linny_menu_items
    if item.mode == 0
      if item.key == ''
        let item.key = linny_menu_util#prepad(index, 1,0)
        let index += 1
      endif
    endif

    let items += [item]
  endfor

  return items

endfunc

" EXPAND MENU ITEMS
function! Menu_expand(item) abort

  let items = []
  let text = linny_menu_util#expand_text(a:item.text)
  let help = ''
  let index = 0
  let padding = repeat(' ', g:linny_menu_padding_left)

  if a:item.mode == 0
    let help = linny_menu_util#expand_text(get(a:item, 'help', ''))
  endif

  for curline in split(text, "\n", 1)

    let item = {}
    "let item = a:item

    let item.mode = a:item.mode
    let item.text = curline
    let item.event = ''
    let item.option_type = a:item.option_type
    let item.option_data = a:item.option_data
    let item.key = ''
    let extra_indent = ''

    if item.mode == 0
      if index == 0
        if strchars(a:item.key)== 1
          let extra_indent = ' '
        end

        let item.text = extra_indent . '[' . a:item.key.']  '. curline
        let index += 1
        let item.key = a:item.key
        let item.event = a:item.event
        let item.help = help
      else
        let item.text = '     '.curline
      endif
    endif

    if len(item.text)
      let item.text = padding . item.text
    endif

    let items += [item]

  endfor

  return items
endfunc

function! linny_menu#create_popup(what, options) abort
    if has('popupwin')
        return popup_create(a:what, a:options)
    elseif has('nvim')
        return s:floatwin(s:to_list(a:what), s:options(#{}, a:options))
    endif
endfunction



function s:job_start(command)
  if has('nvim')
    call jobstart( a:command)
  else
    call job_start( a:command)
  endif
endfunction

" THE REST FOR VIM/NEOVIM
if !has('nvim')
    finish
endif

function! linny_menu#close_pop(id, result = 0) abort
    if has('popupwin')
        call popup_close(a:id, a:result)
    elseif has('nvim')
        call linny_menu#setoptions(a:id, #{result: a:result})
        call nvim_win_close(a:id, v:true)
    endif
endfunction

function! linny_menu#getoptions(id) abort
    if has('popupwin')
        return popup_getoptions(a:id)
    elseif has('nvim')
        return getbufvar(winbufnr(a:id), 'popup_options', {})
    endif
endfunction

function! linny_menu#setoptions(id, options) abort
    if has('popupwin')
        return popup_setoptions(a:id, a:options)
    elseif has('nvim')
        call setbufvar(winbufnr(a:id), 'popup_options',
            \ extend(linny_menu#getoptions(a:id), a:options))
    endif
endfunction


" THE REST FOR NEOVIM ONLY
if !has('nvim')
    finish
endif


function s:num2bool(key, dict) abort
  if has_key(a:dict, a:key)
    if a:dict[a:key] == 0
      let a:dict[a:key] = v:false
    elseif a:dict[a:key] == 1
      let a:dict[a:key] = v:true
    endif
  endif
  return a:dict
endfunction

function s:options(opts, useropts) abort

    let useropts = s:num2bool('wrap',a:useropts)
    let useropts = s:num2bool('cursorline',a:useropts)
    "let useropts = s:num2bool('border',a:useropts)
"    if has_key(a:useropts, 'cursorline')
"      if a:useropts.cursorline == 0
"        let a:useropts.cursorline = false
"      elseif a:useropts.cursorline == 1
"       let a:useropts.cursorline = true
"      end
"    end




    call extend(extend(a:opts, a:useropts), #{
        \ line: 0, col: 0, pos: 'topleft', posinvert: v:true, textprop: '',
        \ textpropwin: 0, textpropid: 0, fixed: v:false, flip: v:true, maxheight: 999,
        \ minheight: 0, maxwidth: 999, minwidth: 0, firstline: 0, hidden: v:false,
        \ tabpage: 0, title: '', wrap: v:true, drag: v:false, resize: v:false,
        \ close: 'none', highlight: '', padding: [0, 0, 0, 0], border: [0, 0, 0, 0],
        \ borderhighlight: [], borderchars: [], scrollbar: v:true,
        \ scrollbarhighlight: '', thumbhighlight: '', zindex: 50, mask: [], time: 0,
        \ moved: [0, 0, 0], mousemoved: [0, 0, 0], cursorline: v:false, filter: {},
        \ mapping: v:true, filtermode: 'a', callback: v:null, box: 0, result: 0
        \ }, 'keep')

    " set defaults suitable for Neovim
    if a:opts.pos is# 'center'
        let a:opts.line = 0
        let a:opts.col = 0
    endif
    let a:opts.highlight = empty(a:opts.highlight) ?
        \ 'EndOfBuffer:,CursorLine:PMenuSel' :
        \ printf('NormalFloat:%s,EndOfBuffer:,CursorLine:PMenuSel', a:opts.highlight)
    let a:opts.padding += [1, 1, 1, 1]
    let a:opts.border += [1, 1, 1, 1]
    if len(a:opts.borderchars) == 1
        let a:opts.borderchars = repeat(a:opts.borderchars, 8)
    elseif len(a:opts.borderchars) == 2
        let a:opts.borderchars = repeat(a:opts.borderchars[0:0], 4) +
            \ repeat(a:opts.borderchars[1:1], 4)
    elseif len(a:opts.borderchars) < 8
        let a:opts.borderchars += [nr2char(0x2550), nr2char(0x2551), nr2char(0x2550),
            \ nr2char(0x2551), nr2char(0x2554), nr2char(0x2557), nr2char(0x255D),
            \ nr2char(0x255A)][len(a:opts.borderchars) : ]
    endif
    if a:opts.filter is# 'popup_filter_menu'
        let a:opts.filter = {'<Space>': '.', '<CR>': '.', '<kEnter>': '.',
            \ '<2-LeftMouse>': '.', 'x': -1, '<Esc>': -1, '<C-C>': -1}
    elseif a:opts.filter is# 'popup_filter_yesno'
        let a:opts.filter = {'y': 1, 'Y': 1, 'n': 0, 'N': 0, 'x': 0, '<Esc>': 0,
            \ '<C-C>': -1}
    elseif type(a:opts.filter) != v:t_dict
        let a:opts.filter = {}
    endif
    if a:opts.filtermode is# 'a'
        let a:opts.filtermode = ''
    endif
    if a:opts.close is# 'button'
        let a:opts.borderchars[5] = 'X'
    elseif a:opts.close is# 'click'
        let a:opts.filter['<LeftMouse>'] = -2
    endif

    return a:opts
endfunction

function s:to_list(what) abort
    if type(a:what) == v:t_number
        return getbufline(a:what, 1, '$')
    elseif type(a:what) == v:t_list
        return copy(a:what)
    else
        return [a:what]
    endif
endfunction

function s:floatwin(lines, opts) abort
    " extra vertical and horizontal space for menu box
    let l:extraV = a:opts.border[0] + a:opts.padding[0] +
        \ a:opts.padding[2] + a:opts.border[2]
    let l:extraH = a:opts.border[3] + a:opts.padding[3] +
        \ a:opts.padding[1] + a:opts.border[1]

    " calc height and width
    let l:height = max([len(a:lines), a:opts.minheight, 1])
    let l:height = min([l:height, a:opts.maxheight, &lines - &cmdheight - l:extraV])
    let l:height += l:extraV
    let l:width = max(extend(map(a:lines[:], 'strwidth(v:val)'), [a:opts.minwidth,
        \ strwidth(a:opts.title) - a:opts.padding[3] - a:opts.padding[1]]))
    let l:width = min([l:width, a:opts.maxwidth, &columns - l:extraH])
    let l:width += l:extraH

    " floatwin config
    let l:config = {'anchor': get({'topright': 'NE', 'botleft': 'SW', 'botright': 'SE'},
        \ a:opts.pos, 'NW'), 'height': l:height, 'width': l:width, 'relative': 'editor',
        \ 'focusable': v:false, 'style': 'minimal'}
    let l:config.row = a:opts.line ? a:opts.line - 1 : s:centered(l:height,
        \ &lines - &cmdheight, l:config.anchor[0] is# 'S')
    let l:config.col = a:opts.col ? a:opts.col - 1 : s:centered(l:width, &columns,
        \ l:config.anchor[1] is# 'E')

    " show menu box
    let a:opts.box = s:get_buffer('popup_box', v:true)
    call s:set_lines(a:opts.box, s:draw_box(l:config.height, l:config.width, a:opts))
    call nvim_open_win(a:opts.box, v:false, l:config)
    call s:set_winopts(bufwinid(a:opts.box), {'winhighlight': a:opts.highlight})

    " shift menu items inside the box
    let l:config.focusable = v:true
    let [l:config.height, l:config.width] -= [l:extraV, l:extraH]
    let [l:config.row, l:config.col] += s:shift_inside(l:config.anchor, a:opts)

    " show menu items
    let l:items = s:get_buffer('popup_options', a:opts)
    call s:set_lines(l:items, a:lines)
    let l:id = nvim_open_win(l:items, v:true, l:config)
    mapclear <buffer>
    autocmd! BufLeave <buffer> call s:bufleave(str2nr(expand('<abuf>')))
    call s:set_winopts(l:id, {'cursorline': a:opts.cursorline, 'scrolloff': 0,
        \ 'sidescrolloff': 0, 'winhighlight': a:opts.highlight, 'wrap': a:opts.wrap})
    call s:set_keymaps(l:id, a:opts.filtermode, a:opts.filter)
    if a:opts.firstline
        call nvim_win_set_cursor(l:id, [a:opts.firstline, 0])
    endif
    if a:opts.time
        call timer_start(a:opts.time, {-> win_getid() == l:id && linny_menu#close_pop(l:id)})
    endif

    return l:id
endfunction

function s:bufleave(buf) abort
    let l:opts = getbufvar(a:buf, 'popup_options')
    if !empty(l:opts.callback)
        " delay callback until another buffer entered
        let s:callback = function(l:opts.callback, [bufwinid(a:buf),
            \ type(l:opts.result) == v:t_string ? line(l:opts.result) : l:opts.result])
        autocmd BufEnter * ++once ++nested call call(remove(s:, 'callback'), [])
    endif
    execute bufwinnr(a:buf) 'hide'
    execute bufwinnr(l:opts.box) 'hide'
endfunction

function s:centered(size, total, far) abort
    return (a:far ? a:total + a:size : a:total - a:size) / 2
endfunction

function s:draw_box(height, width, opts) abort
    let l:border31 = a:opts.border[3] + a:opts.border[1]
    let l:contents = repeat([printf('%.*S%*S%.*S',
        \ a:opts.border[3], a:opts.borderchars[3], a:width - l:border31, '',
        \ a:opts.border[1], a:opts.borderchars[1])],
        \ a:height - a:opts.border[0] - a:opts.border[2])
    if a:opts.border[0]
        call insert(l:contents, printf('%.*S%S%S%.*S',
            \ a:opts.border[3], a:opts.borderchars[4], a:opts.title,
            \ repeat(a:opts.borderchars[0],
            \   a:width - l:border31 - strwidth(a:opts.title)),
            \ a:opts.border[1], a:opts.borderchars[5]))
    endif
    if a:opts.border[2]
        call add(l:contents, printf('%.*S%S%.*S',
            \ a:opts.border[3], a:opts.borderchars[7],
            \ repeat(a:opts.borderchars[2], a:width - l:border31),
            \ a:opts.border[1], a:opts.borderchars[6]))
    endif
    return l:contents
endfunction

" find hidden buffer by looking up variable
" create new if not found
function s:get_buffer(varname, value) abort
    let l:match = filter(getbufinfo({'bufloaded': v:true}),
        \ {_, v -> empty(v.windows) && has_key(v.variables, a:varname) &&
        \ type(v.variables[a:varname]) == type(a:value)})
    let l:buf = empty(l:match) ? nvim_create_buf(v:false, v:true) : l:match[0].bufnr
    call nvim_buf_set_option(l:buf, 'undolevels', -1)
    call setbufvar(l:buf, a:varname, a:value)
    return l:buf
endfunction

function s:set_keymaps(window, mode, keymaps) abort
    for [l:lhs, l:result] in items(a:keymaps)
        call nvim_buf_set_keymap(winbufnr(a:window), a:mode, l:lhs,
            \ printf('<Cmd>call linny_menu#close_pop(%d, %s)<CR>', a:window, string(l:result)),
            \ {'noremap': v:true, 'nowait': v:true})
    endfor
endfunction

function s:set_lines(buf, lines) abort
    call nvim_buf_set_option(a:buf, 'modifiable', v:true)
    call nvim_buf_set_lines(a:buf, 0, -1, 1, a:lines)
    call nvim_buf_set_option(a:buf, 'modifiable', v:false)
endfunction

function s:set_winopts(window, winopts) abort
    for [l:name, l:value] in items(a:winopts)
        call nvim_win_set_option(a:window, l:name, l:value)
    endfor
endfunction

function s:shift_inside(anchor, opts) abort
    if a:anchor is# 'NE'
        return [a:opts.border[0] + a:opts.padding[0],
            \ -a:opts.border[1] - a:opts.padding[1]]
    elseif a:anchor is# 'SE'
        return [-a:opts.border[2] - a:opts.padding[2],
            \ -a:opts.border[1] - a:opts.padding[1]]
    elseif a:anchor is# 'SW'
        return [-a:opts.border[2] - a:opts.padding[2],
            \ a:opts.border[3] + a:opts.padding[3]]
    else "NW
        return [a:opts.border[0] + a:opts.padding[0],
            \ a:opts.border[3] + a:opts.padding[3]]
    endif
endfunction
