## Why

When sharing multiple files with AI assistants, users need to copy all document paths from a taxonomy term at once. The existing "copy path" context menu only works for individual documents, requiring repetitive actions for bulk operations.

## What Changes

- Add `Y` hotkey in level 2 (term) menu to copy all document paths
- Show format selection popup (relative/absolute) after pressing `Y`
- Copy all paths (newline-separated) to system clipboard
- Reuse existing clipboard infrastructure from `export-paths-to-clipboard` change

## Capabilities

### New Capabilities
- `term-paths-hotkey`: Hotkey to copy all document paths in current term view

### Modified Capabilities

## Impact

- `autoload/linny_menu.vim`: Add `Y` keymap for level 2 menu
- `lua/linny/menu/actions.lua`: Add function to collect and copy term paths
- `autoload/linny_menu_actions.vim`: Add callback for term paths format selection
