#!/usr/bin/env fish

# Source required modules
source (dirname (status filename))/_tech_stack_detection.fish
source (dirname (status filename))/_tech_stack_formatting.fish
source (dirname (status filename))/_tech_stack_version.fish

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

function __tech_stack_cache_store --description 'Atomically write one cache file'
    set -l file $argv[1]
    set -l value (string join ' ' -- $argv[2..-1])
    printf '%s\n' $value >$file.tmp$fish_pid 2>/dev/null
    and mv -f $file.tmp$fish_pid $file 2>/dev/null
end

function _tech_stack_worker --description 'Technology detection worker that publishes language and tech results'
    set -l langs_file $argv[1]
    set -l mods_file $argv[2]
    set -l work_dir $PWD

    # Guard against missing result file paths
    test -z "$langs_file" -o -z "$mods_file"; and return

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
    cd $work_dir; or return 1

    # Detection results are cached per directory in the shared runtime cache.
    # The theme is part of the key because results embed color escapes.
    set -l cache_root (dirname (dirname $langs_file))/cache
    mkdir -p $cache_root 2>/dev/null
    set -l theme none
    set -q STACKED_THEME_ACTIVE; and set theme $STACKED_THEME_ACTIVE
    set -l cache_base $cache_root/(string escape --style=var -- "$work_dir|$theme")
    set -l current_mtime (_get_indicator_files_mtime)

    set -l cached_mtime (_stacked_read $cache_base.mtime)
    if test "$cached_mtime" = "$current_mtime" -a -r "$cache_base.langs" -a -r "$cache_base.mods"
        _stacked_publish $langs_file (_stacked_read $cache_base.langs)
        _stacked_publish $mods_file (_stacked_read $cache_base.mods)
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

    # Format and publish the results
    set -l lang_formatted ""
    set -l tech_formatted ""

    if test (count $language_results) -gt 0
        set lang_formatted (_tech_stack_formatting langs $language_results $max_tech_display)
    end
    if test (count $tech_results) -gt 0
        set tech_formatted (_tech_stack_formatting mods $tech_results $max_tech_display)
    end

    _stacked_publish $langs_file $lang_formatted
    _stacked_publish $mods_file $tech_formatted

    # Update the cache (mtime last, so an interrupted write reads as stale)
    __tech_stack_cache_store $cache_base.langs $lang_formatted
    __tech_stack_cache_store $cache_base.mods $tech_formatted
    __tech_stack_cache_store $cache_base.mtime $current_mtime
end
