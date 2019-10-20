
call linny_util#initVariable("g:linny_version", '0.5.0')

" MAIN CONF SETTINGS
call linny_util#initVariable("g:linny_path_dbroot", '~/Linny')
call linny_util#initVariable("g:linny_path_dbindex", '~/.linny/index')
call linny_util#initVariable("g:linny_path_uistate", '~/.linny/state')
call linny_util#initVariable("g:linny_index_cli_command", 'cd $HOME/.vim/linny-script/ && rvm 2.5.1 do ruby ./make_wiki_index.rb')

function! linny#Init()

  let g:linny_root_path = expand(g:linny_path_dbroot)
  let g:linny_state_path = expand(g:linny_path_uistate)
  let g:linny_index_path = expand(g:linny_path_dbindex)

  call linny#setup_paths()

  let g:linny_index_config = linny#parse_yaml_to_dict( expand( g:linny_root_path .'/config/L0-CONF-ROOT.yml'))

  call linny#cache_index()

endfunction

function! linny#setup_paths()

  call linny#fatal_check_dir(g:linny_root_path)

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



function! linny#PluginVersion()
    return g:linny_version
endfunction

function! s:initVariable(var, value)
  if !exists(a:var)
    exec 'let ' . a:var . ' = ' . "'" . a:value . "'"
    return 1
  endif
  return 0
endfunction

call s:initVariable("s:spaceReplaceChar", '_')

"utility
function! linny#FilenameToWikiLink(filename)

  let filename = linny#FilenameToWord(a:filename)
  let word = '[[' . filename . ']]'

  return word

endfunction

function! linny#FilenameToWord(filename)
  return substitute(a:filename, '_', ' ', 'g')

endfunction

"user func for mapping
function! linny#FilenameToWordToUnamedRegister()
  let @@ = linny#FilenameToWikiLink( expand('%:t:r') )
endfunction


function! linny#new_dir(...)

  let dir_name = join(a:000)

  if !isdirectory(g:linny_dirs_root)
    echo "g:linny_dirs_root is not a valid directory"
    return
  endif

  let relativePath = fnameescape(g:linny_dirs_root .'/'.dir_name )
  if filereadable(relativePath)
    echo "directory name already exist"
    return
  endif

  exec "!mkdir ". relativePath
  return g:linny_dirs_root .'/'.dir_name
endfunction

function! linny#make_index()
  if exists('g:linny_index_cli_command')
    execute "!". g:linny_index_cli_command

    call linny#cache_index()

  else
    echo "Error: g:linny_index_cli_command not set"
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

func! linny#browse_taxonomies()

  "let currentKey = linny_wiki#YamlKeyUnderCursor()
  "exec ":startinsert"

  let relativePath = fnameescape(g:linny_index_path . '/_index_taxonomies.json')

  if filereadable(relativePath)
    let taxonomiesList = linny#parse_json_file( relativePath, [] )

    let taxList = []
    for taxonomy in taxonomiesList
      call add(taxList, taxonomy . ": ")
    endfor

    call setline('.', "")
    call cursor(line('.'), 1)
    call complete(1, sort(taxList))
  endif

  return ''
endfunc

func! linny#browse_taxonomy_terms()

  let currentKey = linny_wiki#YamlKeyUnderCursor()

  let relativePath = fnameescape(linny#l2_index_filepath(currentKey))

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

    call setline('.', currentKey .": ")
    call cursor(line('.'), strlen(currentKey)+3)
    call complete(strlen(currentKey)+3, sort(tvList))
  endif

  return ''
endfunc

func! linny#taxTermTitle(tax, term)
  let l2_config = linny#termConfig(a:tax, a:term)
  if has_key(l2_config, 'title')
    return get(l2_config, 'title')
  else
    return a:term
  end
endfunc

function! linny#grep(...)
  let awkLinnyGrep = "grep -nri ".'"'.join(a:000).'"'." ". g:linny_root_path ."/wiki | awk -F".'"'.":".'"'." {'gsub(/^[ \t]/, ".'""'.", $3);print $1".'"'.'|"$2"| "$3'."'}"
  execute 'AsyncRun! '. awkLinnyGrep
endfunction

function! linny#move_to(dest)
  let relativePath = fnameescape( g:linny_root_path . '/wiki/')
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
  return g:linny_index_path . '/L1-INDEX-TAX-'.tolower(a:tax).'.json'
endfunction

function! linny#l2_index_filepath(tax, term)
  return g:linny_index_path . '/L2-INDEX-TAX-'.tolower(a:tax).'-TRM-'.tolower(a:term).'.json'
endfunction

function! linny#l1_config_filepath(tax)
  return g:linny_root_path ."/config/L1-CONF-TAX-".tolower(a:tax).'.yml'
endfunction

function! linny#l2_config_filepath(tax, term)
  return g:linny_root_path ."/config/L2-CONF-TAX-".tolower(a:tax).'-TRM-'.tolower(a:term).'.yml'
endfunction

function! linny#l1_state_filepath(tax)
  return g:linny_state_path ."/L1-STATE-TAX-".tolower(a:tax).'.json'
endfunction

function! linny#l2_state_filepath(tax, term)
  return g:linny_state_path ."/L2-STATE-TRM-".tolower(a:tax).'-TRM-'.tolower(a:term).'.json'
endfunction

function! linny#index_tax_config(tax)
  if has_key(g:linny_index_config, 'index_keys')
    let index_keys = get(g:linny_index_config,'index_keys')
    if has_key(index_keys, a:tax)
      let tax_config = get(index_keys, a:tax)
      return tax_config
    endif
  endif

  return {}

endfunction

function! linny#taxConfig(tax)
  let config = linny#parse_yaml_to_dict( linny#l1_config_filepath(a:tax))
  return config
endfunction

function! linny#termConfig(tax, term)
  let config = linny#parse_yaml_to_dict( linny#l2_config_filepath(a:tax, a:term))
  return config
endfunction


