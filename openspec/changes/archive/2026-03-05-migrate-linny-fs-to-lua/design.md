## Context

Current state:
- `autoload/linny_fs.vim` contains 2 public functions and 1 private helper
- `dir_create_if_path_not_exist(path)` - creates directory if it doesn't exist
- `os_open_with_filemanager(path)` - opens path with system file manager (xdg-open on Linux, open on macOS)
- Uses async jobs via `jobstart()` (Neovim) or `job_start()` (Vim)
- Called from `linny_menu.vim` and `linny_wikitags.vim`

## Goals / Non-Goals

**Goals:**
- Migrate both file system functions to Lua
- Use Neovim's `vim.fn.jobstart()` for async execution
- Detect OS to choose correct file manager command
- Add unit tests

**Non-Goals:**
- Vim compatibility (Neovim-only, as established)
- Synchronous fallback (async is fine)

## Decisions

### 1. Use `vim.fn.mkdir()` for directory creation

```lua
function M.dir_create_if_not_exist(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end
```

**Rationale**: `vim.fn.mkdir()` with "p" flag is synchronous and creates parent directories. Simpler than spawning a shell process. The original used async `mkdir -p` but synchronous is fine for this use case.

**Alternative considered**: Keep async with `vim.fn.jobstart({"mkdir", "-p", path})` - unnecessary complexity for fast local operation.

### 2. Use `vim.fn.jobstart()` for file manager

```lua
function M.os_open_with_filemanager(path)
  local cmd = vim.fn.has("unix") == 1 and "xdg-open" or "open"
  vim.fn.jobstart({cmd, path}, {detach = true})
end
```

**Rationale**: File manager needs to be async and detached so it doesn't block Neovim. `{detach = true}` ensures the process survives if Neovim exits.

### 3. Use `vim.fn.has("unix")` for OS detection

**Rationale**: Same check as original Vimscript. Linux/BSD use `xdg-open`, macOS uses `open`.

## Risks / Trade-offs

**[Synchronous mkdir]** → Changed from async to sync. Acceptable: mkdir is fast, sync is simpler.

**[No Windows support]** → Original didn't support Windows either. Out of scope.
