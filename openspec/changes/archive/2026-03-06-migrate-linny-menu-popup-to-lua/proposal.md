## Why

Continue the VimScript-to-Lua migration for linny.vim. The `linny_menu_popup.vim` file contains cross-platform popup/floating window abstractions that can be migrated to Lua, improving maintainability and enabling other Lua modules to call popup functions directly without `luaeval()` overhead.

## What Changes

- Create `lua/linny/menu/popup.lua` module with cross-platform popup abstraction
- Migrate functions: `create`, `close`, `getoptions`, `setoptions`
- Migrate Neovim floating window helpers (options conversion, box drawing, buffer management)
- Update callers in VimScript files to use `luaeval()` for Lua functions
- Delete `autoload/linny_menu_popup.vim` after migration

## Capabilities

### New Capabilities
- `menu-popup-lua`: Lua module for cross-platform popup/floating window management including popup creation, closing, option get/set, and Neovim-specific floating window rendering with box drawing and keymap management

### Modified Capabilities

## Impact

- `autoload/linny_menu_popup.vim` - will be deleted
- `lua/linny/menu/popup.lua` - new file
- `lua/linny/menu/init.lua` - add popup export
- `autoload/linny_menu_views.vim` - update calls to use Lua
- `autoload/linny_menu_actions.vim` - update calls to use Lua
