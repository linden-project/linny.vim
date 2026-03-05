## Why

Continuing the Vimscript-to-Lua migration with the simplest module. `linny_util.vim` contains just one utility function (`initVariable`) used to set default configuration values. Migrating it establishes patterns for utility modules and adds proper unit test coverage.

## What Changes

- Create `lua/linny/util.lua` module with `init_variable()` function
- Add unit tests for the util module in `tests/util_spec.lua`
- Update all 17 callers in `autoload/linny.vim` to use Lua via `luaeval()`
- **BREAKING**: Delete `autoload/linny_util.vim`

## Capabilities

### New Capabilities
- `lua-util-module`: Lua utility module providing configuration variable initialization with defaults

### Modified Capabilities
- `lua-module-structure`: Add util submodule export to linny module

## Impact

- `lua/linny/util.lua`: New file
- `lua/linny/init.lua`: Add util export
- `autoload/linny.vim`: Update 17 `linny_util#initVariable` calls to use `luaeval()`
- `autoload/linny_util.vim`: Deleted
- `tests/util_spec.lua`: New unit tests
