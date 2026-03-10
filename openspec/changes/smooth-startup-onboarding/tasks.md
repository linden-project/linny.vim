## 1. Initialization State Tracking

- [x] 1.1 Add `g:linny_initialized` flag initialization (default 0) in autoload/linny.vim
- [x] 1.2 Set `g:linny_initialized = 1` at end of successful `linny#Init()` in autoload/linny.vim
- [x] 1.3 Ensure `g:linny_initialized` stays 0 when `linny#setup_paths()` fails

## 2. Fix Fatal Directory Check

- [x] 2.1 Update `linny#fatal_check_dir()` to return 0 on failure, 1 on success (autoload/linny.vim:102-106)
- [x] 2.2 Fix typo in error message: "FUNCION" → "FUNCTION", "DOES NOT EXISTS" → "does not exist"
- [x] 2.3 Update `linny#setup_paths()` to check return values and halt on failure

## 3. Lua Nil Safety Guards

- [x] 3.1 Add nil check in `paths.l1_index_filepath()` - return nil if `vim.g.linny_index_path` is nil (lua/linny/paths.lua)
- [x] 3.2 Add nil check in `paths.l2_index_filepath()` (lua/linny/paths.lua)
- [x] 3.3 Add nil check in `paths.view_config_filepath()` (lua/linny/paths.lua)
- [x] 3.4 Add nil check in `paths.l1_config_filepath()` (lua/linny/paths.lua)
- [x] 3.5 Add nil check in `paths.l2_config_filepath()` (lua/linny/paths.lua)
- [x] 3.6 Add nil check in `paths.l1_state_filepath()` (lua/linny/paths.lua)

## 4. Notebook Module Validation

- [x] 4.1 Update `notebook.init()` to check if `g:linny_open_notebook_path` is nil/empty before use (lua/linny/notebook.lua)
- [x] 4.2 Update `notebook.init()` to validate notebook directory exists before setting paths
- [x] 4.3 Update `notebook.init()` to return true/false indicating success

## 5. Command Guards

- [x] 5.1 Add `linny#require_init()` helper function in autoload/linny.vim
- [x] 5.2 Add init check to `:LinnyStart` command in plugin/linny.vim
- [x] 5.3 Add init check to `:LinnyMenuToggle` command in plugin/linny.vim
- [x] 5.4 Include template URL in warning message: https://github.com/linden-project/linny-notebook-template

## 6. Health Check Module

- [x] 6.1 Create `lua/linny/health.lua` with `M.validate()` function (core validation logic)
- [x] 6.2 Implement notebook path check in `M.validate()`
- [x] 6.3 Implement subdirectory checks (content, lindenConfig, lindenIndex) in `M.validate()`
- [x] 6.4 Add `M.check()` function for Neovim `:checkhealth` (calls validate() internally)
- [x] 6.5 Implement initialization state check in `M.check()`
- [x] 6.6 Add `linny#health_check()` wrapper in autoload/linny.vim that calls `luaeval("require('linny.health').validate()")`

## 7. Verification

- [x] 7.1 Test startup without notebook configured - verify no Lua crash, helpful message shown
- [x] 7.2 Test `:checkhealth linny` in Neovim - verify output shows correct status
- [x] 7.3 Test normal workflow with valid notebook - verify no regressions
- [x] 7.4 Run existing plenary tests to verify no breaking changes
