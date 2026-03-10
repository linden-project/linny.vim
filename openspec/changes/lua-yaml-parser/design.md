## Context

Currently `linny#parse_yaml_to_dict()` uses Ruby to parse YAML:
```vim
return json_decode(system('ruby -rjson -ryaml -e "puts JSON.pretty_generate(YAML.load_file('..."'))"'))
```

This requires Ruby to be installed, adds shell overhead, and can fail silently if Ruby is missing. The YAML files being parsed are simple configuration files (view configs, taxonomy configs) with basic key-value structures.

## Goals / Non-Goals

**Goals:**
- Remove Ruby runtime dependency
- Parse YAML configuration files using pure Lua
- Maintain backward compatibility with existing callers

**Non-Goals:**
- Full YAML 1.2 specification support (only need simple key-value pairs)
- Parsing complex YAML features (anchors, aliases, multi-document)
- Parsing markdown frontmatter (handled separately in wiki module)

## Decisions

### Decision 1: Implement minimal YAML parser in Lua

Create `lua/linny/yaml.lua` with a `parse_file(filepath)` function that handles the subset of YAML used in linny config files:
- Key-value pairs (`key: value`)
- Nested objects (indentation-based)
- Simple lists (`- item`)
- String values (quoted and unquoted)
- Comments (`# comment`)

**Rationale**: The config files use simple YAML structures. A focused parser is simpler and more maintainable than pulling in a full YAML library.

**Alternatives considered**:
- Use external lua-yaml library - adds dependency management complexity
- Use lyaml (C binding) - requires compilation, reduces portability

### Decision 2: Vimscript wrapper calls Lua

Update `linny#parse_yaml_to_dict()` to call the Lua parser:
```vim
function! linny#parse_yaml_to_dict(filePath)
  if filereadable(a:filePath)
    return luaeval("require('linny.yaml').parse_file(_A)", a:filePath)
  endif
  return {}
endfunction
```

**Rationale**: Minimal change to existing code, maintains the same interface.

## Risks / Trade-offs

**Risk**: Custom parser may not handle edge cases in existing YAML files.
→ **Mitigation**: Test against all existing config files in the codebase. The parser only needs to handle the patterns actually used.

**Risk**: Performance difference from Ruby.
→ **Mitigation**: Lua should be faster (no shell/process overhead). Benchmark if needed.
