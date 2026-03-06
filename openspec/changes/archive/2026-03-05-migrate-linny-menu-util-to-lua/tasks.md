## 1. Create Lua module

- [x] 1.1 Create `lua/linny/menu/util.lua` with all utility functions
- [x] 1.2 Update `lua/linny/menu/init.lua` to export util submodule

## 2. Update callers to use Lua

- [x] 2.1 Update `autoload/linny_menu.vim` calls to use luaeval (4 calls)
- [x] 2.2 Update `autoload/linny_menu_render.vim` calls to use luaeval (5 calls)
- [x] 2.3 Update `autoload/linny_menu_items.vim` calls to use luaeval (2 calls)
- [x] 2.4 Update `autoload/linny_menu_documents.vim` calls to use luaeval (3 calls)

## 3. Testing

- [x] 3.1 Create `tests/menu_util_spec.lua` with unit tests
- [x] 3.2 Run all tests and verify they pass

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_util.vim`
- [x] 4.2 Run all tests to verify deletion didn't break anything
