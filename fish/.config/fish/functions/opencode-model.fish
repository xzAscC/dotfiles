function opencode-model --description 'Switch between OpenCode model configurations'
    set config_dir ~/.config/opencode
    set active_config $config_dir/oh-my-opencode.json
    
    if not set -q argv[1]
        echo "OpenCode Model Switcher"
        echo "======================"
        echo ""
        if test -L $active_config
            set current_link (readlink $active_config)
            echo "Current config: "(string replace -r '.*oh-my-opencode\.(.+)\.json' '$1' $current_link)
        else if test -f $active_config
            echo "Current config: (not a symlink - use opencode-model to set)"
        end
        echo ""
        echo "Usage: opencode-model <model>"
        echo ""
        echo "Available models:"
        echo "  glm  - Use GLM configuration"
        echo "  gpt  - Use GPT configuration"
        echo "  opus - Use Opus configuration"
        echo "  qwen - Use Qwen configuration (LMStudio local)"
        return 0
    end
    
    switch $argv[1]
        case glm
            set source_config $config_dir/oh-my-opencode.glm.json
        case gpt
            set source_config $config_dir/oh-my-opencode.gpt.json
        case opus
            set source_config $config_dir/oh-my-opencode.opus.json
        case qwen
            set source_config $config_dir/oh-my-opencode.qwen.json
        case '*'
            echo "Error: Unknown model '$argv[1]'"
            echo "Available models: glm, gpt, opus, qwen"
            return 1
    end
    
    if not test -f $source_config
        echo "Error: Config file not found: $source_config"
        return 1
    end
    
    ln -sf $source_config $active_config
    echo "Switched to $argv[1] configuration"
end
