# OSH Greeting Plugin

A simple greeting plugin that provides a friendly welcome message for OSH users.

## Features

- Time-based greetings (morning, afternoon, evening)
- Shows current user and directory
- Displays git branch if in a git repository
- Clean, friendly output with emojis

## Usage

```bash
osh_greet
```

## Installation

1. The plugin is already created in your OSH plugins directory
2. Add `greeting` to your `oplugins` array in `~/.zshrc`:

```bash
oplugins=(greeting acw proxy fzf taskman)
```

3. Reload your shell or run:
```bash
source ~/.zshrc
```

## Example Output

```
🚀 OSH Framework
Good morning, john!
Ready to boost your productivity? 💪
📁 Current directory: /Users/john/projects
🌿 Git branch: feature/new-feature
✨ Happy coding!
```

## Customization

You can modify the greeting messages, emojis, or add additional information by editing the plugin file at:
`$OSH/plugins/greeting/greeting.plugin.zsh`
