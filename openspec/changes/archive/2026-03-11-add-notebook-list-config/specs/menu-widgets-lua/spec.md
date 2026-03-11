## ADDED Requirements

### Requirement: configured_notebooks widget function

The `linny.menu.widgets` module SHALL provide a `configured_notebooks(widgetconf)` function.

#### Scenario: Function is callable

- **WHEN** calling `require('linny.menu.widgets').configured_notebooks({})`
- **THEN** the function SHALL execute without error

#### Scenario: Function accepts widgetconf parameter

- **WHEN** calling `configured_notebooks({show_path = true})`
- **THEN** the function SHALL accept the configuration table
- **AND** honor any supported options
