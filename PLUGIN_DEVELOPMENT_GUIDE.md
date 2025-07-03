# OSH Plugin Development Guide

## 🎯 Overview

This guide covers everything you need to know about developing plugins for the OSH (Oh Shell) framework, including the new plugin manifest system and categorization process.

## 📋 Plugin Manifest System

OSH uses a centralized plugin manifest (`PLUGIN_MANIFEST.json`) to manage plugin releases, categories, and metadata. This ensures professional release management and better user experience.

### Plugin Categories

#### 🟢 **Stable** (Production Ready)
- **Target Users**: All users
- **Quality**: Thoroughly tested, stable, well-documented
- **Examples**: proxy, sysinfo, weather, taskman
- **Requirements**: 
  - Comprehensive testing
  - Complete documentation
  - Version >= 1.0.0
  - No known critical bugs

#### 🟡 **Beta** (Advanced Users)
- **Target Users**: Advanced users, early adopters
- **Quality**: Functional but may have minor issues
- **Examples**: acw, fzf
- **Requirements**:
  - Basic testing completed
  - Core functionality working
  - Version >= 0.8.0
  - Known issues documented

#### 🔴 **Experimental** (Use with Caution)
- **Target Users**: Developers, testers
- **Quality**: New features, proof of concepts
- **Examples**: greeting, new experimental features
- **Requirements**:
  - Basic functionality implemented
  - Version >= 0.1.0
  - Clear experimental status

## 🚀 Plugin Development Workflow

### Phase 1: Development

#### 1. Create Plugin Structure
```bash
# Create plugin directory
mkdir -p $OSH/plugins/myplugin

# Create main plugin file
touch $OSH/plugins/myplugin/myplugin.plugin.zsh

# Create documentation
touch $OSH/plugins/myplugin/README.md
```

#### 2. Plugin Template
```bash
#!/usr/bin/env zsh
# Plugin: myplugin
# Description: Brief description of what your plugin does
# Author: Your Name
# Version: 0.1.0
# License: MIT

# Plugin initialization
if [[ -z "$MYPLUGIN_LOADED" ]]; then
  export MYPLUGIN_LOADED=1
  
  # Plugin configuration
  MYPLUGIN_CONFIG_DIR="${MYPLUGIN_CONFIG_DIR:-$HOME/.config/myplugin}"
  MYPLUGIN_VERSION="0.1.0"
  
  # Ensure config directory exists
  [[ ! -d "$MYPLUGIN_CONFIG_DIR" ]] && mkdir -p "$MYPLUGIN_CONFIG_DIR"
  
  # Main plugin functions
  myplugin_hello() {
    echo "Hello from MyPlugin v$MYPLUGIN_VERSION!"
  }
  
  myplugin_info() {
    echo "MyPlugin Information:"
    echo "  Version: $MYPLUGIN_VERSION"
    echo "  Config: $MYPLUGIN_CONFIG_DIR"
  }
  
  # Aliases
  alias mp='myplugin_hello'
  alias mpinfo='myplugin_info'
  
  # Completions (if needed)
  if [[ -f "$OSH/plugins/myplugin/completions/_myplugin" ]]; then
    fpath=("$OSH/plugins/myplugin/completions" $fpath)
    autoload -U compinit && compinit
  fi
  
  # Plugin loaded message (optional, for debugging)
  [[ "$OSH_DEBUG" == "1" ]] && echo "✅ MyPlugin loaded"
fi
```

#### 3. Create README.md
```markdown
# MyPlugin

Brief description of what your plugin does.

## Features

- Feature 1: Description
- Feature 2: Description
- Feature 3: Description

## Installation

This plugin is included in OSH. Enable it using the modern plugin management system:

```bash
# Add plugin using modern CLI
osh plugin add myplugin

# Or add to configuration manually
oplugins=(myplugin)
```

## Usage

### Basic Commands

- `myplugin_hello` - Display hello message
- `myplugin_info` - Show plugin information
- `mp` - Alias for myplugin_hello

### Configuration

Set environment variables in your `.zshrc`:

```bash
export MYPLUGIN_CONFIG_DIR="$HOME/.config/myplugin"
```

## Dependencies

- zsh >= 5.0
- curl (optional)

## License

MIT License
```

### Phase 2: Testing & Development

#### Local Testing

```bash
# Test plugin locally
osh plugin add myplugin
osh reload

# Check plugin status
osh plugins
osh plugin info myplugin

# Remove for testing
osh plugin remove myplugin
```

#### 1. Local Testing
```bash
# Test plugin loading
echo 'oplugins=(myplugin)' >> ~/.zshrc.test
OSH_DEBUG=1 zsh -c "source ~/.zshrc.test"

# Test plugin functions
zsh -c "source ~/.zshrc.test && myplugin_hello"
```

#### 2. Add to Experimental Category
```json
{
  "categories": {
    "experimental": {
      "plugins": [
        {
          "name": "myplugin",
          "version": "0.1.0",
          "description": "Brief description of what your plugin does",
          "files": [
            "plugins/myplugin/myplugin.plugin.zsh"
          ],
          "dependencies": [],
          "tags": ["utility", "example"],
          "author": "Your Name",
          "license": "MIT",
          "compatibility": {
            "osh_version": ">=1.0.0",
            "zsh_version": ">=5.0"
          }
        }
      ]
    }
  }
}
```

#### 3. Community Testing
```bash
# Users can test experimental plugins
PLUGIN_CATEGORY=experimental ./install.sh
```

### Phase 3: Beta Release

#### 1. Gather Feedback and Fix Issues
- Collect user feedback
- Fix reported bugs
- Improve documentation
- Add tests if applicable

#### 2. Update Version and Move to Beta
```json
{
  "categories": {
    "beta": {
      "plugins": [
        {
          "name": "myplugin",
          "version": "0.8.0",
          "description": "Improved description with more details",
          "files": [
            "plugins/myplugin/myplugin.plugin.zsh",
            "plugins/myplugin/completions/_myplugin"
          ],
          "dependencies": ["curl"],
          "tags": ["utility", "productivity"],
          "changelog": [
            "0.8.0: Added completions, improved error handling",
            "0.1.0: Initial release"
          ]
        }
      ]
    }
  }
}
```

### Phase 4: Stable Release

#### 1. Final Testing and Documentation
- Comprehensive testing on multiple systems
- Complete documentation
- Performance optimization
- Security review

#### 2. Move to Stable Category
```json
{
  "categories": {
    "stable": {
      "plugins": [
        {
          "name": "myplugin",
          "version": "1.0.0",
          "description": "Production-ready plugin for [specific use case]",
          "files": [
            "plugins/myplugin/myplugin.plugin.zsh",
            "plugins/myplugin/completions/_myplugin",
            "plugins/myplugin/config/default.conf"
          ],
          "dependencies": ["curl"],
          "tags": ["utility", "productivity", "stable"],
          "documentation": "https://github.com/oiahoon/osh/wiki/myplugin",
          "changelog": [
            "1.0.0: Stable release, added configuration system",
            "0.8.0: Beta release with completions",
            "0.1.0: Initial experimental release"
          ]
        }
      ]
    }
  }
}
```

## 🔧 Plugin Best Practices

### Code Quality

#### 1. Error Handling
```bash
# Check dependencies
if ! command -v curl >/dev/null 2>&1; then
  echo "❌ MyPlugin requires curl to be installed" >&2
  return 1
fi

# Validate input
myplugin_process() {
  local input="$1"
  
  if [[ -z "$input" ]]; then
    echo "❌ Error: Input required" >&2
    echo "Usage: myplugin_process <input>" >&2
    return 1
  fi
  
  # Process input...
}
```

#### 2. Configuration Management
```bash
# Default configuration
MYPLUGIN_CONFIG_FILE="${MYPLUGIN_CONFIG_DIR}/config"
MYPLUGIN_DEFAULT_OPTION="value"

# Load user configuration
if [[ -f "$MYPLUGIN_CONFIG_FILE" ]]; then
  source "$MYPLUGIN_CONFIG_FILE"
fi

# Use configuration
myplugin_action() {
  local option="${MYPLUGIN_OPTION:-$MYPLUGIN_DEFAULT_OPTION}"
  echo "Using option: $option"
}
```

#### 3. Namespace Management
```bash
# Use plugin prefix for all functions and variables
myplugin_function_name() { ... }
MYPLUGIN_VARIABLE_NAME="value"

# Avoid generic names that might conflict
# ❌ Bad: process(), config(), data
# ✅ Good: myplugin_process(), myplugin_config(), myplugin_data
```

### Performance

#### 1. Lazy Loading
```bash
# Define stub functions that load the real implementation when needed
myplugin_heavy_function() {
  # Undefine stub
  unfunction myplugin_heavy_function
  
  # Load real implementation
  source "$OSH/plugins/myplugin/heavy_functions.zsh"
  
  # Call real function
  myplugin_heavy_function "$@"
}
```

#### 2. Conditional Loading
```bash
# Only load if needed
if [[ "$MYPLUGIN_ENABLE_FEATURE" == "true" ]]; then
  source "$OSH/plugins/myplugin/optional_feature.zsh"
fi
```

### User Experience

#### 1. Helpful Messages
```bash
myplugin_help() {
  cat << EOF
MyPlugin v$MYPLUGIN_VERSION

USAGE:
  myplugin_hello          Show hello message
  myplugin_info           Show plugin information
  myplugin_config         Configure plugin

ALIASES:
  mp                      myplugin_hello
  mpinfo                  myplugin_info

CONFIGURATION:
  MYPLUGIN_CONFIG_DIR     Configuration directory (default: ~/.config/myplugin)

For more information, visit: https://github.com/oiahoon/osh/wiki/myplugin
EOF
}
```

#### 2. Progress Indicators
```bash
myplugin_long_task() {
  echo "🔄 Processing..."
  
  # Long running task
  for i in {1..10}; do
    echo "  Step $i/10"
    sleep 1
  done
  
  echo "✅ Task completed!"
}
```

## 📦 Plugin Distribution

### Manifest Entry Template
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief description (max 80 chars)",
  "long_description": "Detailed description of plugin functionality and use cases",
  "files": [
    "plugins/plugin-name/plugin-name.plugin.zsh",
    "plugins/plugin-name/completions/_plugin-name",
    "plugins/plugin-name/config/default.conf"
  ],
  "dependencies": ["curl", "git"],
  "optional_dependencies": ["fzf", "jq"],
  "tags": ["utility", "productivity", "development"],
  "author": "Author Name",
  "email": "author@example.com",
  "license": "MIT",
  "homepage": "https://github.com/author/plugin-name",
  "documentation": "https://github.com/oiahoon/osh/wiki/plugin-name",
  "compatibility": {
    "osh_version": ">=1.0.0",
    "zsh_version": ">=5.0",
    "platforms": ["macos", "linux", "wsl"]
  },
  "changelog": [
    "1.0.0: Stable release with full feature set",
    "0.8.0: Beta release with core functionality",
    "0.1.0: Initial experimental release"
  ]
}
```

### File Structure
```
plugins/plugin-name/
├── plugin-name.plugin.zsh    # Main plugin file (required)
├── README.md                 # Documentation (required)
├── LICENSE                   # License file (recommended)
├── completions/              # Zsh completions (optional)
│   └── _plugin-name
├── config/                   # Configuration files (optional)
│   ├── default.conf
│   └── example.conf
├── functions/                # Additional functions (optional)
│   ├── core.zsh
│   └── utils.zsh
├── tests/                    # Tests (recommended)
│   ├── test_basic.zsh
│   └── test_advanced.zsh
└── docs/                     # Additional documentation (optional)
    ├── usage.md
    └── examples.md
```

## 🧪 Testing

### Basic Testing Script
```bash
#!/usr/bin/env zsh
# tests/test_myplugin.zsh

# Test setup
TEST_DIR=$(mktemp -d)
export OSH="$TEST_DIR/osh"
mkdir -p "$OSH/plugins/myplugin"

# Copy plugin files
cp -r plugins/myplugin/* "$OSH/plugins/myplugin/"

# Load plugin
source "$OSH/plugins/myplugin/myplugin.plugin.zsh"

# Test functions
test_hello() {
  local output=$(myplugin_hello)
  if [[ "$output" == *"Hello from MyPlugin"* ]]; then
    echo "✅ test_hello passed"
  else
    echo "❌ test_hello failed: $output"
    return 1
  fi
}

test_info() {
  local output=$(myplugin_info)
  if [[ "$output" == *"MyPlugin Information"* ]]; then
    echo "✅ test_info passed"
  else
    echo "❌ test_info failed: $output"
    return 1
  fi
}

# Run tests
echo "🧪 Running MyPlugin tests..."
test_hello
test_info

# Cleanup
rm -rf "$TEST_DIR"
echo "✅ All tests passed!"
```

## 📚 Resources

### Documentation Templates
- [Plugin README Template](templates/PLUGIN_README.md)
- [Plugin Code Template](templates/plugin-template.plugin.zsh)
- [Test Template](templates/test-template.zsh)

### Tools
- [Plugin Validator](scripts/validate-plugin.sh)
- [Manifest Updater](scripts/update-manifest.sh)
- [Test Runner](scripts/run-tests.sh)

### Examples
- [Simple Plugin Example](examples/simple-plugin/)
- [Advanced Plugin Example](examples/advanced-plugin/)
- [Plugin with Completions](examples/completion-plugin/)

## 🤝 Contributing

1. **Fork the repository**
2. **Create your plugin** following this guide
3. **Test thoroughly** on multiple systems
4. **Update documentation** including README and manifest
5. **Submit pull request** with detailed description

### Pull Request Checklist

- [ ] Plugin follows naming conventions
- [ ] All functions use plugin prefix
- [ ] README.md is complete and accurate
- [ ] Plugin is added to appropriate manifest category
- [ ] Tests are included and passing
- [ ] No conflicts with existing plugins
- [ ] Performance impact is minimal
- [ ] Documentation is clear and helpful

## 📞 Support

- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/oiahoon/osh/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/oiahoon/osh/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/oiahoon/osh/wiki)
- 💬 **Community**: [Discord](https://discord.gg/osh-framework)

---

Happy plugin development! 🚀
