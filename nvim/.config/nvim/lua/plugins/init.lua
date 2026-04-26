return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = require "configs.nvimtree",
  },

  {
    "stevearc/aerial.nvim",
    cmd = { "AerialOpen", "AerialToggle", "AerialNavToggle" },
    opts = require "configs.aerial",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },

  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {
      enhanced_diff_hl = false,
    },
  },

  {
    "lervag/vimtex",
    lazy=false,
    ft = { "tex", "latex" },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    opts = {
      heading = {
        icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      },
      code = {
        sign = true,
        width = 'block',
        right_pad = 1,
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
