-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  -- autocmds.lua 里的语法高亮覆盖用的就是 catppuccin 色板，两者最协调
  theme = "catppuccin",
  -- 配合 kitty 的 background_opacity 透出壁纸
  transparency = true,
  -- <leader>tt 在两个暗色主题间切换
  theme_toggle = { "catppuccin", "tokyonight" },

  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },

  -- Markdown 任务状态 / 优先级徽章（plugins/init.lua 的 render-markdown + utils/md_task.lua）
  hl_add = {
    RenderMarkdownTaskDone = { fg = "green" },
    RenderMarkdownTaskDoing = { fg = "blue", bold = true },
    RenderMarkdownTaskReview = { fg = "yellow", bold = true },
    RenderMarkdownTaskReviewText = { fg = "yellow", italic = true },
    RenderMarkdownTaskWaiting = { fg = "orange", bold = true },
    RenderMarkdownTaskDeferred = { fg = "purple" },
    RenderMarkdownTaskDim = { fg = "light_grey" },
    RenderMarkdownTaskCancelled = { fg = "light_grey" },
    RenderMarkdownTaskCancelledText = { fg = "light_grey", strikethrough = true },
    RenderMarkdownTaskPrio1 = { fg = "red", bg = "one_bg2", bold = true },
    RenderMarkdownTaskPrio2 = { fg = "orange", bg = "one_bg2", bold = true },
    RenderMarkdownTaskPrio3 = { fg = "nord_blue", bg = "one_bg2" },
    RenderMarkdownTaskPrioDone = { fg = "light_grey", bg = "one_bg" },
  },
}

M.ui = {
  statusline = {
    theme = "default",
    separator_style = "round",
  },
  tabufline = {
    lazyload = false,
  },
  telescope = { style = "bordered" },
  cmp = { style = "atom_colored" },
}

M.nvdash = { load_on_startup = true }

return M
