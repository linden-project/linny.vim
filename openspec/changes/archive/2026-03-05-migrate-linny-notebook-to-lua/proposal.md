## Why

Continuing the Vimscript-to-Lua migration. `linny_notebook.vim` contains 2 functions for notebook management: `init()` sets up global path variables, and `open()` prompts for/validates a notebook path and initializes it.

## What Changes

- Create `lua/linny/notebook.lua` module with init and open functions
- Add unit tests for the notebook module in `tests/notebook_spec.lua`
- Update callers in `autoload/linny.vim` and `plugin/linny.vim` to use Lua
- **BREAKING**: Delete `autoload/linny_notebook.vim`

## Capabilities

### New Capabilities
- `lua-notebook-module`: Lua implementations of notebook functions (init, open)

### Modified Capabilities
- `lua-module-structure`: Add notebook submodule export to linny module

## Impact

- `lua/linny/notebook.lua`: New file with 2 functions (init, open)
- `lua/linny/init.lua`: Add notebook export
- `autoload/linny.vim`: Update call to `linny_notebook#init()` to use Lua
- `plugin/linny.vim`: Update `LinnyOpenNotebook` command to use Lua
- `autoload/linny_notebook.vim`: Deleted
- `tests/notebook_spec.lua`: New unit tests

Note: The `open` function calls `linny#Init()` and `linny_menu#start()` which are still Vimscript. We'll use `vim.fn[]` to call back to Vimscript for these.
