## Context

Current state:
- `autoload/linny_wikitags.vim` contains 6 functions implementing wikitag actions
- Functions are registered in `plugin/linny.vim` via `linny#RegisterLinnyWikitag()`
- The registration system expects Vimscript function names as strings (e.g., `'linny_wikitags#file'`)
- The `linny` wikitag calls `linny_menu#openterm()` which remains in Vimscript

## Goals / Non-Goals

**Goals:**
- Migrate all wikitag implementations to Lua
- Keep the registration mechanism working (it expects function name strings)
- Add unit tests for testable functions

**Non-Goals:**
- Migrating `linny_menu#openterm()` (that's a separate, larger change)
- Changing the wikitag registration API

## Decisions

### 1. Create thin Vimscript wrappers for registration

Since `linny#RegisterLinnyWikitag()` expects Vimscript function names, we'll create wrapper functions that call Lua:

```vim
function! LinnyWikitag_file(innertag)
  call luaeval("require('linny.wikitags').file(_A)", a:innertag)
endfunction
```

Register as: `call linny#RegisterLinnyWikitag('FILE', 'LinnyWikitag_file', 'LinnyWikitag_file')`

**Rationale**: Minimal change to registration system. Wrappers are simple pass-throughs.

**Alternative considered**: Modify registration to accept Lua functions - too invasive for this change.

### 2. Place wrappers in `plugin/linny.vim`

Define the wrapper functions in `plugin/linny.vim` right before the registrations.

**Rationale**: Keeps wrappers close to their registration calls. No new files needed.

### 3. Lua function implementations

```lua
-- file: open with file manager
function M.file(innertag)
  local fs = require('linny.fs')
  fs.os_open_with_filemanager(vim.fn.expand(innertag))
end

-- mkdir_if_not_exist: create directory if needed
function M.mkdir_if_not_exist(innertag)
  local path = vim.fn.expand(innertag)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.fn.mkdir(path, "p")
  end
end

-- dir1st: create dir and open with file manager
function M.dir1st(innertag)
  M.mkdir_if_not_exist(innertag)
  local fs = require('linny.fs')
  fs.os_open_with_filemanager(vim.fn.expand(innertag))
end

-- dir2nd: create dir and open in NERDTree
function M.dir2nd(innertag)
  M.mkdir_if_not_exist(innertag)
  local path = vim.fn.expand(innertag)
  if vim.fn.exists(":NERDTree") == 2 then
    vim.cmd('NERDTree ' .. vim.fn.fnameescape(path))
  end
end

-- shell: execute shell command
function M.shell(innertag)
  vim.cmd('!' .. innertag)
end

-- linny: open menu term (calls back to Vimscript)
function M.linny(innertag)
  if innertag:find(":") then
    local parts = vim.split(innertag, ":")
    if #parts == 2 then
      vim.fn['linny_menu#openterm'](parts[1], vim.trim(parts[2]))
    else
      vim.api.nvim_echo({{"Invalid Wikitag", "ErrorMsg"}}, false, {})
    end
  else
    vim.fn['linny_menu#openterm'](vim.trim(innertag), '')
  end
end

-- vim_cmd: execute vim command
function M.vim_cmd(innertag)
  vim.api.nvim_echo({{"!" .. innertag, "None"}}, false, {})
  vim.cmd(innertag)
end
```

### 4. Use `vim.fn['function_name']()` for Vimscript callbacks

For calling `linny_menu#openterm()`, use `vim.fn['linny_menu#openterm'](...)`.

**Rationale**: Standard Neovim way to call autoload functions from Lua.

## Risks / Trade-offs

**[Wrapper indirection]** → Adds one function call layer. Acceptable: negligible performance impact.

**[linny_menu dependency]** → `linny` wikitag still depends on Vimscript `linny_menu#openterm()`. This will be resolved when that module is migrated.
