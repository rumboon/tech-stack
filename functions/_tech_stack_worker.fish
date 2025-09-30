#!/usr/bin/env fish

# Source required modules
source (dirname (status filename))/_tech_stack_detection.fish
source (dirname (status filename))/_tech_stack_formatting.fish
source (dirname (status filename))/_tech_stack_version.fish


function _tech_stack_worker --description 'Technology detection worker that outputs separate language and tech variables'
    set -l langs_var_name $argv[1]
    set -l mods_var_name $argv[2]
    set -l work_dir $PWD

    # Configuration
    set -l max_tech_display 24
    if set -q TECH_STACK_DISPLAY_LIMIT
        set max_tech_display $TECH_STACK_DISPLAY_LIMIT
    else if set -q TECH_DISPLAY_LIMIT
        set max_tech_display $TECH_DISPLAY_LIMIT
    else if set -q tech_display_limit
        set max_tech_display $tech_display_limit
    end

    set -l rules_mods_json "$TECH_STACK_CONFIG_DIR/_tech_stack_rules_mods.json"
    set -l rules_languages_json "$TECH_STACK_CONFIG_DIR/_tech_stack_rules_languages.json"

    # Change to working directory for file tests
    cd $work_dir

    # Detect languages (with versions)
    set -l language_results
    if test -f $rules_languages_json
        set language_results (_tech_stack_detection $rules_languages_json)
    end

    # Detect tech stacks (with versions)
    set -l tech_results
    if test -f $rules_mods_json
        set tech_results (_tech_stack_detection $rules_mods_json)
    end

    # Format and set separate variables
    if test (count $language_results) -gt 0
        set -l lang_formatted (_tech_stack_formatting $language_results $max_tech_display)
        set --universal -- $langs_var_name $lang_formatted
    else
        set --universal -- $langs_var_name ""
    end

    if test (count $tech_results) -gt 0
        set -l tech_formatted (_tech_stack_formatting $tech_results $max_tech_display)
        set --universal -- $mods_var_name $tech_formatted
    else
        set --universal -- $mods_var_name ""
    end
end
