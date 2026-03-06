## Context

The linny.vim menu system has been progressively migrated from VimScript to Lua. Completed migrations include:
- `linny_menu_state.vim` → `lua/linny/menu/state.lua`
- `linny_menu_util.vim` → `lua/linny/menu/util.lua`
- `linny_menu_items.vim` → `lua/linny/menu/items.lua`
- `linny_menu_views.vim` → `lua/linny/menu/views.lua`

The widgets module (`autoload/linny_menu_widgets.vim`, 202 lines) contains dashboard widget rendering functions. These functions already call the migrated `items` module via luaeval(), making them good candidates for full Lua migration.

## Goals / Non-Goals

**Goals:**
- Migrate all widget functions to Lua
- Maintain exact behavioral parity with VimScript implementation
- Follow established patterns from previous migrations
- Create unit tests for pure Lua functions

**Non-Goals:**
- Changing widget behavior or adding features
- Migrating functions that depend heavily on VimScript-specific patterns
- Breaking compatibility with existing view configurations

## Decisions

### Decision 1: Full migration (no VimScript wrapper)

Unlike `views.lua` which kept popup callbacks in VimScript, widgets can be fully migrated because:
- No popup callbacks requiring VimScript function references
- All widget functions are called from `linny_menu_views#render()` which can use luaeval()
- The functions are pure rendering logic using already-migrated modules

### Decision 2: Handle shell commands via vim.fn.systemlist

The `recent_files()` function uses shell commands (`ls -1t | grep | head`). This will be handled via:
- `vim.fn.systemlist()` for shell command execution
- Same command structure to maintain compatibility

Alternative considered: Pure Lua file listing with `vim.fn.glob()` and `vim.fn.getftime()` - rejected to minimize behavioral changes.

### Decision 3: Access global variables via vim.g

Functions access `g:linny_path_wiki_content`, `g:linny_index_path`, etc. These will use:
- `vim.g.linny_path_wiki_content`
- `vim.g.linny_index_path`

### Decision 4: Call existing VimScript functions via vim.fn

Functions like `linny#parse_json_file()`, `linny#titlesForDocs()`, `linny#doc_title_from_index()` will be called via:
- `vim.fn['linny#parse_json_file'](path, default)`

This maintains interop until those functions are migrated.

## Risks / Trade-offs

**Risk: Shell command compatibility**
- `recent_files()` uses Unix shell commands
- Mitigation: Same commands work via vim.fn.systemlist(); Windows users already have this limitation

**Risk: Tab-local variable access**
- `partial_files_listing` accesses `t:linny_tasks_count`
- Mitigation: Use `vim.t.linny_tasks_count` which works identically

**Trade-off: VimScript function dependencies**
- Widget functions call `linny#*` functions that remain in VimScript
- Acceptable: Interop via vim.fn works well; those functions can be migrated later
