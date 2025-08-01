#!/usr/bin/env bash
# OSH.IT Enhanced Command Line Interface - Cyberpunk Edition
# Modern, cyberpunk-styled CLI with advanced plugin management
# Version: 2.1.0

set -e

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
ZSHRC_FILE="$HOME/.zshrc"

# Load error handler if available
if [[ -f "$OSH_DIR/lib/error_handler.zsh" ]]; then
    source "$OSH_DIR/lib/error_handler.zsh"
fi

# Load cyberpunk styling if available
if [[ -f "$OSH_DIR/lib/cyberpunk.zsh" ]]; then
    source "$OSH_DIR/lib/cyberpunk.zsh"
    # Check if cyberpunk functions are actually available
    if declare -f osh_cyber_accent >/dev/null 2>&1; then
        CYBERPUNK_ENABLED=1
    else
        CYBERPUNK_ENABLED=0
    fi
else
    CYBERPUNK_ENABLED=0
fi

# Always define fallback functions to prevent errors
if [[ $CYBERPUNK_ENABLED -eq 0 ]]; then
    # Fallback colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m'
    
    # Define fallback functions
    osh_cyber_accent() { echo -e "${CYAN}$*${NC}"; }
    osh_cyber_success() { echo -e "${GREEN}✅ $*${NC}"; }
    osh_cyber_error() { echo -e "${RED}❌ $*${NC}" >&2; }
    osh_cyber_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
    osh_cyber_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
    osh_cyber_highlight() { echo -e "${CYAN}$*${NC}"; }
fi

# Load ASCII art if available
if [[ -f "$OSH_DIR/lib/cyberpunk_ascii.zsh" ]]; then
    source "$OSH_DIR/lib/cyberpunk_ascii.zsh"
    ASCII_ENABLED=1
else
    ASCII_ENABLED=0
fi

# Load plugin discovery and dependency management
if [[ -f "$OSH_DIR/lib/plugin_discovery.zsh" ]]; then
    source "$OSH_DIR/lib/plugin_discovery.zsh"
    DISCOVERY_ENABLED=1
else
    DISCOVERY_ENABLED=0
fi

if [[ -f "$OSH_DIR/lib/plugin_deps.zsh" ]]; then
    source "$OSH_DIR/lib/plugin_deps.zsh"
    DEPS_ENABLED=1
else
    DEPS_ENABLED=0
fi

# Helper functions with cyberpunk styling
log_info() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_info "$*"
    else
        echo -e "${BLUE}ℹ️  $*${NC}"
    fi
}

log_success() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_success "$*"
    else
        echo -e "${GREEN}✅ $*${NC}"
    fi
}

log_warning() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_warning "$*"
    else
        echo -e "${YELLOW}⚠️  $*${NC}"
    fi
}

log_error() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_error "$*"
    else
        echo -e "${RED}❌ $*${NC}" >&2
    fi
}

log_accent() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_accent "$*"
    else
        echo -e "${CYAN}$*${NC}"
    fi
}

log_highlight() {
    if [[ $CYBERPUNK_ENABLED -eq 1 ]]; then
        osh_cyber_highlight "$*"
    else
        echo -e "${CYAN}$*${NC}"
    fi
}

# Show cyberpunk banner
show_banner() {
    if [[ $ASCII_ENABLED -eq 1 ]]; then
        osh_cyber_logo
    else
        echo "OSH.IT - Cyberpunk Plugin Framework"
        echo "===================================="
    fi
}

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
        log_success "Plugin configuration updated"
    else
        if declare -f osh_config_error >/dev/null 2>&1; then
            osh_config_error "$ZSHRC_FILE" "File not found"
        else
            log_error "Could not find $ZSHRC_FILE"
            echo "💡 Quick fix: Create ~/.zshrc with: touch ~/.zshrc && echo 'source ~/.osh/osh.sh' >> ~/.zshrc"
        fi
        return 1
    fi
}

# Download plugin files with progress
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
    
    # Show loading animation if available
    if [[ $ASCII_ENABLED -eq 1 ]]; then
        (
            osh_cyber_loading_animation "Downloading $plugin_name" 2 &
            local anim_pid=$!
            
            if curl -fsSL "$download_url" -o "$plugin_file"; then
                kill $anim_pid 2>/dev/null || true
                wait $anim_pid 2>/dev/null || true
                log_success "Downloaded $plugin_name"
                return 0
            else
                kill $anim_pid 2>/dev/null || true
                wait $anim_pid 2>/dev/null || true
                log_error "Failed to download $plugin_name"
                return 1
            fi
        )
    else
        if curl -fsSL "$download_url" -o "$plugin_file"; then
            log_success "Downloaded $plugin_name"
            return 0
        else
            log_error "Failed to download $plugin_name"
            return 1
        fi
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
            cmd_plugins_list "$@"
            ;;
        "info")
            cmd_plugin_info "$@"
            ;;
        "search")
            cmd_plugin_search "$@"
            ;;
        "deps"|"dependencies")
            cmd_plugin_deps "$@"
            ;;
        *)
            log_accent "PLUGIN MANAGEMENT SYSTEM"
            echo ""
            echo "Usage: osh plugin <command> [args]"
            echo ""
            echo "Commands:"
            echo "  add <name>     Add a plugin"
            echo "  remove <name>  Remove a plugin"
            echo "  list [cat]     List available plugins (optionally by category)"
            echo "  info <name>    Show plugin information"
            echo "  search <term>  Search plugins by keyword"
            echo "  deps <name>    Check plugin dependencies"
            ;;
    esac
}

cmd_plugin_add() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        if declare -f osh_error_report >/dev/null 2>&1; then
            osh_error_report "missing argument" "Please specify a plugin name" "Usage: osh plugin add <name>"
        else
            log_error "Please specify a plugin name"
            echo "Usage: osh plugin add <name>"
            echo "💡 See available plugins: osh plugin list"
        fi
        return 1
    fi
    
    # Check if plugin exists (if discovery is enabled)
    if [[ $DISCOVERY_ENABLED -eq 1 ]]; then
        if ! osh_plugin_exists "$plugin_name"; then
            log_error "Plugin '$plugin_name' not found"
            log_info "Run 'osh plugin list' to see available plugins"
            return 1
        fi
    fi
    
    # Check dependencies before installation
    if [[ $DEPS_ENABLED -eq 1 ]]; then
        log_info "Checking dependencies for $plugin_name..."
        if ! osh_deps_check_plugin "$plugin_name"; then
            log_warning "Plugin has missing dependencies"
            osh_deps_show_status "$plugin_name"
            
            read -p "Continue installation anyway? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled"
                return 1
            fi
        else
            log_success "All dependencies satisfied"
        fi
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
    local category="${1:-all}"
    
    log_accent "AVAILABLE PLUGINS"
    if [[ "$category" != "all" ]]; then
        echo " (Category: $category)"
    fi
    echo ""
    
    if [[ $DISCOVERY_ENABLED -eq 1 ]]; then
        osh_plugin_list_by_category "$category"
    else
        # Fallback display
        if [[ "$category" == "all" || "$category" == "stable" ]]; then
            echo "🟢 Stable Plugins (Recommended):"
            echo "  sysinfo   - System information display with OSH branding"
            echo "  weather   - Beautiful weather forecast with ASCII art"
            echo "  taskman   - Advanced terminal task manager"
            echo ""
        fi
        
        if [[ "$category" == "all" || "$category" == "beta" ]]; then
            echo "🟡 Beta Plugins (Advanced users):"
            echo "  acw       - Advanced Code Workflow (Git + JIRA integration)"
            echo "  fzf       - Enhanced fuzzy finder with preview"
            echo ""
        fi
        
        if [[ "$category" == "all" || "$category" == "experimental" ]]; then
            echo "🔴 Experimental Plugins (Use with caution):"
            echo "  greeting  - Friendly welcome message"
            echo ""
        fi
    fi
}

cmd_plugin_search() {
    local search_term="$1"
    local search_type="${2:-all}"
    
    if [[ -z "$search_term" ]]; then
        log_error "Please specify a search term"
        echo "Usage: osh plugin search <term> [type]"
        echo "Types: all, name, description, tags, commands"
        return 1
    fi
    
    log_accent "SEARCH RESULTS FOR: $search_term"
    echo ""
    
    if [[ $DISCOVERY_ENABLED -eq 1 ]]; then
        osh_plugin_search "$search_term" "$search_type"
    else
        # Fallback simple search
        local found=0
        
        case "$search_term" in
            *sys*|*info*|*system*)
                echo "  sysinfo   - System information display with OSH branding"
                found=1
                ;;
        esac
        
        case "$search_term" in
            *weather*|*forecast*)
                echo "  weather   - Beautiful weather forecast with ASCII art"
                found=1
                ;;
        esac
        
        case "$search_term" in
            *task*|*todo*|*manage*)
                echo "  taskman   - Advanced terminal task manager"
                found=1
                ;;
        esac
        
        case "$search_term" in
            *git*|*jira*|*workflow*)
                echo "  acw       - Advanced Code Workflow (Git + JIRA integration)"
                found=1
                ;;
        esac
        
        case "$search_term" in
            *fzf*|*fuzzy*|*find*)
                echo "  fzf       - Enhanced fuzzy finder with preview"
                found=1
                ;;
        esac
        
        case "$search_term" in
            *greet*|*welcome*)
                echo "  greeting  - Friendly welcome message"
                found=1
                ;;
        esac
        
        if [[ $found -eq 0 ]]; then
            log_warning "No plugins found matching '$search_term'"
        fi
        
        echo ""
    fi
}

cmd_plugin_deps() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
        echo "Usage: osh plugin deps <name>"
        return 1
    fi
    
    if [[ $DEPS_ENABLED -eq 1 ]]; then
        osh_deps_show_status "$plugin_name"
    else
        log_warning "Dependency management not available"
        log_info "Basic dependency information:"
        
        case "$plugin_name" in
            "weather")
                echo "  Dependencies: curl"
                ;;
            "taskman")
                echo "  Dependencies: python3"
                ;;
            "acw")
                echo "  Dependencies: git, curl"
                ;;
            "fzf")
                echo "  Dependencies: fzf"
                ;;
            "sysinfo"|"greeting")
                echo "  Dependencies: None"
                ;;
            *)
                echo "  Unknown plugin: $plugin_name"
                ;;
        esac
    fi
}

cmd_plugin_info() {
    local plugin_name="$1"
    
    if [[ -z "$plugin_name" ]]; then
        log_error "Please specify a plugin name"
        echo "Usage: osh plugin info <name>"
        return 1
    fi
    
    if [[ $DISCOVERY_ENABLED -eq 1 ]]; then
        osh_plugin_get_info "$plugin_name"
    else
        # Fallback info display
        log_accent "PLUGIN INFORMATION: $plugin_name"
        echo ""
        
        case "$plugin_name" in
            "sysinfo")
                echo "Version: 1.1.0"
                echo "Category: Stable"
                echo "Description: System information display with OSH branding"
                echo "Commands: sysinfo, oshinfo, neofetch-osh"
                echo "Dependencies: None"
                ;;
            "weather")
                echo "Version: 1.3.0"
                echo "Category: Stable"
                echo "Description: Beautiful weather forecast with ASCII art"
                echo "Commands: weather, forecast"
                echo "Dependencies: curl"
                ;;
            "taskman")
                echo "Version: 2.0.0"
                echo "Category: Stable"
                echo "Description: Advanced terminal task manager"
                echo "Commands: tm, tasks"
                echo "Dependencies: python3"
                ;;
            "acw")
                echo "Version: 0.9.0"
                echo "Category: Beta"
                echo "Description: Advanced Code Workflow - Git + JIRA integration"
                echo "Commands: acw, ggco, newb"
                echo "Dependencies: git, curl"
                ;;
            "fzf")
                echo "Version: 0.8.0"
                echo "Category: Beta"
                echo "Description: Enhanced fuzzy finder with preview capabilities"
                echo "Commands: pp, fcommit"
                echo "Dependencies: fzf"
                ;;
            "greeting")
                echo "Version: 0.5.0"
                echo "Category: Experimental"
                echo "Description: Friendly welcome message for OSH users"
                echo "Commands: Auto-display on shell start"
                echo "Dependencies: None"
                ;;
            *)
                log_error "Unknown plugin: $plugin_name"
                echo "Run 'osh plugin list' to see available plugins"
                ;;
        esac
        echo ""
    fi
}

# Status commands
cmd_status() {
    show_banner
    echo ""
    
    log_accent "SYSTEM STATUS"
    echo ""
    echo "Installation: $OSH_DIR"
    echo "Config file: ~/.zshrc"
    echo "Version: $(cat "$OSH_DIR/VERSION" 2>/dev/null || echo "Unknown")"
    echo "Features:"
    echo "  Cyberpunk UI: $([[ $CYBERPUNK_ENABLED -eq 1 ]] && echo "✓" || echo "✗")"
    echo "  ASCII Art: $([[ $ASCII_ENABLED -eq 1 ]] && echo "✓" || echo "✗")"
    echo "  Plugin Discovery: $([[ $DISCOVERY_ENABLED -eq 1 ]] && echo "✓" || echo "✗")"
    echo "  Dependency Management: $([[ $DEPS_ENABLED -eq 1 ]] && echo "✓" || echo "✗")"
    echo ""
    
    cmd_plugins_current
}

cmd_plugins_current() {
    local current=$(get_current_plugins)
    
    log_accent "INSTALLED PLUGINS"
    echo ""
    
    if [[ -n "$current" ]]; then
        if [[ $ASCII_ENABLED -eq 1 ]]; then
            osh_cyber_table_header
            
            echo "$current" | tr ' ' '\n' | while read -r plugin; do
                if [[ -n "$plugin" ]]; then
                    if [[ -d "$OSH_DIR/plugins/$plugin" ]]; then
                        # Determine category
                        local category="unknown"
                        if [[ $DISCOVERY_ENABLED -eq 1 ]]; then
                            category=$(osh_plugin_get_category "$plugin" || echo "unknown")
                        else
                            case "$plugin" in
                                sysinfo|weather|taskman) category="stable" ;;
                                acw|fzf) category="beta" ;;
                                greeting) category="experimental" ;;
                            esac
                        fi
                        
                        # Get description
                        local description=""
                        case "$plugin" in
                            sysinfo) description="System information display" ;;
                            weather) description="Weather forecast with ASCII art" ;;
                            taskman) description="Advanced task manager" ;;
                            acw) description="Advanced Code Workflow" ;;
                            fzf) description="Enhanced fuzzy finder" ;;
                            greeting) description="Welcome message" ;;
                            *) description="Plugin" ;;
                        esac
                        
                        osh_cyber_table_row "$plugin" "INSTALLED" "$category" "$description"
                    else
                        osh_cyber_table_row "$plugin" "MISSING" "unknown" "Files not found"
                    fi
                fi
            done
            
            osh_cyber_table_footer
        else
            echo "$current" | tr ' ' '\n' | while read -r plugin; do
                if [[ -n "$plugin" ]]; then
                    if [[ -d "$OSH_DIR/plugins/$plugin" ]]; then
                        echo "  ✅ $plugin"
                    else
                        echo "  ❌ $plugin (files missing)"
                    fi
                fi
            done
        fi
    else
        echo "  No plugins configured"
    fi
    echo ""
}

# Preset commands with dependency checking
cmd_preset() {
    local preset_name="$1"
    
    if [[ -z "$preset_name" ]]; then
        log_accent "PLUGIN PRESETS"
        echo ""
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
    
    # Check dependencies for the preset
    if [[ $DEPS_ENABLED -eq 1 ]]; then
        log_info "Checking dependencies for preset: $preset_name"
        osh_deps_check_preset "$preset_name"
        local missing_count=$?
        
        if [[ $missing_count -gt 0 ]]; then
            echo ""
            read -p "Some dependencies are missing. Continue installation? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled"
                return 1
            fi
        fi
    fi
    
    log_info "Installing preset: $preset_name"
    log_info "Plugins: $plugins"
    
    # Download all plugins
    local total_plugins=$(echo $plugins | wc -w)
    local current_plugin=0
    
    for plugin in $plugins; do
        ((current_plugin++))
        
        if [[ $ASCII_ENABLED -eq 1 ]]; then
            osh_cyber_progress_bar $current_plugin $total_plugins 40 "Installing"
            echo ""
        fi
        
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
        log_highlight "  source ~/.zshrc"
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
    show_banner
    echo ""
    
    log_accent "COMMAND REFERENCE"
    echo ""
    
    cat << 'EOF'
USAGE:
    osh <command> [arguments]

COMMANDS:
    Plugin Management:
      plugin add <name>      Add a plugin
      plugin remove <name>   Remove a plugin
      plugin list [cat]      List available plugins (optionally by category)
      plugin info <name>     Show plugin information
      plugin search <term>   Search plugins by keyword
      plugin deps <name>     Check plugin dependencies
      plugins                Show currently installed plugins

    Presets:
      preset <name>          Install a plugin preset
                            (minimal, recommended, developer, full)

    System:
      status                 Show OSH.IT status and features
      reload                 Reload configuration
      upgrade                Upgrade OSH.IT
      doctor                 Run diagnostics and fix issues
      help                   Show this help message

EXAMPLES:
    osh plugin add weather
    osh plugin remove taskman
    osh plugin search task
    osh plugin list stable
    osh plugin deps weather
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
            if declare -f osh_error_report >/dev/null 2>&1; then
                osh_error_report "command not found" "Unknown command: $command" "Use 'osh help' to see available commands"
            else
                log_error "Unknown command: $command"
                echo "💡 Available commands: plugin, preset, status, reload, upgrade, doctor, help"
            fi
            echo ""
            cmd_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
