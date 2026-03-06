## Why

The `Select_items()` and `Menu_expand()` functions in `autoload/linny_menu.vim` are pure data transformation functions that can be migrated to Lua. This continues the VimScript-to-Lua migration effort, reducing VimScript code and consolidating menu item formatting logic in Lua.

## What Changes

- Add `select_items()` function to Lua menu module - assigns keys to menu items
- Add `menu_expand()` function to Lua menu module - formats item text with padding and key display
- Update VimScript callers (`openandshow`, `toggle`) to use Lua functions
- Remove duplicate `job_start()` helper (already exists in `actions.lua`)
- Remove migrated VimScript functions

## Capabilities

### New Capabilities
- `menu-item-formatting-lua`: Menu item selection and text expansion functions in Lua

### Modified Capabilities

## Impact

- `autoload/linny_menu.vim`: Remove `Select_items()`, `Menu_expand()`, `s:job_start()` (~80 lines)
- `lua/linny/menu/`: Add new formatting functions to appropriate module
