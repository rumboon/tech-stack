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
    set -l include_versions $argv[2] # "true" for languages, "false" for tech

    set -l results

    if not test -f $rules_file; or not command -v jq >/dev/null 2>&1
        return 1
    end

    set -l rule_count (jq '.rules | length' $rules_file)
    for i in (seq 0 (math $rule_count - 1))
        set -l name (jq -r ".rules[$i].name" $rules_file)
        set -l icon (jq -r ".rules[$i].icon" $rules_file)
        set -l color (jq -r ".rules[$i].color // \"white\"" $rules_file)
        set -l bg_color (jq -r ".rules[$i].bg_color // \"black\"" $rules_file)
        set -l file_indicators (jq -r ".rules[$i].file_indicators[]" $rules_file)

        if _check_file_indicators $file_indicators
            if _apply_special_rules $name "true"
                # Handle version detection for languages
                if test "$include_versions" = "true"
                    set -l lang_version (_tech_stack_version $name)
                    set -l tech_name
                    set -l icon_with_bracket

                    if test -n "$lang_version"
                        set tech_name "$name"_"v$lang_version]"
                        set icon_with_bracket "[$icon "
                    else
                        set tech_name "$name"_"?]"
                        set icon_with_bracket "[$icon "
                    end
                    set -a results "$tech_name|$icon_with_bracket|$color|$bg_color"
                else
                    # Tech stacks don't have versions
                    set -a results "$name|$icon|$color|$bg_color"
                end
            end
        end
    end

    # Output results (one per line)
    for result in $results
        echo $result
    end
end