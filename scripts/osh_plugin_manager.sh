#!/usr/bin/env bash
# OSH.IT Plugin Manager
# Simple plugin management for OSH.IT users

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
MANIFEST_URL="https://raw.githubusercontent.com/oiahoon/osh.it/main/PLUGIN_MANIFEST.json"
REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh.it/main"

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
        log_success "Updated plugin configuration in $ZSHRC_FILE"
    else
        log_error "Could not find $ZSHRC_FILE"
        return 1
    fi
}

# Download plugin files
download_plugin() {
    local plugin_name="$1"
    local plugin_dir="$OSH_DIR/plugins/$plugin_name"
    
    log_info "Downloading plugin: $plugin_name"
    
    # Create plugin directory
    mkdir -p "$plugin_dir"
    
    # Get plugin files from manifest (simplified - just download main file)
    local plugin_file="$plugin_dir/${plugin_name}.plugin.zsh"
    local download_url="$REPO_BASE/plugins/$plugin_name/${plugin_name}.plugin.zsh"
    
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

# List available plugins
list_available_plugins() {
    echo -e "${CYAN}📦 Available OSH.IT Plugins:${NC}\n"
    
    echo -e "${GREEN}🟢 Stable Plugins (Recommended):${NC}"
    echo "  • sysinfo  - System information display with OSH branding"
    echo "  • weather  - Beautiful weather forecast with ASCII art"
    echo "  • taskman  - Advanced terminal task manager"
    echo ""
    
    echo -e "${YELLOW}🟡 Beta Plugins (Advanced users):${NC}"
    echo "  • acw      - Advanced Code Workflow (Git + JIRA integration)"
    echo "  • fzf      - Enhanced fuzzy finder with preview"
    echo ""
    
    echo -e "${RED}🔴 Experimental Plugins (Use with caution):${NC}"
    echo "  • greeting - Friendly welcome message"
    echo ""
}

# List current plugins
list_current_plugins() {
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

# Add plugin
add_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
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
        log_info "Run 'source ~/.zshrc' to load the new plugin"
    else
        log_error "Failed to add plugin: $plugin_name"
        return 1
    fi
}

# Remove plugin
remove_plugin() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
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
    log_info "Run 'source ~/.zshrc' to unload the plugin"
}

# Install preset
install_preset() {
    local preset="$1"
    local plugins=""
    
    case "$preset" in
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
            log_error "Unknown preset: $preset"
            log_info "Available presets: minimal, recommended, developer, full"
            return 1
            ;;
    esac
    
    log_info "Installing preset: $preset"
    log_info "Plugins: $plugins"
    
    # Download all plugins
    for plugin in $plugins; do
        download_plugin "$plugin"
    done
    
    # Update configuration
    update_plugins_config "$plugins"
    log_success "Installed preset: $preset"
    log_info "Run 'source ~/.zshrc' to load all plugins"
}

# Show help
show_help() {
    cat << EOF
OSH.IT Plugin Manager

USAGE:
    $(basename "$0") <command> [arguments]

COMMANDS:
    list                    List available plugins
    current                 Show currently installed plugins
    add <plugin>           Add a plugin
    remove <plugin>        Remove a plugin
    preset <name>          Install a plugin preset
    help                   Show this help message

PRESETS:
    minimal                sysinfo
    recommended            sysinfo weather taskman
    developer              sysinfo weather taskman acw fzf
    full                   sysinfo weather taskman acw fzf greeting

EXAMPLES:
    $(basename "$0") list
    $(basename "$0") current
    $(basename "$0") add weather
    $(basename "$0") remove taskman
    $(basename "$0") preset developer

EOF
}

# Main function
main() {
    local command="$1"
    shift || true
    
    case "$command" in
        "list"|"ls")
            list_available_plugins
            ;;
        "current"|"status")
            list_current_plugins
            ;;
        "add"|"install")
            add_plugin "$1"
            ;;
        "remove"|"uninstall"|"rm")
            remove_plugin "$1"
            ;;
        "preset")
            install_preset "$1"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
