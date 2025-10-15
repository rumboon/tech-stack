# Tech Stack initialization
# This file is automatically loaded when Fish starts

# Fisher will automatically copy JSON files to the functions directory
# So we use the functions path for configuration files
if not set -q TECH_STACK_CONFIG_DIR
    set -gx TECH_STACK_CONFIG_DIR $__fish_config_dir/functions
end

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

# Language version display configuration (overrides TECH_STACK_SHOW_VERSION for languages)
# Options:
#   true         - Show version information for languages
#   false        - Hide version information for languages
#   (unset)      - Use TECH_STACK_SHOW_VERSION value
if not set -q TECH_STACK_SHOW_VERSION_LANGS
    # Default: use global setting
end

# Mods/tools version display configuration (overrides TECH_STACK_SHOW_VERSION for mods)
# Options:
#   true         - Show version information for mods/tools
#   false        - Hide version information for mods/tools
#   (unset)      - Use TECH_STACK_SHOW_VERSION value
if not set -q TECH_STACK_SHOW_VERSION_MODS
    # Default: use global setting
end

# Language color configuration (overrides TECH_STACK_COLOR_MODE for languages)
# Options:
#   "full"       - Show background color + foreground color
#   "foreground" - Show only foreground color, no background
#   "none"       - Show no colors (plain text)
#   set_color arguments - Custom color arguments (e.g., "green --dim", "blue --bold")
#   (unset)      - Use TECH_STACK_COLOR_MODE value
if not set -q TECH_STACK_COLOR_LANGS
    # Default: use global setting
end

# Mods/tools color configuration (overrides TECH_STACK_COLOR_MODE for mods)
# Options:
#   "full"       - Show background color + foreground color
#   "foreground" - Show only foreground color, no background
#   "none"       - Show no colors (plain text)
#   set_color arguments - Custom color arguments (e.g., "green --dim", "blue --bold")
#   (unset)      - Use TECH_STACK_COLOR_MODE value
if not set -q TECH_STACK_COLOR_MODS
    # Default: use global setting
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
    set --erase TECH_STACK_CONFIG_DIR
    echo "Tech Stack plugin uninstalled."
end