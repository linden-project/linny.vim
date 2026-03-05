## Why

The plugin throws `E121: Undefined variable` errors at startup:
1. `g:linnycfg_setup_autocommands` - referenced in `plugin/linny.vim` before autoload initializes it
2. `g:linny_wikitags_register` - used in `linny#RegisterLinnyWikitag()` before `linny#Init()` initializes it

## What Changes

- Use `get()` with default values for variables that may not be initialized yet
- Fix both `plugin/linny.vim` and `autoload/linny.vim`

## Capabilities

### New Capabilities

### Modified Capabilities
- `plugin-initialization`: Plugin loads without errors when variables aren't pre-configured by user

## Impact

- `plugin/linny.vim`: Use `get()` for `g:linnycfg_setup_autocommands`
- `autoload/linny.vim`: Use `get()` for `g:linny_wikitags_register` in `RegisterLinnyWikitag()`
