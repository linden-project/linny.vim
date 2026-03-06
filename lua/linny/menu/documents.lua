-- linny/menu/documents.lua - Document and configuration file operations
-- Handles document copying, creation, and config file management

local M = {}

local util = require('linny.menu.util')

--- Replace a key value in root frontmatter
--- @param file_lines table Array of file lines
--- @param key string The frontmatter key to replace
--- @param new_value string The new value
--- @return table Modified file lines
function M.replace_frontmatter_key(file_lines, key, new_value)
  local frontmatter_started = false
  local key_prefix = key .. ":"

  for idx, line in ipairs(file_lines) do
    if not frontmatter_started and line:sub(1, 3) == "---" then
      frontmatter_started = true
    elseif frontmatter_started and line:sub(1, 3) == "---" then
      break
    elseif frontmatter_started and line:sub(1, #key_prefix) == key_prefix then
      file_lines[idx] = key .. ": " .. new_value
      break
    end
  end

  return file_lines
end

--- Open document in right pane preserving menu layout
--- @param path string Path to the file to open
function M.open_in_right_pane(path)
  local bufname = vim.fn.bufname('%')

  if bufname:find("%[linny_menu%]") then
    local currentwidth = vim.t.linny_menu_lastmaxsize
    local currentWindow = vim.fn.winnr()

    vim.cmd('only')
    vim.cmd('botright vs ' .. vim.fn.fnameescape(path))

    local newWindow = vim.fn.winnr()

    vim.cmd(currentWindow .. 'wincmd w')
    vim.fn['linny_menu#openandshow']()
    vim.cmd('setlocal foldcolumn=0')
    vim.cmd('vertical resize ' .. currentwidth)
    vim.cmd(newWindow .. 'wincmd w')
  else
    vim.cmd('e ' .. vim.fn.fnameescape(path))
  end
end

--- Copy a document with a new title
--- @param source_path string Path to source document
--- @param new_title string Title for the new document
function M.copy(source_path, new_title)
  local fileName = require('linny.wiki').word_to_filename(new_title)
  local relativePath = vim.fn.fnameescape(vim.g.linny_path_wiki_content .. '/' .. fileName)

  if vim.fn.filereadable(relativePath) == 0 and vim.fn.filereadable(source_path) == 1 then
    local fileLines = vim.fn.readfile(source_path)
    fileLines = M.replace_frontmatter_key(fileLines, "title", new_title)

    if vim.fn.writefile(fileLines, relativePath) ~= 0 then
      vim.api.nvim_echo({{"write error", "ErrorMsg"}}, true, {})
      return
    end

    M.open_in_right_pane(relativePath)
  else
    vim.api.nvim_echo({{"Could not copy document with file path: " .. source_path, "WarningMsg"}}, true, {})
  end
end

--- Create new document in current leaf (taxonomy/term)
--- @param title string Title for the new document
function M.new_in_leaf(title)
  local fileName = require('linny.wiki').word_to_filename(title)
  local relativePath = vim.fn.fnameescape(vim.g.linny_path_wiki_content .. '/' .. fileName)

  if vim.fn.filereadable(relativePath) == 0 then
    local taxoEntries = {}

    local taxonomy = vim.t.linny_menu_taxonomy or ""
    local term = vim.t.linny_menu_term or ""

    if taxonomy ~= "" and term ~= "" then
      table.insert(taxoEntries, { term = taxonomy, value = term })

      local config = vim.fn['linny#term_config'](taxonomy, term)
      if config and config.frontmatter_template then
        local fm_template = config.frontmatter_template
        if type(fm_template) == "table" then
          for fm_key, fm_val in pairs(fm_template) do
            local entry = { term = fm_key }
            if fm_val == vim.NIL or fm_val == "v:null" then
              entry.value = ""
            else
              entry.value = fm_val
            end
            table.insert(taxoEntries, entry)
          end
        end
      end
    end

    local fileLines = vim.fn['linny#generate_first_content'](title, taxoEntries)
    if vim.fn.writefile(fileLines, relativePath) ~= 0 then
      vim.api.nvim_echo({{"write error", "ErrorMsg"}}, true, {})
      return
    end
  end

  M.open_in_right_pane(relativePath)
end

--- Archive a L2 (term) config
--- @param taxonomy string The taxonomy name
--- @param taxo_term string The term name
function M.archive_l2_config(taxonomy, taxo_term)
  local confFileName = vim.fn['linny#l2_config_filepath'](taxonomy, taxo_term)
  local fileLines = {}

  if vim.fn.filereadable(confFileName) == 1 then
    fileLines = vim.fn.readfile(confFileName)
    -- Replace first line and add archive: true after ---
    local newLines = { "---", "archive: true" }
    for i = 2, #fileLines do
      table.insert(newLines, fileLines[i])
    end
    fileLines = newLines
  else
    table.insert(fileLines, "---")
    table.insert(fileLines, "title: " .. util.string_capitalize(taxo_term))
    table.insert(fileLines, "infotext: About " .. taxo_term)
    table.insert(fileLines, "archive: true")
  end

  if vim.fn.writefile(fileLines, confFileName) ~= 0 then
    vim.api.nvim_echo({{"write error", "ErrorMsg"}}, true, {})
  end
end

--- Helper to open config file in split
--- @param confFileName string Path to config file
local function open_config_in_split(confFileName)
  vim.cmd('only')
  local currentwidth = vim.t.linny_menu_lastmaxsize
  local currentWindow = vim.fn.winnr()

  vim.cmd('botright vs ' .. confFileName)
  local newWindow = vim.fn.winnr()

  vim.cmd(currentWindow .. 'wincmd w')
  vim.cmd('setlocal foldcolumn=0')
  vim.cmd('vertical resize ' .. currentwidth)
  vim.fn['linny_menu#openandshow']()
  vim.cmd(newWindow .. 'wincmd w')
end

--- Create or open a L2 (term) config
--- @param taxonomy string The taxonomy name
--- @param taxo_term string The term name
function M.create_l2_config(taxonomy, taxo_term)
  local confFileName = vim.fn['linny#l2_config_filepath'](taxonomy, taxo_term)

  if vim.fn.filereadable(confFileName) == 1 then
    open_config_in_split(confFileName)
  else
    local fileLines = {
      "---",
      "title: " .. util.string_capitalize(taxo_term),
      "infotext: About " .. taxo_term,
      "",
      "archive: false",
      "starred: false",
      "",
      "views:",
      "  az:",
      "    sort: az",
      "  date:",
      "    sort: date",
      "  type:",
      "    group_by: type",
      "",
      "#mounts:",
      "  #project docs:",
      "    #source: /home/john/projects/some-project",
      "    #exclude:",
      "      #- README.md",
      "",
      "#locations:",
      "  #website: https://www." .. taxo_term .. ".vim",
      "",
      "#frontmatter_template:",
      "  #project: prj-x",
    }

    if vim.fn.writefile(fileLines, confFileName) ~= 0 then
      vim.api.nvim_echo({{"write error", "ErrorMsg"}}, true, {})
    else
      open_config_in_split(confFileName)
    end
  end
end

--- Create or open a L1 (taxonomy) config
--- @param taxonomy string The taxonomy name
function M.create_l1_config(taxonomy)
  local confFileName = vim.fn['linny#l1_config_filepath'](taxonomy)

  local fileLines = {
    "---",
    "title: " .. util.string_capitalize(taxonomy),
    "infotext: About " .. taxonomy,
    "views:",
    "  type:",
    "    group_by: type",
  }

  if vim.fn.writefile(fileLines, confFileName) ~= 0 then
    vim.api.nvim_echo({{"write error", "ErrorMsg"}}, true, {})
  else
    open_config_in_split(confFileName)
  end
end

return M
