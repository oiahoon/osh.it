# OSH Vintage Design System Guide

<div align="center">

![OSH Vintage](https://img.shields.io/badge/OSH-Vintage%20Design-8B4513?style=for-the-badge)
[![Version](https://img.shields.io/badge/Version-1.0-CD853F?style=for-the-badge)](.)

*Unified vintage styling for all OSH plugins and features*

</div>

## 🎨 Overview

The OSH Vintage Design System provides a cohesive, professional aesthetic across all OSH plugins and features. It uses carefully selected vintage colors, elegant typography, and consistent design patterns to create a unified user experience.

## 🎯 Design Philosophy

- **Vintage Aesthetic**: Muted, sophisticated colors inspired by retro computing
- **Professional Appearance**: Clean, readable interfaces suitable for daily use
- **Consistency**: Unified design language across all OSH components
- **Accessibility**: High contrast and readable color combinations
- **Terminal Friendly**: Optimized for various terminal environments

## 🎨 Color Palette

### Primary Colors (256-color ANSI codes)

| Color | Code | Usage | Example |
|-------|------|-------|---------|
| Vintage Red | 124 | High priority, errors | `\033[38;5;124m` |
| Vintage Orange | 130 | Warnings, attention | `\033[38;5;130m` |
| Vintage Yellow | 136 | Normal priority, info | `\033[38;5;136m` |
| Vintage Olive | 142 | Secondary info | `\033[38;5;142m` |
| Vintage Green | 64 | Success, completed | `\033[38;5;64m` |
| Vintage Teal | 66 | Low priority, calm | `\033[38;5;66m` |
| Vintage Blue | 68 | Information, neutral | `\033[38;5;68m` |
| Vintage Purple | 97 | Accent, special | `\033[38;5;97m` |
| Vintage Magenta | 95 | Highlight, brand | `\033[38;5;95m` |

### UI Element Colors

| Element | Color | Usage |
|---------|-------|-------|
| Accent | Bright Cyan (1;36m) | Labels, UI accents |
| Success | Bright Green (1;32m) | Success messages |
| Warning | Bright Yellow (1;33m) | Warning messages |
| Error | Bright Red (1;31m) | Error messages |
| Dim | Dim (2m) | Secondary information |
| Bold | Bold (1m) | Emphasis |

## 🔧 Usage

### Loading the Vintage Library

```bash
# Load the vintage design system
source "${OSH}/lib/vintage.zsh"

# Check if vintage mode is enabled
if osh_vintage_enabled "myplugin"; then
    # Use vintage styling
    osh_vintage_success "Plugin loaded with vintage styling"
else
    # Use classic styling
    echo "Plugin loaded with classic styling"
fi
```

### Basic Functions

```bash
# Message functions
osh_vintage_success "Operation completed successfully"
osh_vintage_error "Something went wrong"
osh_vintage_warning "Please check your configuration"
osh_vintage_info "Additional information"

# Headers and separators
osh_vintage_header "My Plugin" "Version 1.0"
osh_vintage_separator 60

# List items with priority
osh_vintage_list_item "high" "active" "Important task" "1"
osh_vintage_list_item "normal" "completed" "Regular task" "2"
osh_vintage_list_item "low" "active" "Minor task" "3"

# Progress bars
osh_vintage_progress 7 10 40 "Loading"

# Interactive prompts
osh_vintage_prompt "Enter your name" "default"
if osh_vintage_confirm "Continue with operation?"; then
    osh_vintage_success "Proceeding..."
fi
```

## 🎭 Design Patterns

### Priority System

Use consistent priority levels across all plugins:

- **High Priority**: Vintage Red (124) with Diamond icon (◆)
- **Normal Priority**: Vintage Yellow (136) with Hollow Diamond icon (◇)
- **Low Priority**: Vintage Teal (66) with Circle icon (◦)

### Status Indicators

- **Active**: Circle icon (◯) with full color
- **Completed**: Checkmark icon (✓) with dimmed color
- **Error**: Cross icon (✗) with error color
- **Warning**: Triangle icon (⚠) with warning color

### Layout Principles

1. **Headers**: Use decorative borders with centered text
2. **Lists**: Consistent indentation and icon usage
3. **Separators**: Use appropriate line styles for visual hierarchy
4. **Spacing**: Maintain consistent vertical and horizontal spacing

## 📋 Plugin Development Standards

### 1. Color Usage

```bash
# Use semantic color variables
local high_priority_color=$(osh_vintage_priority_color "high" "active")
local completed_color=$(osh_vintage_priority_color "normal" "completed")

# Apply colors consistently
printf "%s%s%s\n" "$high_priority_color" "Important message" "$OSH_VINTAGE_RESET"
```

### 2. Icon Standards

```bash
# Use standard vintage icons
local priority_icon=$(osh_vintage_priority_icon "high")
local status_icon="$OSH_VINTAGE_ICON_SUCCESS"

printf "%s %s Task completed\n" "$status_icon" "$priority_icon"
```

### 3. Responsive Design

```bash
# Adapt to terminal width
local width=$(tput cols 2>/dev/null || echo 80)
if [[ $width -lt 60 ]]; then
    # Compact layout for narrow terminals
    osh_vintage_list_item "high" "active" "Task"
else
    # Full layout for wider terminals
    osh_vintage_list_item "high" "active" "Detailed task description" "ID123"
fi
```

### 4. Error Handling

```bash
# Graceful degradation for unsupported terminals
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    # Use vintage colors
    osh_vintage_success "Colorful output"
else
    # Fallback to plain text
    echo "✓ Plain text output"
fi
```

## 🎨 Visual Examples

### Header Example
```
╔═══════════════════════════════════════╗
║              ✦ OSH TASKMAN ✦          ║
║        Vintage Terminal Manager       ║
╚═══════════════════════════════════════╝
```

### List Example
```
◯ ◆ High priority task (ID: 1)
◯ ◇ Normal priority task (ID: 2)
✓ ◦ Completed low priority task (ID: 3)
```

### Progress Example
```
Loading: [████████░░] 80% (8/10)
```

### Table Example
```
┌─────────────────────────────────────┐
│ Task │ Priority │ Status │ Age     │
├─────────────────────────────────────┤
│ Fix  │ High     │ Active │ 2h      │
│ Test │ Normal   │ Done   │ 1d      │
└─────────────────────────────────────┘
```

## 🔧 Environment Variables

### Global Settings

```bash
# Enable/disable vintage mode globally
export OSH_VINTAGE=true          # Enable (default)
export OSH_VINTAGE=false         # Disable

# Plugin-specific settings
export OSH_VINTAGE_TASKMAN=true  # Enable for taskman
export OSH_VINTAGE_SYSINFO=false # Disable for sysinfo
```

### Plugin Integration

```bash
# In your plugin
if osh_vintage_enabled "myplugin"; then
    # Use vintage styling
    source "${OSH}/lib/vintage.zsh"
    osh_vintage_header "My Plugin"
else
    # Use classic styling
    echo "=== My Plugin ==="
fi
```

## 📱 Responsive Design Guidelines

### Terminal Size Breakpoints

- **Narrow** (< 60 cols): Minimal layout, compact text
- **Medium** (60-80 cols): Standard layout, abbreviated text
- **Wide** (> 80 cols): Full layout, detailed information

### Adaptive Elements

```bash
# Responsive header
local width=$(tput cols 2>/dev/null || echo 80)
if [[ $width -ge 80 ]]; then
    osh_vintage_header "Full Plugin Name" "Detailed Description"
elif [[ $width -ge 60 ]]; then
    osh_vintage_header "Plugin Name"
else
    printf "%s%s%s\n" "$OSH_VINTAGE_BRAND" "Plugin" "$OSH_VINTAGE_RESET"
fi
```

## 🎯 Best Practices

### 1. Consistency
- Use the same color for the same semantic meaning across plugins
- Maintain consistent spacing and alignment
- Follow the established icon conventions

### 2. Accessibility
- Ensure sufficient contrast between text and background
- Provide fallbacks for terminals without color support
- Use icons alongside colors for better accessibility

### 3. Performance
- Cache color codes to avoid repeated calculations
- Use efficient string operations for large outputs
- Test with various terminal sizes and types

### 4. Maintainability
- Use semantic color variables instead of raw ANSI codes
- Document custom color usage in your plugin
- Follow the established naming conventions

## 🧪 Testing Your Plugin

### Color Testing
```bash
# Test color support
if [[ $(tput colors 2>/dev/null || echo 0) -ge 256 ]]; then
    echo "256-color support available"
else
    echo "Limited color support - use fallbacks"
fi

# Test vintage functions
osh_vintage_success "Success message test"
osh_vintage_error "Error message test"
osh_vintage_list_item "high" "active" "Test item"
```

### Terminal Compatibility
- Test with different terminal emulators
- Verify behavior with various `TERM` values
- Check appearance in light and dark themes

## 📚 Reference

### Complete Function List

| Function | Purpose | Example |
|----------|---------|---------|
| `osh_vintage_print` | Print colored text | `osh_vintage_print "$color" "text"` |
| `osh_vintage_success` | Success message | `osh_vintage_success "Done!"` |
| `osh_vintage_error` | Error message | `osh_vintage_error "Failed!"` |
| `osh_vintage_warning` | Warning message | `osh_vintage_warning "Caution!"` |
| `osh_vintage_info` | Info message | `osh_vintage_info "Note:"` |
| `osh_vintage_header` | Decorative header | `osh_vintage_header "Title"` |
| `osh_vintage_separator` | Horizontal line | `osh_vintage_separator 60` |
| `osh_vintage_list_item` | Formatted list item | `osh_vintage_list_item "high" "active" "text"` |
| `osh_vintage_progress` | Progress bar | `osh_vintage_progress 5 10 40 "Loading"` |
| `osh_vintage_prompt` | Input prompt | `osh_vintage_prompt "Name:"` |
| `osh_vintage_confirm` | Yes/no prompt | `osh_vintage_confirm "Continue?"` |

### Color Variables

All vintage colors are available as environment variables:
- `$OSH_VINTAGE_RED` through `$OSH_VINTAGE_MAGENTA`
- `$OSH_VINTAGE_ACCENT`, `$OSH_VINTAGE_SUCCESS`, etc.
- `$OSH_VINTAGE_RESET` for resetting formatting

### Icon Constants

Standard icons are available as constants:
- `$OSH_VINTAGE_ICON_HIGH`, `$OSH_VINTAGE_ICON_NORMAL`, `$OSH_VINTAGE_ICON_LOW`
- `$OSH_VINTAGE_ICON_SUCCESS`, `$OSH_VINTAGE_ICON_ERROR`, `$OSH_VINTAGE_ICON_WARNING`
- `$OSH_VINTAGE_ICON_ACTIVE`, `$OSH_VINTAGE_ICON_BRAND`

## 🤝 Contributing

When contributing to OSH plugins:

1. **Follow the vintage design standards**
2. **Test with multiple terminal types**
3. **Provide fallbacks for limited environments**
4. **Document any custom styling decisions**
5. **Maintain backward compatibility**

## 📄 License

This design system is part of the OSH framework and follows the same MIT license.

---

<div align="center">

**Create beautiful, consistent terminal experiences with OSH Vintage Design! 🎨**

*Part of the [OSH Framework](https://github.com/oiahoon/osh)*

</div>
