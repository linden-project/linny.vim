## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/window.lua` with module structure
- [x] 1.2 Implement `exist()` function
- [x] 1.3 Implement `close_window()` function
- [x] 1.4 Implement `open_window(size)` function
- [x] 1.5 Implement `render(items)` function
- [x] 1.6 Implement `start()` function
- [x] 1.7 Implement `open()` function
- [x] 1.8 Implement `close()` function
- [x] 1.9 Implement `toggle()` function
- [x] 1.10 Implement `refresh()` function
- [x] 1.11 Implement `open_home()` function
- [x] 1.12 Implement `open_file(filepath)` function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export window submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu.vim` to use luaeval() for window calls
- [x] 3.2 Update `plugin/linny.vim` to use luaeval() for window calls (no calls found)

## 4. Cleanup

- [x] 4.1 Delete `autoload/linny_menu_window.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_window_spec.lua` with unit tests
- [x] 5.2 Run test suite and verify all tests pass
