## Why

`linny_menu.vim` is 2669 lines with ~90 functions. This is too large to convert to Lua in one change. Splitting it into smaller, logically-grouped modules will:
- Make individual Lua conversions manageable
- Improve code organization and maintainability
- Make the codebase easier to understand
- Enable focused unit testing per module

## What Changes

Split `autoload/linny_menu.vim` into 10 smaller files:

1. **linny_menu_state.vim** - Tab state management (`t:` variables)
2. **linny_menu_window.vim** - Window/buffer management
3. **linny_menu_items.vim** - Menu item construction (`s:add_item_*` → public)
4. **linny_menu_render.vim** - Menu level rendering (`s:menu_level*` → public)
5. **linny_menu_views.vim** - View cycling and management
6. **linny_menu_widgets.vim** - Dashboard widgets
7. **linny_menu_keymaps.vim** - Keyboard handling and mappings
8. **linny_menu_actions.vim** - Content actions and dropdowns
9. **linny_menu_documents.vim** - Document operations
10. **linny_menu_util.vim** - Utilities and helpers

All script-local functions (`s:`) become public autoload functions with appropriate prefixes.

## Capabilities

### Modified Capabilities
- `linny-menu`: Split into modular files while preserving all functionality

## Impact

- `autoload/linny_menu.vim`: Deleted (replaced by 10 smaller files)
- `autoload/linny_menu_state.vim`: New file (~150 lines)
- `autoload/linny_menu_window.vim`: New file (~200 lines)
- `autoload/linny_menu_items.vim`: New file (~400 lines)
- `autoload/linny_menu_render.vim`: New file (~600 lines)
- `autoload/linny_menu_views.vim`: New file (~300 lines)
- `autoload/linny_menu_widgets.vim`: New file (~200 lines)
- `autoload/linny_menu_keymaps.vim`: New file (~300 lines)
- `autoload/linny_menu_actions.vim`: New file (~400 lines)
- `autoload/linny_menu_documents.vim`: New file (~200 lines)
- `autoload/linny_menu_util.vim`: New file (~250 lines)
- All callers updated to use new function names

## Non-Goals

- **Lua conversion** - This change only reorganizes Vimscript files. Lua conversion will happen in subsequent changes, one module at a time.
- **Changing functionality** - All behavior remains identical
- **Adding tests** - Tests will be added during Lua conversion
