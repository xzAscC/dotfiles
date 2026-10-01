---@diagnostic disable: undefined-global
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
-- <localleader>：必须在 lazy 加载前设置。Neovim 默认 nil 时会被展开成空串，octo 等插件注册的
-- <localleader>X 会退化成裸 X 被其他映射截获。显式设成 \ 恢复预期行为。
vim.g.maplocalleader = "\\"
vim.g.vscode_snippets_exclude = { "tex", "plaintex" }
vim.g.vscode_snippets_path = vim.fn.stdpath "config" .. "/snippets"

local fish = vim.fn.exepath "fish"
if fish ~= "" then
  vim.o.shell = fish
end

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local result = vim.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }):wait()

  if result.code ~= 0 then
    vim.notify("Failed to clone lazy.nvim: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
  end
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"

require "autocmds"

vim.schedule(function()
  require "mappings"
end)
