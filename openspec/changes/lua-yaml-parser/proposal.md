## Why

The `linny#parse_yaml_to_dict()` function currently shells out to Ruby (`ruby -rjson -ryaml`) to parse YAML configuration files. This adds an external dependency that may not be available on all systems and is slower than a native Lua solution. Replacing it with a pure Lua YAML parser removes the Ruby dependency and improves portability.

## What Changes

- Add a new Lua module `lua/linny/yaml.lua` with YAML parsing functionality
- Replace `linny#parse_yaml_to_dict()` to use the Lua parser instead of Ruby
- Remove the Ruby shell command dependency

## Capabilities

### New Capabilities
- `lua-yaml-module`: Lua module providing YAML parsing for configuration files

### Modified Capabilities
None - the external API (`linny#parse_yaml_to_dict()`) remains unchanged, only the implementation changes.

## Impact

- **autoload/linny.vim**: `linny#parse_yaml_to_dict()` implementation changes from Ruby to Lua
- **lua/linny/yaml.lua**: New file - YAML parsing module
- **Dependencies**: Ruby is no longer required at runtime
- **Functions using YAML**: `linny#view_config()`, `linny#tax_config()`, `linny#term_config()` continue to work unchanged
