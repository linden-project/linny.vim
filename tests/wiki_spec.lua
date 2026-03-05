-- Unit tests for linny.wiki module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.wiki", function()
  local wiki

  before_each(function()
    package.loaded['linny.wiki'] = nil
    wiki = require('linny.wiki')
    -- Set default global variables
    vim.g.spaceReplaceChar = '_'
    vim.g.linny_wikitags_register = nil
  end)

  describe("word_to_filename", function()
    it("converts words correctly", function()
      assert.are.equal("my_document.md", wiki.word_to_filename("My Document"))
    end)

    it("converts to lowercase", function()
      assert.are.equal("hello_world.md", wiki.word_to_filename("HELLO WORLD"))
    end)

    it("handles special characters - slash", function()
      vim.g.spaceReplaceChar = '_'
      assert.are.equal("doc_with_slash.md", wiki.word_to_filename("Doc/With/Slash"))
    end)

    it("handles special characters - colon", function()
      vim.g.spaceReplaceChar = '_'
      assert.are.equal("doc_with_colon.md", wiki.word_to_filename("Doc:With:Colon"))
    end)

    it("trims whitespace", function()
      assert.are.equal("trimmed.md", wiki.word_to_filename("  trimmed  "))
    end)

    it("returns empty for empty input", function()
      assert.are.equal("", wiki.word_to_filename(""))
      assert.are.equal("", wiki.word_to_filename(nil))
    end)
  end)

  describe("file_exists", function()
    it("returns true for existing files", function()
      -- Create a temp file
      local test_file = "/tmp/linny_wiki_test_" .. os.time()
      vim.fn.writefile({"test"}, test_file)

      assert.is_true(wiki.file_exists(test_file))

      -- Cleanup
      vim.fn.delete(test_file)
    end)

    it("returns false for non-existing paths", function()
      assert.is_false(wiki.file_exists("/nonexistent/path/that/does/not/exist"))
    end)
  end)

  describe("str_between", function()
    it("extracts text between delimiters", function()
      -- Create a buffer with test content
      vim.cmd('enew')
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"This is [[a wiki link]] in text"})
      vim.fn.cursor(1, 15) -- Position cursor inside the link

      local result = wiki.str_between("[[", "]]")
      assert.are.equal("a wiki link", result)

      vim.cmd('bdelete!')
    end)

    it("extracts full text without cutting characters", function()
      vim.cmd('enew')
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Click [[this is a link]] here"})
      vim.fn.cursor(1, 12) -- Position cursor inside the link

      local result = wiki.str_between("[[", "]]")
      assert.are.equal("this is a link", result)

      vim.cmd('bdelete!')
    end)

    it("handles wikitags correctly", function()
      vim.cmd('enew')
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Open [[LIN tags]] menu"})
      vim.fn.cursor(1, 10) -- Position cursor inside the link

      local result = wiki.str_between("[[", "]]")
      assert.are.equal("LIN tags", result)

      vim.cmd('bdelete!')
    end)
  end)

  describe("wikitag_has_tag", function()
    it("detects registered tags", function()
      vim.g.linny_wikitags_register = {
        FILE = { primaryAction = "test_func" },
        DIR = { primaryAction = "test_func2" }
      }

      assert.are.equal("FILE", wiki.wikitag_has_tag("FILE ~/Documents"))
      assert.are.equal("DIR", wiki.wikitag_has_tag("DIR /tmp"))
    end)

    it("returns empty for non-tags", function()
      vim.g.linny_wikitags_register = {
        FILE = { primaryAction = "test_func" }
      }

      assert.are.equal("", wiki.wikitag_has_tag("regular link"))
      assert.are.equal("", wiki.wikitag_has_tag("not a wikitag"))
    end)

    it("returns empty when register is nil", function()
      vim.g.linny_wikitags_register = nil
      assert.are.equal("", wiki.wikitag_has_tag("FILE ~/Documents"))
    end)
  end)

  it("module is requireable with all functions", function()
    local ok, mod = pcall(require, 'linny.wiki')
    assert.is_true(ok, "Should be able to require linny.wiki")

    -- Check all expected functions exist
    assert.is_not_nil(mod.wikitag_has_tag, "Should have wikitag_has_tag")
    assert.is_not_nil(mod.execute_wikitag_action, "Should have execute_wikitag_action")
    assert.is_not_nil(mod.file_exists, "Should have file_exists")
    assert.is_not_nil(mod.word_to_filename, "Should have word_to_filename")
    assert.is_not_nil(mod.file_path, "Should have file_path")
    assert.is_not_nil(mod.str_between, "Should have str_between")
    assert.is_not_nil(mod.yaml_key_under_cursor, "Should have yaml_key_under_cursor")
    assert.is_not_nil(mod.yaml_val_under_cursor, "Should have yaml_val_under_cursor")
    assert.is_not_nil(mod.cursor_in_frontmatter, "Should have cursor_in_frontmatter")
    assert.is_not_nil(mod.find_word_pos, "Should have find_word_pos")
    assert.is_not_nil(mod.get_word, "Should have get_word")
    assert.is_not_nil(mod.find_link_pos, "Should have find_link_pos")
    assert.is_not_nil(mod.get_link, "Should have get_link")
    assert.is_not_nil(mod.goto_link, "Should have goto_link")
    assert.is_not_nil(mod.return_to_last, "Should have return_to_last")
    assert.is_not_nil(mod.find_non_existing_links, "Should have find_non_existing_links")
  end)

  it("is accessible from main module", function()
    package.loaded['linny'] = nil
    local linny = require('linny')
    assert.is_not_nil(linny.wiki, "Should have wiki submodule")
    assert.is_not_nil(linny.wiki.goto_link, "Should have goto_link via main module")
  end)
end)
