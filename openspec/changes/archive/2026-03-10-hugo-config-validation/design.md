## Context

The `hugo-index-management` change introduces Hugo detection and index building. This change extends that foundation to validate the notebook's Hugo configuration, ensuring Linny's required settings are present before attempting to build indexes.

Hugo provides `hugo config --format json` to output the fully resolved configuration, which we can parse and validate against Linny's requirements.

## Goals / Non-Goals

**Goals:**
- Parse Hugo configuration via `hugo config --source <path> --format json`
- Validate directory settings match Linny conventions
- Validate required output formats and outputs exist
- Integrate validation into health check system
- Provide actionable error messages referencing the notebook template

**Non-Goals:**
- Fixing configuration automatically
- Supporting alternative directory layouts
- Validating Hugo theme or template files
- Deep validation of output format properties (just check existence)

## Decisions

### Decision 1: Use `hugo config --format json` for parsing

Parse configuration by running `hugo config --source <path> --format json` and decoding the JSON output.

**Rationale:** Hugo's own config command handles all config file formats (yaml, toml, json), config merging, and environment resolution. We get the fully resolved configuration without reimplementing Hugo's config logic.

**Alternatives considered:**
- Parse config files directly with Lua — rejected because Hugo supports multiple formats, config directories, and environment overrides
- Use `hugo config --format toml` — rejected because JSON is easier to parse in Lua

### Decision 2: Extend `lua/linny/hugo.lua` module

Add validation functions to the existing hugo.lua module rather than creating a separate module.

**Rationale:** Config validation is closely related to Hugo execution. Keeping it in one module simplifies imports and maintains cohesion.

### Decision 3: Separate `get_config()` and `validate_config()` functions

Split retrieval and validation into separate functions for testability.

**Rationale:** `validate_config()` can be tested with mock config tables without running Hugo. `get_config()` handles the external command execution.

### Decision 4: Store required values as module constants

Define required directories and output formats as constants at the top of the module.

```lua
local REQUIRED_DIRS = {
  contentDir = "content",
  dataDir = "lindenConfig",
  publishDir = "lindenIndex",
}

local REQUIRED_OUTPUT_FORMATS = {
  "starred", "docs_with_props", "docs_with_title",
  "indexer_info", "taxonomies", "taxonomies_starred", "terms_starred"
}
```

**Rationale:** Makes requirements explicit and easy to update. Constants are self-documenting.

### Decision 5: Return structured validation results

Return `{ok, errors, warnings}` from validation functions.

**Rationale:** Distinguishes between blocking errors (wrong directory) and warnings (missing optional format). Health check can display appropriately.

### Decision 6: Cache config validation result

Cache the validation result alongside the detection result in module state.

**Rationale:** Avoids repeated `hugo config` calls. Config doesn't change during a session unless the user edits files externally.

**Cache invalidation:** Provide `clear_cache()` function for manual refresh if needed.

## Risks / Trade-offs

**Hugo config command may be slow** → Acceptable since validation only runs at health check time, not on every index build.

**JSON parsing errors** → Use pcall around vim.fn.json_decode; return parse error if JSON is malformed.

**Config key casing may vary** → Hugo uses camelCase consistently; test with actual Hugo output.

**Output format names are case-sensitive** → Match exactly as Hugo reports them in the JSON output.
