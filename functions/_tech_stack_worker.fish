#!/usr/bin/env fish

# Source required modules
source (dirname (status filename))/_tech_stack_detection.fish
source (dirname (status filename))/_tech_stack_formatting.fish
source (dirname (status filename))/_tech_stack_version.fish


function _get_cache_key --description 'Generate cache key from directory'
    string replace -a '/' '_' -- $PWD | string replace -a '.' '_'    
end

function _get_indicator_files_mtime --description 'Get modification times of indicator files'
    # Common files that indicate tech stack changes
    set -l indicator_files package.json Cargo.toml go.mod requirements.txt Gemfile composer.json pom.xml build.gradle pyproject.toml
    set -l mtime_hash ""

    for file in $indicator_files
        if test -f $file
            set -l mtime (stat -c %Y $file 2>/dev/null || stat -f %m $file 2>/dev/null)
            set mtime_hash "$mtime_hash:$file=$mtime"
        end
    end

    echo $mtime_hash
end

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

    # Check cache
    set -l cache_key (_get_cache_key)
    set -l current_mtime (_get_indicator_files_mtime)
    set -l cache_mtime_var "_tech_cache_mtime_$cache_key"
    set -l cache_langs_var "_tech_cache_langs_$cache_key"
    set -l cache_mods_var "_tech_cache_mods_$cache_key"

    # Use cache if valid
    if set -q $cache_mtime_var; and test "$$cache_mtime_var" = "$current_mtime"
        # Cache is valid, use cached results
        if set -q $cache_langs_var
            set --universal -- $langs_var_name $$cache_langs_var
        else
            set --universal -- $langs_var_name ""
        end

        if set -q $cache_mods_var
            set --universal -- $mods_var_name $$cache_mods_var
        else
            set --universal -- $mods_var_name ""
        end
        return
    end

    # Cache miss or invalid - run detection
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
    set -l lang_formatted ""
    set -l tech_formatted ""

    if test (count $language_results) -gt 0
        set lang_formatted (_tech_stack_formatting $language_results $max_tech_display)
        set --universal -- $langs_var_name $lang_formatted
    else
        set --universal -- $langs_var_name ""
    end

    if test (count $tech_results) -gt 0
        set tech_formatted (_tech_stack_formatting $tech_results $max_tech_display)
        set --universal -- $mods_var_name $tech_formatted
    else
        set --universal -- $mods_var_name ""
    end

    # Update cache (global vars for caching within session)
    set -g $cache_mtime_var $current_mtime
    set -g $cache_langs_var $lang_formatted
    set -g $cache_mods_var $tech_formatted
end
