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
    set -l category $argv[1]  # "langs" or "mods"
    set -l icon $argv[2]
    set -l label $argv[3]
    set -l color $argv[4]
    set -l bg_color $argv[5]
    set -l tech_version $argv[6]

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

    # Determine if version should be shown based on category-specific or global setting
    set -l show_version "$TECH_STACK_SHOW_VERSION"
    if test "$category" = "langs"; and set -q TECH_STACK_SHOW_VERSION_LANGS
        set show_version "$TECH_STACK_SHOW_VERSION_LANGS"
    else if test "$category" = "mods"; and set -q TECH_STACK_SHOW_VERSION_MODS
        set show_version "$TECH_STACK_SHOW_VERSION_MODS"
    end

    # Add version if available and enabled
    if test -n "$tech_version"; and test "$show_version" = "true"
        set display_text "$display_text $tech_version"
    end

    # Determine color mode based on stacked-prompt scheme first, then category-specific or global setting
    set -l color_config
    if set -q STACKED_PROMPT_COLOR_SCHEME
        # Coordinate with stacked-prompt color scheme
        switch $STACKED_PROMPT_COLOR_SCHEME
            case default
                set color_config green --dim
            case minimal
                set color_config brblack
            case vibrant
                set color_config brcyan
            case ocean
                set color_config blue --dim
            case gruvbox
                set color_config blue --dim
            case nord
                set color_config 5E81AC --dim # Nord9
            case custom
                # Fall through to tech-stack config
                if test "$category" = "langs"; and set -q TECH_STACK_COLOR_LANGS
                    set color_config $TECH_STACK_COLOR_LANGS
                else if test "$category" = "mods"; and set -q TECH_STACK_COLOR_MODS
                    set color_config $TECH_STACK_COLOR_MODS
                else
                    set color_config green --dim
                end
            case '*'
                set color_config green --dim
        end
    else if test "$category" = "langs"; and set -q TECH_STACK_COLOR_LANGS
        set color_config $TECH_STACK_COLOR_LANGS
    else if test "$category" = "mods"; and set -q TECH_STACK_COLOR_MODS
        set color_config $TECH_STACK_COLOR_MODS
    else if set -q TECH_STACK_COLOR_MODE
        set color_config $TECH_STACK_COLOR_MODE
    else
        set color_config "full"
    end

    # Apply color formatting based on mode
    set -l colored_tech
    # Check if it's a single predefined mode
    if test (count $color_config) -eq 1
        switch $color_config[1]
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
                # Custom set_color arguments (e.g., "green" or single arg)
                set colored_tech (set_color $color_config[1])"$display_text"(set_color normal)
        end
    else
        # Multiple arguments (e.g., "green --dim")
        set colored_tech (set_color $color_config)"$display_text"(set_color normal)
    end

    echo "$colored_tech"
end

function _tech_stack_formatting --description 'Format detection results into colored output'
    set -l category $argv[1] # "langs" or "mods"
    set -l results $argv[2..-1]
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
            set formatted_output "$formatted_output "
        end
        set first_item false

        set -l formatted_tech (_format_technology $category $icon $label $color $bg_color $tech_version)
        set formatted_output "$formatted_output$formatted_tech"
    end

    # Add indicator if there are more technologies
    if test (count $unique_results) -gt $max_display
        set formatted_output "$formatted_output…"
    end

    echo "$formatted_output"
end
