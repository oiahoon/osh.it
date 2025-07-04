# OSH.IT Plugin Management Documentation

## 🎯 Overview

OSH.IT v1.4.0 introduces a modern, user-friendly plugin management system that follows industry-standard CLI patterns. This document provides comprehensive guidance on managing plugins after installation.

## 🆕 Modern Command Interface

### Core Philosophy

OSH.IT now uses a **subcommand structure** similar to popular tools like Git, Docker, and Kubernetes:

```bash
# Modern style (recommended)
osh plugin add weather      # Clear hierarchy: tool -> category -> action -> target
osh preset developer        # Simple and intuitive
osh status                  # Direct and concise

# vs. Old style (still supported)
osh-plugin-add weather      # Hyphenated, harder to remember
osh-preset-developer        # Less discoverable
osh-status                  # Inconsistent with modern CLI patterns
```

## 📋 Complete Command Reference

### 🔌 Plugin Management

#### List and Discovery
```bash
# List all available plugins
osh plugin list

# Show currently installed plugins
osh plugins

# Get detailed information about a plugin
osh plugin info weather
```

#### Installation and Removal
```bash
# Add a single plugin
osh plugin add weather

# Add multiple plugins
osh plugin add weather taskman acw

# Remove a plugin
osh plugin remove taskman

# Remove multiple plugins
osh plugin remove taskman acw
```

### 📦 Preset Management

```bash
# Install minimal preset (sysinfo only)
osh preset minimal

# Install recommended preset (sysinfo, weather, taskman)
osh preset recommended

# Install developer preset (recommended + acw, fzf)
osh preset developer

# Install all available plugins
osh preset full
```

### 🔧 System Management

```bash
# Show OSH.IT status and installed plugins
osh status

# Reload configuration after changes
osh reload

# Upgrade OSH.IT to latest version
osh upgrade

# Show help information
osh help
```

## 🔄 Migration Guide

### From Legacy Commands

| Legacy Command | Modern Equivalent | Notes |
|----------------|-------------------|-------|
| `osh-plugins-list` | `osh plugin list` | More discoverable |
| `osh-plugins-current` | `osh plugins` | Shorter, clearer |
| `osh-plugin-add weather` | `osh plugin add weather` | Standard subcommand pattern |
| `osh-plugin-remove weather` | `osh plugin remove weather` | Consistent with add |
| `osh-preset-developer` | `osh preset developer` | Cleaner syntax |
| `osh-status` | `osh status` | Direct command |
| `osh-reload` | `osh reload` | Simplified |

### Backward Compatibility

All legacy commands continue to work:

```bash
# These still work for existing users
osh-plugin-add weather
osh-plugins-list
osh-preset-developer
osh-status
osh-reload
```

## 🎯 Plugin Categories

### 🟢 Stable Plugins (Recommended)

**Target Users**: All users  
**Quality**: Production-ready, thoroughly tested

| Plugin | Description | Commands | Dependencies |
|--------|-------------|----------|--------------|
| **sysinfo** | System information display | `sysinfo`, `oshinfo` | None |
| **weather** | Weather forecast with ASCII art | `weather`, `forecast` | curl |
| **taskman** | Advanced task manager | `tm`, `tasks` | python3 |

### 🟡 Beta Plugins (Advanced Users)

**Target Users**: Advanced users, developers  
**Quality**: Functional but may have minor issues

| Plugin | Description | Commands | Dependencies |
|--------|-------------|----------|--------------|
| **acw** | Advanced Code Workflow | `acw`, `ggco`, `newb` | git, curl |
| **fzf** | Enhanced fuzzy finder | `pp`, `fcommit` | fzf |

### 🔴 Experimental Plugins (Use with Caution)

**Target Users**: Developers, testers  
**Quality**: New features, proof of concepts

| Plugin | Description | Commands | Dependencies |
|--------|-------------|----------|--------------|
| **greeting** | Welcome message | Auto-display | None |

## 💡 Best Practices

### 🎯 For New Users

1. **Start with recommended preset**:
   ```bash
   osh preset recommended
   ```

2. **Explore available plugins**:
   ```bash
   osh plugin list
   ```

3. **Add plugins gradually**:
   ```bash
   osh plugin add acw
   osh reload
   # Test the plugin before adding more
   ```

### 🔧 For Existing Users

1. **Check current setup**:
   ```bash
   osh status
   osh plugins
   ```

2. **Migrate to modern commands gradually**:
   ```bash
   # Instead of: osh-plugin-add weather
   osh plugin add weather
   ```

3. **Use new features**:
   ```bash
   # Get plugin information
   osh plugin info weather
   
   # Quick system check
   osh status
   ```

### 📝 For Script Writers

1. **Use modern commands in new scripts**:
   ```bash
   #!/bin/bash
   # Good: Modern, readable
   osh plugin add weather
   osh reload
   ```

2. **Consider backward compatibility**:
   ```bash
   # For maximum compatibility
   if command -v osh >/dev/null 2>&1; then
       osh plugin add weather
   else
       osh-plugin-add weather
   fi
   ```

## 🔍 Advanced Usage

### Conditional Plugin Loading

```bash
# In your .zshrc, you can add conditional logic
if [[ "$USER" == "developer" ]]; then
    osh preset developer
elif [[ "$HOSTNAME" == "server"* ]]; then
    osh preset minimal
else
    osh preset recommended
fi
```

### Plugin Information and Debugging

```bash
# Get detailed plugin information
osh plugin info weather

# Check system status
osh status

# Debug plugin issues
OSH_DEBUG=1 osh reload
```

### Automation Examples

```bash
# Setup script for new developers
#!/bin/bash
echo "Setting up OSH.IT for development..."
osh preset developer
osh plugin add greeting
osh reload
echo "Setup complete! Run 'osh status' to verify."
```

## 🛠️ Troubleshooting

### Common Issues and Solutions

#### Plugin Not Found
```bash
# Problem: Plugin not found error
# Solution: Check available plugins
osh plugin list

# Verify plugin is installed
osh plugins

# Check plugin files
ls ~/.osh/plugins/
```

#### Configuration Issues
```bash
# Problem: Plugin not loading
# Solution: Check configuration
grep "oplugins=" ~/.zshrc

# Reload configuration
osh reload

# Check status
osh status
```

#### Command Not Found
```bash
# Problem: 'osh' command not found
# Solution: Check PATH
echo $PATH | grep -o '[^:]*\.osh[^:]*'

# Reload shell configuration
source ~/.zshrc

# Or use full path
~/.osh/bin/osh status
```

### Debug Mode

```bash
# Enable debug output
export OSH_DEBUG=1
osh reload

# Check detailed status
osh status

# Disable debug
unset OSH_DEBUG
```

## 📚 Integration Examples

### With Development Workflow

```bash
# Morning setup
osh status                    # Check system
osh plugin add weather        # Check weather
weather                       # See forecast
osh plugin add taskman        # Load tasks
tm                           # Review tasks
```

### With CI/CD

```bash
# In CI script
#!/bin/bash
set -e

# Install minimal OSH.IT setup
osh preset minimal
osh reload

# Verify installation
osh status
```

### With Dotfiles Management

```bash
# In your dotfiles setup script
if command -v osh >/dev/null 2>&1; then
    echo "Configuring OSH.IT plugins..."
    osh preset developer
    osh plugin add greeting
    osh reload
    echo "OSH.IT configured successfully!"
fi
```

## 🔮 Future Enhancements

### Planned Features

- **Plugin Search**: `osh plugin search <keyword>`
- **Plugin Updates**: `osh plugin update <name>`
- **Plugin Dependencies**: Automatic dependency resolution
- **Plugin Profiles**: Save and load plugin configurations
- **Remote Plugins**: Install plugins from external repositories

### Feedback and Contributions

We welcome feedback on the new plugin management system:

- **GitHub Issues**: [Report bugs or request features](https://github.com/oiahoon/osh.it/issues)
- **GitHub Discussions**: [Share ideas and feedback](https://github.com/oiahoon/osh.it/discussions)
- **Pull Requests**: [Contribute improvements](https://github.com/oiahoon/osh.it/pulls)

---

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/oiahoon/osh.it/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/oiahoon/osh.it/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/oiahoon/osh.it/wiki)
- 🔌 **Plugin Development**: [Development Guide](../PLUGIN_DEVELOPMENT_GUIDE.md)

---

*This documentation is for OSH.IT v1.4.0 and later. For older versions, please refer to the legacy documentation.*
