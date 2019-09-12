call wimpi_util#initVariable("g:wimpi_version", '0.4.1')


function! wimpi#Init()
  let g:wimpi_version = '0.4.1'

  let g:wimpi_main_config = wimpi#parse_yaml_to_dict( expand('~/.wimpi/wimpi.yml') )

  let g:wimpi_state_dir = expand('~/.wimpi/state')

  let g:wimpi_root_path = expand(g:wimpi_main_config['root_path'])
  let g:wimpi_index_config = wimpi#parse_yaml_to_dict( expand( g:wimpi_root_path .'/config/wiki_indexes.yml'))

  if has_key(g:wimpi_main_config, 'index_files_path')
    let g:wimpi_index_path = expand(g:wimpi_main_config['index_files_path'])
  else
    let g:wimpi_index_path = expand(g:wimpi_root_path. '/index')
  end

  call wimpi#cache_index()

endfunction

function! wimpi#PluginVersion()
    return g:wimpi_version
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
function! wimpi#FilenameToWord(filename)

  let filename = substitute(a:filename, '_', ' ', 'g')
  let word = '[[' . filename . ']]'

  return word

endfunction

"user func for mapping
function! wimpi#FilenameToWordToUnamedRegister()
  let @@ = wimpi#FilenameToWord( expand('%:t:r') )
endfunction


function! wimpi#new_dir(...)

  let dir_name = join(a:000)

  if !isdirectory(g:wimpi_dirs_root)
    echo "g:wimpi_dirs_root is not a valid directory"
    return
  endif

  let relativePath = fnameescape(g:wimpi_dirs_root .'/'.dir_name )
  if filereadable(relativePath)
    echo "directory name already exist"
    return
  endif

  exec "!mkdir ". relativePath
  return g:wimpi_dirs_root .'/'.dir_name
endfunction

function! wimpi#make_index()
  if exists('g:wimpi_index_cli_command')
    execute "!". g:wimpi_index_cli_command

    call wimpi#cache_index()

  else
    echo "Error: g:wimpi_index_cli_command not set"
  endif
endfunction

function! wimpi#cache_index()
    let g:wimpi_cache_index_docs_titles =  wimpi#docs_titles()
endfunction

function! wimpi#doc_title_from_index(filename)

  if has_key(g:wimpi_cache_index_docs_titles, a:filename)
    return g:wimpi_cache_index_docs_titles[a:filename]
  endif

  return a:filename
endfunction

func! wimpi#browsetaxovals()

  let currentKey = wimpi_wiki#YamlKeyUnderCursor()

  let relativePath = fnameescape(wimpi#l2_index_filepath(currentKey))

  if filereadable(relativePath)
    let termslistDict = wimpi#parse_json_file( relativePath, [] )
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

func! wimpi#taxoValTitle(tk, tv)
  let l3_config = wimpi#termValueLeafConfig(a:tk, a:tv)
  if has_key(l3_config, 'title')
    return get(l3_config, 'title')
  else
    return a:tv
  end
endfunc

function! wimpi#grep(...)
  let awkWimpiGrep = "grep -nri ".'"'.join(a:000).'"'." ". g:wimpi_root_path ."/wiki | awk -F".'"'.":".'"'." {'gsub(/^[ \t]/, ".'""'.", $3);print $1".'"'.'|"$2"| "$3'."'}"
  execute 'AsyncRun! '. awkWimpiGrep
endfunction

function! wimpi#move_to(dest)
  let relativePath = fnameescape( g:wimpi_root_path . '/wiki/')
  exec "!mkdir -p ". relativePath ."/".a:dest
  exec "!mv '%' " . relativePath . "/".a:dest."/"
  exec "bdelete"
endfunction

function! wimpi#generate_first_content(title, taxoEntries)
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

function! wimpi#parse_yaml_to_dict(filePath)
  if filereadable(a:filePath)
    return json_decode(system('ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('."'". a:filePath. "'".'))"'))
  endif
  return {}
endfunction

function! wimpi#parse_json_file(filePath, empty_return)
  if filereadable(a:filePath)
    let lines = readfile(a:filePath)
    let json = join(lines)
    let vars = json_decode(json)
    return vars
  endif
  return a:empty_return
endfunction

function! wimpi#write_json_file(filePath, object)
  call writefile([json_encode(a:object)], a:filePath)
endfunction


function! wimpi#docs_titles()
  let docs_titles = wimpi#parse_json_file(g:wimpi_index_path . '/_index_docs_with_title.json', [])
  return docs_titles
endfunction

function! wimpi#titlesForDocs(docs_list)

  let titles = {}

  for k in a:docs_list
    let titles[wimpi#doc_title_from_index(k)] = k
  endfor

  return titles
endfunction


function! wimpi#l2_index_filepath(term)
  return g:wimpi_index_path . '/L2-INDEX_TRM_'.tolower(a:term).'.json'
endfunction

function! wimpi#l3_index_filepath(term, value)
  "L3-INDEX_TRM_klant_VAL_andreas de kock.json
  return g:wimpi_index_path . '/L3-INDEX_TRM_'.tolower(a:term).'_VAL_'.tolower(a:value).'.json'
endfunction

function! wimpi#l2_config_filepath(term)
  return g:wimpi_root_path ."/config/L2-CONF_TRM_".tolower(a:term).'.yml'
endfunction

function! wimpi#l3_config_filepath(term, value)
  return g:wimpi_root_path ."/config/L3-CONF_TRM_".tolower(a:term).'_VAL_'.tolower(a:value).'.yml'
endfunction

function! wimpi#l3_state_filepath(term, value)

  if !isdirectory(g:wimpi_state_dir)
    exec "!mkdir ". g:wimpi_state_dir
  endif

  return g:wimpi_state_dir ."/L3-STATE_TRM_".tolower(a:term).'_VAL_'.tolower(a:value).'.json'
endfunction

function! wimpi#index_term_config(term)
  if has_key(g:wimpi_index_config, 'index_keys')
    let index_keys = get(g:wimpi_index_config,'index_keys')
    if has_key(index_keys, a:term)
      let term_config = get(index_keys, a:term)
      return term_config
    endif
  endif

  return {}

endfunction

function! wimpi#termValueLeafConfig(term, value)
  let config = wimpi#parse_yaml_to_dict( wimpi#l3_config_filepath(a:term, a:value))
  return config
endfunction

function! wimpi#termLeafConfig(term)
  let config = wimpi#parse_yaml_to_dict( wimpi#l2_config_filepath(a:term))
  return config
endfunction


