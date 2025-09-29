function _tech_stack_worker --description 'Background worker function for comprehensive technology detection'
    # Get the variable name from command line argument
    set tech_var_name $argv[1]

    # Get current working directory (not necessarily git root)
    set work_dir $PWD

    # Set maximum number of technologies to display (customizable)
    # Can be overridden by setting TECH_DISPLAY_LIMIT or tech_display_limit
    set -l max_tech_display 24
    if set -q TECH_DISPLAY_LIMIT
        set max_tech_display $TECH_DISPLAY_LIMIT
    else if set -q tech_display_limit
        set max_tech_display $tech_display_limit
    end

    # Load JSON configuration files
    # Fisher automatically copies these to the Fish config directory
    set -l tech_rules_json "$TECH_STACK_CONFIG_DIR/tech_rules.json"
    set -l language_rules_json "$TECH_STACK_CONFIG_DIR/language_rules.json"

    set -l lang_techs
    set -l lang_icons
    set -l lang_colors
    set -l lang_bg_colors
    set -l tech_techs
    set -l tech_icons
    set -l tech_colors
    set -l tech_bg_colors

    # Change to working directory for file tests
    cd $work_dir

    # Process language detection (with versions) using jq
    if test -f $language_rules_json; and command -v jq >/dev/null 2>&1
        set -l lang_count (jq '.language_rules | length' $language_rules_json)
        for i in (seq 0 (math $lang_count - 1))
            set -l name (jq -r ".language_rules[$i].name" $language_rules_json)
            set -l icon (jq -r ".language_rules[$i].icon" $language_rules_json)
            set -l color (jq -r ".language_rules[$i].color // \"white\"" $language_rules_json)
            set -l bg_color (jq -r ".language_rules[$i].bg_color // \"black\"" $language_rules_json)
            set -l file_indicators (jq -r ".language_rules[$i].file_indicators[]" $language_rules_json)
            set -l version_cmd (jq -r ".language_rules[$i].version_cmd" $language_rules_json)
            set -l version_extract (jq -r ".language_rules[$i].version_extract" $language_rules_json)

            # Check if any file indicators exist
            set -l found_indicator false
            for indicator in $file_indicators
                # Handle glob patterns (containing asterisks)
                if string match -q "*\**" $indicator
                    if eval "count $indicator >/dev/null 2>&1"
                        set found_indicator true
                        break
                    end
                else if test -f $indicator -o -d $indicator
                    set found_indicator true
                    break
                end
            end

            if test $found_indicator = true
                # Try to get version
                set -l lang_version
                if command -v (echo $version_cmd | awk '{print $1}') >/dev/null 2>&1
                    set lang_version (eval $version_cmd 2>/dev/null | eval $version_extract 2>/dev/null)
                end

                if test -n "$lang_version"
                    set -a lang_techs "$name"_"v$lang_version]"
                else
                    set -a lang_techs "$name"_"?]"
                end
                set -a lang_icons "[$icon "
                set -a lang_colors $color
                set -a lang_bg_colors $bg_color
            end
        end
    end

    # Process simple rule-based technologies using jq directly
    if test -f $tech_rules_json; and command -v jq >/dev/null 2>&1
        set -l rule_count (jq '.tech_rules | length' $tech_rules_json)
        for i in (seq 0 (math $rule_count - 1))
            set -l name (jq -r ".tech_rules[$i].name" $tech_rules_json)
            set -l icon (jq -r ".tech_rules[$i].icon" $tech_rules_json)
            set -l color (jq -r ".tech_rules[$i].color // \"white\"" $tech_rules_json)
            set -l bg_color (jq -r ".tech_rules[$i].bg_color // \"black\"" $tech_rules_json)
            set -l cmd (jq -r ".tech_rules[$i].detection_cmd" $tech_rules_json)

            if eval $cmd
                set -a tech_techs $name
                set -a tech_icons $icon
                set -a tech_colors $color
                set -a tech_bg_colors $bg_color
            end
        end
    end

    # Create output with smart deduplication and limiting
    set tech_info ""

    # Process languages first
    if test (count $lang_techs) -gt 0
        # Deduplicate languages while preserving order
        set -l seen_lang_techs
        set -l unique_lang_techs
        set -l unique_lang_icons
        set -l unique_lang_colors
        set -l unique_lang_bg_colors

        for i in (seq (count $lang_techs))
            set -l tech $lang_techs[$i]
            if not contains $tech $seen_lang_techs
                set -a seen_lang_techs $tech
                set -a unique_lang_techs $tech
                set -a unique_lang_icons $lang_icons[$i]
                set -a unique_lang_colors $lang_colors[$i]
                set -a unique_lang_bg_colors $lang_bg_colors[$i]
            end
        end

        # Format language output
        for i in (seq (count $unique_lang_techs))
            if test $i -gt 1
                set tech_info "$tech_info "
            end

            set -l tech_name $unique_lang_techs[$i]
            set -l icon $unique_lang_icons[$i]
            set -l color $unique_lang_colors[$i]
            set -l bg_color $unique_lang_bg_colors[$i]

            # Apply color formatting using Fish's set_color with background and foreground
            set -l colored_icon (set_color --background $bg_color $color)"$icon"(set_color normal)

            # Check if tech has version info
            if string match -q "*_*" $tech_name
                set -l parts (string split "_" $tech_name)
                set -l colored_version (set_color --background $bg_color $color)"$parts[2]"(set_color normal)
                set tech_info "$tech_info$colored_icon$colored_version"
            else
                set tech_info "$tech_info$colored_icon"
            end
        end
    end

    # Add separator if we have both languages and tech stacks
    if test (count $lang_techs) -gt 0 -a (count $tech_techs) -gt 0
        set tech_info "$tech_info • "
    end

    # Process tech stacks
    if test (count $tech_techs) -gt 0
        # Deduplicate tech stacks while preserving order
        set -l seen_tech_techs
        set -l unique_tech_techs
        set -l unique_tech_icons
        set -l unique_tech_colors
        set -l unique_tech_bg_colors

        for i in (seq (count $tech_techs))
            set -l tech $tech_techs[$i]
            if not contains $tech $seen_tech_techs
                set -a seen_tech_techs $tech
                set -a unique_tech_techs $tech
                set -a unique_tech_icons $tech_icons[$i]
                set -a unique_tech_colors $tech_colors[$i]
                set -a unique_tech_bg_colors $tech_bg_colors[$i]
            end
        end

        # Limit tech stacks based on max_tech_display setting
        set -l display_count (math "min($max_tech_display, "(count $unique_tech_techs)")")
        set -l display_techs $unique_tech_techs[1..$display_count]
        set -l display_icons $unique_tech_icons[1..$display_count]
        set -l display_colors $unique_tech_colors[1..$display_count]
        set -l display_bg_colors $unique_tech_bg_colors[1..$display_count]

        # Format tech stack output
        for i in (seq $display_count)
            if test $i -gt 1
                set tech_info "$tech_info "
            end

            set -l tech_name $display_techs[$i]
            set -l icon $display_icons[$i]
            set -l color $display_colors[$i]
            set -l bg_color $display_bg_colors[$i]

            # Apply color formatting using Fish's set_color with background and foreground
            set -l colored_icon (set_color --background $bg_color $color)"$icon"(set_color normal)

            # Check if tech has version info
            if string match -q "*_*" $tech_name
                set -l parts (string split "_" $tech_name)
                set -l colored_version (set_color --background $bg_color $color)"$parts[2]"(set_color normal)
                set tech_info "$tech_info$colored_icon$colored_version"
            else
                set tech_info "$tech_info$colored_icon"
            end
        end

        # Add indicator if there are more technologies
        if test (count $unique_tech_techs) -gt $max_tech_display
            set tech_info "$tech_info…"
        end
    end

    # Set the universal variable to trigger repaint
    set --universal $tech_var_name $tech_info
end
