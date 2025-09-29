#!/usr/bin/env fish

# Source required modules
source (dirname (status filename))/_tech_stack_detection.fish
source (dirname (status filename))/_tech_stack_formatting.fish
source (dirname (status filename))/_tech_stack_version.fish

function _tech_stack_worker --description 'Modern modular technology detection worker'
    set -l tech_var_name $argv[1]
    set -l work_dir $PWD

    # Configuration
    set -l max_tech_display 24
    if set -q TECH_DISPLAY_LIMIT
        set max_tech_display $TECH_DISPLAY_LIMIT
    else if set -q tech_display_limit
        set max_tech_display $tech_display_limit
    end

    set -l tech_rules_json "$TECH_STACK_CONFIG_DIR/_tech_stack_rules.json"
    set -l language_rules_json "$TECH_STACK_CONFIG_DIR/_tech_stack_language_rules.json"

    # Change to working directory for file tests
    cd $work_dir

    # Detect languages (with versions)
    set -l language_results
    if test -f $language_rules_json
        set language_results (_tech_stack_detection $language_rules_json "true")
    end

    # Detect tech stacks (without versions)
    set -l tech_results
    if test -f $tech_rules_json
        set tech_results (_tech_stack_detection $tech_rules_json "false")
    end

    # Format output
    set -l formatted_output ""

    # Format languages
    if test (count $language_results) -gt 0
        set -l lang_formatted (_tech_stack_formatting $language_results $max_tech_display)
        set formatted_output "$formatted_output$lang_formatted"
    end

    # Add separator if we have both
    if test (count $language_results) -gt 0 -a (count $tech_results) -gt 0
        set formatted_output "$formatted_output • "
    end

    # Format tech stacks
    if test (count $tech_results) -gt 0
        set -l tech_formatted (_tech_stack_formatting $tech_results $max_tech_display)
        set formatted_output "$formatted_output$tech_formatted"
    end

    # Set the universal variable
    set --universal $tech_var_name $formatted_output
end