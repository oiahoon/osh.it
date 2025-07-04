# OSH.IT - A Lightweight Zsh Plugin Framework

<div align="center">

![OSH.IT Logo](https://img.shields.io/badge/OSH.IT-Zsh%20Framework-blue?style=for-the-badge)
[![GitHub Stars](https://img.shields.io/github/stars/oiahoon/osh.it?style=for-the-badge)](https://github.com/oiahoon/osh.it)
[![License](https://img.shields.io/github/license/oiahoon/osh.it?style=for-the-badge)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/oiahoon/osh.it?style=for-the-badge)](https://github.com/oiahoon/osh.it/commits)

*A fast, lightweight, and extensible Zsh plugin framework designed for developers who want power without bloat.*

🌐 **[Official Website](https://oiahoon.github.io/osh.it/)** | 📚 **[Documentation](https://github.com/oiahoon/osh.it/wiki)** | 🐛 **[Issues](https://github.com/oiahoon/osh.it/issues)**

</div>

## ✨ Features

- 🚀 **Lightning Fast**: Minimal overhead with smart plugin loading
- ⚡ **Advanced Lazy Loading**: 92% faster startup with on-demand plugin loading
- 🔌 **Smart Plugin System**: Intelligent plugin discovery and management
- 📋 **Plugin Manifest**: Professional plugin release management with categories
- 🛠️ **Built-in Utilities**: Comes with practical plugins for daily development
- 📦 **Easy Installation**: One-command setup with automatic configuration
- 🎯 **Developer Focused**: Built by developers, for developers
- 🔧 **Highly Customizable**: Flexible configuration without complexity

### 🤖 AI-Powered Auto-Implementation

OSH now features an advanced AI-powered auto-implementation system that can automatically analyze GitHub issues and generate complete implementations.

#### Features
- **GitHub Amazon Q Developer**: Native GitHub integration (no additional setup required)
- **Enhanced Requirement Analysis**: Deep understanding with implementation strategies
- **Interactive Analysis**: AI-driven requirement clarification
- **Automatic Code Generation**: Complete implementations with tests and documentation
- **Smart Permission Management**: Automatic diagnosis and fixing of permission issues

#### Usage

**Trigger Enhanced Analysis:**
```
/analyze-enhanced
```

**Approve for Auto-Implementation:**
- Add `auto-implement-approved` label (maintainers)
- React with 👍 to analysis comment (maintainers)

#### Configuration

**GitHub Repository Settings:**
- Enable "Read and write permissions" for GitHub Actions
- Allow GitHub Actions to create and approve pull requests
- Ensure Issues feature is enabled
- Enable GitHub Amazon Q Developer in repository settings

**Optional AI API Keys (for enhanced analysis):**
```bash
DEEPSEEK_API_KEY          # DeepSeek AI (optional)
OPENAI_API_KEY            # OpenAI (optional)
ANTHROPIC_API_KEY         # Claude (optional)
```

> **Note**: No AWS credentials needed! GitHub's Amazon Q Developer handles authentication automatically.

## 🚀 Quick Start

### Installation

```bash
# Fresh installation with automatic network optimization
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"

# Or if you prefer wget
sh -c "$(wget -O- https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"

# Use Gitee mirror for faster access in China
OSH_MIRROR=gitee sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

### Health Check & Diagnostics

```bash
# Run comprehensive health check
osh doctor

# Auto-fix common issues
osh doctor --fix

# Include performance test
osh doctor --perf
```

### ⚡ Lazy Loading System

OSH.IT features an advanced lazy loading system that dramatically improves shell startup performance by loading plugins only when needed.

#### Performance Benefits
- **92% faster startup** compared to immediate loading
- **Reduced memory footprint** - plugins loaded on-demand
- **Intelligent caching** - plugins stay loaded after first use
- **Zero configuration** - works automatically with all plugins

#### Lazy Loading Management

```bash
# Check lazy loading status
osh_lazy stats

# Force load a specific plugin
osh_lazy load weather

# Preload critical plugins
osh_lazy preload weather taskman

# Enable debug mode
osh_lazy debug

# Run performance demo
$OSH/scripts/lazy_loading_demo.sh
```

#### Configuration

```bash
# Enable lazy loading (default)
export OSH_LAZY_LOADING=true

# Disable lazy loading
export OSH_LAZY_LOADING=false

# Enable lazy loading debug output
export OSH_LAZY_DEBUG=1
```

### Upgrade

```bash
# Modern way (recommended)
osh upgrade

# Legacy way (still works)
upgrade_myshell
```

### Quick Start After Installation

```bash
# Check installation status
osh status

# View available plugins
osh plugin list

# Add your first plugin
osh plugin add weather

# Reload to activate changes
osh reload
```

## 🔌 Plugin Management

OSH.IT provides a modern, user-friendly command-line interface for managing plugins after installation.

### 🎯 Quick Commands

```bash
# View available plugins
osh plugin list

# View currently installed plugins  
osh plugins

# Add a plugin
osh plugin add weather

# Remove a plugin
osh plugin remove taskman

# Get plugin information
osh plugin info weather

# Install plugin presets
osh preset recommended    # sysinfo weather taskman
osh preset developer      # recommended + acw fzf
osh preset minimal        # sysinfo only
osh preset full          # all plugins

# System management
osh status               # Show OSH.IT status
osh reload               # Reload configuration
osh upgrade              # Upgrade OSH.IT
```

### 📋 Available Plugins

#### 🟢 **Stable Plugins** (Recommended)
- **sysinfo** - System information display with OSH branding
- **weather** - Beautiful weather forecast with ASCII art  
- **taskman** - Advanced terminal task manager

#### 🟡 **Beta Plugins** (Advanced users)
- **acw** - Advanced Code Workflow (Git + JIRA integration)
- **fzf** - Enhanced fuzzy finder with preview

#### 🔴 **Experimental Plugins** (Use with caution)
- **greeting** - Friendly welcome message

### 💡 Plugin Management Examples

```bash
# Start with recommended plugins
osh preset recommended

# Add development tools
osh plugin add acw
osh plugin add fzf

# Check what's installed
osh plugins

# Get help
osh help
```

### 🔄 Legacy Commands (Backward Compatibility)

For users familiar with the old syntax, these commands still work:
```bash
osh-plugin-add weather      # Same as: osh plugin add weather
osh-plugins-list           # Same as: osh plugin list  
osh-preset-developer       # Same as: osh preset developer
```

## 🔧 Built-in Plugins

### 🌐 Proxy
Network proxy management:

### 🔍 FZF Integration
Enhanced fuzzy finding capabilities:
- `pp` - Preview files with syntax highlighting
- `fcommit` - Interactive git commit browser

### 🌤️ Weather
Weather forecast with ASCII art:
- `weather` - Show current weather for your location
- `weather -l Tokyo` - Show weather for specific location
- `weather -d` - Show detailed forecast with ASCII art
- `forecast` - Alias for detailed weather forecast

### 🖥️ Sysinfo
Neofetch-inspired system information display:
- `sysinfo` - Show system info with beautiful OSH logo
- `sysinfo --no-logo` - Show system info without logo
- `oshinfo` - Alias for sysinfo
- `neofetch-osh` - Alternative alias

### 📋 Taskman
Advanced terminal task manager with smart productivity assistant:
- **🎯 First-time Setup Wizard** - Friendly onboarding for new users
- **📁 Flexible Storage** - Default, custom, or portable data locations
- Interactive task management with priorities
- Smart dino animation that responds to your productivity
- Visual progress indicators and celebration system
- Task-integrated mood system (😴🦕🎯🎉😰)
- Time-aware status display with productivity metrics
- CLI and TUI interfaces with vintage styling

#### Quick Start
```bash
tm                    # Launch task manager (auto-setup on first run)
tasks setup          # Run setup wizard anytime
tasks config         # View current configuration
```

### 🔧 ACW (Advanced Code Workflow)
Git workflow automation for JIRA integration:
- `acw [base-branch]` - Create feature branches with JIRA ticket integration
- `ggco <keyword>` - Smart branch switching by keyword
- `newb [base-branch]` - Create general purpose branches

## ⚙️ Configuration

### Basic Setup

Add to your `~/.zshrc`:

```bash
# OSH Configuration
export OSH="$HOME/.osh"

# Plugin Selection
oplugins=(sysinfo weather taskman)

# Load OSH
source $OSH/osh.sh
```

### Environment Variables

```bash
# Git Configuration
GITUSER="YourName"              # Your name for branch creation

# JIRA Integration (for ACW plugin)
JIRATOKEN="base64-encoded-token"  # Generate: base64 <<< "username:password"
JIRAURL="https://your-jira.com"   # Your JIRA instance URL

# Custom OSH Directory (optional)
OSH_CUSTOM="$HOME/.osh-custom"    # Custom plugins directory

# Plugin Discovery (optional)
PLUGIN_CATEGORY="stable"          # Plugin category: stable, beta, experimental
PLUGIN_DISCOVERY_METHOD="smart"   # Discovery method: smart, remote, local, cached
```

### JIRA Token Generation

```bash
# Generate JIRA token for ACW plugin
echo -n "username:password" | base64
```

## 🔌 Plugin Development

### Creating a Plugin

1. Create plugin directory:
```bash
mkdir -p $OSH/plugins/myplugin
```

2. Create plugin file:
```bash
# $OSH/plugins/myplugin/myplugin.plugin.zsh
#!/bin/zsh

# Your plugin code here
hello_world() {
    echo "Hello from my plugin!"
}
```

3. Add to plugin manifest (for distribution):
```json
{
  "name": "myplugin",
  "version": "1.0.0",
  "description": "My awesome plugin",
  "files": ["plugins/myplugin/myplugin.plugin.zsh"],
  "dependencies": [],
  "tags": ["utility", "example"]
}
```

4. Enable in `~/.zshrc`:
```bash
oplugins=(myplugin)
```

### Plugin Structure

```
plugins/
└── myplugin/
    ├── myplugin.plugin.zsh    # Main plugin file
    ├── README.md              # Plugin documentation
    ├── functions/             # Function definitions
    ├── completions/           # Zsh completions
    └── config/                # Configuration files
```

### Plugin Manifest Integration

For plugins intended for distribution, add them to `PLUGIN_MANIFEST.json`:

```json
{
  "categories": {
    "experimental": {
      "plugins": [
        {
          "name": "myplugin",
          "version": "0.1.0",
          "description": "My experimental plugin",
          "files": ["plugins/myplugin/myplugin.plugin.zsh"],
          "dependencies": [],
          "tags": ["experimental", "utility"]
        }
      ]
    }
  }
}
```

## 🛠️ Advanced Usage

### Custom Plugin Directory

```bash
# Set custom plugin directory
export OSH_CUSTOM="$HOME/my-osh-plugins"

# OSH will look for plugins in both locations:
# 1. $OSH_CUSTOM/plugins/
# 2. $OSH/plugins/
```

### Plugin Loading Order

Plugins are loaded in the order specified in the `oplugins` array:

```bash
oplugins=(
    proxy      # Load first
    sysinfo    # Load second
    weather    # Load third
    taskman    # Load last
)
```

### Plugin Category Selection

```bash
# Install from specific category
PLUGIN_CATEGORY=beta ./install.sh

# Available categories: stable, beta, experimental
```

### Plugin Discovery Methods

```bash
# Smart discovery (default) - tries multiple methods
PLUGIN_DISCOVERY_METHOD=smart ./install.sh

# Remote discovery - checks remote repository
PLUGIN_DISCOVERY_METHOD=remote ./install.sh

# Local discovery - uses local plugin directory
PLUGIN_DISCOVERY_METHOD=local ./install.sh

# Cached discovery - uses cached manifest
PLUGIN_DISCOVERY_METHOD=cached ./install.sh
```

## 🔧 Troubleshooting

### Quick Diagnostics

```bash
# Run comprehensive diagnostics
osh doctor

# Auto-fix common issues
osh doctor --fix

# Include performance test
osh doctor --perf
```

### Common Issues

**Installation Issues (lazy_loader.zsh not found, osh command not found):**
```bash
# Quick fix for existing installations
bash <(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_installation.sh)

# Or re-install with the latest version
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"

# Or run diagnostics to identify missing files
osh doctor --fix
```
See [Installation Fix Guide](INSTALLATION_FIX_GUIDE.md) for detailed solutions.

**Permission Issues (Permission denied, cannot execute):**
```bash
# Quick permission fix
bash <(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_permissions.sh)

# Or manual fix
chmod +x ~/.osh/bin/osh ~/.osh/scripts/*.sh
```
See [Permission Fix Guide](PERMISSION_FIX_GUIDE.md) for detailed solutions.

**Alias Conflict Issues (defining function based on alias, parse error):**
```bash
# Quick alias conflict fix
bash <(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_alias_conflicts.sh)

# Or update lazy loader manually
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/lib/lazy_loader.zsh -o ~/.osh/lib/lazy_loader.zsh
```

**OSH commands not working (osh status, osh plugin add, etc.):**
```bash
# Run diagnostics to identify the issue
osh doctor

# Most common causes:
# 1. PATH not configured - restart terminal or run: source ~/.zshrc
# 2. OSH.IT not properly installed - run the installer again
# 3. File permissions - run: osh doctor --fix
```

**Plugin not found error:**
```bash
[myshell] plugin 'myplugin' not found
```
- Check available plugins: `osh plugin list`
- Verify plugin is installed: `osh plugins`
- Ensure plugin directory exists: `$OSH/plugins/myplugin/`
- Verify plugin file exists: `myplugin.plugin.zsh`
- Check plugin name in `oplugins` array

**Plugin management issues:**
```bash
# Check OSH.IT status
osh status

# Verify plugin installation
osh plugins

# Reinstall a plugin
osh plugin remove weather
osh plugin add weather

# Reload configuration
osh reload
```

**Configuration Bug Fix (July 2025):**
If you see `-e # OSH.IT Configuration` in your `.zshrc`, run:
```bash
# Download and run the fix script
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_zshrc.sh | zsh

# Or if you have OSH.IT installed locally
$OSH/scripts/fix_zshrc.sh
```

**Taskman Auto-Start Fix (December 2024):**
If taskman launches automatically when opening new shells, your `.zshrc` has malformed plugin configuration:
```bash
# Run the comprehensive fix
$OSH/scripts/fix_zshrc.sh

# Or plugin-specific fix
$OSH/scripts/fix_zshrc_plugins.sh
```
See [Taskman Auto-Start Fix Guide](docs/TASKMAN_AUTOSTART_FIX.md) for details.

**JIRA integration not working:**
- Verify `JIRATOKEN` is correctly base64 encoded
- Check `JIRAURL` points to your JIRA instance
- Ensure you have API access permissions

**Slow shell startup:**
- Check current plugins: `osh plugins`
- Reduce number of plugins: `osh plugin remove <name>`
- Use `time zsh -i -c exit` to measure startup time

**Plugin installation fails:**
- Check internet connection
- Verify plugin exists: `osh plugin list`
- Check OSH.IT status: `osh status`

### Debug Mode

```bash
# Enable debug output
export OSH_DEBUG=1
osh reload
```

### Quick Diagnostics

```bash
# Run comprehensive diagnostics
osh status

# Check plugin status
osh plugins

# Verify installation
ls $OSH/plugins/

# Test configuration
grep "oplugins=" ~/.zshrc
```

### Plugin Manifest Issues

```bash
# Force refresh plugin manifest
rm /tmp/osh_plugin_manifest.json
./install.sh

# Use local manifest backup
PLUGIN_DISCOVERY_METHOD=local ./install.sh

# Check manifest information
./plugin_manifest_manager.sh
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines

- Follow existing code style
- Add documentation for new features
- Test on multiple Zsh versions
- Update README for new plugins
- Update `PLUGIN_MANIFEST.json` for new plugins
- Follow plugin categorization guidelines:
  - **experimental**: New, untested plugins
  - **beta**: Tested but not fully stable
  - **stable**: Production-ready plugins

### Plugin Contribution Process

1. **Develop Plugin**: Create in `plugins/yourplugin/`
2. **Add to Experimental**: Update manifest with experimental category
3. **Community Testing**: Gather feedback and fix issues
4. **Promote to Beta**: Move to beta category after testing
5. **Stable Release**: Move to stable after proven reliability

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Oh My Zsh](https://ohmyz.sh/) but designed for simplicity and performance
- Built with ❤️ for the developer community
- Special thanks to all contributors

## 📞 Support

- 🌐 **Official Website**: [https://oiahoon.github.io/osh.it/](https://oiahoon.github.io/osh.it/)
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/oiahoon/osh.it/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/oiahoon/osh.it/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/oiahoon/osh.it/wiki)
- 🔌 **Plugin Development**: See Plugin Development section above

## 🔄 Version History

### v1.4.0 (Latest)
- ✅ **Modern CLI Interface**: New `osh` command with subcommand structure
- ✅ **Enhanced Plugin Management**: `osh plugin add/remove/list/info` commands
- ✅ **Improved User Experience**: Modern command style following industry standards
- ✅ **Backward Compatibility**: Legacy commands still supported
- ✅ **Better Documentation**: Updated guides with new command examples
- ✅ **System Integration**: `osh` command available in PATH after installation

### v1.3.0
- ✅ **Plugin Manifest System**: Professional plugin management with categories
- ✅ **Installation Presets**: Minimal, recommended, developer, and full presets
- ✅ **Smart Plugin Discovery**: Multiple discovery methods with fallback
- ✅ **Enhanced User Experience**: Better plugin selection and installation flow
- ✅ **Improved Documentation**: Comprehensive plugin development guide

### v1.2.0
- ✅ **Enhanced Installation**: Beautiful UI with progress indicators
- ✅ **Shell Detection**: Smart shell detection and configuration
- ✅ **Backup Management**: Automatic configuration backup with rotation

### v1.1.0
- ✅ **Core Framework**: Basic plugin system and essential plugins
- ✅ **Built-in Plugins**: Weather, sysinfo, taskman, proxy, ACW, FZF

---

<div align="center">

**[⭐ Star this repo](https://github.com/oiahoon/osh.it) if you find it useful!**

Made with ❤️ by [oiahoon](https://github.com/oiahoon)

</div>
