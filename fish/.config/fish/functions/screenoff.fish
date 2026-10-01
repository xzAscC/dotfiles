function screenoff --description 'Turn off all monitors (DPMS); GPU and processes keep running'
    # Wait so the Enter key release doesn't immediately wake the screens
    sleep (set -q argv[1]; and echo $argv[1]; or echo 1)
    hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
end
