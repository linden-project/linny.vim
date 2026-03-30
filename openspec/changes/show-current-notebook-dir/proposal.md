## Why

When working with multiple notebooks, users need to know which notebook is currently active. The footer already shows version information, but not the current notebook path. This addresses issue #23.

## What Changes

- Display the current notebook directory (`g:linny_open_notebook_path`) in the menu footer
- Show it below the version number, using the basename for brevity

## Capabilities

### New Capabilities
None - this is a small enhancement to existing footer rendering.

### Modified Capabilities
- `menu-render-lua`: Add notebook path display to footer section

## Impact

- **Code**: `lua/linny/menu/render.lua` (footer rendering section)
- **User experience**: Users can see which notebook is active at a glance
