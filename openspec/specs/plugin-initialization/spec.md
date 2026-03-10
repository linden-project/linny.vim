## Requirements

### Requirement: Hugo watch configuration option

The plugin SHALL support a configuration option to enable automatic Hugo watch mode.

#### Scenario: Default value when not configured

- **WHEN** the plugin is loaded
- **AND** the user has not set `g:linny_hugo_watch_enabled`
- **THEN** the variable SHALL default to `0` (disabled)

#### Scenario: User enables watch mode

- **WHEN** the user sets `g:linny_hugo_watch_enabled = 1` in their vimrc
- **AND** the plugin loads
- **THEN** watch mode SHALL be started automatically on first LinnyMenu open

#### Scenario: User explicitly disables watch mode

- **WHEN** the user sets `g:linny_hugo_watch_enabled = 0` in their vimrc
- **THEN** watch mode SHALL NOT be started automatically

## MODIFIED Requirements

### Requirement: Variable Initialization Before Use

All configuration variables and internal state must be safely accessed with defaults before they are referenced.

#### Scenario: Plugin loads without user configuration

- **WHEN** the plugin is loaded at Vim startup
- **AND** the user has not set `g:linnycfg_setup_autocommands` in their vimrc
- **THEN** the variable should default to `1`
- **AND** no `E121: Undefined variable` error should occur

#### Scenario: User overrides configuration

- **WHEN** the user sets `g:linnycfg_setup_autocommands = 0` in their vimrc
- **AND** the plugin loads
- **THEN** the user's value should be preserved
- **AND** autocommands should not be set up

#### Scenario: Wikitag registration before Init

- **WHEN** `linny#RegisterLinnyWikitag()` is called
- **AND** `linny#Init()` has not been called yet
- **THEN** `g:linny_wikitags_register` should be initialized as empty dict
- **AND** the wikitag should be registered successfully

### Requirement: Version function implementation

The plugin version SHALL be provided via Lua module instead of Vimscript autoload.

#### Scenario: Version accessible from Vimscript via luaeval
- **WHEN** Vimscript code calls `luaeval("require('linny.version').plugin_version()")`
- **THEN** it SHALL return the version string `'0.8.0'`

#### Scenario: Menu footer displays version
- **WHEN** the linny menu is displayed
- **THEN** the footer SHALL show the version from the Lua module
- **AND** the display format SHALL remain `'linny: 0.8.0'`

#### Scenario: Tests verify version via Lua
- **WHEN** running `tests/linny_spec.lua`
- **THEN** the version test SHALL call `require('linny.version').plugin_version()` directly
- **AND** the test SHALL pass

### Requirement: Initialization state tracking

The plugin SHALL track whether initialization completed successfully via `g:linny_initialized`.

#### Scenario: Plugin loads without Init called

- **WHEN** the plugin is loaded at Vim/Neovim startup
- **AND** `linny#Init()` has not been called
- **THEN** `g:linny_initialized` SHALL be 0 or unset

#### Scenario: Successful initialization sets flag

- **WHEN** `linny#Init()` completes successfully
- **AND** all required directories exist
- **THEN** `g:linny_initialized` SHALL be set to 1

#### Scenario: Failed initialization does not set flag

- **WHEN** `linny#Init()` is called
- **AND** `linny#setup_paths()` returns failure (required directory missing)
- **THEN** `g:linny_initialized` SHALL remain 0
- **AND** an error message SHALL be displayed

### Requirement: Fatal directory check returns error state

The `linny#fatal_check_dir()` function SHALL return a boolean indicating success or failure.

#### Scenario: Directory exists

- **WHEN** calling `linny#fatal_check_dir('/existing/directory')`
- **AND** the directory exists
- **THEN** the function SHALL return 1

#### Scenario: Directory does not exist

- **WHEN** calling `linny#fatal_check_dir('/nonexistent/directory')`
- **AND** the directory does not exist
- **THEN** the function SHALL return 0
- **AND** an error message SHALL be displayed using `echohl ErrorMsg`
- **AND** the message SHALL include the path that does not exist

### Requirement: Lua path functions handle nil safely

All path construction functions in `lua/linny/paths.lua` SHALL handle nil path variables without crashing.

#### Scenario: Path function called with nil base path

- **WHEN** calling a path function like `paths.l1_index_filepath('taxonomy')`
- **AND** `vim.g.linny_index_path` is nil
- **THEN** the function SHALL return nil
- **AND** no Lua error SHALL be thrown

#### Scenario: Path function called with valid base path

- **WHEN** calling `paths.l1_index_filepath('taxonomy')`
- **AND** `vim.g.linny_index_path` is `/path/to/index`
- **THEN** the function SHALL return `/path/to/index/taxonomy/index.json`
