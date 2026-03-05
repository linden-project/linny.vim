# lua-util-module Specification

## Purpose
TBD - created by archiving change migrate-linny-util-to-lua. Update Purpose after archive.
## Requirements
### Requirement: Initialize global variable with default

The util module SHALL provide a function to initialize global variables with default values only if they are not already set.

#### Scenario: Variable not set uses default
- **WHEN** calling `require('linny.util').init_variable("g:my_var", "default_value")`
- **AND** `g:my_var` is not defined
- **THEN** `g:my_var` SHALL be set to `"default_value"`
- **AND** the function SHALL return `true`

#### Scenario: Variable already set preserves existing value
- **WHEN** `g:my_var` is already set to `"user_value"`
- **AND** calling `require('linny.util').init_variable("g:my_var", "default_value")`
- **THEN** `g:my_var` SHALL remain `"user_value"`
- **AND** the function SHALL return `false`

#### Scenario: Works with numeric values
- **WHEN** calling `require('linny.util').init_variable("g:my_number", 42)`
- **AND** `g:my_number` is not defined
- **THEN** `g:my_number` SHALL be set to `42`

#### Scenario: Works with variable name without g: prefix
- **WHEN** calling `require('linny.util').init_variable("my_var", "value")`
- **AND** `g:my_var` is not defined
- **THEN** `g:my_var` SHALL be set to `"value"`

### Requirement: Util module accessible via require

The util module SHALL be accessible as `require('linny.util')`.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny.util')` SHALL return the module table
- **AND** the module SHALL have an `init_variable` function

