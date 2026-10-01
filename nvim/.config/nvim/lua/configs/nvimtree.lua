local api = require "nvim-tree.api"

return {
  on_attach = function(bufnr)
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    vim.keymap.set("n", "B", api.marks.clear, opts "Clear all bookmarks")
  end,
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 34,
  },
  renderer = {
    group_empty = true,
    root_folder_label = ":t",
    highlight_git = "name",
    indent_markers = {
      enable = true,
    },
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
    -- 噪音目录默认隐藏，按 U 切换显示
    custom = { "^\\.git$", "^\\.omo$", "^\\.playwright-mcp$", "^\\.pytest_cache$", "^\\.ruff_cache$", "^__pycache__$" },
  },
  bookmarks = {
    persist = true,
  },
}
