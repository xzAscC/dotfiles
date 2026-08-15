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
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.scrollbind = true
          vim.opt_local.cursorbind = true
          pcall(function()
            require("render-markdown").buf_disable()
          end)
        end,
        diff_buf_win_enter = function()
          vim.opt_local.wrap = false
          vim.opt_local.scrollbind = true
          vim.opt_local.cursorbind = true
          pcall(function()
            require("render-markdown").buf_disable()
          end)
        end,
        view_enter = function()
          vim.cmd "syncbind"
        end,
      },
    },
  },

  {
    "lervag/vimtex",
    lazy = false,
    ft = { "tex", "latex" },
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-omni" },
    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      local sources = vim.deepcopy(opts.sources)
      table.insert(sources, { name = "omni" })
      cmp.setup.filetype({ "tex", "plaintex", "latex" }, { sources = sources })
    end,
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
    "babarot/markdown-preview.nvim",
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    opts = {},
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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      image = {
        enabled = true,
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
          "mp4",
          "mov",
          "avi",
          "mkv",
          "webm",
          "pdf",
          "icns",
          "svg",
        },
        doc = {
          enabled = true,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
      },
    },
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

  {
    "dautroc/nvim-flashcard",
    cmd = "Flashcard",
    keys = {
      { "<leader>fl", "<cmd>Flashcard learn<cr>", desc = "Flashcard learn" },
      { "<leader>fe", "<cmd>Flashcard edit<cr>", desc = "Flashcard edit" },
      { "<leader>fc", "<cmd>Flashcard create<cr>", desc = "Flashcard create" },
      { "<leader>fo", "<cmd>Flashcard overview<cr>", desc = "Flashcard overview" },
    },
    opts = {
      decks_dir = vim.fn.expand "~/JD/20 Anki/20.01 LANG",
      new_cards_per_day = 20,
      picker = "snacks",
      keymaps = {
        reveal = "<Space>",
        again = "1",
        hard = "2",
        good = "3",
        easy = "4",
        quit = "q",
      },
      window = { width = 0.5, height = 0.4, border = "rounded" },
    },
  },
}
