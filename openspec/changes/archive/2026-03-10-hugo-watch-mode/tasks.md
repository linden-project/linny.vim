## 1. Watch Process State

- [x] 1.1 Add `_watch_job_id` module-local variable to `lua/linny/hugo.lua`
- [x] 1.2 Add `_watch_started` flag to track if auto-start has occurred this session

## 2. Core Watch Functions

- [x] 2.1 Implement `start_watch(notebook_path)` in `lua/linny/hugo.lua`
- [x] 2.2 Use `vim.fn.jobstart()` with `hugo --source <path> --watch`
- [x] 2.3 Store job ID in `_watch_job_id` on successful start
- [x] 2.4 Return `{ok, job_id}` or `{ok=false, error}` structure
- [x] 2.5 Implement `stop_watch()` using `vim.fn.jobstop(_watch_job_id)`
- [x] 2.6 Implement `is_watching()` returning boolean based on `_watch_job_id`
- [x] 2.7 Add job exit callback to clear `_watch_job_id` when Hugo exits

## 3. Process Cleanup

- [x] 3.1 Register `VimLeavePre` autocmd in hugo.lua to call `stop_watch()`
- [x] 3.2 Ensure cleanup runs even if watch was started manually

## 4. R Key Modification

- [x] 4.1 Modify `lua/linny/menu/window.lua:refresh()` to check `hugo.is_watching()`
- [x] 4.2 Skip `build_index()` call when `is_watching()` returns true
- [x] 4.3 Still refresh menu view regardless of watch status

## 5. Auto-Start on Menu Open

- [x] 5.1 Add check for `g:linny_hugo_watch_enabled` in menu open logic
- [x] 5.2 Check `_watch_started` flag to only auto-start once per session
- [x] 5.3 Call `start_watch()` on first LinnyMenu open if enabled
- [x] 5.4 Set `_watch_started = true` after first attempt (regardless of success)

## 6. Status Display

- [x] 6.1 Add `get_watch_status()` function returning `"watching"` or `"stopped"`
- [x] 6.2 Modify menu footer rendering to include `[Hugo: <status>]`
- [x] 6.3 Locate footer rendering in `autoload/linny_menu.vim` or Lua equivalent

## 7. Vimscript Commands

- [x] 7.1 Add `linny#hugo_start_watch()` function to `autoload/linny.vim`
- [x] 7.2 Add `linny#hugo_stop_watch()` function to `autoload/linny.vim`
- [x] 7.3 Register `:LinnyHugoWatch` command in `plugin/linny.vim`
- [x] 7.4 Register `:LinnyHugoStop` command in `plugin/linny.vim`
- [x] 7.5 Display success/error messages from commands

## 8. Configuration

- [x] 8.1 Document `g:linny_hugo_watch_enabled` option (default 0)
- [x] 8.2 Use `get(g:, 'linny_hugo_watch_enabled', 0)` for safe access

## 9. Tests

- [x] 9.1 Add `start_watch()` tests to `tests/hugo_spec.lua`
- [x] 9.2 Add `stop_watch()` tests
- [x] 9.3 Add `is_watching()` tests
- [x] 9.4 Test R key behavior when watching vs not watching

## 10. Verification

- [x] 10.1 Run test suite: `nvim --headless -c "PlenaryBustedDirectory tests/"`
- [x] 10.2 Manual test: Enable watch, edit file, verify index rebuilds
- [x] 10.3 Manual test: Verify `:LinnyHugoWatch` and `:LinnyHugoStop` commands
- [x] 10.4 Manual test: Verify status shows in menu footer
- [x] 10.5 Manual test: Exit Neovim, verify no orphan Hugo process
