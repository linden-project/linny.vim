## ADDED Requirements

### Requirement: Hugo availability validation

The health check system SHALL validate that Hugo is available on the system.

#### Scenario: Hugo is available

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is installed and in PATH
- **THEN** the result SHALL include `hugo = {available = true, version = "x.y.z"}`

#### Scenario: Hugo is not available

- **WHEN** calling `require('linny.health').validate()`
- **AND** Hugo is not installed or not in PATH
- **THEN** the result SHALL include `hugo = {available = false}`
- **AND** `errors` SHALL include `"Hugo not found (index features disabled)"`

### Requirement: Checkhealth reports Hugo status

The `:checkhealth linny` command SHALL report Hugo availability.

#### Scenario: Checkhealth with Hugo available

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is installed
- **THEN** an OK status SHALL be reported with message including the Hugo version

#### Scenario: Checkhealth with Hugo missing

- **WHEN** user runs `:checkhealth linny` in Neovim
- **AND** Hugo is not installed
- **THEN** a WARN status SHALL be reported with message "Hugo not found"
- **AND** advice SHALL explain that index/search features require Hugo
- **AND** advice SHALL include installation guidance

### Requirement: Hugo check is non-blocking

Missing Hugo SHALL NOT prevent plugin initialization or basic functionality.

#### Scenario: Plugin initializes without Hugo

- **WHEN** Linny initializes
- **AND** Hugo is not available
- **THEN** `g:linny_initialized` SHALL still be set to 1 (if notebook is valid)
- **AND** index-related features SHALL be gracefully disabled
