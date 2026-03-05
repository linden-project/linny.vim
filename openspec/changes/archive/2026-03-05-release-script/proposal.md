## Why

The current Rakefile-based release process requires Ruby and uses fragile grep/sed patterns to update version strings. A bash script with a single-source-of-truth VERSION file is simpler, more portable, and easier to maintain.

## What Changes

- Create `VERSION` file at project root containing only the version string (e.g., `0.8.0`)
- Update `lua/linny/version.lua` to read version from VERSION file instead of hardcoding
- Create `scripts/release.sh` bash script with interactive release workflow:
  - Prompt for bump type: major (1.x.0), minor (0.1.x), or patch (0.0.1)
  - Calculate and write new version to VERSION file
  - Update CHANGELOG.md: rename "Next version" header to new version with date
  - Add fresh "Next version" placeholder section to CHANGELOG.md
  - Create git tag
  - Create GitHub release via `gh release create`
- **BREAKING**: Remove Rakefile (Ruby no longer required for releases)

## Capabilities

### New Capabilities
- `version-file`: Single source of truth VERSION file read by Lua at runtime
- `release-workflow`: Bash script for complete release automation

### Modified Capabilities
- `lua-module-structure`: Version module reads from file instead of returning hardcoded string

## Impact

- `VERSION`: New file at project root
- `lua/linny/version.lua`: Modified to read from VERSION file
- `scripts/release.sh`: New release automation script
- `Rakefile`: Deleted
- `CHANGELOG.md`: Format unchanged, automated updates during release
- `tests/linny_spec.lua`: Verify version is read correctly from VERSION file
