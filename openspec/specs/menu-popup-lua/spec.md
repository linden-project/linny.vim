# menu-popup-lua Specification

## Purpose
TBD - created by archiving change migrate-linny-menu-popup-to-lua. Update Purpose after archive.
## Requirements
### Requirement: Popup creation
The `popup.create(what, options)` function SHALL create a popup window displaying content with specified options. In Vim, it SHALL use `popup_create()`. In Neovim, it SHALL use `nvim_open_win()` with floating window configuration.

#### Scenario: Create popup in Vim
- **WHEN** `popup.create(lines, options)` is called in Vim with popupwin support
- **THEN** a Vim popup window is created using `popup_create()` with the given content and options

#### Scenario: Create popup in Neovim
- **WHEN** `popup.create(lines, options)` is called in Neovim
- **THEN** a floating window is created using `nvim_open_win()` with converted options

### Requirement: Popup closing
The `popup.close(id, result)` function SHALL close the popup identified by `id` and pass `result` to the callback if defined.

#### Scenario: Close popup in Vim
- **WHEN** `popup.close(id, result)` is called in Vim
- **THEN** `popup_close(id, result)` is called to close the popup

#### Scenario: Close popup in Neovim
- **WHEN** `popup.close(id, result)` is called in Neovim
- **THEN** the result is stored in buffer options and `nvim_win_close()` is called

### Requirement: Get popup options
The `popup.getoptions(id)` function SHALL return the options dictionary for the popup identified by `id`.

#### Scenario: Get options in Vim
- **WHEN** `popup.getoptions(id)` is called in Vim
- **THEN** `popup_getoptions(id)` is called and its result is returned

#### Scenario: Get options in Neovim
- **WHEN** `popup.getoptions(id)` is called in Neovim
- **THEN** the popup_options buffer variable is read and returned

### Requirement: Set popup options
The `popup.setoptions(id, options)` function SHALL update the options for the popup identified by `id`.

#### Scenario: Set options in Vim
- **WHEN** `popup.setoptions(id, options)` is called in Vim
- **THEN** `popup_setoptions(id, options)` is called

#### Scenario: Set options in Neovim
- **WHEN** `popup.setoptions(id, options)` is called in Neovim
- **THEN** the popup_options buffer variable is extended with the new options

### Requirement: Neovim floating window box rendering
For Neovim floating windows, the module SHALL render a decorative box around the popup content with configurable border characters and title.

#### Scenario: Box with title
- **WHEN** a popup is created in Neovim with a title option
- **THEN** the floating window displays the title in the top border

#### Scenario: Box border characters
- **WHEN** a popup is created in Neovim with borderchars option
- **THEN** the specified characters are used for the box borders

### Requirement: Neovim keymap management
For Neovim floating windows, the module SHALL set up keymaps based on the filter option that close the popup with appropriate result values.

#### Scenario: Menu filter keymaps
- **WHEN** a popup is created with `filter: 'popup_filter_menu'`
- **THEN** Space, Enter, and 2-LeftMouse close with current line number; x, Esc, C-C close with -1

#### Scenario: Yes/No filter keymaps
- **WHEN** a popup is created with `filter: 'popup_filter_yesno'`
- **THEN** y/Y close with 1; n/N/x/Esc close with 0; C-C closes with -1

### Requirement: Neovim callback execution
For Neovim floating windows, the module SHALL execute the callback function after the popup is closed, passing the window id and result.

#### Scenario: Callback on BufLeave
- **WHEN** the popup buffer loses focus in Neovim
- **THEN** the callback function is scheduled to execute after entering another buffer

### Requirement: Module exports
The module SHALL export functions via `require('linny.menu.popup')` returning a table with `create`, `close`, `getoptions`, and `setoptions` functions.

#### Scenario: Require module
- **WHEN** `require('linny.menu.popup')` is called
- **THEN** a table with `create`, `close`, `getoptions`, `setoptions` functions is returned

