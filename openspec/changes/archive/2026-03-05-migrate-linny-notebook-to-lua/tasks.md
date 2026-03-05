## Tasks

### 1. Create lua/linny/notebook.lua module
Create the notebook Lua module with init and open functions.

**Files:** `lua/linny/notebook.lua`

**Acceptance:**
- [x] Module returns table with functions: init, open
- [x] init() sets g:linny_path_wiki_content from g:linny_open_notebook_path
- [x] init() sets g:linny_path_wiki_config from g:linny_open_notebook_path
- [x] init() sets g:linny_index_path from g:linny_open_notebook_path
- [x] open(path) expands and validates the path
- [x] open(path) sets g:linny_open_notebook_path on valid directory
- [x] open(path) calls linny#Init() and linny_menu#start() on success
- [x] open(path) returns false and shows error on invalid path
- [x] open("") prompts user for path via vim.fn.input()

### 2. Update lua/linny/init.lua to export notebook
Add notebook submodule to main linny module exports.

**Files:** `lua/linny/init.lua`

**Acceptance:**
- [x] require('linny').notebook returns the notebook module
- [x] Existing exports (version, util, fs, wikitags) still work

### 3. Update autoload/linny.vim to use Lua
Change call to linny_notebook#init() to use Lua.

**Files:** `autoload/linny.vim`

**Acceptance:**
- [x] linny_notebook#init() call replaced with luaeval("require('linny.notebook').init()")

### 4. Update plugin/linny.vim command to use Lua
Change LinnyOpenNotebook command to use Lua.

**Files:** `plugin/linny.vim`

**Acceptance:**
- [x] LinnyOpenNotebook command uses luaeval to call require('linny.notebook').open()

### 5. Create tests/notebook_spec.lua
Add unit tests for the notebook module.

**Files:** `tests/notebook_spec.lua`

**Acceptance:**
- [x] Test init() sets global path variables correctly
- [x] Test open() returns false for non-existent path
- [x] Test open() sets g:linny_open_notebook_path for valid path
- [x] Test module is requireable
- [x] All tests pass with `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`

### 6. Delete autoload/linny_notebook.vim
Remove the old Vimscript implementation.

**Files:** `autoload/linny_notebook.vim`

**Acceptance:**
- [x] File is deleted
- [x] All tests still pass
