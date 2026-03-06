# path-utilities-lua Specification

## Purpose
TBD - created by archiving change migrate-linny-path-utilities-to-lua. Update Purpose after archive.
## Requirements
### Requirement: L1 index filepath
The `paths.l1_index_filepath(tax)` function SHALL return the path to a taxonomy's index file.

#### Scenario: Basic taxonomy
- **WHEN** `paths.l1_index_filepath("Category")` is called
- **THEN** it returns `{linny_index_path}/category/index.json` (lowercased)

### Requirement: L2 index filepath
The `paths.l2_index_filepath(tax, term)` function SHALL return the path to a taxonomy term's index file.

#### Scenario: Basic term
- **WHEN** `paths.l2_index_filepath("Category", "My Term")` is called
- **THEN** it returns `{linny_index_path}/category/my-term/index.json` (lowercased, spaces to dashes)

### Requirement: View config filepath
The `paths.view_config_filepath(view_name)` function SHALL return the path to a view's config file.

#### Scenario: View config
- **WHEN** `paths.view_config_filepath("Root")` is called
- **THEN** it returns `{linny_path_wiki_config}/views/root.yml` (lowercased)

### Requirement: L1 config filepath
The `paths.l1_config_filepath(tax)` function SHALL return the path to a taxonomy's config file.

#### Scenario: Taxonomy config
- **WHEN** `paths.l1_config_filepath("Status")` is called
- **THEN** it returns `{linny_path_wiki_config}/L1-CONF-TAX-status.yml` (lowercased)

### Requirement: L2 config filepath
The `paths.l2_config_filepath(tax, term)` function SHALL return the path to a taxonomy term's config file.

#### Scenario: Term config
- **WHEN** `paths.l2_config_filepath("Status", "In Progress")` is called
- **THEN** it returns `{linny_path_wiki_config}/L2-CONF-TAX-status-TRM-in-progress.yml` (lowercased, spaces to dashes)

### Requirement: L1 state filepath
The `paths.l1_state_filepath(tax)` function SHALL return the path to a taxonomy's state file.

#### Scenario: Taxonomy state
- **WHEN** `paths.l1_state_filepath("Project")` is called
- **THEN** it returns `{linny_state_path}/L1-STATE-TAX-project.json` (lowercased)

### Requirement: L2 state filepath
The `paths.l2_state_filepath(tax, term)` function SHALL return the path to a taxonomy term's state file.

#### Scenario: Term state
- **WHEN** `paths.l2_state_filepath("Project", "Alpha")` is called
- **THEN** it returns `{linny_state_path}/L2-STATE-TRM-project-TRM-alpha.json` (lowercased)

### Requirement: Module exports
The paths module SHALL export all 7 path functions.

#### Scenario: Require module
- **WHEN** `require('linny.paths')` is called
- **THEN** the returned table includes `l1_index_filepath`, `l2_index_filepath`, `view_config_filepath`, `l1_config_filepath`, `l2_config_filepath`, `l1_state_filepath`, `l2_state_filepath`

