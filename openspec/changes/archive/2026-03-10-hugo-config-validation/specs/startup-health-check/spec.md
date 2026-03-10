## ADDED Requirements

### Requirement: Health check validates Hugo configuration

The health check system SHALL validate Hugo configuration when Hugo is available.

#### Scenario: Health check with valid Hugo configuration

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is available
- **AND** the notebook has valid Hugo configuration
- **THEN** the result SHALL include `hugo_config = {ok = true}`

#### Scenario: Health check with invalid Hugo configuration

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is available
- **AND** the notebook has invalid Hugo configuration
- **THEN** the result SHALL include `hugo_config = {ok = false, errors = [...]}`
- **AND** the overall result `ok` SHALL be false

#### Scenario: Health check skips config validation when Hugo unavailable

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is not available
- **THEN** Hugo configuration validation SHALL be skipped
- **AND** the result SHALL NOT contain `hugo_config` errors

### Requirement: Checkhealth reports Hugo configuration status

The `:checkhealth linny` command SHALL report Hugo configuration validation results.

#### Scenario: Checkhealth with valid Hugo configuration

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** Hugo configuration is valid
- **THEN** an OK status SHALL be reported with message "Hugo configuration valid"

#### Scenario: Checkhealth with invalid directory settings

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** `publishDir` is not `"lindenIndex"`
- **THEN** an ERROR status SHALL be reported
- **AND** the message SHALL include the expected and actual values
- **AND** advice SHALL reference the notebook template

#### Scenario: Checkhealth with missing output formats

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is available
- **AND** required output formats are missing
- **THEN** a WARN status SHALL be reported for each missing format
- **AND** advice SHALL explain the format's purpose

#### Scenario: Checkhealth skips config when Hugo missing

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is not available
- **THEN** Hugo configuration checks SHALL be skipped
- **AND** an INFO message SHALL indicate config validation was skipped
