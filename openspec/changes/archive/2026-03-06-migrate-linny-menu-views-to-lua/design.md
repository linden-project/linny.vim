## Context

The linny.vim plugin is migrating from VimScript to Lua. Three modules have been converted: `linny_menu_state.vim`, `linny_menu_util.vim`, and `linny_menu_items.vim`. The `linny_menu_views.vim` module already heavily uses the Lua state module via `luaeval()`, making migration straightforward.

Key challenge: The dropdown callback functions (`dropdown_l1_callback`, `dropdown_l2_callback`) are passed as string references to `linny_menu_popup#create()`. These must remain as VimScript functions since they're called by Vim's popup system.

## Goals / Non-Goals

**Goals:**
- Convert pure logic functions to Lua: `get_list`, `get_views`, `get_active`, `current_props`, `new_active`
- Convert cycling functions to Lua: `cycle_l1`, `cycle_l2`
- Convert render function to Lua where possible
- Add comprehensive unit tests

**Non-Goals:**
- Converting dropdown callback functions (must remain VimScript for popup compatibility)
- Converting dropdown display functions (depend on `linny_menu_popup#create`)
- Converting the render function fully (calls VimScript widget functions)
- Refactoring the view data structure

## Decisions

### 1. Module Location: `lua/linny/menu/views.lua`

Following the established pattern of `lua/linny/menu/{state,util,items}.lua`.

### 2. Partial Migration Strategy

Due to Vim popup callback constraints, we'll migrate in two phases:
- **Phase 1 (this change)**: Migrate pure logic functions that don't depend on popup callbacks
- **Future**: Once popup system is converted to Lua, migrate remaining functions

Functions to migrate now:
- `get_list(config)` - pure logic
- `get_views(config)` - pure logic
- `get_active(state)` - pure logic
- `current_props(active_view, views_list, views)` - pure logic
- `new_active(state, views, direction, active_view)` - pure logic
- `cycle_l1(direction)` - orchestration (calls state module)
- `cycle_l2(direction)` - orchestration (calls state module)

Functions to keep in VimScript (for now):
- `render(view_name)` - calls VimScript widget functions
- `dropdown_l1()` / `dropdown_l2()` - creates popups with VimScript callbacks
- `dropdown_l1_callback()` / `dropdown_l2_callback()` - Vim popup callbacks

### 3. VimScript Functions Call Lua

The cycling functions will be Lua, but VimScript callers can invoke them:
```vim
call luaeval("require('linny.menu.views').cycle_l1(_A)", a:direction)
```

### 4. Accessing Tab Variables

Use `vim.t.linny_menu_taxonomy` and `vim.t.linny_menu_term` directly in Lua.

### 5. Calling VimScript Functions from Lua

Use `vim.fn[]` for config lookups:
```lua
local config = vim.fn['linny#tax_config'](taxonomy)
```

## Risks / Trade-offs

**Risk**: Partial migration leaves some functions in VimScript
→ Acceptable: Popup callbacks require VimScript; full migration can happen when popup module is converted

**Risk**: Mixed Lua/VimScript in views module adds complexity
→ Mitigation: Clear documentation of which functions are in which language

**Trade-off**: Dropdown functions remain in VimScript
→ Acceptable: These are tightly coupled to Vim's popup system
