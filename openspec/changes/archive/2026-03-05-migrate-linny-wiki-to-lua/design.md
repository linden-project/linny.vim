## Context

Current state:
- `autoload/linny_wiki.vim` contains ~20 functions for wiki link handling
- Script-local variables `s:lastPosLine` and `s:lastPosCol` track cursor position for Return()
- Functions are called from plugin/linny.vim autocommands, linny_menu.vim, linny.vim, and after/ftplugin/markdown.vim
- Some functions depend on global variables: `g:linny_wikitags_register`, `g:startWord`, `g:endWord`, `g:startLink`, `g:endLink`, `g:spaceReplaceChar`

## Goals / Non-Goals

**Goals:**
- Migrate all wiki functions to Lua
- Maintain script-local state as module-local state
- Keep all callers working
- Add unit tests for pure/testable functions

**Non-Goals:**
- Migrating `linny#generate_first_content()`, `linny#l2_index_filepath()`, or `linny_menu#openterm()` (separate changes)
- Changing the wiki link API

## Decisions

### 1. Module-local state for cursor position

```lua
local M = {}
local last_pos_line = 0
local last_pos_col = 0
```

**Rationale**: Direct translation of script-local variables.

### 2. Function organization

Group functions by category:
- **Wikitag functions**: `wikitag_has_tag()`, `execute_wikitag_action()`
- **Utility functions**: `file_exists()`, `word_to_filename()`, `file_path()`, `str_between()`
- **YAML functions**: `yaml_key_under_cursor()`, `yaml_val_under_cursor()`, `cursor_in_frontmatter()`
- **Word/Link functions**: `find_word_pos()`, `get_word()`, `find_link_pos()`, `get_link()`
- **Navigation**: `goto_link()`, `return_to_last()`
- **Highlighting**: `find_non_existing_links()`

### 3. Access global variables via vim.g

```lua
local wikitags_register = vim.g.linny_wikitags_register
local start_word = vim.g.startWord
```

**Rationale**: Standard Neovim way to access Vimscript globals.

### 4. Update callers directly

Since callers can be updated directly, no wrapper functions needed:

**plugin/linny.vim autocommands:**
```vim
autocmd BufEnter,WinEnter,BufWinEnter *.md lua require('linny.wiki').find_non_existing_links()
autocmd FileType markdown nnoremap <buffer> <CR> :lua require('linny.wiki').goto_link()<CR>
```

**autoload/linny_menu.vim:**
```vim
let fileName = luaeval("require('linny.wiki').word_to_filename(_A)", a:new_title)
```

### 5. Use vim.fn[] for Vimscript callbacks

For calling `linny#generate_first_content()`, `linny#l2_index_filepath()`, `linny_menu#openterm()`:
```lua
vim.fn['linny#generate_first_content'](word, {})
vim.fn['linny_menu#openterm'](yaml_key, yaml_val)
```

### 6. Use Neovim API for cursor/search operations

```lua
-- Instead of getpos('.'), use:
local pos = vim.api.nvim_win_get_cursor(0)

-- Instead of searchpos(), use:
vim.fn.searchpos(pattern, flags, stopline)

-- Instead of cursor(), use:
vim.api.nvim_win_set_cursor(0, {line, col})
```

**Rationale**: Mix of vim.fn for search functions (which work well) and nvim_api for cursor operations.

## Risks / Trade-offs

**[Cursor position handling]** → Lua uses 0-indexed columns vs Vim's 1-indexed. Need careful translation.

**[matchadd for highlighting]** → `vim.fn.matchadd()` works the same from Lua.

**[Vimscript dependencies]** → Several functions still depend on Vimscript modules. This will be resolved when those are migrated.

**[Global variable access]** → Functions depend on globals being set. Same behavior as current Vimscript.
