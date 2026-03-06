-- Unit tests for linny.menu.items module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.menu.items", function()
  local items

  before_each(function()
    package.loaded['linny.menu.items'] = nil
    package.loaded['linny.menu.util'] = nil
    package.loaded['linny.menu'] = nil
    items = require('linny.menu.items')
    -- Reset tab-local state for each test
    vim.t.linny_menu_items = {}
    vim.t.linny_menu = nil
  end)

  describe("item_default", function()
    it("returns table with all required fields", function()
      local item = items.item_default()
      assert.is_not_nil(item)
      assert.are.equal(1, item.mode)
      assert.are.equal('', item.event)
      assert.are.equal('', item.text)
      assert.are.equal('', item.option_type)
      assert.is_not_nil(item.option_data)
      assert.are.equal('', item.key)
      assert.are.equal(0, item.weight)
      assert.are.equal('', item.help)
    end)

    it("returns a new table each time", function()
      local item1 = items.item_default()
      local item2 = items.item_default()
      assert.is_not.equal(item1, item2)
    end)
  end)

  describe("append", function()
    it("adds item to empty list", function()
      local item = items.item_default()
      item.text = "Test"
      items.append(item)
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal("Test", vim.t.linny_menu_items[1].text)
    end)

    it("maintains weight order", function()
      local item1 = items.item_default()
      item1.text = "First"
      item1.weight = 10

      local item2 = items.item_default()
      item2.text = "Second"
      item2.weight = 5

      local item3 = items.item_default()
      item3.text = "Third"
      item3.weight = 15

      items.append(item1)
      items.append(item2)
      items.append(item3)

      assert.are.equal(3, #vim.t.linny_menu_items)
      assert.are.equal("Second", vim.t.linny_menu_items[1].text)
      assert.are.equal("First", vim.t.linny_menu_items[2].text)
      assert.are.equal("Third", vim.t.linny_menu_items[3].text)
    end)

    it("preserves insertion order for same weight", function()
      local item1 = items.item_default()
      item1.text = "First"

      local item2 = items.item_default()
      item2.text = "Second"

      items.append(item1)
      items.append(item2)

      assert.are.equal("First", vim.t.linny_menu_items[1].text)
      assert.are.equal("Second", vim.t.linny_menu_items[2].text)
    end)
  end)

  describe("add_empty_line", function()
    it("adds empty item", function()
      items.add_empty_line()
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal("", vim.t.linny_menu_items[1].text)
      assert.are.equal(1, vim.t.linny_menu_items[1].mode)
    end)
  end)

  describe("add_divider", function()
    it("adds divider with dashes", function()
      items.add_divider()
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.is_true(vim.t.linny_menu_items[1].text:find("-") ~= nil)
    end)
  end)

  describe("add_text", function()
    it("adds text item", function()
      items.add_text("Hello World")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal("Hello World", vim.t.linny_menu_items[1].text)
      assert.are.equal(1, vim.t.linny_menu_items[1].mode)
    end)
  end)

  describe("add_header", function()
    it("adds header with mode 3", function()
      items.add_header("# My Header")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(3, vim.t.linny_menu_items[1].mode)
    end)

    it("strips leading # characters", function()
      items.add_header("# My Header")
      assert.are.equal("My Header", vim.t.linny_menu_items[1].text)
    end)

    it("handles multiple # characters", function()
      items.add_header("### Deep Header")
      assert.are.equal("Deep Header", vim.t.linny_menu_items[1].text)
    end)

    it("handles text without # prefix", function()
      items.add_header("Plain Header")
      assert.are.equal("Plain Header", vim.t.linny_menu_items[1].text)
    end)
  end)

  describe("add_footer", function()
    it("adds footer with mode 4", function()
      items.add_footer("Footer Text")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(4, vim.t.linny_menu_items[1].mode)
      assert.are.equal("Footer Text", vim.t.linny_menu_items[1].text)
    end)
  end)

  describe("add_section", function()
    it("adds empty line before section", function()
      items.add_section("## Section")
      assert.are.equal(2, #vim.t.linny_menu_items)
      assert.are.equal("", vim.t.linny_menu_items[1].text)
    end)

    it("adds section with mode 2", function()
      items.add_section("## Section")
      assert.are.equal(2, vim.t.linny_menu_items[2].mode)
    end)

    it("strips leading # characters", function()
      items.add_section("### My Section")
      assert.are.equal("My Section", vim.t.linny_menu_items[2].text)
    end)
  end)

  describe("add_document", function()
    it("creates document item with mode 0", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(0, vim.t.linny_menu_items[1].mode)
    end)

    it("sets title as text", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.are.equal("My Doc", vim.t.linny_menu_items[1].text)
    end)

    it("sets keyboard key", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.are.equal("d", vim.t.linny_menu_items[1].key)
    end)

    it("sets option_type", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.are.equal("file", vim.t.linny_menu_items[1].option_type)
    end)

    it("sets abs_path in option_data", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.are.equal("/path/to/doc.md", vim.t.linny_menu_items[1].option_data.abs_path)
    end)

    it("sets event with path", function()
      items.add_document("My Doc", "/path/to/doc.md", "d", "file")
      assert.is_true(vim.t.linny_menu_items[1].event:find("/path/to/doc.md") ~= nil)
    end)
  end)

  describe("add_special_event", function()
    it("creates event item with mode 0", function()
      items.add_special_event("Refresh", "refresh", "r")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(0, vim.t.linny_menu_items[1].mode)
    end)

    it("sets event id", function()
      items.add_special_event("Refresh", "refresh", "r")
      assert.are.equal("refresh", vim.t.linny_menu_items[1].event)
    end)

    it("sets keyboard key", function()
      items.add_special_event("Refresh", "refresh", "r")
      assert.are.equal("r", vim.t.linny_menu_items[1].key)
    end)

    it("sets title as text", function()
      items.add_special_event("Refresh", "refresh", "r")
      assert.are.equal("Refresh", vim.t.linny_menu_items[1].text)
    end)
  end)

  describe("add_ex_event", function()
    it("creates ex command item", function()
      items.add_ex_event("Open", ":e file.md", "o")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(0, vim.t.linny_menu_items[1].mode)
    end)

    it("sets ex command as event", function()
      items.add_ex_event("Open", ":e file.md", "o")
      assert.are.equal(":e file.md", vim.t.linny_menu_items[1].event)
    end)

    it("sets keyboard key", function()
      items.add_ex_event("Open", ":e file.md", "o")
      assert.are.equal("o", vim.t.linny_menu_items[1].key)
    end)
  end)

  describe("add_external_location", function()
    it("creates external location item", function()
      items.add_external_location("Website", "https://example.com")
      assert.are.equal(1, #vim.t.linny_menu_items)
      assert.are.equal(0, vim.t.linny_menu_items[1].mode)
    end)

    it("sets event with openexternal prefix", function()
      items.add_external_location("Website", "https://example.com")
      assert.are.equal("openexternal https://example.com", vim.t.linny_menu_items[1].event)
    end)

    it("sets title as text", function()
      items.add_external_location("Website", "https://example.com")
      assert.are.equal("Website", vim.t.linny_menu_items[1].text)
    end)
  end)

  describe("get_by_index", function()
    it("returns nil when menu not set", function()
      local result = items.get_by_index(0)
      assert.is_nil(result)
    end)

    it("returns nil for negative index", function()
      vim.t.linny_menu = { items = {{ text = "Test" }} }
      local result = items.get_by_index(-1)
      assert.is_nil(result)
    end)

    it("returns nil for index out of bounds", function()
      vim.t.linny_menu = { items = {{ text = "Test" }} }
      local result = items.get_by_index(1)
      assert.is_nil(result)
    end)

    it("returns item at valid index (0-indexed)", function()
      vim.t.linny_menu = { items = {{ text = "First" }, { text = "Second" }} }
      local result = items.get_by_index(0)
      assert.is_not_nil(result)
      assert.are.equal("First", result.text)
    end)

    it("returns second item at index 1", function()
      vim.t.linny_menu = { items = {{ text = "First" }, { text = "Second" }} }
      local result = items.get_by_index(1)
      assert.is_not_nil(result)
      assert.are.equal("Second", result.text)
    end)
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.menu.items')
    assert.is_true(ok, "Should be able to require linny.menu.items")

    -- Check all expected functions exist
    assert.is_not_nil(mod.item_default, "Should have item_default")
    assert.is_not_nil(mod.append, "Should have append")
    assert.is_not_nil(mod.add_empty_line, "Should have add_empty_line")
    assert.is_not_nil(mod.add_divider, "Should have add_divider")
    assert.is_not_nil(mod.add_text, "Should have add_text")
    assert.is_not_nil(mod.add_header, "Should have add_header")
    assert.is_not_nil(mod.add_footer, "Should have add_footer")
    assert.is_not_nil(mod.add_section, "Should have add_section")
    assert.is_not_nil(mod.add_document, "Should have add_document")
    assert.is_not_nil(mod.add_document_taxo_key, "Should have add_document_taxo_key")
    assert.is_not_nil(mod.add_document_taxo_key_val, "Should have add_document_taxo_key_val")
    assert.is_not_nil(mod.add_special_event, "Should have add_special_event")
    assert.is_not_nil(mod.add_ex_event, "Should have add_ex_event")
    assert.is_not_nil(mod.add_external_location, "Should have add_external_location")
    assert.is_not_nil(mod.list, "Should have list")
    assert.is_not_nil(mod.get_by_index, "Should have get_by_index")
  end)

  it("is accessible from menu module", function()
    package.loaded['linny.menu'] = nil
    local menu = require('linny.menu')
    assert.is_not_nil(menu.items, "Should have items submodule")
    assert.is_not_nil(menu.items.item_default, "Should have item_default via menu module")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.menu, "Should have menu submodule")
    assert.is_not_nil(linny.menu.items, "Should have items submodule via main")
    assert.is_not_nil(linny.menu.items.item_default, "Should have item_default via main module")
  end)
end)
