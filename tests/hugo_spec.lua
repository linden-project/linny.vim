-- Unit tests for linny.hugo module
-- Run with: nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

describe("linny.hugo", function()
  local hugo

  before_each(function()
    package.loaded['linny.hugo'] = nil
    hugo = require('linny.hugo')
    hugo.clear_cache()
  end)

  describe("module structure", function()
    it("is requireable and has expected functions", function()
      local ok, mod = pcall(require, 'linny.hugo')
      assert.is_true(ok, "Should be able to require linny.hugo")
      assert.is_not_nil(mod.detect, "Should have detect function")
      assert.is_not_nil(mod.build_index, "Should have build_index function")
      assert.is_not_nil(mod.clear_cache, "Should have clear_cache function")
    end)
  end)

  describe("_parse_version", function()
    it("parses extended version string", function()
      local version = hugo._parse_version("hugo v0.155.3+extended+withdeploy linux/amd64 BuildDate=unknown")
      assert.are.equal("0.155.3", version)
    end)

    it("parses simple version string", function()
      local version = hugo._parse_version("hugo v0.120.0 linux/amd64")
      assert.are.equal("0.120.0", version)
    end)

    it("parses version with only major.minor.patch", function()
      local version = hugo._parse_version("hugo v1.2.3")
      assert.are.equal("1.2.3", version)
    end)

    it("returns nil for invalid version string", function()
      local version = hugo._parse_version("not a version")
      assert.is_nil(version)
    end)

    it("returns nil for nil input", function()
      local version = hugo._parse_version(nil)
      assert.is_nil(version)
    end)
  end)

  describe("detect", function()
    it("returns table with expected keys", function()
      local result = hugo.detect()
      assert.is_table(result)
      assert.is_not_nil(result.found)
      -- path and version may be nil if Hugo not installed
    end)

    it("caches result on subsequent calls", function()
      local result1 = hugo.detect()
      local result2 = hugo.detect()
      -- Same table reference means cached
      assert.are.equal(result1, result2)
    end)

    it("force parameter bypasses cache", function()
      local result1 = hugo.detect()
      local result2 = hugo.detect(true)
      -- Different table references when forced
      assert.are_not.equal(result1, result2)
    end)
  end)

  describe("build_index", function()
    it("returns error for nil notebook path", function()
      local result = hugo.build_index(nil)
      assert.is_false(result.ok)
      assert.are.equal("No notebook path provided", result.error)
    end)

    it("returns error for empty notebook path", function()
      local result = hugo.build_index("")
      assert.is_false(result.ok)
      assert.are.equal("No notebook path provided", result.error)
    end)

    it("returns error for non-existent directory", function()
      local result = hugo.build_index("/nonexistent/path/that/does/not/exist")
      assert.is_false(result.ok)
      assert.are.equal("Notebook path does not exist", result.error)
    end)

    -- Test with mock notebook fixture (requires Hugo to be installed)
    it("builds index with mock notebook when Hugo available", function()
      local detection = hugo.detect()
      if not detection.found then
        -- Skip test if Hugo not installed
        pending("Hugo not installed, skipping integration test")
        return
      end

      -- Get path to mock notebook
      local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
      local mock_notebook = plugin_root .. "/tests/fixtures/mock-notebook"

      if vim.fn.isdirectory(mock_notebook) == 0 then
        pending("Mock notebook not found at " .. mock_notebook)
        return
      end

      local result = hugo.build_index(mock_notebook)
      assert.is_true(result.ok, "Should build index successfully: " .. (result.error or ""))
      assert.is_not_nil(result.output)
    end)
  end)

  describe("clear_cache", function()
    it("clears the detection cache", function()
      local result1 = hugo.detect()
      hugo.clear_cache()
      local result2 = hugo.detect()
      -- After clearing cache, should get a new table
      assert.are_not.equal(result1, result2)
    end)
  end)

  describe("_validate_directories", function()
    it("returns no errors for valid config", function()
      local config = {
        contentdir = "content",
        datadir = "lindenConfig",
        publishdir = "lindenIndex",
      }
      local errors = hugo._validate_directories(config)
      assert.are.equal(0, #errors)
    end)

    it("returns error for wrong contentdir", function()
      local config = {
        contentdir = "posts",
        datadir = "lindenConfig",
        publishdir = "lindenIndex",
      }
      local errors = hugo._validate_directories(config)
      assert.are.equal(1, #errors)
      assert.is_true(errors[1]:find("contentdir") ~= nil)
      assert.is_true(errors[1]:find("posts") ~= nil)
    end)

    it("returns error for wrong datadir", function()
      local config = {
        contentdir = "content",
        datadir = "data",
        publishdir = "lindenIndex",
      }
      local errors = hugo._validate_directories(config)
      assert.are.equal(1, #errors)
      assert.is_true(errors[1]:find("datadir") ~= nil)
    end)

    it("returns error for wrong publishdir", function()
      local config = {
        contentdir = "content",
        datadir = "lindenConfig",
        publishdir = "public",
      }
      local errors = hugo._validate_directories(config)
      assert.are.equal(1, #errors)
      assert.is_true(errors[1]:find("publishdir") ~= nil)
    end)

    it("returns multiple errors for multiple wrong dirs", function()
      local config = {
        contentdir = "posts",
        datadir = "data",
        publishdir = "public",
      }
      local errors = hugo._validate_directories(config)
      assert.are.equal(3, #errors)
    end)
  end)

  describe("_validate_taxonomies", function()
    it("returns no errors when taxonomies exist", function()
      local config = {
        taxonomies = { tag = "tags", category = "categories" }
      }
      local errors = hugo._validate_taxonomies(config)
      assert.are.equal(0, #errors)
    end)

    it("returns error when taxonomies is nil", function()
      local config = {}
      local errors = hugo._validate_taxonomies(config)
      assert.are.equal(1, #errors)
      assert.is_true(errors[1]:find("taxonomy") ~= nil)
    end)

    it("returns error when taxonomies is empty", function()
      local config = { taxonomies = {} }
      local errors = hugo._validate_taxonomies(config)
      assert.are.equal(1, #errors)
    end)
  end)

  describe("_validate_output_formats", function()
    it("returns no errors when all formats present", function()
      local config = {
        outputformats = {
          starred = {},
          docs_with_props = {},
          docs_with_title = {},
          indexer_info = {},
          taxonomies = {},
          taxonomies_starred = {},
          terms_starred = {},
        }
      }
      local errors = hugo._validate_output_formats(config)
      assert.are.equal(0, #errors)
    end)

    it("returns error for missing format", function()
      local config = {
        outputformats = {
          starred = {},
          -- missing docs_with_props
          docs_with_title = {},
          indexer_info = {},
          taxonomies = {},
          taxonomies_starred = {},
          terms_starred = {},
        }
      }
      local errors = hugo._validate_output_formats(config)
      assert.are.equal(1, #errors)
      assert.is_true(errors[1]:find("docs_with_props") ~= nil)
    end)

    it("returns multiple errors for multiple missing formats", function()
      local config = {
        outputformats = {
          starred = {},
        }
      }
      local errors = hugo._validate_output_formats(config)
      assert.are.equal(6, #errors) -- 7 required - 1 present = 6 missing
    end)
  end)

  describe("validate_config", function()
    it("returns ok for valid config", function()
      local config = {
        contentdir = "content",
        datadir = "lindenConfig",
        publishdir = "lindenIndex",
        taxonomies = { tag = "tags" },
        outputformats = {
          starred = {},
          docs_with_props = {},
          docs_with_title = {},
          indexer_info = {},
          taxonomies = {},
          taxonomies_starred = {},
          terms_starred = {},
        },
        outputs = {
          home = { "html", "starred", "docs_with_props", "docs_with_title", "indexer_info", "taxonomies", "taxonomies_starred", "terms_starred" },
          page = { "json" },
        }
      }
      local result = hugo.validate_config(config)
      assert.is_true(result.ok)
      assert.are.equal(0, #result.errors)
    end)

    it("returns not ok with directory errors", function()
      local config = {
        contentdir = "posts",
        datadir = "lindenConfig",
        publishdir = "lindenIndex",
        taxonomies = { tag = "tags" },
        outputformats = {},
        outputs = { home = {}, page = {} },
      }
      local result = hugo.validate_config(config)
      assert.is_false(result.ok)
      assert.is_true(#result.errors > 0)
    end)

    it("aggregates warnings from output format validation", function()
      local config = {
        contentdir = "content",
        datadir = "lindenConfig",
        publishdir = "lindenIndex",
        taxonomies = { tag = "tags" },
        outputformats = {}, -- missing all
        outputs = { home = {}, page = {} },
      }
      local result = hugo.validate_config(config)
      assert.is_true(result.ok) -- directory errors are blocking, format errors are warnings
      assert.is_true(#result.warnings > 0)
    end)
  end)

  describe("is_watching", function()
    it("returns false when not watching", function()
      hugo.clear_cache()
      -- Ensure any watch is stopped
      if hugo.is_watching() then
        hugo.stop_watch()
      end
      assert.is_false(hugo.is_watching())
    end)
  end)

  describe("get_watch_status", function()
    it("returns 'stopped' when not watching", function()
      hugo.clear_cache()
      if hugo.is_watching() then
        hugo.stop_watch()
      end
      assert.are.equal("stopped", hugo.get_watch_status())
    end)
  end)

  describe("start_watch", function()
    it("returns error for nil notebook path", function()
      local result = hugo.start_watch(nil)
      assert.is_false(result.ok)
      assert.are.equal("No notebook path provided", result.error)
    end)

    it("returns error for empty notebook path", function()
      local result = hugo.start_watch("")
      assert.is_false(result.ok)
      assert.are.equal("No notebook path provided", result.error)
    end)

    it("returns error for non-existent directory", function()
      local result = hugo.start_watch("/nonexistent/path/that/does/not/exist")
      assert.is_false(result.ok)
      assert.are.equal("Notebook path does not exist", result.error)
    end)

    it("starts watch with valid notebook when Hugo available", function()
      local detection = hugo.detect()
      if not detection.found then
        pending("Hugo not installed, skipping watch test")
        return
      end

      -- Stop any existing watch first
      if hugo.is_watching() then
        hugo.stop_watch()
      end

      local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
      local mock_notebook = plugin_root .. "/tests/fixtures/mock-notebook"

      if vim.fn.isdirectory(mock_notebook) == 0 then
        pending("Mock notebook not found at " .. mock_notebook)
        return
      end

      local result = hugo.start_watch(mock_notebook)
      assert.is_true(result.ok, "Should start watch: " .. (result.error or ""))
      assert.is_not_nil(result.job_id)
      assert.is_true(hugo.is_watching())
      assert.are.equal("watching", hugo.get_watch_status())

      -- Clean up
      hugo.stop_watch()
    end)

    it("returns error when already watching", function()
      local detection = hugo.detect()
      if not detection.found then
        pending("Hugo not installed, skipping watch test")
        return
      end

      -- Stop any existing watch first
      if hugo.is_watching() then
        hugo.stop_watch()
      end

      local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
      local mock_notebook = plugin_root .. "/tests/fixtures/mock-notebook"

      if vim.fn.isdirectory(mock_notebook) == 0 then
        pending("Mock notebook not found")
        return
      end

      -- Start watch
      hugo.start_watch(mock_notebook)

      -- Try to start again
      local result = hugo.start_watch(mock_notebook)
      assert.is_false(result.ok)
      assert.are.equal("Watch already running", result.error)

      -- Clean up
      hugo.stop_watch()
    end)
  end)

  describe("stop_watch", function()
    it("returns error when not watching", function()
      -- Ensure not watching
      if hugo.is_watching() then
        hugo.stop_watch()
      end

      local result = hugo.stop_watch()
      assert.is_false(result.ok)
      assert.are.equal("No watch process running", result.error)
    end)

    it("stops running watch", function()
      local detection = hugo.detect()
      if not detection.found then
        pending("Hugo not installed, skipping watch test")
        return
      end

      local plugin_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
      local mock_notebook = plugin_root .. "/tests/fixtures/mock-notebook"

      if vim.fn.isdirectory(mock_notebook) == 0 then
        pending("Mock notebook not found")
        return
      end

      -- Start watch first
      hugo.start_watch(mock_notebook)
      assert.is_true(hugo.is_watching())

      -- Stop it
      local result = hugo.stop_watch()
      assert.is_true(result.ok)
      assert.is_false(hugo.is_watching())
    end)
  end)
end)
