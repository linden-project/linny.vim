## 1. Configuration Variable Setup

- [x] 1.1 Add `g:linny_hugo_hook_enabled` initialization in `autoload/linny.vim` (after line 20, following `g:linny_hugo_watch_enabled` pattern)
- [x] 1.2 Use `init_variable` pattern: `call luaeval("require('linny.util').init_variable(_A[1], _A[2])", ["g:linny_hugo_hook_enabled", 1])`

## 2. Refresh Function Modification

- [x] 2.1 Modify `M.refresh()` in `lua/linny/menu/window.lua` to check `vim.g.linny_hugo_hook_enabled`
- [x] 2.2 Add early return from Hugo block when `linny_hugo_hook_enabled == 0`
- [x] 2.3 Ensure check happens before any Hugo operations (detection, rebuild)

## 3. Verification

- [x] 3.1 Test with `g:linny_hugo_hook_enabled = 0`: R key should refresh without Hugo messages
- [x] 3.2 Test with `g:linny_hugo_hook_enabled = 1` (default): R key should behave as before
- [x] 3.3 Test independence from watch mode: confirm watch auto-start still works when hook is disabled
