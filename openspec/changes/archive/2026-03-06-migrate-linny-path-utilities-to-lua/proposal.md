## Why

The path utility functions in `autoload/linny.vim` are pure string functions that construct file paths for indexes, configs, and state files. Moving them to Lua consolidates path logic and enables unit testing with plenary.nvim.

## What Changes

- Add path utility functions to a new `lua/linny/paths.lua` module
- Add unit tests for all path functions in `tests/paths_spec.lua`
- Update VimScript callers to use Lua versions via `luaeval()`
- Remove migrated VimScript functions

## Capabilities

### New Capabilities
- `path-utilities-lua`: Path construction functions for index, config, and state files in Lua

### Modified Capabilities

## Impact

- `autoload/linny.vim`: Remove 7 path functions (~25 lines)
- `lua/linny/paths.lua`: New module with path utilities
- `tests/paths_spec.lua`: New test file
- Callers throughout codebase updated to use Lua
