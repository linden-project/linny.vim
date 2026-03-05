## MODIFIED Requirements

### Requirement: Lua module directory structure

The plugin SHALL provide Lua modules under `lua/linny/` following standard Neovim plugin conventions.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny')` SHALL return the module table
- **AND** `require('linny.version')` SHALL return the version submodule
- **AND** `require('linny.util')` SHALL return the util submodule
- **AND** `require('linny.fs')` SHALL return the fs submodule

#### Scenario: Module files exist in correct location
- **WHEN** the plugin is installed
- **THEN** `lua/linny/init.lua` SHALL exist as the module entry point
- **AND** `lua/linny/version.lua` SHALL exist with the version function
- **AND** `lua/linny/util.lua` SHALL exist with the util functions
- **AND** `lua/linny/fs.lua` SHALL exist with the fs functions

#### Scenario: FS accessible from main module
- **WHEN** calling `require('linny').fs.dir_create_if_not_exist(path)`
- **THEN** it SHALL work the same as calling `require('linny.fs').dir_create_if_not_exist(path)`
