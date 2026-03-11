## ADDED Requirements

### Requirement: Hugo hook configuration variable

The plugin SHALL provide a `g:linny_hugo_hook_enabled` configuration variable that controls whether Hugo operations run during menu refresh.

#### Scenario: Default value is enabled

- **WHEN** the plugin loads
- **AND** the user has not set `g:linny_hugo_hook_enabled`
- **THEN** `g:linny_hugo_hook_enabled` SHALL be initialized to `1`

#### Scenario: User disables hugo hook

- **WHEN** the user sets `g:linny_hugo_hook_enabled = 0` in their config
- **AND** the plugin loads
- **THEN** `g:linny_hugo_hook_enabled` SHALL remain `0`

#### Scenario: Variable is independent of watch enabled

- **WHEN** `g:linny_hugo_watch_enabled = 1`
- **AND** `g:linny_hugo_hook_enabled = 0`
- **THEN** watch mode auto-start SHALL still function
- **AND** R key refresh SHALL NOT trigger Hugo operations
