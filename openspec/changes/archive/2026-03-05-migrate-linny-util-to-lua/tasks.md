## 1. Create Lua Util Module

- [x] 1.1 Create `lua/linny/util.lua` with `init_variable()` function
- [x] 1.2 Update `lua/linny/init.lua` to export util submodule

## 2. Add Unit Tests

- [x] 2.1 Create `tests/util_spec.lua` with test for variable not set (uses default)
- [x] 2.2 Add test for variable already set (preserves existing value)
- [x] 2.3 Add test for numeric values
- [x] 2.4 Add test for module requireable

## 3. Update Callers

- [x] 3.1 Update `autoload/linny.vim` lines 12-41: replace all `linny_util#initVariable` calls with `luaeval()`

## 4. Cleanup and Verification

- [x] 4.1 Delete `autoload/linny_util.vim`
- [x] 4.2 Run all tests: `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`
