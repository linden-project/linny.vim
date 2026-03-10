" Copyright (c) Pim Snel 2019-2023

if exists("g:loaded_linny_autoload")
"    finish
endif

let g:loaded_linny_autoload = 1

"----------------------------------------------------------------------
" MAIN CONF SETTINGS
"----------------------------------------------------------------------
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_path_index", '~/.linny_temp/index'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_path_state", '~/.linny_temp/state'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_rebuild_index_command", ''])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_index_version", 'linden01'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_debug", 0])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_setup_autocommands", 1])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_open_notebook_path", ''])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_initialized", 0])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_hugo_watch_enabled", 0])

"----------------------------------------------------------------------
" NAVIGATOR OPTIONS
"----------------------------------------------------------------------
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_max_width", 50])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_padding_left", 3])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_padding_right", 3])

"----------------------------------------------------------------------
" Don't modify these
"----------------------------------------------------------------------
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:startWord", '[['])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:endWord", ']]'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:startLink", '('])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:endLink", ')'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:spaceReplaceChar", '_'])

call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_options", 'T'])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_display_docs_count", 1])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_menu_display_taxo_count", 1])
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnytabnr", 1])


" CONFIG VARS ARE TRANSFERED TO REEGULAR VARS
" CONFIG IS READ
" CACHE IS SETUP
function! linny#Init()
  " Reset initialization state - will be set to 1 only on successful completion
  let g:linny_initialized = 0

  let g:linny_open_notebook_path = expand(g:linny_open_notebook_path)

  if !luaeval("require('linny.notebook').init()")
    return
  endif

  let g:linny_state_path = expand(g:linnycfg_path_state)

  let g:linny_index_version = g:linnycfg_index_version
  let g:linny_debug = g:linnycfg_debug

  let g:linny_wikitags_register = get(g:, 'linny_wikitags_register', {})
  let g:linny_leader = get(g:, 'linny_leader', ';')

  if !linny#setup_paths()
    return
  endif

  call linny#cache_index()

  call linny_menu#RemapGlobalKeys()

  let g:linny_initialized = 1

endfunction

function! linny#ListTags()
  echom g:linny_wikitags_register
endfunction

function! linny#RegisterLinnyWikitag(tagKey, primaryAction, ...)
  let g:linny_wikitags_register = get(g:, 'linny_wikitags_register', {})
  let secondaryAction = a:0 >= 1 ? a:1 : a:primaryAction

  if has_key(g:linny_wikitags_register, a:tagKey)
    return
  else
    let g:linny_wikitags_register[toupper(a:tagKey).' '] = {'primaryAction': a:primaryAction, 'secondaryAction': secondaryAction}
  endif
endfunction

" CHECK LINNY WORKING PATHS AND CREATE IF NEEDED
" Returns 1 on success, 0 on failure
function! linny#setup_paths()
  if !linny#fatal_check_dir(g:linny_path_wiki_content)
    return 0
  endif
  if !linny#fatal_check_dir(g:linny_path_wiki_config)
    return 0
  endif

  call linny#create_dir_if_not_exixt(g:linny_state_path)
  if !linny#fatal_check_dir(g:linny_state_path)
    return 0
  endif

  call linny#create_dir_if_not_exixt(g:linny_index_path)
  if !linny#fatal_check_dir(g:linny_index_path)
    return 0
  endif

  return 1
endfunction

function! linny#create_dir_if_not_exixt(path)
  if !isdirectory(a:path)
    call mkdir(a:path, "p")
  endif
endfunction

" Check if directory exists. Silent operation - use :checkhealth linny for diagnostics.
" Returns 1 if exists, 0 if not
function! linny#fatal_check_dir(path)
  return isdirectory(a:path)
endfunction

" Check if linny is initialized, show helpful message if not
" Returns 1 if initialized, 0 if not
function! linny#require_init()
  if get(g:, 'linny_initialized', 0)
    return 1
  endif
  echohl WarningMsg
  echo "Linny not initialized. Set g:linny_open_notebook_path"
  echo "Get started: https://github.com/linden-project/linny-notebook-template"
  echohl None
  return 0
endfunction

" Health check - validates plugin configuration
" Returns dict with 'ok' (0/1) and 'errors' (list of strings)
function! linny#health_check()
  return luaeval("require('linny.health').validate()")
endfunction

function! linny#FilenameToWikiLink(filename)

  let filename = linny#FilenameToWord(a:filename)
  let word = '[[' . filename . ']]'

  return word

endfunction

function! linny#FilenameToWord(filename)
  return substitute(a:filename, '_', ' ', 'g')

endfunction

" USER FUNC FOR MAPPING
function! linny#FilenameToWordToUnamedRegister()
  let @@ = linny#FilenameToWikiLink( expand('%:t:r') )
endfunction

function! linny#make_index()
  if exists('g:linnycfg_rebuild_index_command')
    silent execute "!". g:linnycfg_rebuild_index_command
    call linny#cache_index()
  else
    echo "Error: g:linnycfg_rebuild_index_command not set"
  endif
endfunction

function! linny#cache_index()
    let g:linny_cache_index_docs_titles = linny#docs_titles()
endfunction

function! linny#doc_title_from_index(filename)

  if has_key(g:linny_cache_index_docs_titles, a:filename)
    return g:linny_cache_index_docs_titles[a:filename]
  endif

  return a:filename
endfunction

func! linny#btx()
  call linny#browse_taxonomies()
  return ''
endfunction

func! linny#browse_taxonomies()

  let relativePath = fnameescape(g:linny_index_path . '/_index_taxonomies.json')

  if filereadable(relativePath)
    let taxonomiesList = linny#parse_json_file( relativePath, [] )

    let taxList = []
    for taxonomy in taxonomiesList
      call add(taxList, taxonomy . ": ")
    endfor

    if mode() =='i'
      let startword = getline('.')[0:col('.')-1]
    else
      let startword = expand("<cword>")
    endif

    let taxListFiltered = filter(copy(taxList), 'v:val =~ "^'. startword .'"')

    call setline('.', "")
    call cursor(line('.'), 1)
    call complete(1, sort(taxListFiltered))
  endif

  return ''
endfunc

func! linny#btr()
  call linny#browse_taxonomy_terms()
  return ''
endfunction

func! linny#browse_taxonomy_terms()

  let currentKey = luaeval("require('linny.wiki').yaml_key_under_cursor()")

  let relativePath = fnameescape(linny#l1_index_filepath(currentKey))

  if filereadable(relativePath)
    let termslistDict = linny#parse_json_file( relativePath, [] )
    let tvList = []

    for trm in keys(termslistDict)
      if has_key( termslistDict[trm], 'title')
        call add(tvList, termslistDict[trm]['title'])
      else
        call add(tvList, trm)
      end
    endfor

    if mode() =='i'
      let startword = getline('.')[strlen(currentKey)+2:col('.')-1]
    else
      let startword = expand("<cword>")
    endif
    echom startword

    let tvListFiltered = filter(copy(tvList), 'v:val =~ "'. startword .'"')

    call setline('.', currentKey .": ")
    call cursor(line('.'), strlen(currentKey)+3)
    call complete(strlen(currentKey)+3, sort(tvListFiltered))
  endif

  return ''
endfunc

func! linny#taxTermTitle(tax, term)
  let l2_config = linny#term_config(a:tax, a:term)
  if has_key(l2_config, 'title')
    return get(l2_config, 'title')
  else
    return a:term
  end
endfunc

function! linny#move_to(dest)
  let relativePath = fnameescape( g:linny_path_wiki_content . '/')
  exec "!mkdir -p ". relativePath ."/".a:dest
  exec "!mv '%' " . relativePath . "/".a:dest."/"
  exec "bdelete"
endfunction

function! linny#generate_first_content(title, taxoEntries)
  let fileLines = []
  call add(fileLines, '---')
  call add(fileLines, 'title: "'.a:title.'"')
  call add(fileLines, 'crdate: "'.strftime("%Y-%m-%d").'"')

  for entry in a:taxoEntries
    call add(fileLines, entry['term'] . ': '.entry['value'])
  endfor

  call add(fileLines, '---')
  call add(fileLines, '')

  return fileLines

endfunction

function! linny#parse_yaml_to_dict(filePath)
  if filereadable(a:filePath)
    "let tmp = json_decode(system('ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('."'". a:filePath. "'".'))"'))
    return json_decode(system('ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('."'". a:filePath. "'".'))"'))
  endif
  return {}
endfunction

function! linny#parse_json_file(filePath, empty_return)
  if filereadable(a:filePath)
    let lines = readfile(a:filePath)
    let json = join(lines)
    let vars = json_decode(json)
    return vars
  endif
  return a:empty_return
endfunction

function! linny#write_json_file(filePath, object)
  call writefile([json_encode(a:object)], a:filePath)
endfunction

function! linny#docs_titles()
  let docs_titles = linny#parse_json_file(g:linny_index_path . '/_index_docs_with_title.json', [])
  return docs_titles
endfunction

function! linny#titlesForDocs(docs_list)

  let titles = {}

  for k in a:docs_list
    let titles[linny#doc_title_from_index(k)] = k
  endfor

  return titles
endfunction


function! linny#l1_index_filepath(tax)
  return luaeval("require('linny.paths').l1_index_filepath(_A)", a:tax)
endfunction

function! linny#l2_index_filepath(tax, term)
  return luaeval("require('linny.paths').l2_index_filepath(_A[1], _A[2])", [a:tax, a:term])
endfunction

function! linny#view_config_filepath(view_name)
  return luaeval("require('linny.paths').view_config_filepath(_A)", a:view_name)
endfunction

function! linny#l1_config_filepath(tax)
  return luaeval("require('linny.paths').l1_config_filepath(_A)", a:tax)
endfunction

function! linny#l2_config_filepath(tax, term)
  return luaeval("require('linny.paths').l2_config_filepath(_A[1], _A[2])", [a:tax, a:term])
endfunction

function! linny#l1_state_filepath(tax)
  return luaeval("require('linny.paths').l1_state_filepath(_A)", a:tax)
endfunction

function! linny#l2_state_filepath(tax, term)
  return luaeval("require('linny.paths').l2_state_filepath(_A[1], _A[2])", [a:tax, a:term])
endfunction

function! linny#view_config(view_name)
  let config = linny#parse_yaml_to_dict( linny#view_config_filepath(a:view_name))
  return config
endfunction

function! linny#tax_config(tax)
  let config = linny#parse_yaml_to_dict( linny#l1_config_filepath(a:tax))
  return config
endfunction

function! linny#term_config(tax, term)
  let config = linny#parse_yaml_to_dict( linny#l2_config_filepath(a:tax, a:term))
  return config
endfunction

" Rebuild Hugo index for the current notebook
" Returns 1 on success, 0 on failure
function! linny#hugo_rebuild_index()
  let notebook_path = get(g:, 'linny_open_notebook_path', '')
  if notebook_path == ''
    echohl WarningMsg
    echo "No notebook path configured"
    echohl None
    return 0
  endif

  let result = luaeval("require('linny.hugo').build_index(_A)", notebook_path)

  if result.ok
    echo "Hugo index rebuilt successfully"
    return 1
  else
    echohl WarningMsg
    echo "Hugo index rebuild failed: " . result.error
    echohl None
    return 0
  endif
endfunction

" Start Hugo watch mode for the current notebook
" Returns 1 on success, 0 on failure
function! linny#hugo_start_watch()
  let notebook_path = get(g:, 'linny_open_notebook_path', '')
  if notebook_path == ''
    echohl WarningMsg
    echo "No notebook path configured"
    echohl None
    return 0
  endif

  let result = luaeval("require('linny.hugo').start_watch(_A)", notebook_path)

  if result.ok
    echo "Hugo watch mode started"
    " Refresh menu if open to show updated status
    if luaeval("require('linny.menu.window').exist()")
      call linny_menu#openandshow()
    endif
    return 1
  else
    echohl WarningMsg
    echo "Hugo watch failed: " . result.error
    echohl None
    return 0
  endif
endfunction

" Stop Hugo watch mode
" Returns 1 on success, 0 on failure
function! linny#hugo_stop_watch()
  let result = luaeval("require('linny.hugo').stop_watch()")

  if result.ok
    echo "Hugo watch mode stopped"
    " Refresh menu if open to show updated status
    if luaeval("require('linny.menu.window').exist()")
      call linny_menu#openandshow()
    endif
    return 1
  else
    echohl WarningMsg
    echo "Hugo stop failed: " . result.error
    echohl None
    return 0
  endif
endfunction
