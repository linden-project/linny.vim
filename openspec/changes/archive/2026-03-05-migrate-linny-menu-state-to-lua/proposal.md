## Why

Continuing the Vimscript-to-Lua migration. `linny_menu_state.vim` (52 lines) is the tab state management module for the menu system. It manages per-tab menu state and provides JSON state file I/O for persisting view states. This is a foundational module that other `linny_menu_*.vim` files depend on.

## What Changes

- Create `lua/linny/menu/state.lua` module with all state functions
- Add unit tests for the state module in `tests/menu_state_spec.lua`
- Update callers in `autoload/linny_menu.vim`, `autoload/linny_menu_render.vim`, `autoload/linny_menu_window.vim`, `autoload/linny_menu_views.vim`
- **BREAKING**: Delete `autoload/linny_menu_state.vim`

## Capabilities

### New Capabilities
- `lua-menu-state-module`: Lua implementations of tab state management and state file I/O functions

### Modified Capabilities
- `lua-module-structure`: Add menu.state submodule export to linny module

## Impact

- `lua/linny/menu/state.lua`: New file with 7 functions
- `lua/linny/menu/init.lua`: New file to expose menu submodules
- `lua/linny/init.lua`: Add menu export
- `autoload/linny_menu.vim`: Update calls to use Lua via luaeval
- `autoload/linny_menu_render.vim`: Update calls to use Lua via luaeval
- `autoload/linny_menu_window.vim`: Update calls to use Lua via luaeval
- `autoload/linny_menu_views.vim`: Update calls to use Lua via luaeval
- `autoload/linny_menu_state.vim`: Deleted
- `tests/menu_state_spec.lua`: New unit tests

Note: Functions call back to Vimscript (`linny#l1_state_filepath`, `linny#l2_state_filepath`, `linny#parse_json_file`, `linny#write_json_file`). We'll use `vim.fn[]` for these callbacks.
