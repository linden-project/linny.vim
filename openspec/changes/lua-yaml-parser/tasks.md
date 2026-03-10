# Tasks

## Task 1: Create lua/linny/yaml.lua module

Create the new Lua module with YAML parsing functionality.

### Subtasks

- [ ] Create `lua/linny/yaml.lua` file
- [ ] Implement `parse(yaml_string)` function that parses YAML string to Lua table
- [ ] Implement `parse_file(filepath)` function that reads file and calls parse()
- [ ] Handle key-value pairs (`key: value`)
- [ ] Handle nested objects via indentation tracking
- [ ] Handle simple lists (`- item`)
- [ ] Handle comments (full line and inline)
- [ ] Handle quoted strings (single and double quotes)
- [ ] Handle boolean values (true/false, yes/no)
- [ ] Handle numeric values (integers and floats)
- [ ] Return nil for non-existent files
- [ ] Return empty table for empty files

### Specs

- specs/lua-yaml-module/spec.md

## Task 2: Update linny#parse_yaml_to_dict() to use Lua

Replace the Ruby implementation with a call to the Lua parser.

### Subtasks

- [ ] Modify `linny#parse_yaml_to_dict()` in autoload/linny.vim
- [ ] Use `luaeval("require('linny.yaml').parse_file(_A)", a:filePath)`
- [ ] Handle nil return by returning empty dictionary
- [ ] Remove Ruby shell command

### Specs

- specs/lua-yaml-module/spec.md

## Task 3: Test against existing config files

Verify the Lua parser correctly handles all existing YAML config files in the codebase.

### Subtasks

- [ ] Test parsing view config files
- [ ] Test parsing taxonomy config files
- [ ] Test parsing term config files
- [ ] Compare output with Ruby parser output for validation
