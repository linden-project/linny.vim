## Why

Continue the VimScript-to-Lua migration for linny.vim. The `linny_menu_views.vim` file contains the `render()` function and dropdown functions that can be migrated to Lua, reducing VimScript code and improving maintainability. The popup callbacks must remain in VimScript due to Vim popup API requirements.

## What Changes

- Migrate `render(view_name)` function to `lua/linny/menu/views.lua`
- Migrate `dropdown_l1()` and `dropdown_l2()` popup creation to Lua
- Keep `dropdown_l1_callback` and `dropdown_l2_callback` in VimScript (Vim popup API requirement)
- Keep `cycle_l1` and `cycle_l2` as thin VimScript wrappers (already delegate to Lua)
- Reduce `linny_menu_views.vim` to only callback functions

## Capabilities

### New Capabilities
- `views-render-lua`: Lua implementation of view rendering including widget iteration and configuration link generation

### Modified Capabilities

## Impact

- `autoload/linny_menu_views.vim` - reduce to callbacks only
- `lua/linny/menu/views.lua` - add render function and dropdown functions
- `autoload/linny_menu.vim` - update to call Lua render function
