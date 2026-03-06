## Why

Continue the VimScript to Lua migration for linny.vim menu system. The actions module handles dropdown menus and content menu execution. It contains popup callback functions which must remain in VimScript (Vim popup callbacks require VimScript function references), but helper logic can be migrated to Lua.

## What Changes

- Create `lua/linny/menu/actions.lua` module with action execution logic
- Migrate `exec_content_menu` action dispatch logic to Lua
- Migrate `job_start` helper to Lua (using vim.fn.jobstart/job_start)
- Keep popup callback functions in VimScript (dropdown_item_callback, dropdown_taxo_item_callback, etc.)
- Update VimScript callbacks to delegate action execution to Lua

## Capabilities

### New Capabilities

- `menu-actions-lua`: Lua module providing action execution and job helpers for linny menu system

### Modified Capabilities

(none - implementation change only, no behavioral changes)

## Impact

- New file: `lua/linny/menu/actions.lua`
- Updated: `lua/linny/menu/init.lua` (export actions submodule)
- Updated: `autoload/linny_menu_actions.vim` (delegate to Lua where possible)
- New test file: `tests/menu_actions_spec.lua`
