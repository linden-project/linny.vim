## Why

Users who don't use Hugo for their notebook (or don't want any Hugo integration after refresh) currently cannot fully disable the Hugo hook that runs on the R key. While `g:linny_hugo_watch_enabled = 0` prevents auto-start of watch mode, the R key still attempts Hugo detection and may trigger manual rebuilds if Hugo is found. A dedicated config option is needed to completely disable all Hugo hooks during refresh.

## What Changes

- Add new configuration variable `g:linny_hugo_hook_enabled` (default: `1`) that controls whether the R key (refresh) triggers any Hugo-related operations
- When set to `0`, the R key will only refresh the menu view without attempting Hugo detection or index rebuilding
- This is independent of `g:linny_hugo_watch_enabled` which controls auto-start of watch mode

## Capabilities

### New Capabilities
- `hugo-hook-config`: Configuration option to fully disable Hugo integration on refresh

### Modified Capabilities
- `hugo-integration`: R key rebuild behavior becomes conditional on new config variable

## Impact

- **Code**: `lua/linny/menu/window.lua` (refresh function), `autoload/linny.vim` (variable initialization)
- **Documentation**: README should mention the new config option
- **User behavior**: Users can now set `g:linny_hugo_hook_enabled = 0` to prevent any Hugo operations during refresh
