## ADDED Requirements

### Requirement: Notebook list configuration variable

The plugin SHALL provide a `g:linny_notebooks` configuration variable that holds a list of notebook paths.

#### Scenario: Default value is empty list

- **WHEN** the plugin loads
- **AND** the user has not set `g:linny_notebooks`
- **THEN** `g:linny_notebooks` SHALL be initialized to an empty list `[]`

#### Scenario: User configures notebook list

- **WHEN** the user sets `g:linny_notebooks = ['/path/to/nb1', '/path/to/nb2']`
- **AND** the plugin loads
- **THEN** `g:linny_notebooks` SHALL contain the configured paths

#### Scenario: List contains active notebook

- **WHEN** `g:linny_notebooks` is set
- **AND** `g:linny_open_notebook_path` is set to a path in the list
- **THEN** the active notebook SHALL be identifiable within the list

### Requirement: Test fixtures for multi-notebook testing

A second mock notebook directory SHALL exist for testing multi-notebook scenarios.

#### Scenario: Second mock notebook structure

- **WHEN** tests need to verify multi-notebook functionality
- **THEN** `tests/fixtures/mock-notebook-2/` SHALL exist
- **AND** it SHALL contain `hugo.yaml` configuration
- **AND** it SHALL contain `content/` directory with at least one markdown file

#### Scenario: Mock notebooks are distinguishable

- **WHEN** both mock notebooks are configured in `g:linny_notebooks`
- **THEN** they SHALL have different paths
- **AND** they SHALL have different content for verification
