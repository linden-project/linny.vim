## Why

Continue the VimScript-to-Lua migration for linny.vim. The `linny_menu_render.vim` file contains menu rendering logic for different levels (root, taxonomy, term) that can be migrated to Lua, improving maintainability and consistency with the existing Lua module structure.

## What Changes

- Create `lua/linny/menu/render.lua` module with rendering functions
- Migrate functions: `level0`, `level1`, `level2`, `partial_debug_info`, `partial_footer_items`, `display_file_ask_view_props`, `test_file_with_display_expression`
- Update callers in VimScript files to use `luaeval()` for Lua functions
- Delete `autoload/linny_menu_render.vim` after migration

## Capabilities

### New Capabilities
- `menu-render-lua`: Lua module for menu rendering including level-based rendering (root, taxonomy, term), footer/debug partials, and view property filtering

### Modified Capabilities

## Impact

- `autoload/linny_menu_render.vim` - will be deleted
- `lua/linny/menu/render.lua` - new file
- `lua/linny/menu/init.lua` - add render export
- `autoload/linny_menu.vim` - update calls to use Lua
- `autoload/linny_menu_views.vim` - update calls if any
