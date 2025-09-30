function _tech_stack_async --description 'Asynchronously detect technologies and versions in any directory'
    # Initialize tech detection variables if not already set
    if not set -q _tech_info_init
        set -g _tech_info_init true
        set -g _tech_stack_langs _tech_stack_langs_$fish_pid
        set -g _tech_stack_mods _tech_stack_mods_$fish_pid

        # Set up variable watchers for tech info updates
        function $_tech_stack_langs --on-variable $_tech_stack_langs
            commandline --function repaint
        end

        function $_tech_stack_mods --on-variable $_tech_stack_mods
            commandline --function repaint
        end
    end

    # Kill any previous tech detection process
    command kill $_tech_last_pid 2>/dev/null

    # Start async tech detection using worker function (works in any directory)
    fish --private -c "set -gx TECH_STACK_CONFIG_DIR $TECH_STACK_CONFIG_DIR; source $TECH_STACK_CONFIG_DIR/_tech_stack_worker.fish; _tech_stack_worker $_tech_stack_langs $_tech_stack_mods" &

    set -g _tech_last_pid $last_pid
end
