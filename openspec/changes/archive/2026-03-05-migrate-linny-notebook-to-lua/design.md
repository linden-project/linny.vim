## Context

Current state:
- `autoload/linny_notebook.vim` contains 2 functions: `init()` and `open()`
- `init()` sets 3 global path variables based on `g:linny_open_notebook_path`
- `open()` prompts for a path (or accepts argument), validates it, sets the notebook path, and calls `linny#Init()` + `linny_menu#start()`
- Called from `autoload/linny.vim` (init) and `plugin/linny.vim` (LinnyOpenNotebook command)

## Goals / Non-Goals

**Goals:**
- Migrate both notebook functions to Lua
- Keep the command and callers working
- Add unit tests for testable functions

**Non-Goals:**
- Migrating `linny#Init()` or `linny_menu#start()` (separate changes)
- Changing the notebook API

## Decisions

### 1. Lua function implementations

```lua
-- init: set up global path variables
function M.init()
  local base = vim.fn.expand(vim.g.linny_open_notebook_path)
  vim.g.linny_path_wiki_content = base .. '/content'
  vim.g.linny_path_wiki_config = base .. '/lindenConfig'
  vim.g.linny_index_path = base .. '/lindenIndex'
end

-- open: open a notebook by path
function M.open(path)
  -- If no path provided, prompt for it
  if not path or path == '' then
    vim.fn.inputsave()
    path = vim.fn.input('Enter path to notebook: ')
    vim.fn.inputrestore()
  end

  if path == '' then
    return false
  end

  vim.api.nvim_echo({{path, 'None'}}, false, {})

  local expanded = vim.fn.expand(path)
  if vim.fn.isdirectory(expanded) == 1 then
    vim.g.linny_open_notebook_path = expanded
    vim.fn['linny#Init']()
    vim.fn['linny_menu#start']()
    return true
  else
    vim.api.nvim_echo({{'ERR: ' .. path .. ' does not exist', 'ErrorMsg'}}, true, {})
    return false
  end
end
```

### 2. Update callers directly to Lua

Since there are only 2 call sites, we'll update them to use `luaeval()` directly:

**In `autoload/linny.vim`:**
```vim
call luaeval("require('linny.notebook').init()")
```

**In `plugin/linny.vim`:**
```vim
command! -nargs=? LinnyOpenNotebook :call luaeval("require('linny.notebook').open(_A)", <q-args>)
```

**Rationale**: No wrapper functions needed since callers can be updated directly.

### 3. Use `vim.fn['function_name']()` for Vimscript callbacks

For calling `linny#Init()` and `linny_menu#start()`, use `vim.fn['linny#Init']()`.

**Rationale**: Standard Neovim way to call autoload functions from Lua.

## Risks / Trade-offs

**[Vimscript dependencies]** → `open()` depends on `linny#Init()` and `linny_menu#start()`. This will be resolved when those modules are migrated.

**[Input handling]** → `vim.fn.input()` works the same as Vimscript `input()`. No issues expected.
