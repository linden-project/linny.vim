## Context

The linny.vim plugin is migrating menu functionality from VimScript to Lua. Already migrated: `state`, `util`, `items`, `views`, `widgets`, `actions`, `documents`, `window`. The `linny_menu_render.vim` file contains rendering logic with 7 functions (403 lines).

Current file structure:
- `autoload/linny_menu_render.vim` (403 lines) - menu rendering
- `lua/linny/menu/` - existing Lua modules

## Goals / Non-Goals

**Goals:**
- Migrate all rendering functions to `lua/linny/menu/render.lua`
- Maintain exact behavior parity with VimScript implementation
- Follow established module patterns from prior migrations

**Non-Goals:**
- Refactoring rendering logic
- Adding new rendering features
- Migrating other files in this change

## Decisions

### 1. Full migration approach
Migrate all functions to Lua. The render module has no popup callbacks.

### 2. Function mapping
| VimScript | Lua |
|-----------|-----|
| `linny_menu_render#level0(view_name)` | `M.level0(view_name)` |
| `linny_menu_render#level1(tax)` | `M.level1(tax)` |
| `linny_menu_render#level2(tax, term)` | `M.level2(tax, term)` |
| `linny_menu_render#partial_debug_info()` | `M.partial_debug_info()` |
| `linny_menu_render#partial_footer_items()` | `M.partial_footer_items()` |
| `linny_menu_render#display_file_ask_view_props(view_props, file_dict)` | `M.display_file_ask_view_props(view_props, file_dict)` |
| `linny_menu_render#test_file_with_display_expression(file_dict, expr)` | `M.test_file_with_display_expression(file_dict, expr)` |

### 3. VimScript function calls
Functions calling VimScript helpers (`linny#tax_config`, `linny#term_config`, `linny#parse_json_file`, etc.) will use `vim.fn[]` calls.

### 4. Lua module dependencies
The render module calls many existing Lua modules:
- `linny.menu.state` - reset(), term_leaf_state(), term_value_leaf_state()
- `linny.menu.items` - add_* functions
- `linny.menu.views` - get_list(), get_views(), get_active(), current_props()
- `linny.menu.util` - calc_active_view_arrow(), string_capitalize()
- `linny.menu.widgets` - partial_files_listing()

## Risks / Trade-offs

**Risk:** Complex nested loops and conditionals may behave differently
→ Mitigation: Careful translation, thorough testing

**Risk:** VimScript dictionary vs Lua table differences
→ Mitigation: Use `vim.fn.has_key()` or Lua's direct indexing with nil checks
