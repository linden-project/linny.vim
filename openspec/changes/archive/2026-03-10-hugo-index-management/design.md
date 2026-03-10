## Context

Linny uses Hugo to generate a search index from notebook content. Currently, users must manually run `hugo --source /path/to/notebook` in a terminal. The refresh action (R key) in menu views calls `linny#make_index()` which reads the pre-built index but doesn't trigger Hugo.

Existing patterns:
- Lua modules in `lua/linny/` follow a table-based module pattern
- Health checks are in `lua/linny/health.lua` with `validate()` and `check()` functions
- External commands are run via `vim.fn.system()` or `vim.fn.jobstart()`
- The refresh flow is: `M.refresh()` → `linny#Init()` → `linny#make_index()` → `linny_menu#openandshow()`

## Goals / Non-Goals

**Goals:**
- Detect Hugo availability and version at health check time
- Provide a Lua function to run Hugo with correct `--source` option
- Integrate index rebuild into the R key refresh flow
- Gracefully degrade when Hugo is unavailable
- Enable unit testing with a mock notebook fixture

**Non-Goals:**
- Running Hugo in the background / async (keep it simple for now)
- Minimum Hugo version enforcement
- Managing Hugo installation
- Watching for file changes (on-demand only)

## Decisions

### Decision 1: New `lua/linny/hugo.lua` module

Create a dedicated module rather than adding to health.lua or fs.lua.

**Rationale:** Hugo integration is a distinct concern with its own detection, execution, and error handling logic. Keeping it separate makes testing easier and follows the existing single-responsibility pattern.

**Alternatives considered:**
- Add to `health.lua` — rejected because health.lua is for validation, not command execution
- Add to `fs.lua` — rejected because fs.lua is for filesystem operations, not external tools

### Decision 2: Use `vim.fn.system()` for synchronous execution

Run Hugo synchronously rather than async with `jobstart()`.

**Rationale:** Index rebuild is a user-initiated action (R key) where the user expects to wait. Async would add complexity for minimal UX benefit. Hugo typically runs in <1 second for personal notebooks.

**Alternatives considered:**
- `vim.fn.jobstart()` with callback — rejected for added complexity
- `vim.loop.spawn()` — rejected, same reason

### Decision 3: Hugo CLI options

Use `hugo --source <notebook_path>` to set the notebook as Hugo's working directory.

**Rationale:** The `--source` flag is Hugo's standard way to specify the site root. This is simpler than `cd notebook && hugo` and avoids shell escaping issues.

### Decision 4: Cache detection result in module state

Cache the Hugo detection result in module-local state, refresh on explicit request.

**Rationale:** Avoids repeated `hugo version` calls on every index rebuild. Detection happens once at health check or first use.

**Alternatives considered:**
- Global variable `g:linny_hugo_available` — rejected to keep Lua state in Lua
- No caching (detect every time) — rejected for performance

### Decision 5: Hook into refresh at `window.refresh()`

Modify `lua/linny/menu/window.lua:refresh()` to call Hugo before the existing flow.

**Rationale:** This is the single entry point for R key refresh. Adding the Hugo call here ensures all refresh paths go through index rebuild.

### Decision 6: Mock notebook in `tests/fixtures/mock-notebook/`

Create a minimal Hugo-compatible notebook structure for testing.

**Rationale:** Tests need a real notebook structure without depending on user's actual notebook. The mock notebook can be committed and provides reproducible test conditions.

**Structure:**
```
tests/fixtures/mock-notebook/
├── hugo.yaml           # Minimal Hugo config
├── content/
│   └── sample.md       # Sample content with frontmatter
├── lindenConfig/
└── lindenIndex/
```

## Risks / Trade-offs

**Synchronous execution blocks UI** → Acceptable for personal notebooks; async can be added later if needed.

**Hugo version parsing may break** → Use permissive regex that extracts first version-like pattern; fail gracefully if parsing fails.

**Mock notebook may diverge from real structure** → Keep mock minimal; document required files.

**No minimum version check** → Hugo's CLI is stable; version is informational only for now.
