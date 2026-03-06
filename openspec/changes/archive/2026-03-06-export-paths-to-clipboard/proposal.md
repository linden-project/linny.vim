## Why

When using AI assistants like Claude for code analysis or documentation tasks, users need to share file paths from their Linny wiki. Currently there's no easy way to copy document paths to the clipboard from the menu, requiring manual path construction.

## What Changes

- Add "copy path" action to the document context menu (triggered by `m` key)
- Prompt user to choose between relative or absolute path format
- Copy the selected path to the system clipboard (using Vim's `+` register or available clipboard mechanism)
- Support both single document and taxonomy term paths

## Capabilities

### New Capabilities
- `clipboard-path-export`: Copy document/taxonomy paths to clipboard with format selection

### Modified Capabilities

## Impact

- `lua/linny/menu/actions.lua`: Add new action handler and clipboard logic
- `autoload/linny_menu_actions.vim`: May need callback for path format selection popup
