## ADDED Requirements

### Requirement: Mock notebook directory structure

A mock notebook directory SHALL exist at `tests/fixtures/mock-notebook/` for unit testing Hugo-related functionality.

#### Scenario: Mock notebook contains required subdirectories

- **WHEN** the mock notebook is used for testing
- **THEN** it SHALL contain the following directories:
  - `content/` - for markdown content files
  - `lindenConfig/` - for configuration files
  - `lindenIndex/` - for index output

#### Scenario: Mock notebook contains minimal Hugo configuration

- **WHEN** the mock notebook is used for Hugo tests
- **THEN** it SHALL contain a `hugo.yaml` (or `hugo.toml`) configuration file
- **AND** the configuration SHALL set the minimum required Hugo settings

### Requirement: Mock content files for testing

The mock notebook SHALL contain sample content files for testing index operations.

#### Scenario: Mock notebook has sample markdown files

- **WHEN** tests need to verify index building
- **THEN** `tests/fixtures/mock-notebook/content/` SHALL contain at least one markdown file
- **AND** the markdown file SHALL have valid frontmatter

#### Scenario: Sample file has expected frontmatter

- **WHEN** reading `tests/fixtures/mock-notebook/content/sample.md`
- **THEN** the file SHALL contain YAML frontmatter with at least a `title` field

### Requirement: Test helper for notebook path

Tests SHALL be able to easily obtain the path to the mock notebook.

#### Scenario: Get mock notebook path in tests

- **WHEN** a test needs the mock notebook path
- **THEN** it SHALL be available via a test helper or constant
- **AND** the path SHALL be relative to the plugin root
