## Why

Continuing the Vimscript-to-Lua migration. `linny_menu_util.vim` (147 lines) contains pure utility functions used across the menu system for string manipulation, text formatting, and display helpers. These have no external dependencies and are foundational for other menu modules.

## What Changes

- Create `lua/linny/menu/util.lua` module with all utility functions
- Add unit tests for the util module in `tests/menu_util_spec.lua`
- Update callers in `autoload/linny_menu.vim`, `autoload/linny_menu_render.vim`, `autoload/linny_menu_items.vim`, `autoload/linny_menu_documents.vim`
- **BREAKING**: Delete `autoload/linny_menu_util.vim`

## Capabilities

### New Capabilities
- `lua-menu-util-module`: Lua implementations of menu utility functions (string padding, text expansion, truncation, capitalization, display helpers)

### Modified Capabilities
- `lua-module-structure`: Add menu.util submodule export to linny.menu module

## Impact

- `lua/linny/menu/util.lua`: New file with 9 functions
- `lua/linny/menu/init.lua`: Add util export
- `autoload/linny_menu.vim`: Update 4 calls to use Lua via luaeval
- `autoload/linny_menu_render.vim`: Update 5 calls to use Lua via luaeval
- `autoload/linny_menu_items.vim`: Update 2 calls to use Lua via luaeval
- `autoload/linny_menu_documents.vim`: Update 3 calls to use Lua via luaeval
- `autoload/linny_menu_util.vim`: Deleted
- `tests/menu_util_spec.lua`: New unit tests
