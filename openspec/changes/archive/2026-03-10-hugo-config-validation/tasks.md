## 1. Module Constants

- [x] 1.1 Add `REQUIRED_DIRS` constant to `lua/linny/hugo.lua` with contentDir, dataDir, publishDir
- [x] 1.2 Add `REQUIRED_OUTPUT_FORMATS` constant with all 7 required format names
- [x] 1.3 Add `REQUIRED_HOME_OUTPUTS` constant listing formats required for home output

## 2. Config Retrieval

- [x] 2.1 Implement `get_config(notebook_path)` function in `lua/linny/hugo.lua`
- [x] 2.2 Execute `hugo config --source <path> --format json` via `vim.fn.system()`
- [x] 2.3 Parse JSON output with `vim.fn.json_decode()` wrapped in pcall
- [x] 2.4 Return structured result `{ok, config}` or `{ok=false, error}`

## 3. Directory Validation

- [x] 3.1 Implement `validate_directories(config)` helper function
- [x] 3.2 Check `contentDir` equals `"content"`
- [x] 3.3 Check `dataDir` equals `"lindenConfig"`
- [x] 3.4 Check `publishDir` equals `"lindenIndex"`
- [x] 3.5 Return list of errors with expected vs actual values

## 4. Taxonomy Validation

- [x] 4.1 Implement `validate_taxonomies(config)` helper function
- [x] 4.2 Check `config.taxonomies` exists and has at least one entry
- [x] 4.3 Return error if no taxonomies defined

## 5. Output Format Validation

- [x] 5.1 Implement `validate_output_formats(config)` helper function
- [x] 5.2 Check each required format exists in `config.outputFormats`
- [x] 5.3 Return list of missing format names

## 6. Outputs Validation

- [x] 6.1 Implement `validate_outputs(config)` helper function
- [x] 6.2 Check `config.outputs.home` includes required formats
- [x] 6.3 Check `config.outputs.page` includes `"json"`
- [x] 6.4 Return list of missing outputs per kind

## 7. Combined Validation

- [x] 7.1 Implement `validate_config(config)` combining all validators
- [x] 7.2 Aggregate errors and warnings from all validators
- [x] 7.3 Return `{ok, errors, warnings}` structure
- [x] 7.4 Implement `validate_notebook_config(notebook_path)` combining get_config and validate_config

## 8. Caching

- [x] 8.1 Add module-local `_config_cache` variable
- [x] 8.2 Cache result in `validate_notebook_config()` keyed by notebook path
- [x] 8.3 Add `clear_cache()` function to reset cached state

## 9. Health Check Integration

- [x] 9.1 Add config validation call to `lua/linny/health.lua:validate()`
- [x] 9.2 Include `hugo_config` in validation result
- [x] 9.3 Skip config validation if Hugo is not available
- [x] 9.4 Update `check()` to report config validation in `:checkhealth`
- [x] 9.5 Show OK for valid config, ERROR for directory issues, WARN for missing formats

## 10. Tests

- [x] 10.1 Add config validation tests to `tests/hugo_spec.lua`
- [x] 10.2 Test `validate_directories()` with valid and invalid configs
- [x] 10.3 Test `validate_taxonomies()` with present and missing taxonomies
- [x] 10.4 Test `validate_output_formats()` with complete and incomplete configs
- [x] 10.5 Test `validate_config()` aggregation of all validators

## 11. Verification

- [x] 11.1 Run test suite: `nvim --headless -c "PlenaryBustedDirectory tests/"`
- [x] 11.2 Manual test: `:checkhealth linny` shows config validation results
- [x] 11.3 Manual test: Modify notebook config and verify errors are reported
