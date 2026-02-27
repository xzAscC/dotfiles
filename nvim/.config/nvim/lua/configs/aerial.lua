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
  filter_kind = { "Class", "Interface", "Struct", "Function", "Method" },
}
