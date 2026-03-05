## Why

Continuing the Vimscript-to-Lua migration. `linny_wikitags.vim` contains the implementations for special wiki link actions (FILE, DIR, SHELL, LIN, VIM). These are registered at plugin startup and called when users interact with tagged wiki links.

## What Changes

- Create `lua/linny/wikitags.lua` module with all wikitag action functions
- Add unit tests for the wikitags module in `tests/wikitags_spec.lua`
- Update `plugin/linny.vim` wikitag registrations to use Lua functions via wrapper pattern
- **BREAKING**: Delete `autoload/linny_wikitags.vim`

## Capabilities

### New Capabilities
- `lua-wikitags-module`: Lua implementations of wikitag actions (file, dir, shell, linny, vim)

### Modified Capabilities
- `lua-module-structure`: Add wikitags submodule export to linny module

## Impact

- `lua/linny/wikitags.lua`: New file with 6 functions (file, mkdir_if_not_exist, dir1st, dir2nd, shell, vim_cmd)
- `lua/linny/init.lua`: Add wikitags export
- `plugin/linny.vim`: Update 5 RegisterLinnyWikitag calls to use Lua wrappers
- `autoload/linny_wikitags.vim`: Deleted
- `tests/wikitags_spec.lua`: New unit tests

Note: The `linny` wikitag action calls `linny_menu#openterm()` which is still Vimscript. We'll create a Lua wrapper that calls back to Vimscript for this.
