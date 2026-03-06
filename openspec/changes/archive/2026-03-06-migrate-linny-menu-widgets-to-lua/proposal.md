## Why

Continue the VimScript to Lua migration for linny.vim menu system. The widgets module contains dashboard widget rendering functions that are currently in VimScript but use the already-migrated Lua `items` module. Migrating to Lua improves maintainability and consistency with other migrated modules (state, util, items, views).

## What Changes

- Create `lua/linny/menu/widgets.lua` module with all widget functions
- Migrate data retrieval functions: `recent_files`, `starred_terms_list`, `starred_docs_list`
- Migrate widget rendering functions: `starred_documents`, `starred_terms`, `starred_taxonomies`, `all_taxonomies`, `recently_modified_documents`, `all_level0_views`, `menu`
- Migrate `partial_files_listing` helper function
- Update callers in `autoload/linny_menu_views.vim` to use luaeval() for widget functions
- Remove migrated functions from `autoload/linny_menu_widgets.vim`

## Capabilities

### New Capabilities

- `menu-widgets-lua`: Lua module providing dashboard widget rendering functions for the linny menu system

### Modified Capabilities

(none - implementation change only, no behavioral changes)

## Impact

- New file: `lua/linny/menu/widgets.lua`
- Updated: `lua/linny/menu/init.lua` (export widgets submodule)
- Updated: `autoload/linny_menu_views.vim` (use luaeval for widget calls)
- Removed functions from: `autoload/linny_menu_widgets.vim`
- New test file: `tests/menu_widgets_spec.lua`
