## Why

When Linny loads without a configured notebook (virgin installation), users encounter uncaught Lua errors from nil concatenation in path operations. Commands like `:LinnyStart` fail cryptically because `vim.g.linny_index_path` and similar variables are nil when `linny#Init()` hasn't run. The existing "fatal" checks in `linny#fatal_check_dir()` only echo a warning but don't halt execution, allowing the plugin to continue in a broken state. New users have no guidance on how to get started.

## What Changes

- Add nil-safety guards in Lua modules before concatenating path variables
- Implement proper initialization state tracking (`g:linny_initialized`)
- Create a startup health check that validates notebook configuration
- Commands check initialization state and show helpful messages instead of crashing
- Fix `linny#fatal_check_dir()` to actually halt execution on fatal errors
- When no notebook is configured, direct users to the template: https://github.com/linden-project/linny-notebook-template

## Capabilities

### New Capabilities
- `startup-health-check`: Validation of plugin readiness before operations, with clear diagnostics and link to notebook template for unconfigured installations

### Modified Capabilities
- `plugin-initialization`: Add initialization state tracking and nil-safe path handling
- `lua-notebook-module`: Validate paths exist before setting globals, return error state

## Impact

- **autoload/linny.vim**: Add `g:linny_initialized` flag, fix fatal_check_dir, add pre-flight checks
- **lua/linny/notebook.lua**: Add validation, return success/failure from init()
- **lua/linny/paths.lua**: Add nil guards before path concatenation
- **lua/linny/health.lua**: New file - Neovim `:checkhealth` integration
- **plugin/linny.vim**: Add startup health check with template link
- **Commands**: All user-facing commands check `g:linny_initialized` before executing
