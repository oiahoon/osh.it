#!/usr/bin/env zsh
# OSH.IT Plugin Management Aliases
# Convenient shortcuts for plugin management

# Main plugin manager alias
alias osh-plugin="$OSH/scripts/osh_plugin_manager.sh"
alias oshp="$OSH/scripts/osh_plugin_manager.sh"

# Quick shortcuts
alias osh-plugins-list="$OSH/scripts/osh_plugin_manager.sh list"
alias osh-plugins-current="$OSH/scripts/osh_plugin_manager.sh current"
alias osh-plugin-add="$OSH/scripts/osh_plugin_manager.sh add"
alias osh-plugin-remove="$OSH/scripts/osh_plugin_manager.sh remove"

# Preset shortcuts
alias osh-preset-minimal="$OSH/scripts/osh_plugin_manager.sh preset minimal"
alias osh-preset-recommended="$OSH/scripts/osh_plugin_manager.sh preset recommended"
alias osh-preset-developer="$OSH/scripts/osh_plugin_manager.sh preset developer"
alias osh-preset-full="$OSH/scripts/osh_plugin_manager.sh preset full"

# Plugin management functions
osh-plugin-help() {
    echo "🔌 OSH.IT Plugin Management Commands:"
    echo ""
    echo "📋 List & Status:"
    echo "  osh-plugins-list      - List all available plugins"
    echo "  osh-plugins-current   - Show currently installed plugins"
    echo ""
    echo "➕ Add/Remove:"
    echo "  osh-plugin-add <name>    - Add a plugin"
    echo "  osh-plugin-remove <name> - Remove a plugin"
    echo ""
    echo "📦 Presets:"
    echo "  osh-preset-minimal       - Install minimal preset (sysinfo)"
    echo "  osh-preset-recommended   - Install recommended preset"
    echo "  osh-preset-developer     - Install developer preset"
    echo "  osh-preset-full          - Install all plugins"
    echo ""
    echo "🔧 Main Commands:"
    echo "  osh-plugin <command>     - Full plugin manager"
    echo "  oshp <command>           - Short alias for plugin manager"
    echo ""
    echo "💡 Examples:"
    echo "  osh-plugin-add weather"
    echo "  osh-plugin-remove taskman"
    echo "  osh-preset-developer"
    echo "  oshp list"
}

# Quick reload function
osh-reload() {
    echo "🔄 Reloading OSH.IT configuration..."
    source ~/.zshrc
    echo "✅ Configuration reloaded!"
}

# Plugin status check
osh-status() {
    echo "🔌 OSH.IT Status:"
    echo ""
    echo "📁 Installation: $OSH"
    echo "📄 Config file: ~/.zshrc"
    echo ""
    osh-plugins-current
}
