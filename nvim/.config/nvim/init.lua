---@diagnostic disable: undefined-global
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.g.vscode_snippets_exclude = { "tex", "plaintex" }
vim.g.vscode_snippets_path = vim.fn.stdpath "config" .. "/snippets"

vim.api.nvim_create_user_command("ClearMarks", function()
  vim.cmd "delmarks!"
  pcall(function()
    vim.cmd "delmarks A-Z0-9"
  end)
  vim.cmd "wshada!"
  vim.notify "Cleared local, global, and ShaDa marks"
end, { desc = "Clear local/global marks and persist ShaDa" })

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

-- nvim tree setting 
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
