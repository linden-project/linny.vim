## Why

Continue the systematic migration of linny.vim from VimScript to Lua. The `linny_menu_views.vim` module (197 lines) manages view cycling, dropdown selection, and view configuration extraction. It already uses the Lua state module extensively, making it a natural next candidate for conversion.

## What Changes

- Create new `lua/linny/menu/views.lua` module with all view management functions
- Migrate 11 functions: `render`, `cycle_l1`, `cycle_l2`, `dropdown_l1_callback`, `dropdown_l1`, `dropdown_l2_callback`, `dropdown_l2`, `new_active`, `get_list`, `get_views`, `get_active`, `current_props`
- Update all callers in VimScript files to use `luaeval()` with the new Lua module
- Delete the original `autoload/linny_menu_views.vim` after migration
- Add unit tests for the new Lua module

## Capabilities

### New Capabilities
- `menu-views-lua`: Lua implementation of view management functions, accessible as `require('linny.menu.views')`

### Modified Capabilities
<!-- No spec-level behavior changes - this is a pure implementation migration -->

## Impact

- `autoload/linny_menu_views.vim` - will be deleted
- `autoload/linny_menu_render.vim` - update calls to use luaeval
- `autoload/linny_menu.vim` - update calls to use luaeval
- `autoload/linny_menu_actions.vim` - update calls to use luaeval (if any)
- `lua/linny/menu/init.lua` - export views submodule
- `tests/menu_views_spec.lua` - new test file
