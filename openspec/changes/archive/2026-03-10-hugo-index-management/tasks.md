## 1. Test Fixtures

- [x] 1.1 Create `tests/fixtures/mock-notebook/` directory structure
- [x] 1.2 Add `hugo.yaml` with minimal Hugo configuration
- [x] 1.3 Create `content/sample.md` with valid frontmatter
- [x] 1.4 Create empty `lindenConfig/` and `lindenIndex/` directories

## 2. Hugo Module Core

- [x] 2.1 Create `lua/linny/hugo.lua` with module table structure
- [x] 2.2 Implement `detect()` function to find Hugo and get version
- [x] 2.3 Implement version string parsing (extract semver from `hugo v0.155.3+extended...`)
- [x] 2.4 Add module-local caching for detection result

## 3. Hugo Build Function

- [x] 3.1 Implement `build_index(notebook_path)` function
- [x] 3.2 Add notebook path validation (nil/empty check, directory exists)
- [x] 3.3 Execute `hugo --source <notebook_path>` via `vim.fn.system()`
- [x] 3.4 Return structured result `{ok, output/error}`

## 4. Vimscript Integration

- [x] 4.1 Add `linny#hugo_rebuild_index()` function in `autoload/linny.vim`
- [x] 4.2 Call Lua module via luaeval with `g:linny_open_notebook_path`
- [x] 4.3 Display success/failure message to user

## 5. Health Check Integration

- [x] 5.1 Add Hugo detection to `lua/linny/health.lua:validate()`
- [x] 5.2 Add Hugo status to `:checkhealth linny` output in `check()`
- [x] 5.3 Report as WARN (not ERROR) when Hugo is missing

## 6. Refresh Integration

- [x] 6.1 Modify `lua/linny/menu/window.lua:refresh()` to call hugo module
- [x] 6.2 Add status message during index rebuild
- [x] 6.3 Ensure graceful degradation when Hugo unavailable (no error, just skip)

## 7. Tests

- [x] 7.1 Create `tests/hugo_spec.lua` with plenary test structure
- [x] 7.2 Test `detect()` with mock executable
- [x] 7.3 Test version parsing with various Hugo version strings
- [x] 7.4 Test `build_index()` validation (nil path, empty path, missing directory)
- [x] 7.5 Test `build_index()` with mock notebook fixture

## 8. Verification

- [x] 8.1 Run full test suite: `nvim --headless -c "PlenaryBustedDirectory tests/"`
- [x] 8.2 Manual test: `:checkhealth linny` shows Hugo status
- [x] 8.3 Manual test: R key in menu view triggers index rebuild
