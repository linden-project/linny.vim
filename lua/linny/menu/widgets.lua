-- linny/menu/widgets.lua - Dashboard widget functions for linny menu
-- Provides widget rendering and data retrieval for the menu system

local M = {}

local items = require('linny.menu.items')

--- Get recently modified files from wiki content directory
--- @param number number Number of recent files to return
--- @return table List of recently modified filenames
function M.recent_files(number)
  local cmd = 'ls -1t ' .. vim.g.linny_path_wiki_content .. ' | grep -ve "^index.*\\|\\.docdir" | head -' .. number
  local files = vim.fn.systemlist(cmd)
  return files or {}
end

--- Get starred terms from index
--- @return table List of starred term objects
function M.starred_terms_list()
  local terms = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_terms_starred.json', {})
  return terms
end

--- Get starred docs from index
--- @return table List of starred document filenames
function M.starred_docs_list()
  local docs = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_docs_starred.json', {})
  return docs
end

--- Render a list of files in the menu
--- @param files_list table List of files (strings or tables with .file and .fm)
--- @param view_props table View properties including sort, label
--- @param bool_extra_file_info boolean Whether to include extra file info
function M.partial_files_listing(files_list, view_props, bool_extra_file_info)
  local vsort = view_props.sort or "az"

  local titles = {}

  if bool_extra_file_info then
    if view_props.label then
      -- Custom label template
      for _, filel in ipairs(files_list) do
        local label_conf = view_props.label

        -- Replace {placeholder} patterns
        for found in string.gmatch(label_conf, "{(%w+)}") do
          local replace = ""
          if found == "title" then
            replace = vim.fn['linny#doc_title_from_index'](filel.file)
            if not replace or replace == vim.NIL or replace == false then
              replace = filel.file
            end
          else
            if filel.fm and filel.fm[found] then
              replace = filel.fm[found]
            end
          end
          label_conf = string.gsub(label_conf, "{" .. found .. "}", replace)
        end

        titles[label_conf] = filel.file
      end
    else
      -- Simple list - extract file names
      local simple_list = {}
      for _, filel in ipairs(files_list) do
        table.insert(simple_list, filel.file)
      end
      titles = vim.fn['linny#titlesForDocs'](simple_list)
    end
  else
    titles = vim.fn['linny#titlesForDocs'](files_list)
  end

  -- Build sortable structure
  local t_sortable = {}
  local longest_title_length = 0
  local margin_count_string = 5
  local i = 0

  for k, v in pairs(titles) do
    if #k > longest_title_length then
      longest_title_length = #k
    end

    local entry = {
      orgTitle = k,
      orgFile = vim.g.linny_path_wiki_content .. "/" .. v,
      orgBaseFile = v
    }

    if vsort == "az" then
      t_sortable[string.lower(k)] = entry
    elseif vsort == "date" then
      local mod_time = vim.fn.getftime(vim.g.linny_path_wiki_content .. "/" .. v)
      t_sortable[string.format("%011d", 99999999999 - mod_time) .. k] = entry
    else
      t_sortable[tostring(i)] = entry
      i = i + 1
    end
  end

  -- Sort and render
  local title_keys = vim.fn.sort(vim.tbl_keys(t_sortable))

  for _, tk in ipairs(title_keys) do
    local tasks_stats_str = ""

    if bool_extra_file_info then
      local filename = t_sortable[tk].orgBaseFile
      local tasks_count = vim.t.linny_tasks_count

      if tasks_count and tasks_count[filename] then
        local open = tasks_count[filename].open
        local closed = tasks_count[filename].closed
        local total = tasks_count[filename].total

        if open and open > 0 then
          tasks_stats_str = "[" .. closed .. "/" .. total .. "]"
          local space = string.rep(" ", longest_title_length - #t_sortable[tk].orgTitle - #tasks_stats_str + margin_count_string)
          tasks_stats_str = " " .. space .. tasks_stats_str
        end
      end
    end

    items.add_document(
      t_sortable[tk].orgTitle .. tasks_stats_str,
      t_sortable[tk].orgFile,
      "",
      "document"
    )
  end
end

--- Widget: Starred documents
--- @param widgetconf table Widget configuration
function M.starred_documents(widgetconf)
  local starred = M.starred_docs_list()
  M.partial_files_listing(starred, { sort = "az" }, false)
end

--- Widget: All level0 views
--- @param widgetconf table Widget configuration
function M.all_level0_views(widgetconf)
  local level0views = vim.fn.glob(vim.g.linny_path_wiki_config .. "/views/*.yml", false, true)
  for _, viewfile in ipairs(vim.fn.sort(level0views)) do
    local filename = vim.fn.fnamemodify(viewfile, ":t")
    items.add_document(filename, viewfile, "", "file")
  end
end

--- Widget: Starred terms
--- @param widgetconf table Widget configuration
function M.starred_terms(widgetconf)
  local starred = M.starred_terms_list()
  local starred_list = {}

  for _, item in ipairs(starred) do
    local key = item.taxonomy .. "," .. item.term
    starred_list[key] = item
  end

  for _, sk in ipairs(vim.fn.sort(vim.tbl_keys(starred_list))) do
    items.add_document_taxo_key_val(starred_list[sk].taxonomy, starred_list[sk].term, 1)
  end
end

--- Widget: Starred taxonomies
--- @param widgetconf table Widget configuration
function M.starred_taxonomies(widgetconf)
  local index_keys_list = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_taxonomies_starred.json', {})

  for _, k in ipairs(vim.fn.sort(index_keys_list)) do
    items.add_document_taxo_key(k)
  end
end

--- Widget: All taxonomies
--- @param widgetconf table Widget configuration
function M.all_taxonomies(widgetconf)
  local index_keys_list = vim.fn['linny#parse_json_file'](vim.g.linny_index_path .. '/_index_taxonomies.json', {})

  for _, k in ipairs(vim.fn.sort(index_keys_list)) do
    items.add_document_taxo_key(k)
  end
end

--- Widget: Recently modified documents
--- @param widgetconf table Widget configuration
function M.recently_modified_documents(widgetconf)
  local number = widgetconf.number or 5
  local recent = M.recent_files(number)
  M.partial_files_listing(recent, { sort = "date" }, false)
end

--- Widget: Menu items
--- @param widgetconf table Widget configuration with items array
function M.menu(widgetconf)
  if widgetconf.items then
    for _, item in ipairs(widgetconf.items) do
      if item.execute then
        items.add_ex_event(item.title, item.execute, "")
      end
    end
  end
end

--- Widget: Configured notebooks
--- Displays all notebooks from g:linny_notebooks list
--- @param widgetconf table Widget configuration (show_path: boolean)
function M.configured_notebooks(widgetconf)
  local notebooks = vim.g.linny_notebooks or {}
  local current_notebook = vim.g.linny_open_notebook_path or ''

  for _, notebook_path in ipairs(notebooks) do
    -- Get basename as display title
    local title = vim.fn.fnamemodify(notebook_path, ':t')
    if title == '' then
      title = notebook_path
    end

    -- Mark active notebook with asterisk
    local is_active = (notebook_path == current_notebook)
    if is_active then
      title = '* ' .. title
    end

    -- Show full path if configured
    if widgetconf.show_path then
      title = title .. ' (' .. notebook_path .. ')'
    end

    -- Create switch command: set path and reinitialize
    local switch_cmd = string.format(
      ":let g:linny_open_notebook_path = '%s' | call linny#Init() | call linny#make_index() | call linny_menu#openandshow()",
      vim.fn.escape(notebook_path, "'")
    )

    items.add_ex_event(title, switch_cmd, "")
  end
end

return M
