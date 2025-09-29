#!/usr/bin/env fish

function _deduplicate_results --description 'Remove duplicate technologies while preserving order'
    set -l input_results $argv
    set -l seen_names
    set -l unique_results

    for result in $input_results
        set -l parts (string split "|" $result)
        set -l name $parts[1]

        if not contains $name $seen_names
            set -a seen_names $name
            set -a unique_results $result
        end
    end

    for result in $unique_results
        echo $result
    end
end

function _format_technology --description 'Format a single technology with colors'
    set -l tech_name $argv[1]
    set -l icon $argv[2]
    set -l color $argv[3]
    set -l bg_color $argv[4]

    # Apply color formatting using Fish's set_color with background and foreground
    set -l colored_icon (set_color --background $bg_color $color)"$icon"(set_color normal)

    # Check if tech has version info (for languages)
    if string match -q "*_*" $tech_name
        set -l parts (string split "_" $tech_name)
        set -l colored_version (set_color --background $bg_color $color)"$parts[2]"(set_color normal)
        echo "$colored_icon$colored_version"
    else
        echo "$colored_icon"
    end
end

function _tech_stack_formatting --description 'Format detection results into colored output'
    set -l results $argv
    set -l max_display $argv[-1] # Last argument is max display count
    set -l results_without_max $results[1..-2] # All except last

    if test (count $results_without_max) -eq 0
        return 0
    end

    # Deduplicate first
    set -l unique_results (_deduplicate_results $results_without_max)

    # Apply display limit
    set -l display_count (math "min($max_display, "(count $unique_results)")")
    set -l limited_results $unique_results[1..$display_count]

    set -l formatted_output ""
    set -l first_item true

    for result in $limited_results
        set -l parts (string split "|" $result)
        set -l tech_name $parts[1]
        set -l icon $parts[2]
        set -l color $parts[3]
        set -l bg_color $parts[4]

        if test $first_item != "true"
            set formatted_output "$formatted_output "
        end
        set first_item false

        set -l formatted_tech (_format_technology $tech_name $icon $color $bg_color)
        set formatted_output "$formatted_output$formatted_tech"
    end

    # Add indicator if there are more technologies
    if test (count $unique_results) -gt $max_display
        set formatted_output "$formatted_output…"
    end

    echo $formatted_output
end