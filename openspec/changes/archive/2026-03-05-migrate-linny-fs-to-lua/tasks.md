## 1. Create Lua FS Module

- [x] 1.1 Create `lua/linny/fs.lua` with `dir_create_if_not_exist()` and `os_open_with_filemanager()` functions
- [x] 1.2 Update `lua/linny/init.lua` to export fs submodule

## 2. Add Unit Tests

- [x] 2.1 Create `tests/fs_spec.lua` with test for directory creation
- [x] 2.2 Add test for module requireable and has expected functions
- [x] 2.3 Add test for fs accessible from main module

## 3. Update Callers

- [x] 3.1 Update `autoload/linny_menu.vim` lines 1768-1769, 1938-1939: replace `linny_fs#` calls with `luaeval()`
- [x] 3.2 Update `autoload/linny_wikitags.vim` lines 5, 17: replace `linny_fs#` calls with `luaeval()`

## 4. Cleanup and Verification

- [x] 4.1 Delete `autoload/linny_fs.vim`
- [x] 4.2 Run all tests: `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`
