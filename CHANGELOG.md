# Changelog

All notable changes to OSH.IT will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🔌 Added - New Plugins
- **git-heatmap Plugin**: GitHub-style contribution heatmap display for git repositories
  - Visual contribution patterns with cyberpunk colors
  - Multiple view options (year/month) and customizable time ranges
  - Streak tracking with current and longest commit streaks
  - Performance optimized with efficient git log parsing
  - Aliases: `ghm`, `git-heat`
- **ascii-text Plugin**: Cyberpunk ASCII art text generator 
  - Multiple styles: Matrix, Circuit, and Neon ASCII fonts
  - 8 cyberpunk color options matching OSH.IT theme
  - Preview mode to see all styles at once
  - Full character set support (A-Z, 0-9, special characters)
  - Aliases: `ascii`, `asciit`

### 🎯 Improved - Plugin Ecosystem
- Enhanced stable plugin collection with visual and development tools
- Better integration between plugins using consistent cyberpunk theming
- Expanded use cases for terminal customization and git workflow visualization

## [1.5.0] - 2025-07-24

### 🎨 Added - Cyberpunk UI System
- **Complete Cyberpunk Design System**: New visual identity with neon colors, ASCII art, and futuristic styling
- **Advanced Color System**: Support for true color (24-bit) and 256-color terminals with automatic detection
- **ASCII Art Components**: Professional logo, table displays, progress bars, and status indicators
- **Terminal Compatibility**: Intelligent adaptation to different terminal capabilities
- **UI Component Library**: Reusable components for consistent visual experience

### 🔍 Added - Enhanced Plugin Management
- **Plugin Search System**: `osh plugin search <keyword>` with multi-dimensional search capabilities
- **Plugin Discovery Engine**: Comprehensive metadata database with categories, versions, and dependencies
- **Dependency Management**: Automatic dependency checking with platform-specific installation guidance
- **Category-based Browsing**: `osh plugin list [category]` for organized plugin exploration
- **Detailed Plugin Information**: `osh plugin info <name>` with comprehensive metadata display

### 🚀 Added - Modern CLI Interface
- **Redesigned Command Structure**: Modern `osh plugin <command>` syntax following industry standards
- **Enhanced Status Display**: `osh status` with system information and feature availability
- **Interactive Help System**: Comprehensive help with examples and usage patterns
- **Improved Error Handling**: Clear error messages with actionable suggestions
- **Performance Optimized**: Sub-100ms response times for all commands

### 🔧 Added - Advanced Features
- **Plugin Dependency Checking**: `osh plugin deps <name>` for dependency validation
- **Multi-platform Support**: Installation commands for macOS, Linux, and WSL
- **Intelligent Caching**: Optimized performance with smart caching mechanisms
- **Backward Compatibility**: Full compatibility with existing configurations and commands

### 🎯 Improved - User Experience
- **Professional Visual Design**: Consistent cyberpunk aesthetic across all interfaces
- **Intuitive Command Discovery**: Self-documenting commands with built-in help
- **Enhanced Plugin Information**: Rich metadata display with installation status
- **Performance Monitoring**: Real-time performance metrics and optimization

### 🛠️ Technical Improvements
- **Modular Architecture**: Clean separation of concerns with dedicated libraries
- **Shell Compatibility**: Support for both bash and zsh environments
- **Error Resilience**: Robust error handling and graceful degradation
- **Comprehensive Testing**: 91.7% test success rate with 44 passing tests

### 📚 Documentation
- **Updated README**: Comprehensive documentation with new features and examples
- **Plugin Management Guide**: Detailed guide for the new plugin management system
- **Development Documentation**: Complete technical documentation for contributors

## [1.4.1] - 2025-07-07

### Fixed
- ✅ **Self-Updating Scripts**: Both `install.sh` and `upgrade.sh` now automatically update themselves before execution
- ✅ **Smart Version Checking**: Upgrade command now checks if update is needed and exits gracefully if already up-to-date
- ✅ **Enhanced User Experience**: Improved upgrade messages with helpful diagnostics suggestions
- ✅ **Bug Fixes**: Fixed missing `show_progress_with_file` function in upgrade script
- ✅ **Automatic Fallback**: Graceful handling of network issues during self-update

## [1.4.0] - 2025-07-04

### Added
- ✅ **Modern CLI Interface**: New `osh` command with subcommand structure
- ✅ **Enhanced Plugin Management**: `osh plugin add/remove/list/info` commands
- ✅ **Improved User Experience**: Modern command style following industry standards
- ✅ **Backward Compatibility**: Legacy commands still supported
- ✅ **Better Documentation**: Updated guides with new command examples
- ✅ **System Integration**: `osh` command available in PATH after installation

## [1.3.0] - 2025-07-03

### Added
- ✅ **Plugin Manifest System**: Professional plugin management with categories
- ✅ **Installation Presets**: Minimal, recommended, developer, and full presets
- ✅ **Smart Plugin Discovery**: Multiple discovery methods with fallback
- ✅ **Enhanced User Experience**: Better plugin selection and installation flow
- ✅ **Improved Documentation**: Comprehensive plugin development guide

## [1.2.0] - 2025-06-25

### Added
- ✅ **Enhanced Installation**: Beautiful UI with progress indicators
- ✅ **Shell Detection**: Smart shell detection and configuration
- ✅ **Backup Management**: Automatic configuration backup with rotation

## [1.1.0] - 2025-06-16

### Added
- ✅ **Core Framework**: Basic plugin system and essential plugins
- ✅ **Built-in Plugins**: Weather, sysinfo, taskman, proxy, ACW, FZF

---

## Version Comparison

| Version | Key Features | UI System | Plugin Management | CLI Interface |
|---------|-------------|-----------|-------------------|---------------|
| 1.5.0 | Cyberpunk UI + Advanced Plugin Management | ⭐⭐⭐ Cyberpunk | ⭐⭐⭐ Advanced | ⭐⭐⭐ Modern |
| 1.4.1 | Self-updating + Bug fixes | ⭐⭐ Vintage | ⭐⭐ Enhanced | ⭐⭐ Improved |
| 1.4.0 | Modern CLI commands | ⭐⭐ Vintage | ⭐⭐ Enhanced | ⭐⭐ Modern |
| 1.3.0 | Plugin manifest system | ⭐ Basic | ⭐⭐ Structured | ⭐ Basic |
| 1.2.0 | Enhanced installation | ⭐ Basic | ⭐ Basic | ⭐ Basic |
| 1.1.0 | Core framework | ⭐ Basic | ⭐ Basic | ⭐ Basic |

## Migration Guide

### From 1.4.x to 1.5.0

The new version is fully backward compatible. All existing commands continue to work, but you can now enjoy:

- **Enhanced Visual Experience**: Automatic cyberpunk UI activation
- **New Search Capabilities**: `osh plugin search <keyword>`
- **Dependency Checking**: `osh plugin deps <name>`
- **Better Plugin Information**: `osh plugin info <name>`

### Recommended Actions

1. **Try the new search**: `osh plugin search task`
2. **Check plugin dependencies**: `osh plugin deps weather`
3. **Explore the new status display**: `osh status`
4. **Browse plugins by category**: `osh plugin list stable`

No configuration changes are required - everything works out of the box!
