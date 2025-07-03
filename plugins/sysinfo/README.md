# 🖥️ Sysinfo Plugin

A neofetch-inspired system information display tool for OSH framework with enhanced colors and perfect alignment.

## ✨ Features

- **Beautiful ASCII Art** - Custom OSH logo with vibrant colors
- **Perfect Alignment** - Smart text alignment that handles ANSI color codes
- **Comprehensive System Info** - OS, kernel, uptime, hardware details
- **OSH Framework Info** - Plugin count, active plugins, version
- **Cross-platform** - Works on macOS and Linux
- **Smart Text Handling** - Automatic truncation of long text
- **Enhanced Colors** - Bright, vibrant color scheme for better visibility
- **Debug Mode** - Built-in debugging for color and alignment issues

## 🚀 Usage

### Basic Usage
```bash
# Show full system information with OSH logo
sysinfo

# Alternative aliases
oshinfo
neofetch-osh
```

### Options
```bash
# Hide the OSH logo
sysinfo --no-logo

# Show debug information (useful for troubleshooting)
sysinfo --debug

# Show help
sysinfo --help
```

## 🎨 Recent Improvements

### Vintage Gradient Color System
- **Retro Color Palette**: Switched from bright rainbow colors to softer, vintage-inspired tones
- **Muted Gradients**: Dark red → orange → olive → forest green → teal → steel blue → vintage purple
- **Better Terminal Compatibility**: Enhanced color detection for various terminal environments
- **User-Friendly**: Responds to user feedback for less eye-strain and more professional appearance

### Perfect Alignment
- **Smart Length Calculation**: Properly handles ANSI color codes when calculating text width
- **Dynamic Padding**: Intelligent padding system that adapts to actual display length
- **Text Truncation**: Automatic truncation of long text (CPU names, resolutions, etc.)

### Debug Mode
- **Terminal Information**: Shows TERM and TERM_PROGRAM variables
- **Color Testing**: Displays color test to verify color support
- **Alignment Debugging**: Helps troubleshoot display issues

## 📊 Information Displayed

### System Information
- **OS**: Operating system name and version
- **Host**: Hardware model identifier
- **Kernel**: Kernel version
- **Uptime**: System uptime in human-readable format
- **Packages**: Package count (brew on macOS)
- **Shell**: Current shell and version
- **Resolution**: Display resolution (truncated if too long)
- **Terminal**: Terminal application
- **CPU**: Processor information (truncated if too long)
- **GPU**: Graphics processor information (truncated if too long)
- **Memory**: Memory usage in MiB

### OSH Framework Information
- **Version**: OSH framework version
- **Location**: Installation directory
- **Plugins**: Number of installed plugins
- **Active**: Currently loaded plugins (truncated if too long)

## 🎨 Example Output

### Full Display (Side-by-Side Layout)
```
        ██████╗  ███████╗██╗  ██╗          huangyuyao@dongerwas-Mac-Studio
       ██╔═══██╗██╔════╝██║  ██║           -------------------------------
       ██║   ██║███████╗███████║           OS: macOS 15.5 24F74 arm64
       ██║   ██║╚════██║██╔══██║           Host: Mac16,9
       ╚██████╔╝███████║██║  ██║           Kernel: 24.5.0
        ╚═════╝ ╚══════╝╚═╝  ╚═╝           Uptime: 17 mins
                                           Packages: 20 (brew)
     ╔════════════════════════════════╗    Shell: zsh 5.9
     ║    Lightweight Zsh Framework   ║    Resolution: 2560 x 1080 (UW-UXGA - Ultr...
     ║      Fast • Simple • Cool      ║    Terminal: WarpTerminal
     ╚════════════════════════════════╝    CPU: Apple M4 Max
                                           GPU: Apple M4 Max
       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄       Memory: 6951MiB / 65536MiB
      ▐ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ▌        
       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀       OSH Framework:
                                           Version: v2.1.0
                                           Location: /Users/user/.osh
                                           Plugins: 8 installed
                                           Active: acw proxy fzf weather sysinfo...
```

### Debug Mode Output
```bash
$ sysinfo --debug
Debug Info:
TERM: xterm-256color
TERM_PROGRAM: WarpTerminal
Color test: RED GREEN BLUE

[... normal output follows ...]
```

## 🔧 Installation

Add `sysinfo` to your plugins list in `~/.zshrc`:

```bash
oplugins=(acw proxy fzf weather taskman sysinfo)
```

Then reload your shell:
```bash
source ~/.zshrc
```

## 🛠️ Technical Details

### Color System
The plugin uses vintage-inspired ANSI color codes for a retro aesthetic:
- **Logo Colors**: Muted 256-color palette (124, 130, 142, 64, 66, 68, 61, 97, 96, 95) for vintage feel
- **Info Labels**: Bright cyan (1;36m) for labels
- **Info Values**: White (0;37m) for values
- **Accent Text**: Bright yellow (1;33m) for highlights

### Alignment Algorithm
1. **Calculate Display Length**: Strips ANSI codes to get actual text width
2. **Dynamic Padding**: Calculates exact padding needed for alignment
3. **Text Truncation**: Automatically truncates long text with ellipsis
4. **Fixed Column Width**: Maintains consistent 42-character logo column

### Text Truncation Limits
- **CPU/GPU Names**: 35 characters
- **Resolution**: 30 characters  
- **Active Plugins**: 40 characters
- **General Text**: 50 characters (configurable)

## 🎯 Troubleshooting

### Colors Not Showing
1. Run `sysinfo --debug` to check terminal support
2. Verify `TERM` environment variable is set correctly
3. Try different terminal applications

### Alignment Issues
1. Use `--debug` mode to see actual vs expected lengths
2. Check for unusual characters in system information
3. Verify terminal width is sufficient (minimum 80 characters recommended)

### Performance Issues
- The plugin caches system information calls where possible
- Most system calls are lightweight and cached by the OS

## 🤝 Contributing

Feel free to contribute improvements, additional system information, or platform-specific enhancements!

### Recent Contributors
- Enhanced color system and alignment fixes
- Smart text truncation implementation
- Debug mode addition
- Cross-platform compatibility improvements
