#!/usr/bin/env fish

set root (dirname (status filename))
set -l error false

set -l temp_dir "$(mktemp -d)"
fish "$root/tests/_run.fish" "$root/tests/_example_test.fish" "$temp_dir"
or begin
    echo "$root/tests/_example_test.fish has failed, but it should have succeeded" >&2
    cat "$temp_dir/out" >&2
    exit 1
end

set passed 0
set fixed 0
set failed 0
set broken 0

if test (count $argv) = 0
    set argv "$root/tests"
end
for dir in $argv
    find "$dir" -type f -name "[^_]*.fish" | while read -l -d\n test_file
        # FIXME on `-v` echo "$test_file"
        set temp_dir "$(mktemp -d)"
        if fish "$root/tests/_run.fish" "$test_file" "$temp_dir"
            if test -e "$temp_dir/broken"
                # echo "Test $test_file is broken." >&2
                set broken (math $broken + 1)
            else
                # echo "Test $test_file has succeeded." >&2
                set passed (math $passed + 1)
            end
        else
            if test -e "$temp_dir/failure"
                echo "Test $test_file has failed:" >&2
                cat "$temp_dir/out" >&2
                set failed (math $failed + 1)
            else if test -e "$temp_dir/fixed"
                echo "Test $test_file is fixed." >&2
                set fixed (math $fixed + 1)
            else
                echo UNREACHABLE >&2
                exit 42
            end
        end
    end
end

echo "$(math "$passed" + "$fixed" + "$broken" + "$failed") tests finished. $failed failed and $broken broken." >&2
test "$failed" = 0 -a "$fixed" = 0
