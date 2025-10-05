function _tech_stack_cleanup --description 'Clean up tech stack processes and variables'
    command kill $_tech_last_pid 2>/dev/null
    set --erase _tech_info_git
end

# Set up event handlers for cleanup
function _tech_stack_info_cleanup --on-variable PWD --on-event fish_exit
    _tech_stack_cleanup
end