#!/usr/bin/env bash
# OSH.IT Command Line Interface
# Modern, user-friendly CLI for OSH.IT management

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
ZSHRC_FILE="$HOME/.zshrc"

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}" >&2; }

# Get current plugins from .zshrc
get_current_plugins() {
    if [[ -f "$ZSHRC_FILE" ]]; then
        grep "^oplugins=(" "$ZSHRC_FILE" 2>/dev/null | sed 's/oplugins=(\(.*\))/\1/' | tr -d '()'
    fi
}

# Update plugins in .zshrc
update_plugins_config() {
    local plugins="$1"
    local temp_file=$(mktemp)
    
    if [[ -f "$ZSHRC_FILE" ]]; then
        # Backup original file
        cp "$ZSHRC_FILE" "${ZSHRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Update or add oplugins line
        if grep -q "^oplugins=(" "$ZSHRC_FILE"; then
            sed "s/^oplugins=(.*/oplugins=($plugins)/" "$ZSHRC_FILE" > "$temp_file"
        else
            # Add oplugins line after OSH configuration
            awk '/# OSH Configuration|# Load OSH/ {print; print "oplugins=('$plugins')"; next} 1' "$ZSHRC_FILE" > "$temp_file"
        fi
        
        mv "$temp_file" "$ZSHRC_FILE"
        log_success "Updated plugin configuration"
    else
        log_error "Could not find $ZSHRC_FILE"
        return 1
    fi
}

# Download plugin files
download_plugin() {
    local plugin_name="$1"
    local plugin_dir="$OSH_DIR/plugins/$plugin_name"
    local repo_base="https://raw.githubusercontent.com/oiahoon/osh.it/main"
    
    log_info "Downloading plugin: $plugin_name"
    
    # Create plugin directory
    mkdir -p "$plugin_dir"
    
    # Download main plugin file
    local plugin_file="$plugin_dir/${plugin_name}.plugin.zsh"
    local download_url="$repo_base/plugins/$plugin_name/${plugin_name}.plugin.zsh"
    
    if curl -fsSL "$download_url" -o "$plugin_file"; then
        log_success "Downloaded $plugin_name"
        return 0
    else
        log_error "Failed to download $plugin_name"
        return 1
    fi
}

# Remove plugin files
remove_plugin_files() {
    local plugin_name="$1"
    local plugin_dir="$OSH_DIR/plugins/$plugin_name"
    
    if [[ -d "$plugin_dir" ]]; then
        rm -rf "$plugin_dir"
        log_success "Removed plugin files for $plugin_name"
    fi
}

# Plugin management commands
cmd_plugin() {
    local action="$1"
    shift || true
    
    case "$action" in
        "add"|"install")
            cmd_plugin_add "$@"
            ;;
        "remove"|"uninstall"|"rm")
            cmd_plugin_remove "$@"
            ;;
        "list"|"ls")
            cmd_plugins_list
            ;;
        "info")
            cmd_plugin_info "$@"
            ;;
        *)
            echo "Usage: osh plugin <command> [args]"
            echo ""
            echo "Commands:"
            echo "  add <name>     Add a plugin"
            echo "  remove <name>  Remove a plugin"
            echo "  list           List available plugins"
            echo "  info <name>    Show plugin information"
            ;;
    esac
}

cmd_plugin_add() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
        echo "Usage: osh plugin add <name>"
        return 1
    fi
    
    # Check if plugin is already installed
    local current=$(get_current_plugins)
    if echo "$current" | grep -q "\b$plugin_name\b"; then
        log_warning "Plugin $plugin_name is already installed"
        return 0
    fi
    
    # Download plugin files
    if download_plugin "$plugin_name"; then
        # Update configuration
        local new_plugins
        if [[ -n "$current" ]]; then
            new_plugins="$current $plugin_name"
        else
            new_plugins="$plugin_name"
        fi
        
        update_plugins_config "$new_plugins"
        log_success "Added plugin: $plugin_name"
        log_info "Run 'osh reload' to load the new plugin"
    else
        log_error "Failed to add plugin: $plugin_name"
        return 1
    fi
}

cmd_plugin_remove() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
        echo "Usage: osh plugin remove <name>"
        return 1
    fi
    
    # Check if plugin is installed
    local current=$(get_current_plugins)
    if ! echo "$current" | grep -q "\b$plugin_name\b"; then
        log_warning "Plugin $plugin_name is not installed"
        return 0
    fi
    
    # Remove from configuration
    local new_plugins=$(echo "$current" | sed "s/\b$plugin_name\b//g" | tr -s ' ' | sed 's/^ *//;s/ *$//')
    
    update_plugins_config "$new_plugins"
    remove_plugin_files "$plugin_name"
    
    log_success "Removed plugin: $plugin_name"
    log_info "Run 'osh reload' to unload the plugin"
}

cmd_plugins_list() {
    echo -e "${CYAN}📦 Available OSH.IT Plugins:${NC}\n"
    
    echo -e "${GREEN}🟢 Stable Plugins (Recommended):${NC}"
    echo "  sysinfo   - System information display with OSH branding"
    echo "  weather   - Beautiful weather forecast with ASCII art"
    echo "  taskman   - Advanced terminal task manager"
    echo ""
    
    echo -e "${YELLOW}🟡 Beta Plugins (Advanced users):${NC}"
    echo "  acw       - Advanced Code Workflow (Git + JIRA integration)"
    echo "  fzf       - Enhanced fuzzy finder with preview"
    echo ""
    
    echo -e "${RED}🔴 Experimental Plugins (Use with caution):${NC}"
    echo "  greeting  - Friendly welcome message"
    echo ""
}

cmd_plugin_info() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
        echo "Usage: osh plugin info <name>"
        return 1
    fi
    
    case "$plugin_name" in
        "sysinfo")
            echo -e "${CYAN}📋 Plugin: sysinfo${NC}"
            echo "Version: 1.1.0"
            echo "Category: Stable"
            echo "Description: System information display with OSH branding"
            echo "Commands: sysinfo, oshinfo, neofetch-osh"
            echo "Dependencies: None"
            ;;
        "weather")
            echo -e "${CYAN}📋 Plugin: weather${NC}"
            echo "Version: 1.3.0"
            echo "Category: Stable"
            echo "Description: Beautiful weather forecast with ASCII art"
            echo "Commands: weather, forecast"
            echo "Dependencies: curl"
            ;;
        "taskman")
            echo -e "${CYAN}📋 Plugin: taskman${NC}"
            echo "Version: 2.0.0"
            echo "Category: Stable"
            echo "Description: Advanced terminal task manager"
            echo "Commands: tm, tasks"
            echo "Dependencies: python3"
            ;;
        *)
            log_error "Unknown plugin: $plugin_name"
            echo "Run 'osh plugins list' to see available plugins"
            ;;
    esac
}

# Status commands
cmd_status() {
    echo -e "${CYAN}🔌 OSH.IT Status:${NC}\n"
    
    echo "📁 Installation: $OSH_DIR"
    echo "📄 Config file: ~/.zshrc"
    echo "🔧 Version: $(cat "$OSH_DIR/VERSION" 2>/dev/null || echo "Unknown")"
    echo ""
    
    cmd_plugins_current
}

cmd_plugins_current() {
    local current=$(get_current_plugins)
    
    echo -e "${CYAN}🔌 Currently Installed Plugins:${NC}\n"
    
    if [[ -n "$current" ]]; then
        echo "$current" | tr ' ' '\n' | while read -r plugin; do
            if [[ -n "$plugin" ]]; then
                if [[ -d "$OSH_DIR/plugins/$plugin" ]]; then
                    echo -e "  ✅ $plugin"
                else
                    echo -e "  ❌ $plugin (files missing)"
                fi
            fi
        done
    else
        echo "  No plugins configured"
    fi
    echo ""
}

# Preset commands
cmd_preset() {
    local preset_name="$1"
    
    if [[ -z "$preset_name" ]]; then
        echo "Usage: osh preset <name>"
        echo ""
        echo "Available presets:"
        echo "  minimal      - sysinfo"
        echo "  recommended  - sysinfo weather taskman"
        echo "  developer    - sysinfo weather taskman acw fzf"
        echo "  full         - all plugins"
        return 1
    fi
    
    local plugins=""
    
    case "$preset_name" in
        "minimal")
            plugins="sysinfo"
            ;;
        "recommended")
            plugins="sysinfo weather taskman"
            ;;
        "developer")
            plugins="sysinfo weather taskman acw fzf"
            ;;
        "full")
            plugins="sysinfo weather taskman acw fzf greeting"
            ;;
        *)
            log_error "Unknown preset: $preset_name"
            echo "Available presets: minimal, recommended, developer, full"
            return 1
            ;;
    esac
    
    log_info "Installing preset: $preset_name"
    log_info "Plugins: $plugins"
    
    # Download all plugins
    for plugin in $plugins; do
        download_plugin "$plugin"
    done
    
    # Update configuration
    update_plugins_config "$plugins"
    log_success "Installed preset: $preset_name"
    log_info "Run 'osh reload' to load all plugins"
}

# Utility commands
cmd_reload() {
    log_info "Reloading OSH.IT configuration..."
    if [[ -f ~/.zshrc ]]; then
        log_success "To reload configuration, please run:"
        echo -e "${CYAN}  source ~/.zshrc${NC}"
        echo ""
        log_info "Or restart your terminal for changes to take effect"
    else
        log_error "Could not find ~/.zshrc"
    fi
}

cmd_upgrade() {
    log_info "Upgrading OSH.IT..."
    if [[ -f "$OSH_DIR/upgrade.sh" ]]; then
        bash "$OSH_DIR/upgrade.sh"
    else
        log_error "Upgrade script not found"
    fi
}

cmd_doctor() {
    if [[ -f "$OSH_DIR/scripts/osh_doctor.sh" ]]; then
        bash "$OSH_DIR/scripts/osh_doctor.sh" "$@"
    else
        log_error "Doctor script not found"
        log_info "Please reinstall OSH.IT to get the latest version"
    fi
}

# Help command
cmd_help() {
    cat << 'EOF'
OSH.IT - A Lightweight Zsh Plugin Framework

USAGE:
    osh <command> [arguments]

COMMANDS:
    Plugin Management:
      plugin add <name>      Add a plugin
      plugin remove <name>   Remove a plugin
      plugin list            List available plugins
      plugin info <name>     Show plugin information
      plugins                Show currently installed plugins

    Presets:
      preset <name>          Install a plugin preset
                            (minimal, recommended, developer, full)

    System:
      status                 Show OSH.IT status
      reload                 Reload configuration
      upgrade                Upgrade OSH.IT
      doctor                 Run diagnostics and fix issues
      help                   Show this help message

EXAMPLES:
    osh plugin add weather
    osh plugin remove taskman
    osh plugin list
    osh plugins
    osh preset developer
    osh status
    osh reload

For more information, visit: https://github.com/oiahoon/osh.it
EOF
}

# Main function
main() {
    local command="$1"
    shift || true
    
    case "$command" in
        "plugin")
            cmd_plugin "$@"
            ;;
        "plugins")
            cmd_plugins_current
            ;;
        "preset")
            cmd_preset "$@"
            ;;
        "status")
            cmd_status
            ;;
        "reload")
            cmd_reload
            ;;
        "upgrade")
            cmd_upgrade
            ;;
        "doctor")
            cmd_doctor "$@"
            ;;
        "help"|"--help"|"-h"|"")
            cmd_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo ""
            cmd_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
