## Context

Linny.vim currently has fragile startup behavior. The plugin defines commands at load time that assume `linny#Init()` has been called, but Init is not automatically invoked. Lua modules like `paths.lua` concatenate `vim.g.linny_index_path` without nil checks, causing hard crashes. The `linny#fatal_check_dir()` function echoes warnings but doesn't stop execution, leaving the plugin in a broken state.

Users with a fresh installation see cryptic Lua errors like `attempt to concatenate nil value` when running `:LinnyStart`.

## Goals / Non-Goals

**Goals:**
- Prevent crashes from nil path variables in Lua modules
- Track initialization state so commands can fail gracefully
- Provide clear error messages directing users to the notebook template
- Fix fatal checks to actually halt on fatal errors

**Non-Goals:**
- Building an interactive setup wizard (separate change)
- Auto-creating notebook directories
- Changing the notebook structure or configuration format

## Decisions

### Decision 1: Initialization state flag

Add `g:linny_initialized` (boolean, default 0) set to 1 only after successful Init.

**Rationale**: Simple, testable, and allows commands to check state before executing. Alternatives considered:
- Function `linny#is_initialized()` - more overhead, no benefit over a flag
- Exception-based flow - Vimscript try/catch is awkward and less readable

### Decision 2: Nil guards in Lua path functions

Wrap path concatenations in `lua/linny/paths.lua` with nil checks that return nil or raise a clear error.

```lua
function M.l1_index_filepath(tax)
  local base = vim.g.linny_index_path
  if not base then return nil end
  return base .. '/' .. tax .. '/index.json'
end
```

**Rationale**: Fail fast with clear context rather than cryptic Lua errors. Callers already handle nil returns from file operations.

### Decision 3: Unified health check in Lua

Implement all health check logic in `lua/linny/health.lua` with two public functions:
1. `M.validate()` - Core validation, returns `{ok = bool, errors = {...}}`
2. `M.check()` - Neovim `:checkhealth` integration, calls validate() internally

The Vimscript `linny#health_check()` becomes a thin wrapper:

```vim
function! linny#health_check()
  return luaeval("require('linny.health').validate()")
endfunction
```

The Lua module:

```lua
local M = {}

-- Core validation logic (single source of truth)
function M.validate()
  local result = { ok = true, errors = {} }

  local notebook_path = vim.g.linny_open_notebook_path
  if not notebook_path or notebook_path == "" then
    result.ok = false
    table.insert(result.errors, "Notebook path not configured")
    return result
  end

  local base = vim.fn.expand(notebook_path)
  if vim.fn.isdirectory(base) == 0 then
    result.ok = false
    table.insert(result.errors, "Notebook directory does not exist: " .. base)
    return result
  end

  for _, subdir in ipairs({"content", "lindenConfig", "lindenIndex"}) do
    local path = base .. "/" .. subdir
    if vim.fn.isdirectory(path) == 0 then
      table.insert(result.errors, "Missing directory: " .. subdir)
      result.ok = false
    end
  end

  return result
end

-- Neovim :checkhealth integration
function M.check()
  vim.health.start("linny.vim")

  local notebook_path = vim.g.linny_open_notebook_path
  if not notebook_path or notebook_path == "" then
    vim.health.error("Notebook path not configured", {
      "Set g:linny_open_notebook_path in your config",
      "Get started: https://github.com/linden-project/linny-notebook-template"
    })
    return
  end

  local base = vim.fn.expand(notebook_path)
  if vim.fn.isdirectory(base) == 0 then
    vim.health.error("Notebook directory does not exist: " .. base)
    return
  end

  vim.health.ok("Notebook configured: " .. base)

  for _, subdir in ipairs({"content", "lindenConfig", "lindenIndex"}) do
    local path = base .. "/" .. subdir
    if vim.fn.isdirectory(path) == 1 then
      vim.health.ok(subdir .. " directory exists")
    else
      vim.health.warn(subdir .. " directory missing: " .. path)
    end
  end

  if vim.g.linny_initialized == 1 then
    vim.health.ok("Plugin initialized")
  else
    vim.health.warn("Plugin not initialized - call linny#Init()")
  end
end

return M
```

**Rationale**: Single source of truth for validation logic. Avoids duplicate code between Vimscript and Lua. The `validate()` function is reusable programmatically, while `check()` provides the standard Neovim `:checkhealth` UX.

**Alternatives considered**:
- Separate Vimscript implementation - rejected due to code duplication
- Lua-only without Vimscript wrapper - rejected for Vim compatibility

### Decision 4: Fix fatal_check_dir to return error state

Change `linny#fatal_check_dir(path)` to return 0 on failure, 1 on success. Callers must check return value.

```vim
function! linny#fatal_check_dir(path)
  if !isdirectory(a:path)
    echohl ErrorMsg
    echom "Linny: Required directory does not exist: " . a:path
    echohl None
    return 0
  endif
  return 1
endfunction
```

**Rationale**: Allows callers to halt execution. Keeps backward compatibility (existing callers that ignore return value continue to work, just with warnings).

### Decision 5: Command guards with helpful message

Commands check `g:linny_initialized` and show setup instructions if not initialized:

```vim
if !get(g:, 'linny_initialized', 0)
  echohl WarningMsg
  echo "Linny not initialized. Set g:linny_open_notebook_path and call linny#Init()"
  echo "Get started: https://github.com/linden-project/linny-notebook-template"
  echohl None
  return
endif
```

**Rationale**: User sees actionable guidance instead of a crash.

## Risks / Trade-offs

**Risk**: Existing users with working setups see no change, but edge cases in their config might now surface warnings they didn't see before.
→ **Mitigation**: Warnings are informative, not breaking. Actual behavior unchanged for valid configs.

**Risk**: Adding guards to every command is repetitive.
→ **Mitigation**: Create `linny#require_init()` helper that commands call, centralizing the check and message.

**Risk**: Nil guards in Lua paths change return type semantics (some functions now return nil).
→ **Mitigation**: Document the change. Most callers already check for file existence before using paths.
