-- Example test file for linny
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny", function()
  it("loads without error", function()
    -- Check that linny commands exist
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands["LinnyStart"], "LinnyStart command should exist")
  end)

  it("has version defined", function()
    -- The version should be accessible and match VERSION file
    local ok, version_mod = pcall(require, 'linny.version')
    assert.is_true(ok, "Should be able to require linny.version")
    local version = version_mod.plugin_version()
    assert.is_not_nil(version, "Version should be defined")

    -- Read VERSION file directly and compare
    local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
    local f = io.open(plugin_root .. "/VERSION", "r")
    if f then
      local expected = f:read("*l")
      f:close()
      assert.are.equal(expected, version, "Version should match VERSION file")
    end
  end)
end)

-- Add more tests as you convert modules to Lua
-- describe("linny.wiki", function()
--   it("finds wiki link pattern", function()
--     -- Test wiki link detection
--   end)
-- end)
