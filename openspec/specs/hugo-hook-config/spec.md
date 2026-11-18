# hugo-hook-config Specification

## Purpose
TBD - created by archiving change add-hugo-hook-disable-config. Update Purpose after archive.

## Requirements

### Requirement: Index hook configuration variable

The plugin SHALL provide a `g:linny_index_hook_enabled` configuration variable
that controls whether index operations run during menu refresh. The former
`g:linny_hugo_hook_enabled` SHALL be accepted as a deprecated alias when the new
variable is unset.

#### Scenario: Default value is enabled

- **WHEN** the plugin loads
- **AND** the user has set neither variable
- **THEN** the effective hook setting SHALL be `1`

#### Scenario: User disables hugo hook

- **WHEN** the user sets `g:linny_index_hook_enabled = 0` in their config
- **AND** the plugin loads
- **THEN** the effective hook setting SHALL remain `0`

#### Scenario: Deprecated alias is honoured

- **WHEN** the user sets `g:linny_hugo_hook_enabled = 0`
- **AND** `g:linny_index_hook_enabled` is unset
- **THEN** the effective hook setting SHALL be `0`

#### Scenario: New variable wins over the alias

- **WHEN** the user sets `g:linny_hugo_hook_enabled = 0`
- **AND** the user sets `g:linny_index_hook_enabled = 1`
- **THEN** the effective hook setting SHALL be `1`

#### Scenario: Variable is independent of watch enabled

- **WHEN** watch is enabled
- **AND** the index hook is disabled
- **THEN** watch mode auto-start SHALL still function
- **AND** menu refresh SHALL NOT trigger index operations
