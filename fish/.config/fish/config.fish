# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != "linux"
        starship init fish | source
        enable_transience
    end
    
    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    function rm
        for arg in $argv
            switch $arg
                case '-*f*' '--force'
                    read -l -P "rm with -f detected. Continue? [y/N] " confirm
                    if test "$confirm" != y
                        echo "aborted"
                        return 1
                    end
                    break
            end
        end
        command rm -Iv $argv
    end
    if test "$TERM" != "linux"
        alias ls 'eza --icons'
    end
    if test "$TERM" = "xterm-kitty"
        alias ssh 'kitten ssh'
    end
end

# Added by git-ai installer on Sun Jun 14 01:21:47 AM EDT 2026
fish_add_path -g "/home/xzascc/.git-ai/bin"

# cubic
fish_add_path "/home/xzascc/.cubic/bin"
