## MODIFIED Requirements

### Requirement: Version function accessible via Lua

The version function SHALL be accessible as `require('linny.version').plugin_version()` and SHALL read the version from the VERSION file at runtime.

#### Scenario: Version function returns value from VERSION file
- **WHEN** calling `require('linny.version').plugin_version()`
- **THEN** it SHALL return the content of the VERSION file
- **AND** the value SHALL match what is in the VERSION file

#### Scenario: VERSION file missing returns fallback
- **WHEN** calling `require('linny.version').plugin_version()`
- **AND** the VERSION file does not exist
- **THEN** it SHALL return `"unknown"`

#### Scenario: Version accessible from main module
- **WHEN** calling `require('linny').version.plugin_version()`
- **THEN** it SHALL return the same version string as the submodule
