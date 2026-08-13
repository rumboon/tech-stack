function _tech_stack_async --description 'Asynchronously detect technologies and versions in any directory'
    if not functions -q _stacked_async_run
        if not set -q _tech_stack_core_warned
            set -g _tech_stack_core_warned true
            echo "tech-stack: stacked-core is required — fisher install rumboon/stacked-core" >&2
        end
        return 1
    end

    # The worker is sourced by path so it runs in any directory
    set -l worker_path (dirname (status --current-filename))/_tech_stack_worker.fish
    set -l config_dir ""
    if set -q TECH_STACK_CONFIG_DIR
        set config_dir $TECH_STACK_CONFIG_DIR
    end
    set -l escaped_worker_path (string escape -- $worker_path)
    set -l escaped_config_dir (string escape -- $config_dir)
    set -l cmd "set -gx TECH_STACK_CONFIG_DIR $escaped_config_dir; source $escaped_worker_path; _tech_stack_worker"

    _stacked_async_run tech $cmd _tech_stack_langs _tech_stack_mods
end
