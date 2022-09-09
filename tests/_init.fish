# Initialization file for the tests

# TODO error handling

set temp_dir "$argv[1]"
if test (count $_broken) = 0 -o -n "$_broken"
    touch "$temp_dir/broken"
end
set result success

function validate_val -a caption value expected
    if test (count $expected) -gt 0 -a "$value" != "$expected"
        echo "$caption $(string escape "$value") ($(string escape "$expected") expected)" >> "$temp_dir/out"
        set result failure
    else
        echo "$caption $(string escape "$value")" >> "$temp_dir/out"
    end
end

function validate
    validate_val "Bind mode:        " "$fish_bind_mode" $_mode
    validate_val "Cursor line:      " "$(commandline --line)" $_line
    validate_val "Cursor position:  " "$(commandline --cursor)" $_cursor
    validate_val "Buffer content:   " "$(commandline)" $_buffer
    validate_val "Selection content:" "$(commandline --current-selection)" $_selection

    echo $result >> "$temp_dir/result/result"
    exit
end

set -g fish_key_bindings fish_helix_key_bindings
bind --user --erase --all
for mode in default visual insert
    bind --user -M $mode -k f12 validate
end
bind --user -M insert -m default -k f11 ''

for sequence in $_input
    switch "$sequence"
    case "Normal"
        tmux send-keys F11
    case "Line"
        tmux send-keys F11 o
    case '*'
        tmux send-keys $sequence
    end
end
tmux send-keys F12
