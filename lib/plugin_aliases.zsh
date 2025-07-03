#!/usr/bin/env zsh
# OSH.IT Plugin Management Aliases
# Modern command-line interface for OSH.IT

# Main OSH command (modern style - recommended)
alias osh="$OSH/scripts/osh_cli.sh"

# Backward compatibility aliases (old style)
alias osh-plugin="$OSH/scripts/osh_plugin_manager.sh"
alias oshp="$OSH/scripts/osh_plugin_manager.sh"

# Quick shortcuts (old style - kept for compatibility)
alias osh-plugins-list="$OSH/scripts/osh_cli.sh plugin list"
alias osh-plugins-current="$OSH/scripts/osh_cli.sh plugins"
alias osh-plugin-add="$OSH/scripts/osh_cli.sh plugin add"
alias osh-plugin-remove="$OSH/scripts/osh_cli.sh plugin remove"

# Preset shortcuts (old style - kept for compatibility)
alias osh-preset-minimal="$OSH/scripts/osh_cli.sh preset minimal"
alias osh-preset-recommended="$OSH/scripts/osh_cli.sh preset recommended"
alias osh-preset-developer="$OSH/scripts/osh_cli.sh preset developer"
alias osh-preset-full="$OSH/scripts/osh_cli.sh preset full"

# Modern shortcuts (new style - recommended)
alias osh-reload="$OSH/scripts/osh_cli.sh reload"
alias osh-status="$OSH/scripts/osh_cli.sh status"
alias osh-upgrade="$OSH/scripts/osh_cli.sh upgrade"

# Plugin management functions
osh-help() {
    echo "🔌 OSH.IT Command Reference:"
    echo ""
    echo "🆕 Modern Style (Recommended):"
    echo "  osh plugin add <name>      - Add a plugin"
    echo "  osh plugin remove <name>   - Remove a plugin"
    echo "  osh plugin list            - List available plugins"
    echo "  osh plugin info <name>     - Show plugin information"
    echo "  osh plugins                - Show installed plugins"
    echo "  osh preset <name>          - Install plugin preset"
    echo "  osh status                 - Show OSH.IT status"
    echo "  osh reload                 - Reload configuration"
    echo "  osh upgrade                - Upgrade OSH.IT"
    echo ""
    echo "📦 Presets:"
    echo "  osh preset minimal         - sysinfo only"
    echo "  osh preset recommended     - sysinfo weather taskman"
    echo "  osh preset developer       - recommended + acw fzf"
    echo "  osh preset full            - all plugins"
    echo ""
    echo "🔄 Legacy Style (Backward Compatibility):"
    echo "  osh-plugin-add <name>      - Add a plugin"
    echo "  osh-plugins-list           - List available plugins"
    echo "  osh-preset-developer       - Install developer preset"
    echo ""
    echo "💡 Examples:"
    echo "  osh plugin add weather"
    echo "  osh plugin remove taskman"
    echo "  osh preset developer"
    echo "  osh status"
}

# Quick status check
osh-quick-status() {
    echo "🔌 OSH.IT Quick Status:"
    echo "📁 Installation: $OSH"
    local current=$($OSH/scripts/osh_cli.sh plugins 2>/dev/null | grep "✅" | wc -l | tr -d ' ')
    echo "🔌 Active plugins: $current"
}
