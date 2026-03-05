## Why

Continuing the Vimscript-to-Lua migration with the next simplest module. `linny_fs.vim` contains file system utilities for directory creation and opening paths with the OS file manager. It's self-contained with no dependencies on other linny modules.

## What Changes

- Create `lua/linny/fs.lua` module with `dir_create_if_not_exist()` and `os_open_with_filemanager()` functions
- Add unit tests for the fs module in `tests/fs_spec.lua`
- Update 6 callers across `linny_menu.vim` and `linny_wikitags.vim` to use Lua via `luaeval()`
- **BREAKING**: Delete `autoload/linny_fs.vim`

## Capabilities

### New Capabilities
- `lua-fs-module`: Lua file system utilities for directory creation and OS file manager integration

### Modified Capabilities
- `lua-module-structure`: Add fs submodule export to linny module

## Impact

- `lua/linny/fs.lua`: New file
- `lua/linny/init.lua`: Add fs export
- `autoload/linny_menu.vim`: Update 4 calls (lines 1768, 1769, 1938, 1939)
- `autoload/linny_wikitags.vim`: Update 2 calls (lines 5, 17)
- `autoload/linny_fs.vim`: Deleted
- `tests/fs_spec.lua`: New unit tests
