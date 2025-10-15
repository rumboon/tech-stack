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

The tech stack detection runs automatically when used by a compatible prompt. The detected information is stored in the `$_tech_info_git` variable.

Manual usage:
```fish
_tech_stack_async
# Check the result
echo $_tech_info_git
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

Tech Stack automatically coordinates colors with `stacked-prompt` if installed. When `STACKED_PROMPT_COLOR_SCHEME` is set, tech info colors match the prompt theme.

For standalone use or custom colors:
- `TECH_STACK_COLOR_LANGS` - Color for languages (e.g., "green --dim")
- `TECH_STACK_COLOR_MODS` - Color for mods/frameworks
- `TECH_STACK_COLOR_MODE` - Color mode: "full", "foreground", or "none"

### Detection Rules

Technology detection rules are defined in JSON files:
- `functions/_tech_stack_language_rules.json` - Language detection rules (with version support)
- `functions/_tech_stack_rules.json` - Tech stack/framework detection rules

## Testing

Run the test suite:
```fish
fish test_tech_stack.fish
```

The test suite includes:
- Dynamic testing of all configured languages and tech stacks
- Multi-technology detection validation
- JSON configuration validation
- Automatic testing via GitHub Actions CI
