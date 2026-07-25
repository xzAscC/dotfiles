# dotfiles

Centralized dotfiles for fish, Neovim, OpenCode, and Zathura managed with GNU Stow.

## Layout

- `fish/.config/fish`
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
stow fish nvim opencode zathura
```

## Re-link on this machine

From `~/dotfiles` run:

```bash
stow --restow fish nvim opencode zathura
```

## Remove links

```bash
stow --delete fish nvim opencode zathura
```
