return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    ft = { "tex", "latex" },
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    branch = "main",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = require "configs.nvimtree",
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "lua")
      table.insert(opts.ensure_installed, "python")
      table.insert(opts.ensure_installed, "bash")
      table.insert(opts.ensure_installed, "html")
      table.insert(opts.ensure_installed, "css")
      table.insert(opts.ensure_installed, "javascript")
    end,
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
    lazy = false,
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

  {
    "wallpants/github-preview.nvim",
    ft = "markdown",
    cmd = { "GithubPreviewStart", "GithubPreviewStop", "GithubPreviewToggle" },
    opts = require "configs.github_preview",
  },

  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
      default_mappings = true,
      mappings = {
        set = "m",
        set_next = "m,",
        toggle = "m;",
        next = "m]",
        prev = "m[",
        preview = "m:",
        set_bookmark0 = "m0",
        delete = "dm",
        delete_line = "dm-",
        delete_buf = "dm<space>",
      },
    },
  },

  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {},
  },

  {
    "3rd/image.nvim",
    event = {
      "VeryLazy",
      "BufReadPre *.png",
      "BufReadPre *.jpg",
      "BufReadPre *.jpeg",
      "BufReadPre *.gif",
      "BufReadPre *.webp",
      "BufReadPre *.avif",
      "BufReadPre *.pdf",
    },
    config = function()
      local image_config = require(table.concat({ "configs", "image" }, "."))

      require("image").setup(image_config)
    end,
  },

  {
    "pwntester/octo.nvim",
    cmd = { "Octo" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = require "configs.octo",
  },
}
