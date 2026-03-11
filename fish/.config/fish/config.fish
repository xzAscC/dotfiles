function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Use starship
    starship init fish | source
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # codex


    # Aliases
    alias pamcan pacman

    # OpenCode model switcher (basic - only switches sisyphus/prometheus/metis)
    function ocode-switch
        set -l model $argv[1]
        set -l config ~/.config/opencode/oh-my-opencode.json
        set -l agents sisyphus prometheus metis

        for agent in $agents
            jq --arg m "$model" ".agents.$agent.model = \$m" $config > /tmp/oh-my-opencode.tmp && mv /tmp/oh-my-opencode.tmp $config
        end
        echo "✓ Switched to $model"
    end

    # Switch to GLM mode (all claude → glm-5)
    function ocode-glm
        cp ~/.config/opencode/oh-my-opencode.glm.json ~/.config/opencode/oh-my-opencode.json
        echo "✓ Switched to GLM mode"
        opencode $argv
    end

    # Switch to Opus mode (all glm-5 → claude-opus-4-6)
    function ocode-opus
        cp ~/.config/opencode/oh-my-opencode.opus.json ~/.config/opencode/oh-my-opencode.json
        echo "✓ Switched to Opus mode"
        opencode $argv
    end

    # Switch to GPT mode (all glm-5 → gpt-5.4)
    function ocode-gpt
        cp ~/.config/opencode/oh-my-opencode.gpt.json ~/.config/opencode/oh-my-opencode.json
        echo "✓ Switched to GPT mode"
        opencode $argv
    end

    # Switch to Qwen mode (all glm-5 → qwen3.5-9b via LMStudio)
    function ocode-qwen
        cp ~/.config/opencode/oh-my-opencode.qwen.json ~/.config/opencode/oh-my-opencode.json
        echo "✓ Switched to Qwen mode"
        opencode $argv
    end
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    # pnpm for fish
    set -gx PNPM_HOME /home/xzascc/.local/share/pnpm

    if not contains $PNPM_HOME $PATH
      set -gx PATH $PNPM_HOME $PATH
    end

end
