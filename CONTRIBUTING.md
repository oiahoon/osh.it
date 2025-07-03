# Contributing to OSH

Thank you for your interest in contributing to OSH! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues

Before creating an issue, please:

1. **Search existing issues** to avoid duplicates
2. **Use the issue templates** when available
3. **Provide detailed information** including:
   - OS and Zsh version
   - OSH version
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant configuration

### Suggesting Features

We welcome feature suggestions! Please:

1. **Check existing feature requests** first
2. **Describe the use case** clearly
3. **Explain the expected behavior**
4. **Consider implementation complexity**

### Code Contributions

#### Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/osh.git
   cd osh
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Development Guidelines

##### Code Style

- **Shell Scripts**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Indentation**: Use 2 spaces (no tabs)
- **Line Length**: Maximum 100 characters
- **Comments**: Use `#` for comments, document complex logic

##### Plugin Development

**Plugin Structure**:
```
plugins/your-plugin/
├── your-plugin.plugin.zsh    # Main plugin file
├── README.md                 # Plugin documentation
├── functions/                # Function definitions (optional)
├── completions/              # Zsh completions (optional)
└── config/                   # Configuration files (optional)
```

**Plugin Template**:
```bash
#!/usr/bin/env zsh
# Plugin: your-plugin
# Description: Brief description of what your plugin does
# Author: Your Name
# Version: 1.0.0

# Check dependencies
if ! command -v required_command >/dev/null 2>&1; then
    echo "Error: your-plugin requires 'required_command' to be installed"
    return 1
fi

# Main function
your_plugin_function() {
    # Your code here
    echo "Hello from your plugin!"
}

# Aliases (if needed)
alias yp='your_plugin_function'

# Auto-completion (if needed)
if [[ -d "$OSH/plugins/your-plugin/completions" ]]; then
    fpath=("$OSH/plugins/your-plugin/completions" $fpath)
fi
```

##### Core Development

**File Structure**:
- `osh.sh` - Core framework logic
- `install.sh` - Installation script
- `upgrade.sh` - Upgrade script

**Key Principles**:
- **Minimal overhead** - Keep the core lightweight
- **Backward compatibility** - Don't break existing configurations
- **Error handling** - Graceful failure with helpful messages
- **Cross-platform** - Support macOS, Linux, and other Unix-like systems

#### Testing

##### Manual Testing

1. **Test installation** on a clean system
2. **Test plugin loading** with various configurations
3. **Test upgrade process**
4. **Verify backward compatibility**

##### Test Checklist

- [ ] Fresh installation works
- [ ] Upgrade from previous version works
- [ ] Plugin loading/unloading works
- [ ] Error messages are helpful
- [ ] No shell startup performance regression
- [ ] Works on macOS and Linux
- [ ] Documentation is accurate

#### Submitting Changes

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add awesome feature"
   ```

2. **Follow commit message conventions**:
   - `feat:` - New features
   - `fix:` - Bug fixes
   - `docs:` - Documentation changes
   - `style:` - Code style changes
   - `refactor:` - Code refactoring
   - `test:` - Test additions/changes
   - `chore:` - Maintenance tasks

3. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request**:
   - Use the PR template
   - Link related issues
   - Describe changes clearly
   - Include screenshots if applicable

## 📋 Plugin Contribution Guidelines

### Plugin Requirements

- **Functionality**: Must provide clear value to users
- **Documentation**: Include comprehensive README.md
- **Dependencies**: Clearly document all dependencies
- **Error Handling**: Graceful failure with helpful messages
- **Performance**: Minimal impact on shell startup time

### Plugin README Template

```markdown
# Plugin Name

Brief description of what the plugin does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

Add to your `~/.zshrc`:
```bash
oplugins=(your-plugin)
```

## Usage

### Commands

- `command1` - Description
- `command2 <arg>` - Description with argument

### Examples

```bash
# Example usage
command1
command2 example-arg
```

## Configuration

```bash
# Optional configuration
export PLUGIN_VAR="value"
```

## Dependencies

- `dependency1` - Required for feature X
- `dependency2` - Optional, enhances feature Y

## Troubleshooting

Common issues and solutions.
```

### Plugin Submission Process

1. **Create plugin** following the structure above
2. **Test thoroughly** on multiple systems
3. **Write comprehensive documentation**
4. **Submit PR** with plugin in `plugins/` directory
5. **Respond to review feedback**

## 🔧 Development Setup

### Prerequisites

- Zsh 5.0+
- Git
- Basic Unix tools (curl, wget, etc.)

### Local Development

1. **Clone the repository**
2. **Create test environment**:
   ```bash
   # Use a separate directory for testing
   export OSH="$HOME/.osh-dev"
   ```
3. **Test your changes**:
   ```bash
   source osh.sh
   ```

### Debugging

Enable debug mode:
```bash
export OSH_DEBUG=1
source $OSH/osh.sh
```

## 📖 Documentation

### Documentation Standards

- **Clear and concise** language
- **Code examples** for all features
- **Screenshots** for visual features
- **Up-to-date** information
- **Proper formatting** with Markdown

### Documentation Structure

- **README.md** - Main project documentation
- **CONTRIBUTING.md** - This file
- **Plugin READMEs** - Individual plugin documentation
- **Wiki** - Extended documentation and tutorials

## 🎯 Roadmap

See our [GitHub Issues](https://github.com/oiahoon/osh/issues) and [Projects](https://github.com/oiahoon/osh/projects) for current priorities.

## 💬 Community

- **GitHub Discussions** - General questions and ideas
- **GitHub Issues** - Bug reports and feature requests
- **Pull Requests** - Code contributions

## 📄 License

By contributing to OSH, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to OSH! 🎉