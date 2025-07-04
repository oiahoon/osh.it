# Example Plugin

This is an example plugin that demonstrates OSH.IT's auto-update features.

## Features

- 🎉 Hello world functionality
- 📊 Plugin information display
- 🔄 Demonstrates auto-update mechanism

## Usage

```bash
# Say hello
example_hello
ex-hello

# Show plugin info
example_info
ex-info
```

## Auto-Update Demo

When you add this plugin to your OSH.IT installation, the website will automatically:

1. **Detect the new plugin** in the plugins/ directory
2. **Extract metadata** from the plugin file comments
3. **Update plugin count** on the website
4. **Categorize the plugin** based on its category tag
5. **Deploy the changes** via GitHub Actions

## Plugin Metadata

The auto-update system reads the following metadata from plugin files:

- `# Description:` - Plugin description
- `# Version:` - Plugin version
- `# Category:` - Plugin category (stable/beta/experimental)
- `# Author:` - Plugin author
- `# Tags:` - Plugin tags

## Installation

Add to your `.zshrc`:

```bash
oplugins=(example)
```

Then reload your shell or run:

```bash
osh reload
```
