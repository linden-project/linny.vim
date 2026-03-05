## Context

Current state:
- `autoload/linny_util.vim` contains one function: `linny_util#initVariable(var, value)`
- Function sets a global variable to a default value only if it doesn't already exist
- Called 17 times in `autoload/linny.vim` to initialize configuration defaults
- Allows users to override defaults by setting variables in their vimrc before plugin loads

## Goals / Non-Goals

**Goals:**
- Migrate `initVariable` function to Lua
- Maintain exact same behavior (set default only if not already set)
- Add unit tests for the new Lua implementation
- Update all Vimscript callers to use Lua via `luaeval()`

**Non-Goals:**
- Changing the configuration variable names
- Migrating the callers in `autoload/linny.vim` to Lua (that's a separate change)

## Decisions

### 1. Use `vim.g` for global variable access

```lua
function M.init_variable(var_name, default_value)
  local name = var_name:gsub("^g:", "")
  if vim.g[name] == nil then
    vim.g[name] = default_value
    return true
  end
  return false
end
```

**Rationale**: `vim.g` is the idiomatic Lua way to access global variables in Neovim. It handles the `g:` prefix automatically when we strip it.

**Alternative considered**: Using `vim.api.nvim_get_var/nvim_set_var` - more verbose, no benefit.

### 2. Strip `g:` prefix in Lua function

Callers pass `"g:varname"` (Vimscript convention). The Lua function strips the prefix to use with `vim.g`.

**Rationale**: Keeps caller syntax unchanged, making migration simpler.

### 3. Return boolean instead of 0/1

Lua function returns `true`/`false` instead of `1`/`0`.

**Rationale**: Idiomatic Lua. Vimscript callers don't use the return value anyway.

### 4. Caller syntax with `luaeval()` and `_A`

```vim
call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linnycfg_path_index", "~/.linny_temp/index"])
```

**Rationale**: `_A` allows passing arguments as a Vim list, cleaner than string concatenation.

## Risks / Trade-offs

**[Neovim-only]** → `vim.g` requires Neovim. Acceptable as plugin already uses Lua modules.

**[Verbose caller syntax]** → `luaeval()` calls are longer than Vimscript. Mitigated: This is temporary until `autoload/linny.vim` itself is migrated to Lua.
