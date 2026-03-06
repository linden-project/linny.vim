## Why

Continue the systematic migration of linny.vim from VimScript to Lua. The `linny_menu_items.vim` module (180 lines) contains functions for creating and managing menu item structures. Converting it enables better testability, type safety, and aligns with the established Lua module architecture.

## What Changes

- Create new `lua/linny/menu/items.lua` module with all menu item functions
- Migrate 16 functions: `item_default`, `add_empty_line`, `add_divider`, `add_header`, `add_footer`, `add_section`, `add_text`, `add_document`, `add_document_taxo_key`, `add_document_taxo_key_val`, `add_special_event`, `add_ex_event`, `add_external_location`, `append`, `list`, `get_by_index`
- Update all callers in VimScript files to use `luaeval()` with the new Lua module
- Delete the original `autoload/linny_menu_items.vim` after migration
- Add unit tests for the new Lua module

## Capabilities

### New Capabilities
- `menu-items-lua`: Lua implementation of menu item construction functions, accessible as `require('linny.menu.items')`

### Modified Capabilities
<!-- No spec-level behavior changes - this is a pure implementation migration -->

## Impact

- `autoload/linny_menu_items.vim` - will be deleted
- `autoload/linny_menu_render.vim` - update ~20 calls to use luaeval
- `autoload/linny_menu_views.vim` - update calls to use luaeval
- `autoload/linny_menu_widgets.vim` - update calls to use luaeval
- `lua/linny/menu/init.lua` - export items submodule
- `tests/menu_items_spec.lua` - new test file
