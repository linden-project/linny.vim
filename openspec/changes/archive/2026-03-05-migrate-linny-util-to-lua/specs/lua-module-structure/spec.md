## MODIFIED Requirements

### Requirement: Lua module directory structure

The plugin SHALL provide Lua modules under `lua/linny/` following standard Neovim plugin conventions.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny')` SHALL return the module table
- **AND** `require('linny.version')` SHALL return the version submodule
- **AND** `require('linny.util')` SHALL return the util submodule

#### Scenario: Module files exist in correct location
- **WHEN** the plugin is installed
- **THEN** `lua/linny/init.lua` SHALL exist as the module entry point
- **AND** `lua/linny/version.lua` SHALL exist with the version function
- **AND** `lua/linny/util.lua` SHALL exist with the util functions

#### Scenario: Util accessible from main module
- **WHEN** calling `require('linny').util.init_variable("g:var", "val")`
- **THEN** it SHALL work the same as calling `require('linny.util').init_variable("g:var", "val")`
