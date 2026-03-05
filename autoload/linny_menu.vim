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
      call linny_menu_documents#create_l2_config(item.option_data.taxo_key, item.option_data.taxo_term)
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

  call linny_menu_actions#dropdown_item()

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
      call linny_menu_documents#create_l1_config(t:linny_menu_taxonomy)

    elseif(item.event == 'createl2config')
      call linny_menu_documents#create_l2_config(t:linny_menu_taxonomy, t:linny_menu_term)

    elseif(item.event == 'opencontextmenu')
      echo "Place cursor on item first"

    elseif(item.event == 'newdocingroup')

      call inputsave()
      let name = input('Enter document name: ')
      call inputrestore()

      if(!empty(name))
        call linny_menu_documents#new_in_leaf(name)
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

function s:job_start(command)
  if has('nvim')
    call jobstart( a:command)
  else
    call job_start( a:command)
  endif
endfunction
