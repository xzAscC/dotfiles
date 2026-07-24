local M = {}

local SESSION_PREFIX = "opencode"

local function have(bin)
  return vim.fn.executable(bin) == 1
end

---@param cwd string
---@return string
local function session_name(cwd)
  local base = vim.fn.fnamemodify(cwd, ":t")
  if base == "" or base == "/" then
    base = "root"
  end
  base = base:gsub("[^%w._-]", "_")
  local hash = vim.fn.sha256(cwd):sub(1, 8)
  return string.format("%s-%s-%s", SESSION_PREFIX, base, hash)
end

---@param cwd string|nil
---@return string|nil cmd
---@return string|nil err
function M.cmd(cwd)
  if not have "tmux" then
    return nil, "tmux not found in PATH"
  end
  if not have "opencode" then
    return nil, "opencode not found in PATH"
  end

  cwd = cwd and vim.fn.expand(cwd) or vim.fn.getcwd()
  if vim.fn.isdirectory(cwd) == 0 then
    return nil, "not a directory: " .. cwd
  end

  local name = session_name(cwd)
  return string.format(
    "tmux new-session -A -s %s -c %s -- opencode",
    vim.fn.shellescape(name),
    vim.fn.shellescape(cwd)
  )
end

---@param opts? { pos?: string, cwd?: string, id?: string }
function M.open(opts)
  opts = opts or {}
  local cmd, err = M.cmd(opts.cwd)
  if not cmd then
    vim.notify(err or "failed to build opencode command", vim.log.levels.ERROR)
    return
  end

  local pos = opts.pos or "float"
  local id = opts.id or ("opencode_" .. pos)

  require("nvchad.term").toggle {
    pos = pos,
    id = id,
    cmd = cmd,
  }
end

return M
