## Why

Continue the VimScript to Lua migration for linny.vim menu system. The documents module handles document operations like copy, archive, create new documents, and config file management. These are mostly pure logic functions that can be fully migrated to Lua.

## What Changes

- Create `lua/linny/menu/documents.lua` module with document operation functions
- Migrate `replace_frontmatter_key` for editing document frontmatter
- Migrate `copy` for duplicating documents with new titles
- Migrate `new_in_leaf` for creating documents in current taxonomy/term
- Migrate `archive_l2_config` for archiving term configurations
- Migrate `create_l2_config` and `create_l1_config` for config file creation
- Migrate `open_in_right_pane` for window layout management
- Update callers to use luaeval() for document functions
- Remove migrated functions from VimScript

## Capabilities

### New Capabilities

- `menu-documents-lua`: Lua module providing document and config file operations for the linny menu system

### Modified Capabilities

(none - implementation change only, no behavioral changes)

## Impact

- New file: `lua/linny/menu/documents.lua`
- Updated: `lua/linny/menu/init.lua` (export documents submodule)
- Updated: `autoload/linny_menu_actions.vim` (use luaeval for document operations)
- Updated: `autoload/linny_menu.vim` (use luaeval for document operations)
- Removed: `autoload/linny_menu_documents.vim`
- New test file: `tests/menu_documents_spec.lua`
