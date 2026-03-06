-- Unit tests for linny.menu.documents module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.documents", function()
  local documents

  before_each(function()
    package.loaded['linny.menu.documents'] = nil
    package.loaded['linny.menu'] = nil
    documents = require('linny.menu.documents')
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.documents')
    assert.is_true(ok, "Should be able to require linny.menu.documents")

    assert.is_not_nil(mod.replace_frontmatter_key, "Should have replace_frontmatter_key")
    assert.is_not_nil(mod.open_in_right_pane, "Should have open_in_right_pane")
    assert.is_not_nil(mod.copy, "Should have copy")
    assert.is_not_nil(mod.new_in_leaf, "Should have new_in_leaf")
    assert.is_not_nil(mod.archive_l2_config, "Should have archive_l2_config")
    assert.is_not_nil(mod.create_l2_config, "Should have create_l2_config")
    assert.is_not_nil(mod.create_l1_config, "Should have create_l1_config")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.documents, "Should have documents submodule")
    assert.is_not_nil(menu.documents.replace_frontmatter_key, "Should have replace_frontmatter_key via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.documents, "Should have documents submodule via main")
    assert.is_not_nil(linny.menu.documents.replace_frontmatter_key, "Should have replace_frontmatter_key via main module")
  end)

  describe("replace_frontmatter_key", function()
    it("replaces existing key in frontmatter", function()
      local lines = {
        "---",
        "title: Old Title",
        "date: 2024-01-01",
        "---",
        "Content here"
      }
      local result = documents.replace_frontmatter_key(lines, "title", "New Title")
      assert.are.equal("title: New Title", result[2])
      assert.are.equal("date: 2024-01-01", result[3])
    end)

    it("does not modify keys outside frontmatter", function()
      local lines = {
        "---",
        "title: In Frontmatter",
        "---",
        "title: Not In Frontmatter"
      }
      local result = documents.replace_frontmatter_key(lines, "title", "New Value")
      assert.are.equal("title: New Value", result[2])
      assert.are.equal("title: Not In Frontmatter", result[4])
    end)

    it("does nothing if key not found", function()
      local lines = {
        "---",
        "title: My Title",
        "---"
      }
      local result = documents.replace_frontmatter_key(lines, "author", "Someone")
      assert.are.equal("title: My Title", result[2])
    end)

    it("handles frontmatter without the key", function()
      local lines = {
        "---",
        "date: 2024-01-01",
        "---"
      }
      local result = documents.replace_frontmatter_key(lines, "title", "New Title")
      assert.are.equal("date: 2024-01-01", result[2])
    end)

    it("only replaces first occurrence", function()
      local lines = {
        "---",
        "title: First",
        "title: Second",
        "---"
      }
      local result = documents.replace_frontmatter_key(lines, "title", "New")
      assert.are.equal("title: New", result[2])
      assert.are.equal("title: Second", result[3])
    end)

    it("handles empty frontmatter", function()
      local lines = {
        "---",
        "---",
        "Content"
      }
      local result = documents.replace_frontmatter_key(lines, "title", "New")
      assert.are.equal("---", result[1])
      assert.are.equal("---", result[2])
    end)
  end)
end)
