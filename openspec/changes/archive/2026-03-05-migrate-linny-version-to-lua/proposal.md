## Why

This is the initial migration step to prove we can lift and shift Linny from Vimscript to Lua. The `linny_version#PluginVersion()` function is the simplest function in the codebase - it just returns a version string. Starting here establishes the Lua module structure and proves the migration approach works before tackling more complex functions.

## What Changes

- Create a new `lua/linny/version.lua` module with a `plugin_version()` function
- Delete the original `autoload/linny_version.vim` file entirely
- Update all internal callers to use the Lua function directly
- Establish the `lua/linny/` directory structure for future migrations

## Capabilities

### New Capabilities
- `lua-module-structure`: Establish the Lua module directory structure (`lua/linny/`) and require pattern for Linny

### Modified Capabilities
- `plugin-initialization`: Version function moves from Vimscript autoload to Lua module

## Impact

- `autoload/linny_version.vim`: Deleted
- `lua/linny/version.lua`: New file with Lua implementation
- `lua/linny/init.lua`: New file establishing module entry point
- `autoload/linny_menu.vim`: Update version call to use Lua
- `tests/linny_spec.lua`: Update to call Lua function
- `Rakefile`: Update version grep pattern for new file location
