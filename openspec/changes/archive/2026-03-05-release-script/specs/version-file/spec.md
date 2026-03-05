## ADDED Requirements

### Requirement: VERSION file as single source of truth

The project SHALL have a `VERSION` file at the repository root containing only the semantic version string.

#### Scenario: VERSION file exists and is readable
- **WHEN** the repository is cloned
- **THEN** a `VERSION` file SHALL exist at the root
- **AND** it SHALL contain a valid semver string (e.g., `0.8.0`)
- **AND** it SHALL have no trailing newline or whitespace

#### Scenario: VERSION file is the only place version is defined
- **WHEN** the version needs to be updated
- **THEN** only the `VERSION` file SHALL be modified
- **AND** all other components SHALL read from this file
