# Tech Stack

Asynchronous technology detection for Fish shell prompts.

## Features

- Detects technologies in your project directory (Node.js, Python, Rust, Go, etc.)
- Shows version information when available
- Runs asynchronously to avoid blocking your prompt
- Automatic cleanup on directory changes

## Installation

Install with [Fisher](https://github.com/jorgebucaran/fisher):

```fish
fisher install rumboon/tech-stack
```

## Usage

The tech stack detection runs automatically when used by a compatible prompt. Asynchronous results are written to per-session variables whose names are exported via `_tech_stack_langs` (languages) and `_tech_stack_mods` (tools/frameworks).

Manual usage:
```fish
_tech_stack_async
set -l langs_var $_tech_stack_langs
set -l mods_var $_tech_stack_mods
printf "Langs: %s\n" $$langs_var
printf "Mods:  %s\n" $$mods_var
```

## Functions

- `_tech_stack_async` - Main async detection function
- `_tech_stack_worker` - Background worker for detection
- `_tech_stack_detection` - Core technology detection logic
- `_tech_stack_formatting` - Output formatting
- `_tech_stack_version` - Version detection for languages
- `_tech_stack_cleanup` - Cleanup function for processes and variables

## Configuration

### Color Coordination

Tech Stack reads the exported tokens from `stacked-theme` when available (`STACKED_THEME_COLOR_TECH_LANGS`, `STACKED_THEME_COLOR_TECH_MODS`, `STACKED_THEME_COLOR_NORMAL`) so async workers stay in sync with the active prompt palette. If the theme module is not installed, the plugin falls back to the configuration variables below.

For standalone use or explicit overrides:
- `TECH_STACK_COLOR_LANGS` - Color for languages (e.g., "green --dim")
- `TECH_STACK_COLOR_MODS` - Color for mods/frameworks
- `TECH_STACK_COLOR_MODE` - Color mode: "full", "foreground", or "none"

### Detection Rules

Technology detection rules are defined in JSON files:
- `functions/_tech_stack_rules_languages.json` - Language detection rules (with version support)
- `functions/_tech_stack_rules_mods.json` - Tech stack/framework detection rules

## Testing

Run the test suite:
```fish
fish test_tech_stack.fish
```

The test suite includes:
- Dynamic testing of all configured languages and tech stacks
- Multi-technology detection validation
- JSON configuration validation
