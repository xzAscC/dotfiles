# dotfiles-nvim

Personal Neovim config built on [NvChad](https://github.com/NvChad/NvChad) with a focused custom layer for:

- Lua formatting (`conform.nvim` + `stylua`)
- Python LSP (`pyright`)
- File tree behavior (`nvim-tree`)
- LaTeX workflow (`vimtex` + quick PDF open mapping)

## Quick start

1. Clone this repo to your Neovim config location:

```bash
git clone https://github.com/<your-user>/<your-repo>.git ~/.config/nvim
```

2. Start Neovim once to bootstrap plugins.
3. Sync/update plugins when needed:

```bash
nvim --headless "+Lazy! sync" +qa
```

## Requirements

- `nvim` 0.10+
- `git`
- `stylua` (for Lua formatting)
- `pyright` (for Python LSP)
- `latexmk` and a PDF viewer (`skim` on macOS, `zathura` on Linux) for VimTeX
- Optional shell integration: if `fish` exists, it is used as `:set shell`

## Structure

```text
.
├── init.lua                 # Entry point: bootstraps lazy.nvim and loads modules
├── lazy-lock.json           # Plugin lockfile (exact plugin versions)
└── lua
    ├── autocmds.lua         # User autocommands + custom highlights
    ├── chadrc.lua           # NvChad UI/theme config (flouromachine)
    ├── mappings.lua         # Custom keymaps + LSP keymaps on attach
    ├── options.lua          # Editor options, shell/python provider, vimtex settings
    ├── configs
    │   ├── conform.lua      # Formatter setup (Lua -> stylua)
    │   ├── lazy.lua         # lazy.nvim behavior/performance options
    │   ├── lspconfig.lua    # LSP setup (enables pyright)
    │   └── nvimtree.lua     # NvimTree options
    └── plugins
        └── init.lua         # Custom plugin specs
```

## Custom plugins

Declared in `lua/plugins/init.lua`:

- `stevearc/conform.nvim`
- `neovim/nvim-lspconfig`
- `nvim-tree/nvim-tree.lua`
- `tpope/vim-fugitive`
- `lervag/vimtex`

Everything else comes from NvChad and the pinned `lazy-lock.json`.

## Keymaps

- `<Space>` is the leader key
- `;` in normal mode enters command-line mode (`:`)
- `jk` in insert mode exits to normal mode
- `<C-n>` toggles NvimTree
- `<leader>p` opens the compiled PDF for the current TeX buffer
- LSP buffer-local maps on attach: `gd`, `gr`, `gD`, `gi`, `K`

## Notes

- Python host provider is enabled when `~/.local/share/nvim/venv/bin/python` exists.
- `vimtex` compiler is set to `latexmk`; quickfix auto-open is disabled.
- NvimTree closes automatically if it is the last remaining window.
