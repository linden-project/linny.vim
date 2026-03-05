-- Unit tests for linny.util module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.util", function()
  local util

  before_each(function()
    -- Clear any cached module
    package.loaded['linny.util'] = nil
    util = require('linny.util')
  end)

  describe("init_variable", function()
    it("sets default when variable not set", function()
      -- Ensure variable doesn't exist
      vim.g.test_util_var1 = nil

      local result = util.init_variable("g:test_util_var1", "default_value")

      assert.is_true(result, "Should return true when setting default")
      assert.are.equal("default_value", vim.g.test_util_var1, "Should set the default value")

      -- Cleanup
      vim.g.test_util_var1 = nil
    end)

    it("preserves existing value when already set", function()
      -- Set a value first
      vim.g.test_util_var2 = "user_value"

      local result = util.init_variable("g:test_util_var2", "default_value")

      assert.is_false(result, "Should return false when variable exists")
      assert.are.equal("user_value", vim.g.test_util_var2, "Should preserve existing value")

      -- Cleanup
      vim.g.test_util_var2 = nil
    end)

    it("works with numeric values", function()
      vim.g.test_util_num = nil

      util.init_variable("g:test_util_num", 42)

      assert.are.equal(42, vim.g.test_util_num, "Should set numeric default")

      -- Cleanup
      vim.g.test_util_num = nil
    end)

    it("works without g: prefix", function()
      vim.g.test_util_noprefix = nil

      util.init_variable("test_util_noprefix", "value")

      assert.are.equal("value", vim.g.test_util_noprefix, "Should work without g: prefix")

      -- Cleanup
      vim.g.test_util_noprefix = nil
    end)
  end)

  it("module is requireable", function()
    local ok, mod = pcall(require, 'linny.util')
    assert.is_true(ok, "Should be able to require linny.util")
    assert.is_not_nil(mod.init_variable, "Should have init_variable function")
  end)

  it("is accessible from main module", function()
    local linny = require('linny')
    assert.is_not_nil(linny.util, "Should have util submodule")
    assert.is_not_nil(linny.util.init_variable, "Should have init_variable via main module")
  end)
end)
