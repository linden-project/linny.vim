## 1. Create Lua Module

- [x] 1.1 Create `lua/linny/menu/actions.lua` with module structure
- [x] 1.2 Implement `job_start(command)` function
- [x] 1.3 Implement `build_dropdown_views(item)` function
- [x] 1.4 Implement `exec_content_menu(action, item)` function

## 2. Module Integration

- [x] 2.1 Update `lua/linny/menu/init.lua` to export actions submodule

## 3. Update VimScript Callers

- [x] 3.1 Update `autoload/linny_menu_actions.vim` to use Lua for job_start
- [x] 3.2 Update `autoload/linny_menu_actions.vim` to use Lua for build_dropdown_views
- [x] 3.3 Update `autoload/linny_menu_actions.vim` to use Lua for exec_content_menu

## 4. Cleanup

- [x] 4.1 Remove migrated helper functions from `autoload/linny_menu_actions.vim`

## 5. Testing

- [x] 5.1 Create `tests/menu_actions_spec.lua` with unit tests
- [x] 5.2 Run test suite and verify all tests pass
