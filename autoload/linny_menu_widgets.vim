" linny_menu_widgets.vim - Dashboard widget functions for linny menu

" Get recently modified files
function! linny_menu_widgets#recent_files(number)
  let files = []
  let files = systemlist('ls -1t '.g:linny_path_wiki_content.' | grep -ve "^index.*\|\.docdir" | head -' . a:number)
  return files
endfunction

" Get starred terms from index
function! linny_menu_widgets#starred_terms_list()
  let terms = linny#parse_json_file(g:linny_index_path . '/_index_terms_starred.json', [])
  return terms
endfunction

" Get starred docs from index
function! linny_menu_widgets#starred_docs_list()
  let docs = linny#parse_json_file(g:linny_index_path . '/_index_docs_starred.json', [])
  return docs
endfunction

" Render a list of files in the menu
function! linny_menu_widgets#partial_files_listing(files_list, view_props, bool_extra_file_info)

  if has_key(a:view_props, 'sort')
    let vsort = get(a:view_props,'sort')
  else
    let vsort = "az"
  end

  if (a:bool_extra_file_info)

    if has_key(a:view_props, 'label')

      let titles = {}
      for filel in a:files_list

        let label_conf = a:view_props.label

        let pat = '[{]\w\+[}]'

        while match(label_conf, pat ) >= 0
          let found = matchstr(label_conf, pat )
          let found2 = substitute(found, '[{]', '', '')
          let found2 = substitute(found2, '[}]', '', '')

          let replace = ""
          if found2 == 'title'
            let replace = linny#doc_title_from_index(filel.file)
            if !replace
              let replace = ""
              let replace = filel.file
            endif

          else
            if has_key(filel.fm, found2)
              let replace = filel.fm[found2]
            else
              let replace = ""
            end
          end

          let label_conf = substitute(label_conf, found, replace, "")
        endwhile

        let titles[label_conf] = filel.file

      endfor

    else
      let simple_list = []
      for filel in a:files_list
        call add(simple_list,filel.file)
      endfor

      let titles = linny#titlesForDocs(simple_list)

    endif

  else
    let titles = linny#titlesForDocs(a:files_list)
  end

  let t_sortable = {}
  let i = 0
  let longest_title_length = 0
  let margin_count_string = 5
  for k in keys(titles)

    if strchars(k) > longest_title_length
      let longest_title_length = strchars(k)
    endif

    let entry = {}
    let entry.orgTitle = k
    let entry.orgFile = g:linny_path_wiki_content . "/" . titles[k]
    let entry.orgBaseFile = titles[k]

    if vsort == 'az'
      let t_sortable[tolower(k)] = entry
    elseif vsort == 'date'
      let modFileTime = getftime(g:linny_path_wiki_content . "/".titles[k])
      let t_sortable[string(99999999999-modFileTime).k] = entry
    else
      let t_sortable[i] = entry
      let i += 1
    endif

  endfor

  let title_keys = sort(keys(t_sortable))

  for tk in title_keys

    let tasks_stats_str = ''
    if (a:bool_extra_file_info)
      let filename = t_sortable[tk]['orgBaseFile']
      if has_key(t:linny_tasks_count, filename)

        let open = t:linny_tasks_count[filename]['open']
        let closed = t:linny_tasks_count[filename]['closed']
        let total = t:linny_tasks_count[filename]['total']

        if(open>0)
          let tasks_stats_str = '[' . closed .'/'. total .']'
          let space = repeat(' ',longest_title_length - strchars(t_sortable[tk]['orgTitle'])-strchars(tasks_stats_str) + margin_count_string)
          let tasks_stats_str = ' ' . space . tasks_stats_str
        end
      end
    end

    call linny_menu_items#add_document(t_sortable[tk]['orgTitle'] . tasks_stats_str, t_sortable[tk]['orgFile'], '', 'document')
  endfor

endfunction

" Widget: Starred documents
function! linny_menu_widgets#starred_documents(widgetconf)
  let starred = linny_menu_widgets#starred_docs_list()
  call linny_menu_widgets#partial_files_listing( starred, {'sort':'az'}, 0)
endfunction

" Widget: All level0 views
function! linny_menu_widgets#all_level0_views(widgetconf)
  echom a:widgetconf
  let level0views = glob(g:linny_path_wiki_config .'/views/*.yml',0,1)
  for viewfile in sort(level0views)
    let filename = substitute(viewfile, '^.*/', '', '')
    call linny_menu_items#add_document(filename, viewfile,'','file')
  endfor
endfunction

" Widget: Starred terms
function! linny_menu_widgets#starred_terms(widgetconf)
  let starred = linny_menu_widgets#starred_terms_list()
  let starred_list = {}

  for i in starred
    let starred_list[i['taxonomy'].','.i['term']] = i
  endfor

  for sk in sort(keys(starred_list))
    call linny_menu_items#add_document_taxo_key_val(starred_list[sk]['taxonomy'], starred_list[sk]['term'], 1)
  endfor
endfunction

" Widget: Starred taxonomies
function! linny_menu_widgets#starred_taxonomies(widgetconf)
  let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies_starred.json', [])

  for k in sort(index_keys_list)
    call linny_menu_items#add_document_taxo_key(k)
  endfor
endfunction

" Widget: All taxonomies
function! linny_menu_widgets#all_taxonomies(widgetconf)
  let index_keys_list = linny#parse_json_file(g:linny_index_path . '/_index_taxonomies.json', [])
  for k in sort(index_keys_list)
    call linny_menu_items#add_document_taxo_key(k)
  endfor
endfunction

" Widget: Recently modified documents
function! linny_menu_widgets#recently_modified_documents(widgetconf)
  let number = 5
  if has_key(a:widgetconf, 'number')
    let number = a:widgetconf['number']
  end

  let recent = linny_menu_widgets#recent_files(number)
  call linny_menu_widgets#partial_files_listing( recent , {'sort':'date'}, 0)
endfunction

" Widget: Menu items
function! linny_menu_widgets#menu(widgetconf)
  for item in a:widgetconf['items']
    if has_key(item, 'execute')
      call linny_menu_items#add_ex_event(item['title'], item['execute'], '')
    endif
  endfor
endfunction
