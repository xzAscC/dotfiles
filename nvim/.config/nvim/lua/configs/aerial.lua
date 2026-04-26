return {
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = {
    default_direction = "right",
    min_width = 30,
  },
  attach_mode = "window",
  close_automatic_events = { "unsupported" },
  highlight_on_hover = true,
  show_guides = true,

  filter_kind = false,
  nerd_font = false,

  guides = {
    mid_item = "├─ ",
    last_item = "└─ ",
    nested_top = "│  ",
    whitespace = "   ",
  },

  icons = {
    python = {
      Class = "class ",
      Function = "def ",
      Method = "def ",
      Variable = "var ",
      Constant = "const ",
      Field = "attr ",
      Property = "prop ",
      Module = "mod ",
      Constructor = "new ",
      Collapsed = "▸ ",
    },

    _ = {
      Class = "class ",
      Function = "func ",
      Method = "func ",
      Variable = "var ",
      Constant = "const ",
      Field = "field ",
      Property = "prop ",
      Module = "mod ",
      Collapsed = "▸ ",
    },
  },
}
