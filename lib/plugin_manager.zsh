#!/usr/bin/env zsh
# OSH Plugin Manager
# Interactive plugin management system
# Version: 1.0.0

# Source configuration manager
source "${OSH}/lib/config_manager.zsh" 2>/dev/null || {
  echo "Error: Could not load configuration manager"
  return 1
}

# Plugin information database
declare -A PLUGIN_INFO=(
  ["proxy"]="Network proxy management - Toggle proxy settings on/off"
  ["sysinfo"]="System information display - Beautiful system info with OSH branding"
  ["weather"]="Weather forecast - ASCII art weather display with location support"
  ["taskman"]="Task manager - Advanced terminal task manager with productivity features"
  ["acw"]="Advanced Code Workflow - Git workflow automation with JIRA integration"
  ["fzf"]="Fuzzy finder - Enhanced fuzzy finding with preview capabilities"
)

declare -A PLUGIN_DEPENDENCIES=(
  ["acw"]="git"
  ["fzf"]="fzf fd"
  ["weather"]="curl"
)

declare -A PLUGIN_CATEGORIES=(
  ["proxy"]="Network"
  ["sysinfo"]="System"
  ["weather"]="Utility"
  ["taskman"]="Productivity"
  ["acw"]="Development"
  ["fzf"]="Navigation"
)

# Colors for output
if [[ -t 1 ]]; then
  RED='\033[31m'
  GREEN='\033[32m'
  YELLOW='\033[33m'
  BLUE='\033[34m'
  MAGENTA='\033[35m'
  CYAN='\033[36m'
  BOLD='\033[1m'
  DIM='\033[2m'
  NORMAL='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' MAGENTA='' CYAN='' BOLD='' DIM='' NORMAL=''
fi

# Logging functions
pm_log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
pm_log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
pm_log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
pm_log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*" >&2; }

# Get available plugins
get_available_plugins() {
  local osh_dir="${OSH:-$HOME/.osh}"
  local plugins=()
  
  if [[ -d "$osh_dir/plugins" ]]; then
    for plugin_dir in "$osh_dir/plugins"/*; do
      if [[ -d "$plugin_dir" ]]; then
        local plugin_name=$(basename "$plugin_dir")
        local plugin_file="$plugin_dir/$plugin_name.plugin.zsh"
        if [[ -f "$plugin_file" ]]; then
          plugins+=("$plugin_name")
        fi
      fi
    done
  fi
  
  printf '%s\n' "${plugins[@]}" | sort
}

# Get currently enabled plugins
get_enabled_plugins() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  get_current_plugins "$config_file" 2>/dev/null || echo ""
}

# Check if plugin is enabled
is_plugin_enabled() {
  local plugin="$1"
  local enabled_plugins
  mapfile -t enabled_plugins < <(get_enabled_plugins)
  
  [[ " ${enabled_plugins[*]} " =~ " $plugin " ]]
}

# Check plugin dependencies
check_plugin_dependencies() {
  local plugin="$1"
  local missing_deps=()
  
  if [[ -n "${PLUGIN_DEPENDENCIES[$plugin]}" ]]; then
    local deps=(${=PLUGIN_DEPENDENCIES[$plugin]})
    for dep in "${deps[@]}"; do
      if ! command -v "$dep" >/dev/null 2>&1; then
        missing_deps+=("$dep")
      fi
    done
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    pm_log_warning "Plugin '$plugin' requires: ${missing_deps[*]}"
    return 1
  fi
  
  return 0
}

# Display plugin information
show_plugin_info() {
  local plugin="$1"
  local enabled_status=""
  
  if is_plugin_enabled "$plugin"; then
    enabled_status="${GREEN}[ENABLED]${NORMAL}"
  else
    enabled_status="${DIM}[DISABLED]${NORMAL}"
  fi
  
  echo "${BOLD}${CYAN}$plugin${NORMAL} $enabled_status"
  
  if [[ -n "${PLUGIN_INFO[$plugin]}" ]]; then
    echo "  ${PLUGIN_INFO[$plugin]}"
  fi
  
  if [[ -n "${PLUGIN_CATEGORIES[$plugin]}" ]]; then
    echo "  ${DIM}Category: ${PLUGIN_CATEGORIES[$plugin]}${NORMAL}"
  fi
  
  if [[ -n "${PLUGIN_DEPENDENCIES[$plugin]}" ]]; then
    echo "  ${DIM}Dependencies: ${PLUGIN_DEPENDENCIES[$plugin]}${NORMAL}"
    check_plugin_dependencies "$plugin" >/dev/null || echo "  ${YELLOW}⚠️  Missing dependencies${NORMAL}"
  fi
  
  echo
}

# List all plugins with status
list_plugins() {
  local show_category="$1"
  local available_plugins
  mapfile -t available_plugins < <(get_available_plugins)
  
  if [[ ${#available_plugins[@]} -eq 0 ]]; then
    pm_log_warning "No plugins found in ${OSH}/plugins/"
    return 1
  fi
  
  echo "${BOLD}${BLUE}📦 Available OSH Plugins${NORMAL}"
  echo
  
  if [[ "$show_category" == "true" ]]; then
    # Group by category
    declare -A category_plugins
    for plugin in "${available_plugins[@]}"; do
      local category="${PLUGIN_CATEGORIES[$plugin]:-Other}"
      category_plugins[$category]+="$plugin "
    done
    
    for category in $(printf '%s\n' "${(@k)category_plugins}" | sort); do
      echo "${BOLD}${MAGENTA}$category:${NORMAL}"
      for plugin in ${=category_plugins[$category]}; do
        echo -n "  "
        show_plugin_info "$plugin"
      done
    done
  else
    # Simple list
    for plugin in "${available_plugins[@]}"; do
      show_plugin_info "$plugin"
    done
  fi
}

# Interactive plugin selection menu
interactive_plugin_menu() {
  local available_plugins
  mapfile -t available_plugins < <(get_available_plugins)
  local enabled_plugins
  mapfile -t enabled_plugins < <(get_enabled_plugins)
  
  while true; do
    clear
    echo "${BOLD}${CYAN}🔌 OSH Plugin Manager${NORMAL}"
    echo
    
    # Show current status
    if [[ ${#enabled_plugins[@]} -gt 0 ]]; then
      echo "${BOLD}${GREEN}Currently enabled plugins:${NORMAL} ${enabled_plugins[*]}"
    else
      echo "${BOLD}${YELLOW}No plugins currently enabled${NORMAL}"
    fi
    echo
    
    # Show available plugins
    echo "${BOLD}Available plugins:${NORMAL}"
    for i in "${!available_plugins[@]}"; do
      local plugin="${available_plugins[$i]}"
      local status_icon="○"
      local status_color="$DIM"
      
      if is_plugin_enabled "$plugin"; then
        status_icon="●"
        status_color="$GREEN"
      fi
      
      printf "  %s%2d) %s %s${NORMAL}" "$status_color" $((i + 1)) "$status_icon" "$plugin"
      
      if [[ -n "${PLUGIN_INFO[$plugin]}" ]]; then
        printf " - %s" "${PLUGIN_INFO[$plugin]}"
      fi
      echo
    done
    
    echo
    echo "${BOLD}Actions:${NORMAL}"
    echo "  ${CYAN}1-${#available_plugins[@]})${NORMAL} Toggle plugin"
    echo "  ${CYAN}a)${NORMAL} Enable all plugins"
    echo "  ${CYAN}n)${NORMAL} Disable all plugins"
    echo "  ${CYAN}s)${NORMAL} Save and apply changes"
    echo "  ${CYAN}r)${NORMAL} Reset to current configuration"
    echo "  ${CYAN}i)${NORMAL} Show detailed plugin information"
    echo "  ${CYAN}q)${NORMAL} Quit without saving"
    echo
    
    read -r "choice?Choose an action: "
    
    case "$choice" in
      [1-9]|[1-9][0-9])
        if [[ $choice -ge 1 && $choice -le ${#available_plugins[@]} ]]; then
          local plugin="${available_plugins[$((choice - 1))]}"
          if is_plugin_enabled "$plugin"; then
            # Remove from enabled list
            enabled_plugins=(${enabled_plugins[@]/$plugin})
            pm_log_info "Disabled $plugin"
          else
            # Add to enabled list
            enabled_plugins+=("$plugin")
            pm_log_success "Enabled $plugin"
          fi
        else
          pm_log_error "Invalid selection: $choice"
        fi
        ;;
      "a"|"all")
        enabled_plugins=("${available_plugins[@]}")
        pm_log_success "Enabled all plugins"
        ;;
      "n"|"none")
        enabled_plugins=()
        pm_log_info "Disabled all plugins"
        ;;
      "s"|"save")
        echo
        pm_log_info "Applying plugin configuration..."
        if apply_plugin_changes "${enabled_plugins[@]}"; then
          pm_log_success "Plugin configuration saved successfully!"
          echo
          echo "${BOLD}${BLUE}Next steps:${NORMAL}"
          echo "  1. Restart your terminal or run: ${CYAN}source ~/.zshrc${NORMAL}"
          echo "  2. Try your enabled plugins!"
          echo
          read -r "?Press Enter to continue..."
          return 0
        else
          pm_log_error "Failed to save plugin configuration"
          read -r "?Press Enter to continue..."
        fi
        ;;
      "r"|"reset")
        mapfile -t enabled_plugins < <(get_enabled_plugins)
        pm_log_info "Reset to current configuration"
        ;;
      "i"|"info")
        echo
        read -r "plugin_name?Enter plugin name for detailed info: "
        if [[ " ${available_plugins[*]} " =~ " $plugin_name " ]]; then
          echo
          show_plugin_info "$plugin_name"
          read -r "?Press Enter to continue..."
        else
          pm_log_error "Plugin not found: $plugin_name"
          read -r "?Press Enter to continue..."
        fi
        ;;
      "q"|"quit")
        pm_log_info "Exiting without saving changes"
        return 0
        ;;
      *)
        pm_log_error "Invalid choice: $choice"
        sleep 1
        ;;
    esac
  done
}

# Apply plugin changes to configuration
apply_plugin_changes() {
  local plugins=("$@")
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  local osh_dir="${OSH:-$HOME/.osh}"
  
  # Validate plugins
  if ! validate_plugins "$osh_dir" "${plugins[@]}"; then
    return 1
  fi
  
  # Check dependencies
  local missing_deps=()
  for plugin in "${plugins[@]}"; do
    if ! check_plugin_dependencies "$plugin"; then
      missing_deps+=("$plugin")
    fi
  done
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo
    pm_log_warning "Some plugins have missing dependencies:"
    for plugin in "${missing_deps[@]}"; do
      echo "  $plugin: ${PLUGIN_DEPENDENCIES[$plugin]}"
    done
    echo
    read -r "continue?Continue anyway? (y/N): "
    if [[ ! "$continue" =~ ^[Yy] ]]; then
      return 1
    fi
  fi
  
  # Update configuration
  update_osh_config "$config_file" "$osh_dir" "${plugins[@]}"
}

# Command-line interface
osh_plugin_manager() {
  local action="$1"
  shift
  
  case "$action" in
    "list"|"ls")
      list_plugins "$@"
      ;;
    "enable")
      if [[ $# -eq 0 ]]; then
        pm_log_error "Usage: osh plugin enable <plugin1> [plugin2] ..."
        return 1
      fi
      
      local enabled_plugins
      mapfile -t enabled_plugins < <(get_enabled_plugins)
      
      for plugin in "$@"; do
        if [[ " ${enabled_plugins[*]} " =~ " $plugin " ]]; then
          pm_log_warning "Plugin '$plugin' is already enabled"
        else
          enabled_plugins+=("$plugin")
          pm_log_success "Added '$plugin' to enabled plugins"
        fi
      done
      
      apply_plugin_changes "${enabled_plugins[@]}"
      ;;
    "disable")
      if [[ $# -eq 0 ]]; then
        pm_log_error "Usage: osh plugin disable <plugin1> [plugin2] ..."
        return 1
      fi
      
      local enabled_plugins
      mapfile -t enabled_plugins < <(get_enabled_plugins)
      
      for plugin in "$@"; do
        if [[ " ${enabled_plugins[*]} " =~ " $plugin " ]]; then
          enabled_plugins=(${enabled_plugins[@]/$plugin})
          pm_log_success "Removed '$plugin' from enabled plugins"
        else
          pm_log_warning "Plugin '$plugin' is not enabled"
        fi
      done
      
      apply_plugin_changes "${enabled_plugins[@]}"
      ;;
    "info")
      if [[ $# -eq 0 ]]; then
        pm_log_error "Usage: osh plugin info <plugin>"
        return 1
      fi
      show_plugin_info "$1"
      ;;
    "interactive"|"menu"|"")
      interactive_plugin_menu
      ;;
    *)
      echo "${BOLD}OSH Plugin Manager${NORMAL}"
      echo
      echo "${BOLD}Usage:${NORMAL}"
      echo "  osh plugin [interactive]     Interactive plugin management"
      echo "  osh plugin list              List all available plugins"
      echo "  osh plugin enable <plugins>  Enable specific plugins"
      echo "  osh plugin disable <plugins> Disable specific plugins"
      echo "  osh plugin info <plugin>     Show plugin information"
      echo
      echo "${BOLD}Examples:${NORMAL}"
      echo "  osh plugin                   # Interactive mode"
      echo "  osh plugin list              # List all plugins"
      echo "  osh plugin enable weather    # Enable weather plugin"
      echo "  osh plugin disable acw fzf   # Disable multiple plugins"
      echo "  osh plugin info taskman      # Show taskman plugin info"
      ;;
  esac
}

# Main entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
  osh_plugin_manager "$@"
fi
