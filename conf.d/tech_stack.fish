# Tech Stack initialization
# This file is automatically loaded when Fish starts

# Fisher will automatically copy JSON files to the functions directory
# So we use the functions path for configuration files
if not set -q TECH_STACK_CONFIG_DIR
    set -gx TECH_STACK_CONFIG_DIR $__fish_config_dir/functions
end

# Initialize tech stack variables
set -g _tech_stack_initialized false

# Display format configuration
# Options:
#   "icon_label" - Show both icon and label (e.g., "⬡ Node")
#   "label"      - Show only label (e.g., "Node") [DEFAULT]
#   "icon"       - Show only icon (e.g., "⬡")
if not set -q TECH_STACK_DISPLAY_FORMAT
    set -gx TECH_STACK_DISPLAY_FORMAT "label"
end

# Color display configuration
# Options:
#   "full"       - Show background color + foreground color [DEFAULT]
#   "foreground" - Show only foreground color, no background
#   "none"       - Show no colors (plain text)
if not set -q TECH_STACK_COLOR_MODE
    set -gx TECH_STACK_COLOR_MODE "full"
end

# Version display configuration
# Options:
#   true         - Show version information [DEFAULT]
#   false        - Hide version information
if not set -q TECH_STACK_SHOW_VERSION
    set -gx TECH_STACK_SHOW_VERSION true
end

# Fisher event handlers
function __tech_stack_install --on-event tech_stack_install
    echo "Tech Stack plugin installed successfully!"
    echo "Configuration files are available in $__fish_config_dir/functions/"
    echo ""
    echo "Configuration options:"
    echo "  set -gx TECH_STACK_DISPLAY_FORMAT \"icon_label\"  # Show icons + labels"
    echo "  set -gx TECH_STACK_COLOR_MODE \"foreground\"      # Use foreground color only"
    echo "  set -gx TECH_STACK_SHOW_VERSION false             # Hide version information"
    echo "  set -gx TECH_STACK_DISPLAY_LIMIT 10               # Limit number of technologies shown"
end

function __tech_stack_uninstall --on-event tech_stack_uninstall
    echo "Cleaning up Tech Stack plugin..."
    # Clean up any persistent variables
    set --erase _tech_stack_initialized
    set --erase TECH_STACK_CONFIG_DIR
    echo "Tech Stack plugin uninstalled."
end