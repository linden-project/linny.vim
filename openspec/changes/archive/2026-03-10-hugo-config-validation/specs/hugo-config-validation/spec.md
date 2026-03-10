## ADDED Requirements

### Requirement: Parse Hugo configuration via CLI

The `lua/linny/hugo.lua` module SHALL provide a `get_config(notebook_path)` function that retrieves the parsed Hugo configuration.

#### Scenario: Get config from valid notebook

- **WHEN** calling `require('linny.hugo').get_config("/path/to/notebook")`
- **AND** Hugo is available
- **AND** the notebook has a valid Hugo configuration
- **THEN** the function SHALL execute `hugo config --source /path/to/notebook --format json`
- **AND** return `{ok = true, config = <parsed_table>}`

#### Scenario: Get config when Hugo unavailable

- **WHEN** calling `require('linny.hugo').get_config("/path/to/notebook")`
- **AND** Hugo is not available
- **THEN** the function SHALL return `{ok = false, error = "Hugo not found"}`

#### Scenario: Get config from invalid notebook

- **WHEN** calling `require('linny.hugo').get_config("/path/to/notebook")`
- **AND** Hugo cannot parse the configuration
- **THEN** the function SHALL return `{ok = false, error = <hugo_error_message>}`

### Requirement: Validate directory settings

The module SHALL provide a `validate_config(config)` function that validates required directory settings.

#### Scenario: Valid directory configuration

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.contentDir` equals `"content"`
- **AND** `config.dataDir` equals `"lindenConfig"`
- **AND** `config.publishDir` equals `"lindenIndex"`
- **THEN** the validation result SHALL NOT contain directory errors

#### Scenario: Invalid contentDir

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.contentDir` does not equal `"content"`
- **THEN** the validation result SHALL include error `"contentDir must be 'content', got '<actual>'"`

#### Scenario: Invalid dataDir

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.dataDir` does not equal `"lindenConfig"`
- **THEN** the validation result SHALL include error `"dataDir must be 'lindenConfig', got '<actual>'"`

#### Scenario: Invalid publishDir

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.publishDir` does not equal `"lindenIndex"`
- **THEN** the validation result SHALL include error `"publishDir must be 'lindenIndex', got '<actual>'"`

### Requirement: Validate taxonomies

The module SHALL validate that at least one taxonomy is defined.

#### Scenario: Valid taxonomies configuration

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.taxonomies` contains at least one entry
- **THEN** the validation result SHALL NOT contain taxonomy errors

#### Scenario: Missing taxonomies

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.taxonomies` is nil or empty
- **THEN** the validation result SHALL include error `"At least one taxonomy must be defined"`

### Requirement: Validate output formats

The module SHALL validate that required output formats are defined.

#### Scenario: All required output formats present

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.outputFormats` contains all required formats: `starred`, `docs_with_props`, `docs_with_title`, `indexer_info`, `taxonomies`, `taxonomies_starred`, `terms_starred`
- **THEN** the validation result SHALL NOT contain output format errors

#### Scenario: Missing output format

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.outputFormats` is missing `docs_with_props`
- **THEN** the validation result SHALL include error `"Missing required output format: docs_with_props"`

### Requirement: Validate outputs configuration

The module SHALL validate that outputs are configured correctly for each kind.

#### Scenario: Valid home outputs

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.outputs.home` includes all required output formats
- **THEN** the validation result SHALL NOT contain home output errors

#### Scenario: Missing home outputs

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.outputs.home` is missing required output formats
- **THEN** the validation result SHALL include error listing missing formats for home

#### Scenario: Valid page outputs

- **WHEN** calling `require('linny.hugo').validate_config(config)`
- **AND** `config.outputs.page` includes `"json"`
- **THEN** the validation result SHALL NOT contain page output errors

### Requirement: Combined validation function

The module SHALL provide a `validate_notebook_config(notebook_path)` function that combines config retrieval and validation.

#### Scenario: Validate complete notebook configuration

- **WHEN** calling `require('linny.hugo').validate_notebook_config("/path/to/notebook")`
- **AND** Hugo is available
- **AND** the notebook has valid configuration
- **THEN** the function SHALL return `{ok = true, warnings = [], errors = []}`

#### Scenario: Validate notebook with configuration errors

- **WHEN** calling `require('linny.hugo').validate_notebook_config("/path/to/notebook")`
- **AND** Hugo is available
- **AND** the notebook has invalid `publishDir`
- **THEN** the function SHALL return `{ok = false, warnings = [], errors = ["publishDir must be 'lindenIndex', got '...'"]}`
