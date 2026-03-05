## Tasks

### 1. Create lua/linny/wikitags.lua module
Create the wikitags Lua module with all 6 functions.

**Files:** `lua/linny/wikitags.lua`

**Acceptance:**
- [x] Module returns table with functions: file, mkdir_if_not_exist, dir1st, dir2nd, shell, linny, vim_cmd
- [x] file() expands path and calls fs.os_open_with_filemanager()
- [x] mkdir_if_not_exist() creates directory if it doesn't exist
- [x] dir1st() creates directory and opens with file manager
- [x] dir2nd() creates directory and opens in NERDTree if available
- [x] shell() executes shell command via vim.cmd('!')
- [x] linny() parses taxonomy:term and calls linny_menu#openterm()
- [x] vim_cmd() executes vim command

### 2. Update lua/linny/init.lua to export wikitags
Add wikitags submodule to main linny module exports.

**Files:** `lua/linny/init.lua`

**Acceptance:**
- [x] require('linny').wikitags returns the wikitags module
- [x] Existing exports (version, util, fs) still work

### 3. Add Vimscript wrapper functions to plugin/linny.vim
Create thin wrapper functions that call Lua implementations, placed before registrations.

**Files:** `plugin/linny.vim`

**Acceptance:**
- [x] LinnyWikitag_file(innertag) calls require('linny.wikitags').file()
- [x] LinnyWikitag_dir1st(innertag) calls require('linny.wikitags').dir1st()
- [x] LinnyWikitag_dir2nd(innertag) calls require('linny.wikitags').dir2nd()
- [x] LinnyWikitag_shell(innertag) calls require('linny.wikitags').shell()
- [x] LinnyWikitag_linny(innertag) calls require('linny.wikitags').linny()
- [x] LinnyWikitag_vim(innertag) calls require('linny.wikitags').vim_cmd()

### 4. Update wikitag registrations in plugin/linny.vim
Change RegisterLinnyWikitag calls to use new wrapper function names.

**Files:** `plugin/linny.vim`

**Acceptance:**
- [x] FILE wikitag uses LinnyWikitag_file
- [x] DIR wikitag uses LinnyWikitag_dir1st and LinnyWikitag_dir2nd
- [x] SHELL wikitag uses LinnyWikitag_shell
- [x] LIN wikitag uses LinnyWikitag_linny
- [x] VIM wikitag uses LinnyWikitag_vim

### 5. Create tests/wikitags_spec.lua
Add unit tests for the wikitags module.

**Files:** `tests/wikitags_spec.lua`

**Acceptance:**
- [x] Test mkdir_if_not_exist creates directory
- [x] Test mkdir_if_not_exist skips existing directory
- [x] Test linny() parses "taxonomy:term" correctly
- [x] Test linny() handles "taxonomy" without term
- [x] Test module is requireable
- [x] All tests pass with `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`

### 6. Delete autoload/linny_wikitags.vim
Remove the old Vimscript implementation.

**Files:** `autoload/linny_wikitags.vim`

**Acceptance:**
- [x] File is deleted
- [x] All tests still pass
