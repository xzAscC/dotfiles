function screenoff --description 'Turn off displays after an optional delay'
    set delay 10

    if test (count $argv) -ge 1
        set delay $argv[1]
    end

    sleep $delay
    hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'
end
