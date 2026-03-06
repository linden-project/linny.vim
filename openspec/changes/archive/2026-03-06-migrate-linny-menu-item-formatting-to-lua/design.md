## Context

The `autoload/linny_menu.vim` file contains `Select_items()` and `Menu_expand()` functions used to format menu items for display. These are pure data transformation functions called by `openandshow()` and `toggle()`. The file also has a duplicate `s:job_start()` helper that already exists in `lua/linny/menu/actions.lua`.

## Goals / Non-Goals

**Goals:**
- Move `Select_items()` logic to Lua
- Move `Menu_expand()` logic to Lua
- Remove duplicate `s:job_start()` VimScript function
- Reduce VimScript in linny_menu.vim by ~80 lines

**Non-Goals:**
- Migrating keymapping setup (still needs VimScript buffer-local mappings)
- Migrating cursor handling functions
- Changing item formatting behavior

## Decisions

### 1. Add functions to existing items.lua module
Add `select_items()` and `expand_item()` to `lua/linny/menu/items.lua` since they operate on menu items.

Rationale: Items module already handles item storage and retrieval. Formatting belongs with items.

### 2. Keep function behavior identical
Translate VimScript logic directly without optimization or behavior changes.

Rationale: Reduces risk of regressions. Can optimize later if needed.

### 3. Return expanded content list from Lua
VimScript callers will receive the fully formatted content list from Lua, reducing back-and-forth calls.

Rationale: Cleaner integration, single luaeval call per render.

## Risks / Trade-offs

**[Risk] String width calculation differences** → Use `vim.fn.strdisplaywidth()` which wraps the same VimScript function.

**[Risk] Tab variable access from Lua** → Use `vim.t` which is well-established pattern in this codebase.
