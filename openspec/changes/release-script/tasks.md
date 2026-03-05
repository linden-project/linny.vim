## 1. VERSION File Setup

- [x] 1.1 Create `VERSION` file at project root with content `0.8.0`
- [x] 1.2 Update `lua/linny/version.lua` to read version from VERSION file using `debug.getinfo` for path resolution
- [x] 1.3 Update `tests/linny_spec.lua` to verify version matches VERSION file content

## 2. Release Script

- [x] 2.1 Create `scripts/release.sh` with executable permissions
- [x] 2.2 Implement gh CLI availability check (exit early if not installed)
- [x] 2.3 Implement interactive version bump selection (major/minor/patch)
- [x] 2.4 Implement semver calculation and VERSION file update
- [x] 2.5 Implement CHANGELOG.md update (replace "Next version" header, add new placeholder)
- [x] 2.6 Implement git tag creation (`vX.Y.Z`)
- [x] 2.7 Implement GitHub release creation with changelog body extraction

## 3. Cleanup and Verification

- [x] 3.1 Delete `Rakefile`
- [x] 3.2 Run tests to verify version reading works: `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`
- [x] 3.3 Manually test release script with `--dry-run` flag (if implemented) or verify each step
