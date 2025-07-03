# OSH Weather Plugin

A simple weather forecast plugin for OSH that displays current weather conditions with ASCII art representation.

## Features

- Show current weather conditions for your location
- Display weather with ASCII art visualization
- Support for detailed weather forecasts
- Automatic location detection based on IP
- Manual location specification
- Data caching (5 hours) to reduce API calls

## Installation

1. Ensure the plugin is in your OSH plugins directory:
   ```
   $OSH/plugins/weather/
   ```

2. Add `weather` to your plugin list in `~/.zshrc`:
   ```bash
   oplugins=(... weather ...)
   ```

3. Reload your shell or source your `.zshrc`:
   ```bash
   source ~/.zshrc
   ```

## Dependencies

This plugin requires:
- `curl` - for API requests
- `jq` - for JSON parsing (optional, enhances functionality)

## Usage

### Basic Usage

```bash
# Show weather for your current location
weather

# Show weather for a specific location
weather Tokyo

# Show detailed weather forecast with ASCII art
weather -d
weather --detailed

# Show weather for a specific location with detailed view
weather -l Paris -d
```

### Command Options

| Option | Description |
|--------|-------------|
| `-l, --location LOCATION` | Specify location (city name) |
| `-d, --detailed` | Show detailed weather with ASCII art |
| `-h, --help` | Show help message |

### Aliases

- `wtr` - Shorthand for `weather`
- `forecast` - Shorthand for `weather -d` (detailed forecast)

## Configuration

The plugin uses the following default settings:

- Cache directory: `$OSH_CUSTOM/cache/weather` or `$HOME/.osh-custom/cache/weather`
- Cache expiry: 5 hours (18000 seconds)
- Weather API: [wttr.in](https://wttr.in)

## Examples

```bash
# Show weather for current location
weather

# Show weather for Tokyo
weather -l Tokyo
weather Tokyo

# Show detailed forecast for current location
weather -d
forecast

# Show detailed forecast for Paris
weather -l Paris -d
forecast -l Paris
```

## API Credits

This plugin uses the [wttr.in](https://wttr.in) service by [Igor Chubin](https://github.com/chubin/wttr.in).

## License

This plugin is released under the MIT License.