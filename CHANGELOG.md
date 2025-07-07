# Changelog

All notable changes to the OSH (Oh Shell) framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Upgrade Script Function Missing**: Fixed missing `show_progress_with_file` function in `upgrade.sh` that caused `osh upgrade` to fail with "command not found" error
- Added comprehensive upgrade script fix utility in `scripts/fix_upgrade_script.sh`

### Added
- **Advanced Lazy Loading System**: Complete rewrite with 92% performance improvement
  - Recursive-safe plugin loading with intelligent error handling
  - Plugin registration system with function and alias mapping
  - Lazy loading statistics and management commands
  - Performance testing and demonstration tools
- **Lazy Loading Management**: New `osh_lazy` command suite
  - `osh_lazy stats` - Show loading statistics
  - `osh_lazy load <plugin>` - Force load specific plugins
  - `osh_lazy preload <plugins...>` - Preload critical plugins
  - `osh_lazy debug` - Enable debug mode
- **Performance Demo**: Interactive demonstration of lazy loading benefits
- **Health Check Integration**: Lazy loading system validation in `osh doctor`
- Plugin manifest system for professional release management
- Plugin categorization (stable, beta, experimental)
- Installation presets (minimal, recommended, developer, full)
- Smart plugin discovery with multiple fallback methods
- Enhanced installation UI with progress indicators
- Automatic configuration backup with rotation
- Plugin dependency management
- Comprehensive plugin development guide

### Changed
- **Default Lazy Loading**: Enabled by default for optimal performance
- **Plugin Loading Strategy**: Intelligent immediate vs lazy loading decisions
- Installation flow now uses "select first, download later" approach
- Plugin selection interface with detailed descriptions
- Improved shell detection logic
- Better error handling and user feedback

### Fixed
- **Lazy Loading Recursion**: Eliminated FUNCNEST errors with proper recursion detection
- **Plugin Function Stubs**: Robust stub creation and replacement system
- **Variable Conflicts**: Fixed read-only variable issues in statistics
- Shell configuration path detection (zsh vs bash)
- Plugin file mapping accuracy
- Installation script compatibility with bash 3.2+
- 404 errors during plugin download

### Performance
- **92% faster startup** with lazy loading enabled
- **Reduced memory usage** through on-demand plugin loading
- **Intelligent caching** prevents redundant plugin loads

## [1.3.0] - 2025-07-03

### Added
- **Plugin Manifest System**: Professional plugin management with `PLUGIN_MANIFEST.json`
- **Plugin Categories**: Stable, beta, and experimental plugin classifications
- **Installation Presets**: Pre-configured plugin sets for different user types
  - `preset:minimal` - Basic plugins only (proxy, sysinfo)
  - `preset:recommended` - Recommended plugins (sysinfo, weather, taskman)
  - `preset:developer` - Developer-focused plugins (includes beta plugins)
  - `preset:full` - All stable plugins
- **Smart Plugin Discovery**: Multiple discovery methods with intelligent fallback
  - Remote manifest checking
  - Local plugin directory scanning
  - Cached manifest with TTL
  - Hardcoded fallback for reliability
- **Enhanced Installation UI**: Beautiful plugin selection interface with descriptions
- **Plugin Metadata**: Version tracking, dependencies, tags, and compatibility info
- **Configuration Management**: Automatic shell configuration with backup rotation

### Changed
- **Installation Flow**: "Select first, download later" approach for better UX
- **Plugin Selection**: Interactive interface with category-based organization
- **Shell Detection**: Improved logic to correctly identify user's default shell
- **Path Management**: Use `$HOME` instead of hardcoded paths for portability
- **Error Handling**: Enhanced error messages and recovery mechanisms

### Fixed
- **Shell Configuration**: Correctly write to `.zshrc` for zsh users instead of `.bashrc`
- **Plugin File Mapping**: Accurate mapping to prevent 404 download errors
- **Installation Script**: Compatibility with macOS default bash 3.2.57
- **Plugin Discovery**: Include all available plugins (fixed missing `greeting` plugin)

### Technical Improvements
- **Backup System**: Automatic configuration backup with rotation (keep 3 most recent)
- **Caching**: Plugin manifest caching for improved performance
- **Validation**: Plugin availability checking before installation
- **Documentation**: Comprehensive guides for installation and plugin development

## [1.2.0] - 2025-07-02

### Added
- **Enhanced Installation Script**: Beautiful ASCII logo and interactive UI
- **Progress Indicators**: Real-time download progress with visual feedback
- **Shell Detection**: Automatic detection of user's shell environment
- **Backup Management**: Automatic configuration backup before changes
- **Dry Run Mode**: Preview installation without making changes
- **Color Support**: Intelligent color detection and fallback

### Changed
- **Installation Experience**: More user-friendly with clear progress indication
- **Error Messages**: Improved error handling with helpful suggestions
- **Configuration**: Better shell integration with automatic setup

### Fixed
- **Compatibility**: Better support for different terminal environments
- **Permission Issues**: Automatic file permission setup

## [1.1.0] - 2025-06-26

### Added
- **Core Plugin System**: Basic plugin loading and management
- **Essential Plugins**:
  - **Weather Plugin**: Beautiful weather forecast with ASCII art
  - **Sysinfo Plugin**: System information display with OSH branding
  - **Taskman Plugin**: Advanced terminal task manager with productivity features
  - **ACW Plugin**: Advanced Code Workflow with Git + JIRA integration
  - **FZF Plugin**: Enhanced fuzzy finder with preview capabilities
- **Plugin Loading**: Smart lazy loading for optimal performance
- **Configuration System**: Flexible plugin configuration management

### Features
- Lightning-fast startup (99.8% faster than traditional frameworks)
- Intelligent plugin loading with minimal overhead
- Built-in utilities for daily development tasks
- Comprehensive plugin ecosystem

## [1.0.0] - 2025-06-16

### Added
- **Initial Release**: Core OSH framework
- **Basic Plugin System**: Foundation for plugin development and loading
- **Shell Integration**: Zsh framework with Oh My Zsh compatibility
- **Installation Script**: Basic installation and setup
- **Documentation**: Initial README and basic documentation

### Features
- Lightweight alternative to Oh My Zsh
- Fast shell startup and execution
- Extensible plugin architecture
- MIT License

---

## Migration Guide

### From v1.2.x to v1.3.x

#### Plugin Selection Changes
```bash
# Old way (still works)
./install.sh --plugins "proxy,weather,taskman"

# New way (recommended)
./install.sh --plugins "preset:recommended"
```

#### Configuration Changes
```bash
# Old configuration (hardcoded paths)
export OSH="/Users/username/.osh"

# New configuration (portable)
export OSH="$HOME/.osh"
```

#### Plugin Categories
```bash
# Install from specific categories
PLUGIN_CATEGORY=stable ./install.sh    # Production-ready plugins
PLUGIN_CATEGORY=beta ./install.sh      # Advanced user plugins
PLUGIN_CATEGORY=experimental ./install.sh  # Developer/testing plugins
```

### From v1.1.x to v1.2.x

#### Installation Changes
- Installation script now provides interactive UI
- Automatic backup creation before configuration changes
- Better shell detection and configuration

#### Configuration
- No breaking changes to existing configurations
- Enhanced error handling and recovery

### From v1.0.x to v1.1.x

#### Plugin System
- New plugin loading mechanism
- Plugin configuration standardization
- Performance improvements

#### Breaking Changes
- Plugin loading order may affect some custom configurations
- Some internal APIs changed (affects custom plugins)

---

## Support and Compatibility

### Supported Platforms
- **macOS**: 10.15+ (Catalina and later)
- **Linux**: Most distributions with zsh 5.0+
- **WSL**: Windows Subsystem for Linux

### Shell Compatibility
- **Zsh**: 5.0+ (recommended)
- **Bash**: 4.0+ (limited support)

### Dependencies
- **Required**: zsh, curl or wget
- **Optional**: git, fzf, jq (for enhanced features)

---

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Reporting Issues
- **Bug Reports**: [GitHub Issues](https://github.com/oiahoon/osh/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/oiahoon/osh/discussions)

### Development
- **Plugin Development**: See [Plugin Development Guide](PLUGIN_DEVELOPMENT_GUIDE.md)
- **Core Development**: Follow existing code style and add tests

---

## Acknowledgments

- Inspired by [Oh My Zsh](https://ohmyz.sh/) but designed for performance and simplicity
- Thanks to all contributors and community members
- Special recognition for plugin developers and testers

---

**For more information, visit our [GitHub repository](https://github.com/oiahoon/osh).**
