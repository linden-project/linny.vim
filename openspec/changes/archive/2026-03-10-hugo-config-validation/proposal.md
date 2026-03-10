## Why

When Hugo is available but the notebook's Hugo configuration is incorrect or incomplete, Linny will fail silently or produce incorrect index files. Users need clear feedback about which required settings are missing or misconfigured, rather than debugging cryptic Hugo errors or missing menu items.

## What Changes

- Add Hugo configuration validation using `hugo config` command to parse the notebook's configuration
- Validate essential directory settings: `contentDir`, `dataDir`, `publishDir`
- Validate required taxonomies exist (at least one)
- Validate required output formats are defined for Linny's index files
- Validate outputs configuration for home, pages, terms, and taxonomies
- Integrate validation into health check with detailed error messages

## Capabilities

### New Capabilities
- `hugo-config-validation`: Validates Hugo configuration of the notebook against Linny's requirements using `hugo config` command output

### Modified Capabilities
- `startup-health-check`: Add Hugo configuration validation to health check (beyond just Hugo availability)

## Impact

- **Code**: Extensions to `lua/linny/hugo.lua` module; modifications to `lua/linny/health.lua`
- **Dependencies**: Requires Hugo to be available (validation skipped if Hugo missing)
- **User experience**: Health check provides actionable feedback about misconfigured notebooks
- **Reference**: Configuration requirements based on https://github.com/linden-project/linny-notebook-template
