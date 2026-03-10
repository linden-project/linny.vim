## Context

Currently all menu open commands (`linny_menu#open()`, `linny_menu#toggle()`, `linny_menu#start()`) call `open_home()` which resets state to root. There's no way to restore the previous menu state. The toggle function contains logic that should be delegated.

Menu state is stored in tab variables: `t:linny_menu_taxonomy`, `t:linny_menu_term`, `t:linny_menu_view`.

## Goals / Non-Goals

**Goals:**
- Clear command semantics: Start = root, Open = restore, Close = preserve, Toggle = delegate
- Hugo watch auto-start only on Start (intentional session start)
- Single responsibility for each command

**Non-Goals:**
- Persisting state across Neovim sessions
- Changing the underlying rendering logic

## Decisions

### Decision 1: Separate open_home() and open_restore()

Create two Lua functions:
- `open_home()`: Resets state to root view, triggers Hugo watch auto-start
- `open_restore()`: Opens menu with current `t:linny_menu_*` state (or root if never set)

**Rationale**: Clean separation between "start fresh" and "resume where I was".

### Decision 2: Toggle delegates via function calls

`linny_menu#toggle()` checks `exist()` and calls either `linny_menu#open()` or `linny_menu#close()`.

**Rationale**: Single responsibility - toggle only decides, doesn't implement.

### Decision 3: State preserved on close (already works)

Current `close_window()` doesn't clear `t:linny_menu_*` variables. No change needed.

**Rationale**: Closing already preserves state by not touching it.

## Risks / Trade-offs

**Trade-off**: LinnyMenuOpen after LinnyStart will show root (since Start clears state)
→ Expected behavior - Start intentionally resets.
