return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
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
    build = ":TSUpdate",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "css",
        "html",
        "javascript",
        "json",
        "latex",
        "markdown",
        "markdown_inline",
        "python",
        "regex",
        "toml",
        "yaml",
      })
    end,
    -- main 分支的 setup() 不再识别 ensure_installed，这里手动补装缺失的 parser
    config = function(_, opts)
      local ts = require "nvim-treesitter"
      ts.setup()

      local installed = require("nvim-treesitter.config").get_installed "parsers"
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, opts.ensure_installed)

      if #missing > 0 then
        ts.install(missing)
      end
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
    -- vimtex 自己按 filetype 延迟加载，官方要求不要交给插件管理器 lazy-load
    "lervag/vimtex",
    lazy = false,
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
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
        sign = true,
        width = "block",
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
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        -- 保留原生 f/t/;/, 行为，只用 s/S 触发 flash
        char = { enabled = false },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter select",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Flash remote",
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
}
