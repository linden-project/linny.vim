## Why

When sharing multiple documents with AI assistants or other tools, users need to export a collection of files at once. Currently, users must manually copy each file. A zip export option in the context menu would allow bulk export of all documents in a taxonomy term.

## What Changes

- Add "export to zip" option in document context menu (level 2 menu)
- When `group_by` view is active, prompt user to choose: export flat or preserve folder structure
- Create zip file containing selected documents
- Open system file dialog or use clipboard for destination path

## Capabilities

### New Capabilities
- `export-to-zip`: Context menu option to export term documents to a zip archive

### Modified Capabilities

## Impact

- `lua/linny/menu/actions.lua`: Add export zip functions
- `autoload/linny_menu_actions.vim`: Add callback for export action
- External dependency: May need zip command or Lua zip library
