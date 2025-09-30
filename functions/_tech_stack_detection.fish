#!/usr/bin/env fish

function _check_file_indicators --description 'Check if file indicators exist'
    set -l file_indicators $argv

    for indicator in $file_indicators
        # Handle glob patterns (containing asterisks)
        if string match -q "*\**" $indicator
            # Use find for reliable glob pattern matching and check if it actually found files
            set -l found_files (find . -name "$indicator" -type f -print -quit 2>/dev/null)
            if test -n "$found_files"
                return 0
            end
        else if test -f $indicator -o -d $indicator
            return 0
        end
    end
    return 1
end

function _apply_special_rules --description 'Apply special detection rules for complex technologies'
    set -l name $argv[1]
    set -l found_indicator $argv[2]

    if test $found_indicator != "true"
        return 1
    end

    # iOS requires BOTH ios directory AND xcodeproj files
    if test "$name" = "ios"
        if test -d ios; and ls *.xcodeproj >/dev/null 2>&1
            return 0
        end
        return 1
    end

    # Default: if found_indicator is true, accept it
    return 0
end

function _tech_stack_detection --description 'Detect technologies from rules file'
    set -l rules_file $argv[1]

    set -l results

    if not test -f $rules_file; or not command -v jq >/dev/null 2>&1
        return 1
    end

    # Parse all rules at once to avoid repeated jq calls
    set -l rules_data (jq -r '.rules[] | "\(.id)|\(.icon)|\(.label)|\(.color // "white")|\(.bg_color // "black")|\(.file_indicators | join(","))"' $rules_file)
    for rule_line in $rules_data
        set -l parts (string split "|" $rule_line)
        set -l name $parts[1]
        set -l icon $parts[2]
        set -l label $parts[3]
        set -l color $parts[4]
        set -l bg_color $parts[5]
        set -l file_indicators (string split "," $parts[6])

        if _check_file_indicators $file_indicators
            if _apply_special_rules $name "true"
                # Get version for both languages and mods
                set -l tech_version (_tech_stack_version $name)
                set -a results "$name|$icon|$label|$color|$bg_color|$tech_version"
            end
        end
    end

    # Output results (one per line)
    for result in $results
        echo $result
    end
end