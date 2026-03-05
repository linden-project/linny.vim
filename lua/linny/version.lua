local M = {}

local function get_plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(source, ":h:h:h")
end

local function read_version()
  local root = get_plugin_root()
  local f = io.open(root .. "/VERSION", "r")
  if f then
    local version = f:read("*l")
    f:close()
    return version
  end
  return "unknown"
end

function M.plugin_version()
  return read_version()
end

return M
