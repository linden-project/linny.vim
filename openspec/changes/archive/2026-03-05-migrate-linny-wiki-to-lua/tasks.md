## Tasks

### 1. Create lua/linny/wiki.lua module
Create the wiki Lua module with all wiki functions.

**Files:** `lua/linny/wiki.lua`

**Acceptance:**
- [x] Module returns table with all functions
- [x] Module-local state for last_pos_line and last_pos_col
- [x] wikitag_has_tag(word) detects wikitags from g:linny_wikitags_register
- [x] execute_wikitag_action(word, tag_key) executes registered wikitag action
- [x] file_exists(path) checks if file is readable
- [x] word_to_filename(word) converts wiki word to filename (lowercase, replace spaces/special chars)
- [x] file_path(filename) returns path relative to current buffer directory
- [x] str_between(start_str, end_str) extracts string between delimiters on current line
- [x] yaml_key_under_cursor() returns YAML key on current line
- [x] yaml_val_under_cursor() returns YAML value on current line
- [x] cursor_in_frontmatter() checks if cursor is in YAML frontmatter
- [x] find_word_pos() finds wiki word position on current line
- [x] get_word() returns wiki word under cursor
- [x] find_link_pos() finds wiki link position on current line
- [x] get_link() returns wiki link under cursor
- [x] goto_link() navigates to wiki link or creates new file
- [x] return_to_last() returns to previous buffer position
- [x] find_non_existing_links() highlights non-existing wiki links

### 2. Update lua/linny/init.lua to export wiki
Add wiki submodule to main linny module exports.

**Files:** `lua/linny/init.lua`

**Acceptance:**
- [x] require('linny').wiki returns the wiki module
- [x] Existing exports (version, util, fs, wikitags, notebook) still work

### 3. Update plugin/linny.vim autocommands to use Lua
Change autocommands to call Lua functions.

**Files:** `plugin/linny.vim`

**Acceptance:**
- [x] BufEnter/WinEnter/BufWinEnter *.md calls lua require('linny.wiki').find_non_existing_links()
- [x] FileType markdown mapping calls lua require('linny.wiki').goto_link()

### 4. Update autoload/linny.vim to use Lua
Change call to linny_wiki#YamlKeyUnderCursor() to use Lua.

**Files:** `autoload/linny.vim`

**Acceptance:**
- [x] linny_wiki#YamlKeyUnderCursor() call replaced with luaeval

### 5. Update autoload/linny_menu.vim to use Lua
Change calls to linny_wiki#WordFilename() to use Lua.

**Files:** `autoload/linny_menu.vim`

**Acceptance:**
- [x] All linny_wiki#WordFilename() calls replaced with luaeval

### 6. Update after/ftplugin/markdown.vim to use Lua
Change MdwiReturn command to use Lua.

**Files:** `after/ftplugin/markdown.vim`

**Acceptance:**
- [x] MdwiReturn command calls lua require('linny.wiki').return_to_last()

### 7. Create tests/wiki_spec.lua
Add unit tests for the wiki module.

**Files:** `tests/wiki_spec.lua`

**Acceptance:**
- [x] Test word_to_filename converts words correctly
- [x] Test word_to_filename handles special characters
- [x] Test file_exists returns true for existing paths
- [x] Test file_exists returns false for non-existing paths
- [x] Test wikitag_has_tag detects registered tags
- [x] Test wikitag_has_tag returns empty for non-tags
- [x] Test module is requireable with all functions
- [x] All tests pass

### 8. Delete autoload/linny_wiki.vim
Remove the old Vimscript implementation.

**Files:** `autoload/linny_wiki.vim`

**Acceptance:**
- [x] File is deleted
- [x] All tests still pass
