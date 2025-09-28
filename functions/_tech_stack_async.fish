function _tech_stack_async --description 'Asynchronously detect technologies and versions in any directory'
    # Initialize tech detection variables if not already set
    if not set -q _tech_info_init
        set -g _tech_info_init true
        set -g _tech_info_git _tech_info_git_$fish_pid

        # Set up variable watcher for tech info updates
        function $_tech_info_git --on-variable $_tech_info_git
            commandline --function repaint
        end
    end

    # Kill any previous tech detection process
    command kill $_tech_last_pid 2>/dev/null

    # Start async tech detection using worker function (works in any directory)
    fish --private -c "_tech_stack_worker $_tech_info_git" &

    set -g _tech_last_pid $last_pid
end
