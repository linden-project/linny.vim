## MODIFIED Requirements

### Requirement: Lua module directory structure

The plugin SHALL provide Lua modules under `lua/linny/` following standard Neovim plugin conventions.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny')` SHALL return the module table
- **AND** `require('linny.version')` SHALL return the version submodule
- **AND** `require('linny.util')` SHALL return the util submodule
- **AND** `require('linny.fs')` SHALL return the fs submodule
- **AND** `require('linny.wikitags')` SHALL return the wikitags submodule
- **AND** `require('linny.notebook')` SHALL return the notebook submodule
- **AND** `require('linny.wiki')` SHALL return the wiki submodule
- **AND** `require('linny.menu')` SHALL return the menu submodule
- **AND** `require('linny.menu.state')` SHALL return the menu state submodule
- **AND** `require('linny.menu.util')` SHALL return the menu util submodule

#### Scenario: Module files exist in correct location
- **WHEN** the plugin is installed
- **THEN** `lua/linny/init.lua` SHALL exist as the module entry point
- **AND** `lua/linny/version.lua` SHALL exist
- **AND** `lua/linny/util.lua` SHALL exist
- **AND** `lua/linny/fs.lua` SHALL exist
- **AND** `lua/linny/wikitags.lua` SHALL exist
- **AND** `lua/linny/notebook.lua` SHALL exist
- **AND** `lua/linny/wiki.lua` SHALL exist
- **AND** `lua/linny/menu/init.lua` SHALL exist
- **AND** `lua/linny/menu/state.lua` SHALL exist
- **AND** `lua/linny/menu/util.lua` SHALL exist

#### Scenario: Menu util accessible from main module
- **WHEN** calling `require('linny').menu.util.string_capitalize("test")`
- **THEN** it SHALL work the same as calling `require('linny.menu.util').string_capitalize("test")`
