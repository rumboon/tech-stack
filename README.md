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
- `_tech_stack_cleanup` - Cleanup function for processes and variables

## Testing

Run the test suite:
```fish
fish test_tech_stack.fish
```
