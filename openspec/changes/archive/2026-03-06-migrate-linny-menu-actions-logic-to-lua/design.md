## Context

The `linny_menu_actions.vim` file contains popup creation functions and callbacks for action menus. The `lua/linny/menu/actions.lua` module already handles core action logic like `build_dropdown_views`, `get_item_name`, and `exec_content_menu`.

Remaining VimScript functions that create popups can be migrated to Lua. The callbacks must stay in VimScript.

## Goals / Non-Goals

**Goals:**
- Move popup creation for `dropdown_item()` to Lua
- Move popup creation for "set taxonomy" and "remove taxonomy" to Lua
- Move popup creation for term selection (inside taxo callback) to Lua
- Reduce VimScript to callbacks and thin wrappers

**Non-Goals:**
- Migrating popup callbacks (not possible due to Vim API)
- Changing action behavior

## Decisions

### 1. Add dropdown functions to existing actions.lua
Add `dropdown_item()`, `show_set_taxonomy()`, `show_remove_taxonomy()`, `show_term_selection()` to the existing module.

Rationale: Keeps action-related functions together.

### 2. Pass context through tab variables
VimScript callbacks access `t:linny_menu_*` variables. Lua functions will read/write these same variables via `vim.t`.

Rationale: Maintains compatibility with existing callback pattern.

### 3. Callbacks call Lua for nested popups
When `dropdown_taxo_item_callback` needs to show terms, it calls a Lua function to create the popup rather than inline VimScript.

Rationale: Reduces VimScript while keeping required callback in VimScript.

## Risks / Trade-offs

**[Risk] Tab variable coordination** → Both Lua and VimScript access `vim.t` / `t:` variables. Mitigation: Keep variable names consistent.
