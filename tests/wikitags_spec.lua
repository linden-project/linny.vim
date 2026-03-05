-- Unit tests for linny.wikitags module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.wikitags", function()
  local wikitags

  before_each(function()
    package.loaded['linny.wikitags'] = nil
    wikitags = require('linny.wikitags')
  end)

  describe("mkdir_if_not_exist", function()
    it("creates directory when it does not exist", function()
      local test_path = "/tmp/linny_wikitags_test_" .. os.time()

      -- Ensure it doesn't exist
      assert.are.equal(0, vim.fn.isdirectory(test_path), "Test dir should not exist initially")

      -- Create it
      wikitags.mkdir_if_not_exist(test_path)

      -- Verify it exists
      assert.are.equal(1, vim.fn.isdirectory(test_path), "Directory should be created")

      -- Cleanup
      vim.fn.delete(test_path, "d")
    end)

    it("does not error when directory already exists", function()
      local test_path = "/tmp"

      -- Should not throw
      assert.has_no.errors(function()
        wikitags.mkdir_if_not_exist(test_path)
      end)
    end)
  end)

  describe("linny", function()
    it("parses taxonomy:term correctly", function()
      local called_with = {}
      -- Mock linny_menu#openterm
      vim.fn['linny_menu#openterm'] = function(tax, term)
        called_with = {tax, term}
      end

      wikitags.linny("category:value")

      assert.are.same({"category", "value"}, called_with)
    end)

    it("handles taxonomy without term", function()
      local called_with = {}
      -- Mock linny_menu#openterm
      vim.fn['linny_menu#openterm'] = function(tax, term)
        called_with = {tax, term}
      end

      wikitags.linny("mytaxonomy")

      assert.are.same({"mytaxonomy", ""}, called_with)
    end)

    it("trims whitespace from taxonomy and term", function()
      local called_with = {}
      vim.fn['linny_menu#openterm'] = function(tax, term)
        called_with = {tax, term}
      end

      wikitags.linny("  taxonomy  ")

      assert.are.equal("taxonomy", called_with[1])
    end)

    it("trims whitespace from term after colon", function()
      local called_with = {}
      vim.fn['linny_menu#openterm'] = function(tax, term)
        called_with = {tax, term}
      end

      wikitags.linny("category:  value  ")

      assert.are.equal("value", called_with[2])
    end)
  end)

  it("module is requireable and has expected functions", function()
    local ok, mod = pcall(require, 'linny.wikitags')
    assert.is_true(ok, "Should be able to require linny.wikitags")
    assert.is_not_nil(mod.file, "Should have file function")
    assert.is_not_nil(mod.mkdir_if_not_exist, "Should have mkdir_if_not_exist function")
    assert.is_not_nil(mod.dir1st, "Should have dir1st function")
    assert.is_not_nil(mod.dir2nd, "Should have dir2nd function")
    assert.is_not_nil(mod.shell, "Should have shell function")
    assert.is_not_nil(mod.linny, "Should have linny function")
    assert.is_not_nil(mod.vim_cmd, "Should have vim_cmd function")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.wikitags, "Should have wikitags submodule")
    assert.is_not_nil(linny.wikitags.file, "Should have file via main module")
  end)
end)
