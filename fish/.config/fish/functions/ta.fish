function ta --description 'Switch/attach to another tmux session (fzf picker, or `ta NAME`)'
    if not tmux has-session 2>/dev/null
        echo "ta: no tmux sessions" >&2
        return 1
    end

    set -l current
    if set -q TMUX
        set current (tmux display-message -p '#S')
    end

    set -l target $argv[1]
    if test -z "$target"
        # name, pinned?, windows, active command, cwd; current session excluded.
        # Kept as one shell string so fzf can rerun it to reload after a kill.
        set -l list_cmd "tmux list-sessions -f '#{!=:#{session_name},$current}' -F '#{session_name}|#{?#{==:#{destroy-unattached},off},pinned,temp}|#{session_windows}w|#{pane_current_command}|#{pane_current_path}' | column -t -s '|'"
        if test (count (eval $list_cmd)) -eq 0
            echo "ta: no other tmux sessions" >&2
            return 1
        end
        set target (eval $list_cmd |
            fzf --prompt 'tmux> ' --header 'enter: switch   ctrl-x: kill session' \
                --preview 'tmux capture-pane -ep -t ={1}:' --preview-window right,60% \
                --bind "ctrl-x:execute-silent(tmux kill-session -t ={1})+reload($list_cmd)" |
            string split -f1 ' ')
        test -n "$target"; or return 1
    end

    if set -q TMUX
        # Leaving a throwaway session destroys it. That's fine for the idle
        # shell running `ta`, but pin it if anything else lives in it.
        if test (tmux display-message -p '#{&&:#{==:#{session_windows},1},#{==:#{window_panes},1}}') = 0
            tmux set-option destroy-unattached off
        end
        tmux switch-client -t "=$target"
    else
        tmux attach-session -t "=$target"
    end
end
