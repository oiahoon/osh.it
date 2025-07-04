# OSH.IT - A Lightweight Zsh Plugin Framework

<div align="center">

![OSH.IT Logo](https://img.shields.io/badge/OSH.IT-Zsh%20Framework-blue?style=for-the-badge)
[![GitHub Stars](https://img.shields.io/github/stars/oiahoon/osh.it?style=for-the-badge)](https://github.com/oiahoon/osh.it)
[![License](https://img.shields.io/github/license/oiahoon/osh.it?style=for-the-badge)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/oiahoon/osh.it?style=for-the-badge)](https://github.com/oiahoon/osh.it/commits)

*A fast, lightweight, and extensible Zsh plugin framework designed for developers who want power without bloat.*

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
upgrade_myshell
```

## 📦 Plugin Management System

OSH features a professional plugin management system with categorized releases and intelligent discovery.

### 🏷️ Plugin Categories

#### **Stable Plugins** (Recommended for all users)
- **sysinfo** - System information display with OSH branding
- **weather** - Beautiful weather forecast with ASCII art
- **taskman** - Advanced terminal task manager with productivity features

#### **Beta Plugins** (For advanced users)
- **acw** - Advanced Code Workflow with Git + JIRA integration
- **fzf** - Enhanced fuzzy finder with preview capabilities

#### **Experimental Plugins** (Use with caution)
- **greeting** - Friendly welcome message for OSH users

### 🎯 Installation Presets

```bash
# Minimal installation (basic functionality)
./install.sh --plugins "preset:minimal"

# Recommended installation (default)
./install.sh --plugins "preset:recommended"

# Developer installation (includes beta plugins)
./install.sh --plugins "preset:developer"

# Full installation (all stable plugins)
./install.sh --plugins "preset:full"
```

### 📋 Plugin Selection Options

During interactive installation, you can:

- **Select by numbers**: `1 2 3 4` (space-separated)
- **Use presets**: `preset:recommended`, `preset:developer`
- **Install all**: `all` or `a`
- **Default choice**: Press Enter for recommended preset

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

### Common Issues

**Plugin not found error:**
```bash
[myshell] plugin 'myplugin' not found
```
- Ensure plugin directory exists: `$OSH/plugins/myplugin/`
- Verify plugin file exists: `myplugin.plugin.zsh`
- Check plugin name in `oplugins` array
- Verify plugin is in the selected category (stable/beta/experimental)

**Configuration Bug Fix (July 2025):**
If you see `-e # OSH.IT Configuration` in your `.zshrc`, run:
```bash
# Download and run the fix script
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_zshrc.sh | zsh

# Or if you have OSH.IT installed locally
$OSH/scripts/fix_zshrc.sh
```

**JIRA integration not working:**
- Verify `JIRATOKEN` is correctly base64 encoded
- Check `JIRAURL` points to your JIRA instance
- Ensure you have API access permissions

**Slow shell startup:**
- Reduce number of plugins in `oplugins`
- Check for plugin conflicts
- Use `time zsh -i -c exit` to measure startup time

**Plugin installation fails:**
- Check internet connection
- Verify plugin exists in manifest
- Try different discovery method: `PLUGIN_DISCOVERY_METHOD=local ./install.sh`

### Debug Mode

```bash
# Enable debug output
export OSH_DEBUG=1
source $OSH/osh.sh
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

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/oiahoon/osh.it/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/oiahoon/osh.it/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/oiahoon/osh.it/wiki)
- 🔌 **Plugin Development**: See Plugin Development section above

## 🔄 Version History

### v1.3.0 (Latest)
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
