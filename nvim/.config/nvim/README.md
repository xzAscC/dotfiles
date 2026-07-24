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
- Kitty 0.28+ and ImageMagick 7 with the `rsvg` delegate for in-editor image/SVG previews
- `mpv` (with Kitty video output) and optional `yt-dlp` for YouTube/stream URLs via `<leader>mv`
- `stylua` (for Lua formatting)
- `pyright` (for Python LSP)
- `latexmk` and a PDF viewer (`skim` on macOS, `zathura` on Linux) for VimTeX
- `gh` CLI with `yusukebe/gh-markdown-preview` extension for browser-based GitHub Markdown preview
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
    ├── utils
    │   ├── kitty_mpv.lua    # Kitty + mpv media playback helper
    │   └── xattr.lua        # Dolphin-compatible xattr tags/comment/rating
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
- `MeanderingProgrammer/render-markdown.nvim`
- `babarot/markdown-preview.nvim`
- `folke/snacks.nvim` (image and SVG rendering)
- `dautroc/nvim-flashcard` (SM-2 flashcards; decks in `~/JD/20 Anki/20.01 LANG`)

Everything else comes from NvChad and the pinned `lazy-lock.json`.

## Keymaps

- `<Space>` is the leader key
- `;` in normal mode enters command-line mode (`:`)
- `jk` in insert mode exits to normal mode
- `<Alt-h/j/k/l>` moves between Neovim windows, including terminal windows
- `<C-n>` toggles NvimTree
- `<leader>p` opens the compiled PDF for the current TeX buffer
- `<leader>mp` toggles in-editor Markdown rendering
- `<leader>mP` toggles browser-based GitHub-style Markdown preview
- `<leader>mv` plays media under cursor/selection (or video buffer) with `mpv --vo=kitty` in a Kitty window; also `:KittyMpv [path|url]`
- `<leader>oc` / `:OpenCode [dir]` opens `opencode` inside a tmux session in a float terminal (`-A` attaches if the session already exists); `<leader>oC` / `:OpenCodeSp` horizontal, `:OpenCodeVsp` vertical
- Flashcards (`nvim-flashcard`, no Anki app): `<leader>fl` learn, `<leader>fe` edit, `<leader>fc` create, `<leader>fo` overview; also `:Flashcard …`
- LSP buffer-local maps on attach: `gd`, `gr`, `gD`, `gi`, `K`
- Python, shell, and Lua files support structural folding for functions, classes, loops, and
  control blocks; use `zc`/`zo` to close/open a fold, or `zM`/`zR` to close/open all folds.

## Notes

- Python host provider is enabled when `~/.local/share/nvim/venv/bin/python` exists.
- `vimtex` compiler is set to `latexmk`; quickfix auto-open is disabled.
- NvimTree closes automatically if it is the last remaining window.
- `<leader>mv` launches an external Kitty window running mpv (not an in-buffer player). Quit with `q` in mpv.
- Flashcard decks are Markdown under `~/JD/20 Anki/20.01 LANG` (`---` between cards, `?` between front/back). Scheduling state is sibling `*.state.json`.
- Paper reading inbox: Zathura keys `t` / `T` / `<C-t>` run `scripts/zathura-todo` and append to `~/JD/20 Anki/20.01 LANG/todo.md` (shared file, not per-PDF).
