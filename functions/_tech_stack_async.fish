function _tech_stack_async --description 'Asynchronously detect technologies and versions in any directory'
    # Initialize tech detection variables if not already set
    if not set -q _tech_info_init
        set -g _tech_info_init true
        set -g _tech_stack_langs _tech_stack_langs_$fish_pid
        set -g _tech_stack_mods _tech_stack_mods_$fish_pid

        # Set up variable watchers for tech info updates
        function $_tech_stack_langs --on-variable $_tech_stack_langs
            commandline -f repaint 2>/dev/null
        end

        function $_tech_stack_mods --on-variable $_tech_stack_mods
            commandline -f repaint 2>/dev/null
        end
    end

    # Kill any previous tech detection process
    if set -q _tech_last_pid; and test -n "$_tech_last_pid"
        command kill $_tech_last_pid 2>/dev/null
    end

    # Start async tech detection using worker function (works in any directory)
    set -l worker_path (dirname (status --current-filename))/_tech_stack_worker.fish
    set -l config_dir ""
    if set -q TECH_STACK_CONFIG_DIR
        set config_dir $TECH_STACK_CONFIG_DIR
    end
    set -l escaped_worker_path (string escape -- $worker_path)
    set -l escaped_config_dir (string escape -- $config_dir)
    set -l escaped_lang_var (string escape -- $_tech_stack_langs)
    set -l escaped_mod_var (string escape -- $_tech_stack_mods)
    set -l async_cmd "set -gx TECH_STACK_CONFIG_DIR $escaped_config_dir; source $escaped_worker_path; _tech_stack_worker $escaped_lang_var $escaped_mod_var"
    fish --private -c $async_cmd & disown

    set -g _tech_last_pid $last_pid
end
