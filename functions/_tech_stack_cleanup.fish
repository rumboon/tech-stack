function _tech_stack_cleanup --description 'Clean up tech stack processes and variables'
    command kill $_tech_last_pid 2>/dev/null
    # Erase the universal variables by dereferencing the variable names
    if set -q _tech_stack_langs; and test -n "$_tech_stack_langs"
        set --erase --universal $_tech_stack_langs 2>/dev/null
    end
    if set -q _tech_stack_mods; and test -n "$_tech_stack_mods"
        set --erase --universal $_tech_stack_mods 2>/dev/null
    end
end

# Set up event handlers for cleanup
function _tech_stack_info_cleanup --on-variable PWD --on-event fish_exit
    _tech_stack_cleanup
end
