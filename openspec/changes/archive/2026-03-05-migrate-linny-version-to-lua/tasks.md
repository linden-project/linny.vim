## 1. Create Lua Module Structure

- [x] 1.1 Create `lua/linny/version.lua` with `plugin_version()` function returning `'0.8.0'`
- [x] 1.2 Create `lua/linny/init.lua` that exports the version submodule

## 2. Update Callers

- [x] 2.1 Update `autoload/linny_menu.vim:903` to use `luaeval("require('linny.version').plugin_version()")` instead of `linny_version#PluginVersion()`
- [x] 2.2 Update `tests/linny_spec.lua:13` to use `require('linny.version').plugin_version()` directly
- [x] 2.3 Update `Rakefile:33-36` to grep version from `lua/linny/version.lua` instead of `autoload/linny_version.vim`

## 3. Cleanup and Verification

- [x] 3.1 Delete `autoload/linny_version.vim`
- [x] 3.2 Run tests to verify version function works: `nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"`
