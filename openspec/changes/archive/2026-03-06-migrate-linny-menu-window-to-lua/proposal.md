## Why

Continue the VimScript-to-Lua migration for linny.vim. The `linny_menu_window.vim` file contains window/buffer management functions that can be cleanly migrated to Lua, improving maintainability and consistency with the existing Lua module structure.

## What Changes

- Create `lua/linny/menu/window.lua` module with window management functions
- Migrate functions: `exist`, `close_window`, `open_window`, `render`, `start`, `open`, `close`, `toggle`, `refresh`, `open_home`, `open_file`
- Update callers in VimScript files to use `luaeval()` for Lua functions
- Delete `autoload/linny_menu_window.vim` after migration

## Capabilities

### New Capabilities
- `menu-window-lua`: Lua module for menu window/buffer management including window existence checks, opening/closing, rendering items, and file navigation

### Modified Capabilities

## Impact

- `autoload/linny_menu_window.vim` - will be deleted
- `lua/linny/menu/window.lua` - new file
- `lua/linny/menu/init.lua` - add window export
- `autoload/linny_menu.vim` - update calls to use Lua
- `plugin/linny.vim` - update any direct calls
