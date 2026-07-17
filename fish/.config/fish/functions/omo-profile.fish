function omo-profile --description 'Switch oh-my-openagent model profile (glm|grok)'
    set -l cfg_dir ~/.config/opencode
    set -l profiles_dir $cfg_dir/profiles
    set -l active $cfg_dir/oh-my-openagent.json

    if test (count $argv) -eq 0
        echo "Usage: omo-profile <glm|grok|list|show>"
        if test -f $active
            echo -n "Active sisyphus: "
            jq -r '.agents.sisyphus.model // "unknown"' $active 2>/dev/null
        end
        return 0
    end

    switch $argv[1]
        case list
            if not test -d $profiles_dir
                echo "No profiles directory: $profiles_dir" >&2
                return 1
            end
            for f in $profiles_dir/*.json
                if test -f $f
                    basename $f .json
                end
            end
        case show
            if not test -f $active
                echo "Active config not found: $active" >&2
                return 1
            end
            jq '{sisyphus: .agents.sisyphus}' $active
        case glm grok
            set -l src $profiles_dir/$argv[1].json
            if not test -f $src
                echo "Profile not found: $src" >&2
                return 1
            end
            # Atomic replace so a partial write cannot leave a broken config
            cp -f -- $src $active.tmp
            and mv -f -- $active.tmp $active
            and echo "Switched to profile: $argv[1]"
            and jq -r '"sisyphus → " + (.agents.sisyphus.model // "unknown")' $active
            and echo "Restart/reopen OpenCode for it to take effect."
        case '*'
            echo "Unknown profile: $argv[1]" >&2
            echo "Available: glm | grok | list | show" >&2
            return 1
    end
end
