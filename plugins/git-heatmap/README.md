# Git Heatmap Plugin

A cyberpunk-style terminal plugin that displays GitHub-like contribution heatmaps for your git repositories.

## Features

- 📊 **GitHub-style heatmap** - Visual contribution patterns in your terminal
- 🎨 **Cyberpunk colors** - Matches OSH.IT's aesthetic
- 📅 **Multiple views** - Year and month views available
- 🔥 **Streak tracking** - Shows current and longest commit streaks
- ⚡ **Performance optimized** - Efficient git log parsing
- 🎯 **Customizable** - Different styles and time ranges

## Usage

### Basic Commands

```bash
# Show contribution heatmap for the last year
git-heatmap

# Show last 90 days
git-heatmap --days 90

# Show current month
git-heatmap --view month

# Compact view
git-heatmap --style compact

# Show help
git-heatmap --help
```

### Aliases

- `ghm` - Short alias for git-heatmap
- `git-heat` - Alternative alias

### Example Output

```
Contribution Graph - Last 365 days
┌─────────────────────────────────────────────────────────────────────┐
│  Jan   Feb   Mar   Apr   May   Jun   Jul   Aug   Sep   Oct   Nov   Dec│
├─────────────────────────────────────────────────────────────────────┤
│▢▢▢▢▢▢▢▢▢▢▢▢▢■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Mon
│▢▢▢▢▢▢▢▢▢▢▢▢▢■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Tue
│▢▢▢▢▢▢▢▢▢▢▢▢■■■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Wed
│▢▢▢▢▢▢▢▢▢▢▢▢■■■■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Thu
│▢▢▢▢▢▢▢▢▢▢▢■■■■■■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Fri
│▢▢▢▢▢▢▢▢▢▢▢■■■■■■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Sat
│▢▢▢▢▢▢▢▢▢▢▢▢■■■■■■▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢▢│ Sun
└─────────────────────────────────────────────────────────────────────┘

Less ▢ ░ ▒ ▓ ■ More    523 contributions in 2024
Longest streak: 42 days • Current streak: 7 days • Active days: 298/365
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `--days NUM` | Number of days to display | 365 |
| `--style STYLE` | Display style: `default`, `compact` | default |
| `--view VIEW` | View type: `year`, `month` | year |
| `--help, -h` | Show help message | - |

## Color Legend

- ▢ No contributions (0)
- ░ Low contributions (1-3)
- ▒ Medium contributions (4-6) 
- ▓ High contributions (7-9)
- ■ Very high contributions (10+)

## Requirements

- Git repository (must be run inside a git project)
- Zsh shell
- Git command-line tool

## Performance

The plugin is optimized for performance:
- Efficient git log queries with date ranges
- Minimal memory usage
- Fast rendering even for large repositories
- Smart caching of date calculations

## Integration

This plugin integrates seamlessly with OSH.IT's cyberpunk theme and uses the same color palette for consistency.

## Troubleshooting

**Error: "Not in a git repository"**
- Make sure you're inside a git project directory

**Heatmap appears empty**
- Check if you have commits in the specified date range
- Try `git log --oneline` to verify commit history

**Date calculation issues**
- The plugin handles both GNU date (Linux) and BSD date (macOS)
- Ensure your system date command is working properly