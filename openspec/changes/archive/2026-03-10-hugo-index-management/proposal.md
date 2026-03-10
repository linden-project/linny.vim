## Why

Linny relies on Hugo to build the search index for the notebook. Currently, users must manually run Hugo outside of Vim, which breaks the workflow and requires knowledge of Hugo's command-line options. Linny should manage Hugo internally to keep the index fresh automatically.

## What Changes

- Add Hugo availability and version check to the health check system
- Create a dedicated Lua module for Hugo execution with proper notebook root configuration
- Automatically trigger index rebuild before the R key (refresh) action in views
- Validate notebook state before allowing index operations
- Determine and document the correct Hugo CLI options for using the notebook as root
- Add a mockup notebook directory structure for unit testing Hugo integration

## Capabilities

### New Capabilities
- `hugo-integration`: Manages Hugo executable detection, version checking, command execution with proper notebook root options, and index rebuild triggering from within Linny
- `hugo-test-fixtures`: Mockup notebook directory structure for unit testing Hugo-related functionality

### Modified Capabilities
- `startup-health-check`: Add Hugo executable availability and version validation to the health check system

## Impact

- **Code**: New `lua/linny/hugo.lua` module; modifications to `lua/linny/health.lua`
- **Tests**: New `tests/fixtures/mock-notebook/` directory with minimal Hugo-compatible structure
- **Dependencies**: Hugo must be installed on the system (soft dependency - Linny works without it but index features are disabled)
- **Views**: R key behavior in menu views will trigger index rebuild
- **User experience**: Users no longer need to manually run Hugo; health check warns if Hugo is missing
