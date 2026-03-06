## Why

Continue the VimScript-to-Lua migration for linny.vim. The `linny_menu_actions.vim` file has popup creation functions that can be migrated to Lua, while popup callbacks must remain in VimScript due to Vim popup API requirements.

## What Changes

- Migrate `dropdown_item()` popup creation to Lua
- Migrate `exec_content_menu()` popup creation for "set taxonomy" and "remove taxonomy" to Lua
- Keep all `*_callback` functions in VimScript (Vim popup API requirement)
- Reduce VimScript file to thin wrappers and callbacks only

## Capabilities

### New Capabilities
- `actions-dropdown-lua`: Lua functions for creating action dropdowns including item dropdown, taxonomy selection, and term selection popups

### Modified Capabilities

## Impact

- `autoload/linny_menu_actions.vim` - reduce to callbacks and thin wrappers
- `lua/linny/menu/actions.lua` - add dropdown_item, show_set_taxonomy, show_remove_taxonomy functions
