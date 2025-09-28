# Tech Stack initialization
# This file is automatically loaded when Fish starts

# Fisher will automatically copy JSON files to the functions directory
# So we use the functions path for configuration files
if not set -q TECH_STACK_CONFIG_DIR
    set -gx TECH_STACK_CONFIG_DIR $__fish_config_dir/functions
end

# Initialize tech stack variables
set -g _tech_stack_initialized false

# Fisher event handlers
function __tech_stack_install --on-event tech_stack_install
    echo "Tech Stack plugin installed successfully!"
    echo "Configuration files are available in $__fish_config_dir/functions/"
end

function __tech_stack_uninstall --on-event tech_stack_uninstall
    echo "Cleaning up Tech Stack plugin..."
    # Clean up any persistent variables
    set --erase _tech_stack_initialized
    set --erase TECH_STACK_CONFIG_DIR
    echo "Tech Stack plugin uninstalled."
end