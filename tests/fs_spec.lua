-- Unit tests for linny.fs module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.fs", function()
  local fs

  before_each(function()
    package.loaded['linny.fs'] = nil
    fs = require('linny.fs')
  end)

  describe("dir_create_if_not_exist", function()
    it("creates directory when it does not exist", function()
      local test_path = "/tmp/linny_test_dir_" .. os.time()

      -- Ensure it doesn't exist
      assert.are.equal(0, vim.fn.isdirectory(test_path), "Test dir should not exist initially")

      -- Create it
      fs.dir_create_if_not_exist(test_path)

      -- Verify it exists
      assert.are.equal(1, vim.fn.isdirectory(test_path), "Directory should be created")

      -- Cleanup
      vim.fn.delete(test_path, "d")
    end)

    it("creates nested directories", function()
      local test_path = "/tmp/linny_test_nested_" .. os.time() .. "/sub/dir"

      fs.dir_create_if_not_exist(test_path)

      assert.are.equal(1, vim.fn.isdirectory(test_path), "Nested directory should be created")

      -- Cleanup
      vim.fn.delete("/tmp/linny_test_nested_" .. os.time(), "rf")
    end)

    it("does not error when directory already exists", function()
      local test_path = "/tmp"

      -- Should not throw
      assert.has_no.errors(function()
        fs.dir_create_if_not_exist(test_path)
      end)
    end)
  end)

  it("module is requireable and has expected functions", function()
    local ok, mod = pcall(require, 'linny.fs')
    assert.is_true(ok, "Should be able to require linny.fs")
    assert.is_not_nil(mod.dir_create_if_not_exist, "Should have dir_create_if_not_exist function")
    assert.is_not_nil(mod.os_open_with_filemanager, "Should have os_open_with_filemanager function")
  end)

  it("is accessible from main module", function()
    local linny = require('linny')
    assert.is_not_nil(linny.fs, "Should have fs submodule")
    assert.is_not_nil(linny.fs.dir_create_if_not_exist, "Should have dir_create_if_not_exist via main module")
    assert.is_not_nil(linny.fs.os_open_with_filemanager, "Should have os_open_with_filemanager via main module")
  end)
end)
