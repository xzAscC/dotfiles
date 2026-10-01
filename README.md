# dotfiles

Centralized dotfiles for fish, kitty, Neovim, OpenCode, and Zathura managed with GNU Stow.

## Layout

- `fish/.config/fish`
- `kitty/.config/kitty` (colors are included from the quickshell-generated theme)
- `nvim/.config/nvim`
- `opencode/.config/opencode`
- `zathura/.config/zathura`

## Requirements

- `git`
- `stow`

## Bootstrap on a new machine

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow fish kitty nvim opencode zathura
```

## Re-link on this machine

From `~/dotfiles` run:

```bash
stow --restow fish kitty nvim opencode zathura
```

## Remove links

```bash
stow --delete fish kitty nvim opencode zathura
```
