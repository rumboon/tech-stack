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
    set -l id $argv[1]
    set -l color $argv[2]
    set -l bg_color $argv[3]
    set -l tech_version $argv[4]

    # Build the complete display string
    set -l display_text $id
    if test -n "$tech_version"
        set display_text "$id $tech_version"
    end

    # Apply color formatting to the complete string
    set -l colored_tech (set_color --background $bg_color $color)"$display_text"(set_color normal)
    echo "$colored_tech"
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
        set -l label $parts[3]
        set -l color $parts[4]
        set -l bg_color $parts[5]
        set -l tech_version $parts[6]

        if test $first_item != true
            set formatted_output "$formatted_output, "
        end
        set first_item false

        set -l formatted_tech (_format_technology $label $color $bg_color $tech_version)
        set formatted_output "$formatted_output$formatted_tech"
    end

    # Add indicator if there are more technologies
    if test (count $unique_results) -gt $max_display
        set formatted_output "$formatted_output…"
    end

    echo "$formatted_output"
end
