## Context

The `linny_menu_views.vim` file contains view rendering and dropdown logic. The `render()` function iterates over widgets and calls Lua functions via `luaeval()`. The dropdown functions create popups and have callbacks.

Current state:
- `render()` - 35 lines, can fully migrate to Lua
- `cycle_l1/l2()` - already delegate to Lua (thin wrappers)
- `dropdown_l1/l2()` - popup creation, can migrate to Lua
- `dropdown_l1/l2_callback()` - must stay in VimScript (Vim popup API)

## Goals / Non-Goals

**Goals:**
- Move `render()` logic entirely to Lua
- Move `dropdown_l1/l2()` popup creation to Lua
- Keep VimScript file minimal (callbacks only)
- Maintain existing behavior

**Non-Goals:**
- Changing view rendering behavior
- Migrating popup callbacks (not possible due to Vim API)
- Removing the VimScript file entirely

## Decisions

### 1. Add render() to existing views.lua
The `lua/linny/menu/views.lua` module already exists with `cycle_l1`, `cycle_l2`, `get_active`, `get_list`. Add `render()` to this module.

Rationale: Keeps view-related functions together.

### 2. Move dropdown popup creation to Lua
Create `dropdown_l1()` and `dropdown_l2()` in Lua that create the popup. The VimScript callbacks will remain and be passed as string callback names.

Rationale: Reduces VimScript while keeping required callbacks.

### 3. Access view config via vim.fn
Use `vim.fn['linny#view_config']()` to get view configuration from VimScript.

Rationale: Reuses existing VimScript config parsing until that's also migrated.

## Risks / Trade-offs

**[Risk] Config access from Lua** → Need to call VimScript functions via `vim.fn`. Mitigation: This is temporary until `linny.vim` is migrated.

**[Risk] Global variable access** → Callbacks need `t:linny_menu_taxonomy` etc. Mitigation: VimScript callbacks remain, so they have direct access.
