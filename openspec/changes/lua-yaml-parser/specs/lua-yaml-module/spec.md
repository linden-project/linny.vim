## ADDED Requirements

### Requirement: Parse YAML file to Lua table

The `lua/linny/yaml.lua` module SHALL provide a `parse_file(filepath)` function that reads and parses YAML configuration files.

#### Scenario: Parse simple key-value pairs

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/config.yaml')`
- **AND** the file contains:
  ```yaml
  name: My Config
  enabled: true
  count: 42
  ```
- **THEN** the function SHALL return `{name = "My Config", enabled = true, count = 42}`

#### Scenario: Parse nested objects

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/config.yaml')`
- **AND** the file contains:
  ```yaml
  settings:
    theme: dark
    size: large
  ```
- **THEN** the function SHALL return `{settings = {theme = "dark", size = "large"}}`

#### Scenario: Parse simple lists

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/config.yaml')`
- **AND** the file contains:
  ```yaml
  items:
    - apple
    - banana
    - cherry
  ```
- **THEN** the function SHALL return `{items = {"apple", "banana", "cherry"}}`

#### Scenario: Handle comments

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/config.yaml')`
- **AND** the file contains:
  ```yaml
  # This is a comment
  name: value  # inline comment
  ```
- **THEN** the function SHALL return `{name = "value"}`
- **AND** comments SHALL be ignored

#### Scenario: Handle quoted strings

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/config.yaml')`
- **AND** the file contains:
  ```yaml
  single: 'quoted value'
  double: "another value"
  ```
- **THEN** the function SHALL return `{single = "quoted value", double = "another value"}`

#### Scenario: Handle non-existent file

- **WHEN** calling `require('linny.yaml').parse_file('/nonexistent/path.yaml')`
- **AND** the file does not exist
- **THEN** the function SHALL return `nil`

#### Scenario: Handle empty file

- **WHEN** calling `require('linny.yaml').parse_file('/path/to/empty.yaml')`
- **AND** the file is empty
- **THEN** the function SHALL return `{}`

### Requirement: Parse YAML string to Lua table

The module SHALL provide a `parse(yaml_string)` function for parsing YAML content from a string.

#### Scenario: Parse string content

- **WHEN** calling `require('linny.yaml').parse("key: value")`
- **THEN** the function SHALL return `{key = "value"}`

## MODIFIED Requirements

### Requirement: Vimscript YAML parsing uses Lua

The `linny#parse_yaml_to_dict()` function SHALL use the Lua YAML parser instead of Ruby.

#### Scenario: Parse YAML file via Vimscript

- **WHEN** calling `linny#parse_yaml_to_dict('/path/to/config.yaml')`
- **AND** the file exists and contains valid YAML
- **THEN** the function SHALL return the parsed content as a Vimscript dictionary
- **AND** Ruby SHALL NOT be invoked

#### Scenario: Handle missing file via Vimscript

- **WHEN** calling `linny#parse_yaml_to_dict('/nonexistent/path.yaml')`
- **THEN** the function SHALL return an empty dictionary `{}`
