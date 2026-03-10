## Why

The menu commands (`LinnyMenuOpen`, `LinnyMenuClose`, `LinnyMenuToggle`, `LinnyStart`) have unclear responsibilities. Some contain duplicate logic, and the distinction between "open" and "start" is ambiguous. This makes the code harder to maintain and behavior inconsistent.

## What Changes

- `LinnyMenuOpen`: Opens menu in the last opened state (restores previous view/taxonomy/term)
- `LinnyMenuClose`: Closes menu, preserving state for next open
- `LinnyMenuToggle`: Delegates to Open or Close based on current state (no logic of its own)
- `LinnyStart`: Opens menu in start position (root view), resets state

## Capabilities

### New Capabilities

- `menu-command-semantics`: Clear separation of menu command responsibilities with defined behaviors for Open, Close, Toggle, and Start

### Modified Capabilities

None - this is a refactoring of existing commands without changing external behavior expectations.

## Impact

- `autoload/linny_menu.vim`: Refactor `linny_menu#open()`, `linny_menu#close()`, `linny_menu#toggle()`, `linny_menu#start()`
- `lua/linny/menu/window.lua`: May need `open_last_state()` vs `open_home()` distinction
