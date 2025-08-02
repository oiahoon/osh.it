# ASCII Text Plugin

A cyberpunk-style ASCII art text generator that converts regular text into stylized ASCII art using various font styles and colors.

## Features

- 🎨 **Multiple Styles** - Matrix, Circuit, and Neon ASCII font styles
- 🌈 **Cyberpunk Colors** - 8 color options matching OSH.IT's theme
- ⚡ **Fast Generation** - Optimized text rendering
- 🔤 **Full Character Set** - Letters, numbers, and special characters
- 👀 **Preview Mode** - See all styles at once
- 🎯 **CLI Friendly** - Perfect for terminal banners and headers

## Usage

### Basic Commands

```bash
# Basic usage
ascii-text "HELLO WORLD"

# Custom style
ascii-text "CYBER" --style circuit

# Custom color
ascii-text "NEON" --color green

# Preview all styles
ascii-text "OSH" --preview

# List available styles and colors
ascii-text --list-styles

# Show help
ascii-text --help
```

### Aliases

- `ascii` - Short alias for ascii-text
- `asciit` - Alternative short alias

### Example Output

```
Matrix Style:
╦ ╦╔═╗╦  ╦  ╔═╗
╠═╣║╣ ║  ║  ║ ║
╩ ╩╚═╝╩═╝╩═╝╚═╝

Circuit Style:
┃ ┃┏━┓┃  ┃  ┏━┓
┣━┫┣━ ┃  ┃  ┃ ┃
┛ ┗┗━┛┗━┛┗━┛┗━┛

Neon Style:
█ █▄▀██  █  ▄▀█
█▀██▀▀█  █  █ █
▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀
```

## Available Styles

| Style | Description | Character Set |
|-------|-------------|---------------|
| `matrix` | Matrix/digital style with Unicode box characters | ╔╗╚╝║═ |
| `circuit` | Circuit board style with technical lines | ┏┓┗┛┃━ |
| `neon` | Neon sign style with block characters | █▀▄▀ |

## Available Colors

| Color | Description | OSH.IT Theme |
|-------|-------------|--------------|
| `cyan` | Electric blue (default) | Primary |
| `green` | Matrix green | Success |
| `yellow` | Neon yellow | Warning |
| `red` | Alert red | Error |
| `purple` | UV purple | Accent |
| `orange` | Neon orange | Highlight |
| `pink` | Hot pink | Special |
| `white` | Pure white | Text |

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--style STYLE` | ASCII font style: matrix, circuit, neon | matrix |
| `--color COLOR` | Text color (see available colors above) | cyan |
| `--list-styles` | List all available styles and colors | - |
| `--preview` | Preview text in all available styles | - |
| `--help, -h` | Show help message | - |

## Character Support

- **Letters**: A-Z (case insensitive)
- **Numbers**: 0-9
- **Special**: Space, period (.), exclamation (!), question (?)
- **Fallback**: Unsupported characters display as spaces

## Use Cases

### Terminal Banners
```bash
# Project header
ascii-text "MY PROJECT" --style matrix --color cyan

# Welcome message
ascii-text "WELCOME" --style neon --color green
```

### Status Messages
```bash
# Success
ascii-text "SUCCESS" --color green --style circuit

# Error
ascii-text "ERROR" --color red --style matrix

# Done
ascii-text "DONE" --color yellow --style neon
```

### Integration with OSH.IT
```bash
# Show OSH.IT logo
ascii-text "OSH.IT" --style matrix --color cyan

# Project name banner
ascii-text "$(basename $(pwd))" --preview
```

## Performance

The plugin is optimized for performance:
- Pre-defined character maps for fast lookup
- Minimal memory usage
- No external dependencies
- Cross-platform compatibility

## Integration

This plugin integrates seamlessly with OSH.IT's cyberpunk theme:
- Colors match the main color palette
- ASCII styles complement the overall aesthetic  
- Works great with other OSH.IT plugins like git-heatmap

## Examples

```bash
# Create a cyberpunk project banner
ascii-text "CYBERPUNK 2077" --style circuit --color purple

# Show build status
ascii-text "BUILD OK" --style neon --color green

# Display version
ascii-text "V1.0.0" --style matrix --color yellow

# Create ASCII headers for documentation
ascii-text "API DOCS" --style circuit --color white
```

## Troubleshooting

**Characters appear as spaces**
- The character may not be supported yet
- Use supported characters: A-Z, 0-9, space, ., !, ?

**Colors not showing**
- Ensure your terminal supports ANSI colors
- Try a different terminal emulator

**Text too wide**
- Use shorter text strings
- ASCII art is designed for headers and short messages