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
