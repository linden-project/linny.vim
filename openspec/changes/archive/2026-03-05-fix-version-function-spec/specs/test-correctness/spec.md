## Requirements

### Requirement: Test calls correct function names

Tests must reference actual function names that exist in the codebase.

#### Scenario: Version function test

- **WHEN** the version test runs
- **THEN** it calls `linny_version#PluginVersion()` (the actual function name)
- **AND** the test passes when the function returns a version string
