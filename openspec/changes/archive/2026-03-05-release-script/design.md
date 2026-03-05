## Context

Current state:
- Version is hardcoded in `lua/linny/version.lua` as `return '0.8.0'`
- Rakefile uses grep/sed to find and update version strings
- CHANGELOG.md has "Next version" section that needs manual updating during release

The release process requires Ruby (for Rake) and fragile text parsing.

## Goals / Non-Goals

**Goals:**
- Single source of truth for version in plain text `VERSION` file
- Lua reads version at runtime from file
- Bash script automates complete release workflow
- No Ruby dependency for releases

**Non-Goals:**
- Automated CI/CD release triggers (manual script execution)
- Backward compatibility with Rakefile
- Supporting Vim (Neovim-only due to Lua file reading)

## Decisions

### 1. VERSION file format: plain text, single line

```
0.8.0
```

**Rationale**: Simplest format - `cat VERSION` in bash, `io.open()` in Lua. No parsing needed.

**Alternative considered**: JSON or TOML - rejected as overkill for a single value.

### 2. Lua reads VERSION file relative to plugin root

```lua
local function get_plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(source, ":h:h:h")
end

local function read_version()
  local root = get_plugin_root()
  local f = io.open(root .. "/VERSION", "r")
  if f then
    local version = f:read("*l")
    f:close()
    return version
  end
  return "unknown"
end
```

**Rationale**: Uses `debug.getinfo` to find script location, then navigates up to plugin root. This works regardless of where Neovim is launched from.

**Alternative considered**: Hardcode path or use runtimepath search - rejected as less reliable.

### 3. Release script location: `scripts/release.sh`

**Rationale**: Follows common convention of `scripts/` directory for tooling. Keeps root directory clean.

### 4. Version bump uses semantic versioning calculation

Script parses current version `X.Y.Z` and increments based on user choice:
- major: `X+1.0.0`
- minor: `X.Y+1.0`
- patch: `X.Y.Z+1`

**Rationale**: Standard semver behavior. Pure bash arithmetic with IFS parsing.

### 5. CHANGELOG update uses sed with date

Pattern: Replace `## Next version` with `## X.Y.Z - DD mon YYYY`

Then prepend new `## Next version` section.

**Rationale**: sed is portable and handles this simple replacement well.

### 6. GitHub release extracts changelog section for body

Script extracts content between `## X.Y.Z` and next `##` header for release notes.

**Rationale**: Reuses existing changelog content, single source of truth.

## Risks / Trade-offs

**[Neovim-only]** → Lua file I/O requires Neovim. Acceptable as project already uses Lua modules.

**[VERSION file could be missing]** → Lua returns "unknown" as fallback. Acceptable for development.

**[gh CLI required]** → Script requires `gh` for GitHub release. Mitigated: clear error message if not installed.
