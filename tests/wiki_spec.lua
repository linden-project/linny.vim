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
    vim.g.linny_cache_index_docs_titles = nil
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

  describe("filename_by_title", function()
    it("finds filename by exact title", function()
      vim.g.linny_cache_index_docs_titles = {
        ["my_document.md"] = "My Document",
        ["other_note.md"] = "Other Note"
      }

      assert.are.equal("my_document.md", wiki.filename_by_title("My Document"))
    end)

    it("matches titles case-insensitively", function()
      vim.g.linny_cache_index_docs_titles = {
        ["improvement_it_-_medux_away_from_ami_build.md"] = "Medux away from Ami build"
      }

      assert.are.equal(
        "improvement_it_-_medux_away_from_ami_build.md",
        wiki.filename_by_title("medux away from ami build")
      )
    end)

    it("trims the word before matching", function()
      vim.g.linny_cache_index_docs_titles = {
        ["my_document.md"] = "My Document"
      }

      assert.are.equal("my_document.md", wiki.filename_by_title("  My Document  "))
    end)

    it("returns empty when no title matches", function()
      vim.g.linny_cache_index_docs_titles = {
        ["my_document.md"] = "My Document"
      }

      assert.are.equal("", wiki.filename_by_title("Unknown Title"))
    end)

    it("returns empty when index cache is not set", function()
      vim.g.linny_cache_index_docs_titles = nil
      assert.are.equal("", wiki.filename_by_title("My Document"))
    end)

    it("returns empty for empty input", function()
      vim.g.linny_cache_index_docs_titles = {
        ["my_document.md"] = "My Document"
      }

      assert.are.equal("", wiki.filename_by_title(""))
      assert.are.equal("", wiki.filename_by_title(nil))
    end)
  end)

  describe("goto_link", function()
    it("opens file matched by frontmatter title instead of creating a new one", function()
      local dir = vim.fn.tempname()
      vim.fn.mkdir(dir, 'p')

      local target = dir .. '/improvement_it_-_medux_away_from_ami_build.md'
      vim.fn.writefile({'---', 'title: "Medux away from Ami build"', '---', 'content'}, target)

      local source = dir .. '/weekly_planning.md'
      vim.fn.writefile({'- [ ] [[medux away from ami build]]'}, source)

      vim.g.linny_cache_index_docs_titles = {
        ["improvement_it_-_medux_away_from_ami_build.md"] = "Medux away from Ami build"
      }

      vim.cmd('edit ' .. vim.fn.fnameescape(source))
      vim.fn.cursor(1, 12) -- Position cursor inside the link

      wiki.goto_link()

      assert.are.equal(target, vim.fn.expand('%:p'))
      assert.is_false(wiki.file_exists(dir .. '/medux_away_from_ami_build.md'))

      vim.cmd('bdelete!')
      vim.fn.delete(dir, 'rf')
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
    assert.is_not_nil(mod.filename_by_title, "Should have filename_by_title")
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
