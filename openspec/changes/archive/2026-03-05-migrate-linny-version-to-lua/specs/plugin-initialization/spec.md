## MODIFIED Requirements

### Requirement: Version function implementation

The plugin version SHALL be provided via Lua module instead of Vimscript autoload.

#### Scenario: Version accessible from Vimscript via luaeval
- **WHEN** Vimscript code calls `luaeval("require('linny.version').plugin_version()")`
- **THEN** it SHALL return the version string `'0.8.0'`

#### Scenario: Menu footer displays version
- **WHEN** the linny menu is displayed
- **THEN** the footer SHALL show the version from the Lua module
- **AND** the display format SHALL remain `'linny: 0.8.0'`

#### Scenario: Tests verify version via Lua
- **WHEN** running `tests/linny_spec.lua`
- **THEN** the version test SHALL call `require('linny.version').plugin_version()` directly
- **AND** the test SHALL pass

## REMOVED Requirements

### Requirement: Vimscript autoload version function

**Reason**: Replaced by Lua implementation as part of Vimscript-to-Lua migration.

**Migration**: Use `require('linny.version').plugin_version()` in Lua or `luaeval("require('linny.version').plugin_version()")` in Vimscript.
