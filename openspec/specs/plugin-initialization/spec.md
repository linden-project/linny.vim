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
