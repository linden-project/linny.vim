## Why

Continuing the Vimscript-to-Lua migration. `linny_wiki.vim` (368 lines) is the wiki link handling module containing:
- Wiki link parsing and navigation (`GotoLink`, `GetWord`, `GetLink`)
- Non-existing link highlighting (`FindNonExistingLinks`)
- Wikitag detection and execution
- YAML frontmatter handling
- File path utilities

This is called from `plugin/linny.vim` autocommands and from `linny_menu.vim`.

## What Changes

- Create `lua/linny/wiki.lua` module with all wiki functions
- Add unit tests for the wiki module in `tests/wiki_spec.lua`
- Update callers in `plugin/linny.vim`, `autoload/linny.vim`, `autoload/linny_menu.vim`, and `after/ftplugin/markdown.vim`
- **BREAKING**: Delete `autoload/linny_wiki.vim`

## Capabilities

### New Capabilities
- `lua-wiki-module`: Lua implementations of wiki link handling functions

### Modified Capabilities
- `lua-module-structure`: Add wiki submodule export to linny module

## Impact

- `lua/linny/wiki.lua`: New file with ~20 functions
- `lua/linny/init.lua`: Add wiki export
- `plugin/linny.vim`: Update autocommands to use Lua
- `autoload/linny.vim`: Update call to `linny_wiki#YamlKeyUnderCursor()`
- `autoload/linny_menu.vim`: Update calls to `linny_wiki#WordFilename()`
- `after/ftplugin/markdown.vim`: Update `MdwiReturn` command
- `autoload/linny_wiki.vim`: Deleted
- `tests/wiki_spec.lua`: New unit tests

Note: Some functions call back to Vimscript (`linny#generate_first_content`, `linny#l2_index_filepath`, `linny_menu#openterm`). We'll use `vim.fn[]` for these callbacks.
