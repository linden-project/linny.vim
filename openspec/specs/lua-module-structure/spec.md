# Capability: lua-module-structure

## Purpose

This capability defines the Lua module structure for the linny.vim plugin, following standard Neovim plugin conventions. It ensures that Lua modules are properly organized and accessible.

## Requirements

### Requirement: Lua module directory structure

The plugin SHALL provide Lua modules under `lua/linny/` following standard Neovim plugin conventions.

#### Scenario: Module is requireable
- **WHEN** Neovim loads with the plugin in runtimepath
- **THEN** `require('linny')` SHALL return the module table
- **AND** `require('linny.version')` SHALL return the version submodule

#### Scenario: Module files exist in correct location
- **WHEN** the plugin is installed
- **THEN** `lua/linny/init.lua` SHALL exist as the module entry point
- **AND** `lua/linny/version.lua` SHALL exist with the version function

### Requirement: Version function accessible via Lua

The version function SHALL be accessible as `require('linny.version').plugin_version()`.

#### Scenario: Version function returns correct value
- **WHEN** calling `require('linny.version').plugin_version()`
- **THEN** it SHALL return the version string `'0.8.0'`

#### Scenario: Version accessible from main module
- **WHEN** calling `require('linny').version.plugin_version()`
- **THEN** it SHALL return the same version string as the submodule
