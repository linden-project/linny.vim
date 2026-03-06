## 1. Create Lua module structure

- [x] 1.1 Create `lua/linny/menu/state.lua` with all state functions
- [x] 1.2 Create `lua/linny/menu/init.lua` to export menu submodules
- [x] 1.3 Update `lua/linny/init.lua` to export menu module

## 2. Update callers to use Lua

- [x] 2.1 Update `autoload/linny_menu.vim` calls to use luaeval
- [x] 2.2 Update `autoload/linny_menu_render.vim` calls to use luaeval
- [x] 2.3 Update `autoload/linny_menu_window.vim` calls to use luaeval
- [x] 2.4 Update `autoload/linny_menu_views.vim` calls to use luaeval

## 3. Testing

- [x] 3.1 Create `tests/menu_state_spec.lua` with unit tests
- [x] 3.2 Run all tests and verify they pass

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_state.vim`
- [x] 4.2 Run all tests to verify deletion didn't break anything
