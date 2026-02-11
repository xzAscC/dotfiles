# dotfiles

Centralized dotfiles for fish, Neovim, and OpenCode managed with GNU Stow.

## Layout

- `fish/.config/fish`
- `nvim/.config/nvim`
- `opencode/.config/opencode`

## Requirements

- `git`
- `stow`

## Bootstrap on a new machine

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow fish nvim opencode
```

## Re-link on this machine

From `~/dotfiles` run:

```bash
stow --restow fish nvim opencode
```

## Remove links

```bash
stow --delete fish nvim opencode
```
