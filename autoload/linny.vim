" Copyright (c) Pim Snel 2019-2021

if exists("g:loaded_linny_autoload")
"    finish
endif

let g:loaded_linny_autoload = 1

"----------------------------------------------------------------------
" MAIN CONF SETTINGS
"----------------------------------------------------------------------
call linny_util#initVariable("g:linnycfg_path_index", '~/.linny_temp/index')
call linny_util#initVariable("g:linnycfg_path_state", '~/.linny_temp/state')
call linny_util#initVariable("g:linnycfg_rebuild_index_command", '')
call linny_util#initVariable("g:linnycfg_index_version", 'linden01')
call linny_util#initVariable("g:linnycfg_debug", 0)
call linny_util#initVariable("g:linnycfg_setup_autocommands", 1)
call linny_util#initVariable("g:linnycfg_path_wiki_content", '~/Linny/wikiContent')
call linny_util#initVariable("g:linnycfg_path_wiki_config", '~/Linny/wikiConfig')

"----------------------------------------------------------------------
" NAVIGATOR OPTIONS
"----------------------------------------------------------------------
call linny_util#initVariable("g:linny_menu_max_width", 50)
call linny_util#initVariable("g:linny_menu_padding_left", 3)
call linny_util#initVariable("g:linny_menu_padding_right", 3)

"----------------------------------------------------------------------
" Don't modify these
"----------------------------------------------------------------------
call linny_util#initVariable("g:startWord", '[[')
call linny_util#initVariable("g:endWord", ']]')
call linny_util#initVariable("g:startLink", '(')
call linny_util#initVariable("g:endLink", ')')
call linny_util#initVariable("g:spaceReplaceChar", '_')

call linny_util#initVariable("g:linny_menu_options", 'T')
call linny_util#initVariable("g:linny_menu_display_docs_count", 1)
call linny_util#initVariable("g:linny_menu_display_taxo_count", 1)
call linny_util#initVariable("g:linnytabnr", 1)


" CONFIG VARS ARE TRANSFERED TO REEGULAR VARS
" CONFIG IS READ
" CACHE IS SETUP
function! linny#Init()

  let g:linny_path_wiki_content = expand(g:linnycfg_path_wiki_content)
  let g:linny_path_wiki_config = expand(g:linnycfg_path_wiki_config)

  let g:linny_state_path = expand(g:linnycfg_path_state)
  let g:linny_index_path = expand(g:linnycfg_path_index)

  let g:linny_index_version = g:linnycfg_index_version
  let g:linny_debug = g:linnycfg_debug

  let g:linny_wikitags_register = get(g:, 'linny_wikitags_register', {})
  let g:linny_leader = get(g:, 'linny_leader', ';')

  call linny#setup_paths()

  "let g:linny_index_config = linny#parse_yaml_to_dict( expand( g:linny_path_wiki_config .'/L0-CONF-ROOT.yml'))

  call linny#cache_index()

  call linny_menu#RemapGlobalKeys()

endfunction

function! linny#ListTags()
  echom g:linny_wikitags_register
endfunction

function! linny#RegisterLinnyWikitag(tagKey, primaryAction, ...)
  let secondaryAction = a:0 >= 1 ? a:1 : a:primaryAction

  if has_key(g:linny_wikitags_register, a:tagKey)
    return
  else
    let g:linny_wikitags_register[toupper(a:tagKey).' '] = {'primaryAction': a:primaryAction, 'secondaryAction': secondaryAction}
  endif
endfunction

" CHECK LINNY WORKING PATHS AND CREATE IF NEEDED
function! linny#setup_paths()
  call linny#fatal_check_dir(g:linny_path_wiki_content)
  call linny#fatal_check_dir(g:linny_path_wiki_config)

  call linny#create_dir_if_not_exixt(g:linny_state_path)
  call linny#fatal_check_dir(g:linny_state_path)

  call linny#create_dir_if_not_exixt(g:linny_index_path)
  call linny#fatal_check_dir(g:linny_index_path)
endfunction

function! linny#create_dir_if_not_exixt(path)
  if !isdirectory(a:path)
    call mkdir(a:path, "p")
  endif
endfunction

function! linny#fatal_check_dir(path)
  if !isdirectory(a:path)
    echom "linny CANNOT FUNCION! ERROR: " . a:path . "DOES NOT EXISTS."
  endif
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

"function! linny#new_dir(...)

  "let dir_name = join(a:000)

  "if !isdirectory(g:linny_dirs_root)
    "echo "g:linny_dirs_root is not a valid directory"
    "return
  "endif

  "let relativePath = fnameescape(g:linny_dirs_root .'/'.dir_name )
  "if filereadable(relativePath)
    "echo "directory name already exist"
    "return
  "endif

  "exec "!mkdir ". relativePath
  "return g:linny_dirs_root .'/'.dir_name
"endfunction

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

  let currentKey = linny_wiki#YamlKeyUnderCursor()

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

  for entry in a:taxoEntries
    call add(fileLines, entry['term'] . ': '.entry['value'])
  endfor

  call add(fileLines, '---')
  call add(fileLines, '')

  return fileLines

endfunction

function! linny#parse_yaml_to_dict(filePath)
  if filereadable(a:filePath)

    let tmp = json_decode(system('ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('."'". a:filePath. "'".'))"'))
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
  return g:linny_index_path . '/'.tolower(a:tax).'/index.json'
endfunction

function! linny#l2_index_filepath(tax, term)
  return g:linny_index_path . '/'.tolower(a:tax).'/'.substitute(tolower(a:term),' ','-','g').'/index.json'
endfunction

function! linny#view_config_filepath(view_name)
  return g:linny_path_wiki_config ."/views/".tolower(a:view_name).'.yml'
endfunction

function! linny#l1_config_filepath(tax)
  return g:linny_path_wiki_config ."/L1-CONF-TAX-".tolower(a:tax).'.yml'
endfunction

function! linny#l2_config_filepath(tax, term)
  return g:linny_path_wiki_config ."/L2-CONF-TAX-".tolower(a:tax).'-TRM-'.tolower(a:term).'.yml'
endfunction

function! linny#l1_state_filepath(tax)
  return g:linny_state_path ."/L1-STATE-TAX-".tolower(a:tax).'.json'
endfunction

function! linny#l2_state_filepath(tax, term)
  return g:linny_state_path ."/L2-STATE-TRM-".tolower(a:tax).'-TRM-'.tolower(a:term).'.json'
endfunction

"function! linny#index_tax_config(tax)
  "if has_key(g:linny_index_config, 'index_keys')
    "let index_keys = get(g:linny_index_config,'index_keys')
    "if has_key(index_keys, a:tax)
      "let tax_config = get(index_keys, a:tax)
      "return tax_config
    "endif
  "endif

  "return {}

"endfunction

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


