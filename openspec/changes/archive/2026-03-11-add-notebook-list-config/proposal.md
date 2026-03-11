## Why

Users who work with multiple notebooks cannot quickly switch between them. Currently `g:linny_open_notebook_path` holds only the active notebook, with no way to configure known notebooks for quick access. This addresses ticket #11 (widget to see available notebooks).

## What Changes

- Add `g:linny_notebooks` config variable: a list of pre-configured notebook paths
- Add `configured_notebooks` widget that displays all notebooks from `g:linny_notebooks`
- `g:linny_open_notebook_path` becomes the "default" notebook (first in list if unset)
- Add second mock notebook (`tests/fixtures/mock-notebook-2/`) for testing multi-notebook scenarios

## Capabilities

### New Capabilities
- `notebook-list-config`: Configuration variable for defining multiple notebook paths as a list
- `configured-notebooks-widget`: Menu widget that displays all configured notebooks for selection

### Modified Capabilities
- `menu-widgets-lua`: Add `configured_notebooks(widgetconf)` widget function

## Impact

- **Code**: `autoload/linny.vim` (new config variable), `lua/linny/menu/widgets.lua` (new widget)
- **Tests**: `tests/fixtures/mock-notebook-2/` (new fixture), widget tests
- **User config**: Users can now set `g:linny_notebooks = ['/path/to/nb1', '/path/to/nb2']`
