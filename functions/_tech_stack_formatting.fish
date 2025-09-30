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
    set -l icon $argv[1]
    set -l label $argv[2]
    set -l color $argv[3]
    set -l bg_color $argv[4]
    set -l tech_version $argv[5]

    # Determine display format
    set -l display_format "label"
    if set -q TECH_STACK_DISPLAY_FORMAT
        set display_format $TECH_STACK_DISPLAY_FORMAT
    end

    # Build the display text based on format
    set -l display_text
    switch $display_format
        case "icon_label"
            set display_text "$icon $label"
        case "icon"
            set display_text "$icon"
        case "label"
            set display_text "$label"
        case "*"
            set display_text "$label"  # Default fallback
    end

    # Add version if available and enabled
    if test -n "$tech_version"; and test "$TECH_STACK_SHOW_VERSION" = "true"
        set display_text "$display_text $tech_version"
    end

    # Determine color mode
    set -l color_mode "full"
    if set -q TECH_STACK_COLOR_MODE
        set color_mode $TECH_STACK_COLOR_MODE
    end

    # Apply color formatting based on mode
    set -l colored_tech
    switch $color_mode
        case "full"
            # Background + foreground color
            set colored_tech (set_color --background $bg_color $color)"$display_text"(set_color normal)
        case "foreground"
            # Only foreground color, no background
            set colored_tech (set_color $color)"$display_text"(set_color normal)
        case "none"
            # No colors, plain text
            set colored_tech "$display_text"
        case "*"
            # Default fallback to full color
            set colored_tech (set_color --background $bg_color $color)"$display_text"(set_color normal)
    end

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

        set -l formatted_tech (_format_technology $icon $label $color $bg_color $tech_version)
        set formatted_output "$formatted_output$formatted_tech"
    end

    # Add indicator if there are more technologies
    if test (count $unique_results) -gt $max_display
        set formatted_output "$formatted_output…"
    end

    echo "$formatted_output"
end
