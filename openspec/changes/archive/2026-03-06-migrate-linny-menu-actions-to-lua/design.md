## Context

The linny.vim menu system migration continues. Completed migrations:
- `linny_menu_state.vim` → `lua/linny/menu/state.lua`
- `linny_menu_util.vim` → `lua/linny/menu/util.lua`
- `linny_menu_items.vim` → `lua/linny/menu/items.lua`
- `linny_menu_views.vim` → `lua/linny/menu/views.lua`
- `linny_menu_widgets.vim` → `lua/linny/menu/widgets.lua`

The actions module (`autoload/linny_menu_actions.vim`, 216 lines) handles:
1. Dropdown popup creation and callbacks
2. Action execution (archive, copy, set taxonomy, etc.)
3. Job execution for external commands (fred CLI)

## Goals / Non-Goals

**Goals:**
- Migrate action execution logic to Lua
- Migrate job_start helper to Lua
- Maintain exact behavioral parity
- Keep popup callbacks in VimScript (required by Vim's popup API)

**Non-Goals:**
- Full migration (popup callbacks must stay in VimScript)
- Changing action behavior or adding features

## Decisions

### Decision 1: Partial migration - callbacks stay in VimScript

Vim's `popup_create` requires a VimScript function name string for callbacks. These functions must remain in VimScript:
- `dropdown_item_callback`
- `dropdown_taxo_item_callback`
- `dropdown_remove_taxo_item_callback`
- `dropdown_term_item_callback`
- `dropdown_item` (creates popups)

### Decision 2: Migrate exec_content_menu to Lua

The `exec_content_menu` function contains pure action dispatch logic that can be fully migrated. It handles:
- Archive actions
- Copy operations
- Taxonomy set/remove
- Open docdir

### Decision 3: Migrate job_start helper to Lua

The cross-platform job helper can move to Lua:
```lua
function M.job_start(command)
  if vim.fn.has('nvim') == 1 then
    vim.fn.jobstart(command)
  else
    vim.fn.job_start(command)
  end
end
```

### Decision 4: Keep tab-local state access pattern

Actions rely heavily on `t:linny_menu_*` variables. Lua will access these via `vim.t.*`.

## Risks / Trade-offs

**Risk: Popup callback interop**
- VimScript callbacks call Lua for action execution
- Mitigation: Simple luaeval() delegation, well-tested pattern

**Trade-off: Split module**
- Some logic in Lua, callbacks in VimScript
- Acceptable: Same pattern as views module; cleaner than keeping everything in VimScript
