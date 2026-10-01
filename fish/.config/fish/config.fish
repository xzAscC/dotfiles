# Commands to run in interactive sessions can go here
if status is-interactive
    # Greeting: fastfetch once per terminal window. SHLVL is unreliable here
    # (Hyprland launches kitty via a bash script), so use an exported guard
    # that nested fish shells inherit.
    function fish_greeting
        if type -q fastfetch; and not set -q SSH_TTY; and not set -q __fastfetch_shown; and test "$TERM" != linux
            set -gx __fastfetch_shown 1
            fastfetch
        end
    end

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != linux
        starship init fish | source
        enable_transience
    end

    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        command cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Syntax highlighting: the single source of truth for the fish theme.
    # ANSI names follow the quickshell palette; 252 is remapped to
    # secondaryContainer by the generated kitty theme.
    set -g fish_color_normal normal
    set -g fish_color_command blue --bold
    set -g fish_color_keyword magenta --bold
    set -g fish_color_param normal
    set -g fish_color_option cyan
    set -g fish_color_quote green
    set -g fish_color_redirection cyan --bold
    set -g fish_color_end cyan
    set -g fish_color_operator cyan
    set -g fish_color_escape brcyan
    set -g fish_color_comment brblack --italics
    set -g fish_color_error red --bold
    set -g fish_color_autosuggestion brblack
    set -g fish_color_valid_path --underline
    set -g fish_color_cancel --reverse
    set -g fish_color_history_current --bold
    set -g fish_color_search_match --background=252
    set -g fish_color_selection --background=252
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_user brgreen
    set -g fish_color_host normal
    set -g fish_color_host_remote yellow
    set -g fish_color_status red
    set -g fish_pager_color_prefix cyan --bold
    set -g fish_pager_color_completion normal
    set -g fish_pager_color_description brblack --italics
    set -g fish_pager_color_progress brblack
    set -g fish_pager_color_selected_background --background=252

    # Environment
    set -q VISUAL; or set -gx VISUAL nvim
    # Man pages in nvim: treesitter highlighting, gO outline, K to follow refs
    set -gx MANPAGER 'nvim +Man!'

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    function clear --description 'Clear screen and scrollback'
        printf '\033[2J\033[3J\033[1;1H'
    end
    alias celar clear
    alias claer clear
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != linux
        alias ls 'eza --icons=auto --group-directories-first'
    end
    abbr -a ll 'eza --icons=auto -l --git --header --time-style=relative --group-directories-first'
    abbr -a la 'eza --icons=auto -la --git --header --time-style=relative --group-directories-first'
    abbr -a lt 'eza --icons=auto --tree --level=2'
    abbr -a gs 'git status -sb'
    abbr -a gd 'git diff'
    abbr -a ga 'git add'
    abbr -a gc 'git commit'
    abbr -a gp 'git push'
    abbr -a gl 'git log --oneline --graph --decorate -20'

    # Tools
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q fzf
        fzf --fish | source
        set -gx FZF_DEFAULT_OPTS "--height=40% --layout=reverse --border=rounded --info=inline \
--color=fg:7,bg:-1,hl:6,fg+:15,bg+:252,hl+:14 \
--color=border:245,prompt:255,pointer:255,marker:2,spinner:255,header:5,info:8"
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
        # `||` instead of fish's `; or`: fzf runs previews with $SHELL, which may not be fish
        set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:200 {} 2>/dev/null || head -200 {}'"
        set -gx FZF_ALT_C_OPTS "--preview 'eza --icons=always --tree --level=2 --color=always {}'"
    end
    if type -q bat
        set -gx BAT_THEME ansi
        alias cat 'bat --paging=never --style=plain'
    end
    if test "$TERM" = xterm-kitty
        alias ssh 'kitten ssh'
    end
end

# Added by git-ai installer on Sat Sep 26 23:32:51 2026
fish_add_path -g "/home/xzascc/.git-ai/bin"
