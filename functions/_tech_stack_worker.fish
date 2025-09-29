function _get_language_version --description 'Get version for supported languages'
    set -l language $argv[1]

    switch $language
        case "Node.js"
            if command -v node >/dev/null 2>&1
                node -v 2>/dev/null | sed 's/v//'
            end
        case "Python"
            if command -v python3 >/dev/null 2>&1
                python3 --version 2>/dev/null | awk '{print $2}'
            else if command -v python >/dev/null 2>&1
                python --version 2>/dev/null | awk '{print $2}'
            end
        case "Rust"
            if command -v rustc >/dev/null 2>&1
                rustc --version 2>/dev/null | awk '{print $2}'
            end
        case "Go"
            if command -v go >/dev/null 2>&1
                go version 2>/dev/null | awk '{print $3}' | sed 's/go//'
            end
        case "PHP"
            if command -v php >/dev/null 2>&1
                php --version 2>/dev/null | head -n1 | awk '{print $2}' | cut -d'-' -f1
            end
        case "Ruby"
            if command -v ruby >/dev/null 2>&1
                ruby --version 2>/dev/null | awk '{print $2}'
            end
        case "Java"
            if command -v javac >/dev/null 2>&1
                javac -version 2>/dev/null | awk '{print $2}'
            end
        case ".NET"
            if command -v dotnet >/dev/null 2>&1
                dotnet --version 2>/dev/null
            end
    end
end


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
        set -l lang_count (jq '.rules | length' $language_rules_json)
        for i in (seq 0 (math $lang_count - 1))
            set -l name (jq -r ".rules[$i].name" $language_rules_json)
            set -l icon (jq -r ".rules[$i].icon" $language_rules_json)
            set -l color (jq -r ".rules[$i].color // \"white\"" $language_rules_json)
            set -l bg_color (jq -r ".rules[$i].bg_color // \"black\"" $language_rules_json)
            set -l file_indicators (jq -r ".rules[$i].file_indicators[]" $language_rules_json)

            # Check if any file indicators exist
            set -l found_indicator false
            for indicator in $file_indicators
                # Handle glob patterns (containing asterisks)
                if string match -q "*\**" $indicator
                    # Use find for reliable glob pattern matching
                    if find . -name "$indicator" -type f -print -quit | read -l
                        set found_indicator true
                        break
                    end
                else if test -f $indicator -o -d $indicator
                    set found_indicator true
                    break
                end
            end

            if test $found_indicator = true
                # Get version using safe function
                set -l lang_version (_get_language_version $name)

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

    # Process tech stack detection using file indicators
    if test -f $tech_rules_json; and command -v jq >/dev/null 2>&1
        set -l rule_count (jq '.rules | length' $tech_rules_json)
        for i in (seq 0 (math $rule_count - 1))
            set -l name (jq -r ".rules[$i].name" $tech_rules_json)
            set -l icon (jq -r ".rules[$i].icon" $tech_rules_json)
            set -l color (jq -r ".rules[$i].color // \"white\"" $tech_rules_json)
            set -l bg_color (jq -r ".rules[$i].bg_color // \"black\"" $tech_rules_json)
            set -l file_indicators (jq -r ".rules[$i].file_indicators[]" $tech_rules_json)

            # Check if any file indicators exist
            set -l found_indicator false
            for indicator in $file_indicators
                # Handle glob patterns (containing asterisks)
                if string match -q "*\**" $indicator
                    # Use find for reliable glob pattern matching
                    if find . -name "$indicator" -type f -print -quit | read -l
                        set found_indicator true
                        break
                    end
                else if test -f $indicator -o -d $indicator
                    set found_indicator true
                    break
                end
            end

            # Special handling for complex detection rules
            if test $found_indicator = true
                # Apply special logic for certain technologies
                set -l should_add true

                # iOS requires BOTH ios directory AND xcodeproj files
                if test "$name" = "ios"
                    set should_add false
                    if test -d ios
                        if ls *.xcodeproj >/dev/null 2>&1
                            set should_add true
                        end
                    end
                # Swift can be detected by Package.swift, Podfile, OR xcodeproj files
                else if test "$name" = "swift"
                    # Default found_indicator logic is fine for swift
                end

                if test $should_add = true
                    set -a tech_techs $name
                    set -a tech_icons $icon
                    set -a tech_colors $color
                    set -a tech_bg_colors $bg_color
                end
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
