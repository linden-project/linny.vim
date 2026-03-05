-- Example test file for linny
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny", function()
  it("loads without error", function()
    -- Check that linny commands exist
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands["LinnyStart"], "LinnyStart command should exist")
  end)

  it("has version defined", function()
    -- The version should be accessible
    local ok, version = pcall(vim.fn["linny_version#PluginVersion"])
    assert.is_true(ok, "Should be able to call version function")
    assert.is_not_nil(version, "Version should be defined")
  end)
end)

-- Add more tests as you convert modules to Lua
-- describe("linny.wiki", function()
--   it("finds wiki link pattern", function()
--     -- Test wiki link detection
--   end)
-- end)
