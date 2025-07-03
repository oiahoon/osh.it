#!/usr/bin/env zsh
# OSH Configuration Management Command
# Provides comprehensive configuration management for OSH
# Version: 1.0.0

# Source required libraries
source "${OSH}/lib/config_manager.zsh" 2>/dev/null || {
  echo "Error: Could not load configuration manager"
  return 1
}

source "${OSH}/lib/plugin_manager.zsh" 2>/dev/null || {
  echo "Error: Could not load plugin manager"
  return 1
}

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
osh_log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
osh_log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
osh_log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
osh_log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*" >&2; }

# Show current OSH configuration
show_current_config() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  
  echo "${BOLD}${CYAN}🔧 Current OSH Configuration${NORMAL}"
  echo
  
  # Basic info
  echo "${BOLD}OSH Directory:${NORMAL} ${OSH:-Not set}"
  echo "${BOLD}Config File:${NORMAL} $config_file"
  echo "${BOLD}Shell:${NORMAL} ${SHELL##*/}"
  echo
  
  # Check if OSH config exists
  if has_osh_config "$config_file"; then
    echo "${BOLD}${GREEN}✅ OSH Configuration Found${NORMAL}"
    echo
    
    # Show current plugins
    local current_plugins
    mapfile -t current_plugins < <(get_current_plugins "$config_file")
    
    if [[ ${#current_plugins[@]} -gt 0 ]]; then
      echo "${BOLD}Enabled Plugins:${NORMAL}"
      for plugin in "${current_plugins[@]}"; do
        local status="${GREEN}●${NORMAL}"
        local plugin_file="${OSH}/plugins/$plugin/$plugin.plugin.zsh"
        
        if [[ ! -f "$plugin_file" ]]; then
          status="${RED}●${NORMAL} ${DIM}(missing)${NORMAL}"
        fi
        
        echo "  $status $plugin"
      done
    else
      echo "${BOLD}${YELLOW}No plugins enabled${NORMAL}"
    fi
    echo
    
    # Show configuration block
    echo "${BOLD}Configuration Block:${NORMAL}"
    get_current_osh_config "$config_file" | sed 's/^/  /'
  else
    echo "${BOLD}${YELLOW}⚠️  No OSH Configuration Found${NORMAL}"
    echo "OSH may not be properly installed or configured."
  fi
  echo
}

# Show configuration backups
show_backups() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  local backups
  mapfile -t backups < <(list_config_backups "$config_file")
  
  echo "${BOLD}${CYAN}📦 Configuration Backups${NORMAL}"
  echo
  
  if [[ ${#backups[@]} -eq 0 ]]; then
    echo "${BOLD}${YELLOW}No backups found${NORMAL}"
    return 0
  fi
  
  echo "${BOLD}Available backups for $config_file:${NORMAL}"
  for i in "${!backups[@]}"; do
    local backup="${backups[$i]}"
    local backup_name=$(basename "$backup")
    local backup_date=$(echo "$backup_name" | grep -o '[0-9]\{8\}_[0-9]\{6\}' || echo "unknown")
    local backup_size=$(ls -lh "$backup" 2>/dev/null | awk '{print $5}' || echo "unknown")
    
    printf "  %d) %s ${DIM}(%s, %s)${NORMAL}\n" $((i + 1)) "$backup_name" "$backup_date" "$backup_size"
  done
  echo
}

# Interactive backup restoration
restore_backup_interactive() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  local backups
  mapfile -t backups < <(list_config_backups "$config_file")
  
  if [[ ${#backups[@]} -eq 0 ]]; then
    osh_log_warning "No backups available for restoration"
    return 1
  fi
  
  echo "${BOLD}${CYAN}🔄 Restore Configuration Backup${NORMAL}"
  echo
  
  show_backups
  
  read -r "choice?Select backup to restore (1-${#backups[@]}): "
  
  if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#backups[@]} ]]; then
    local selected_backup="${backups[$((choice - 1))]}"
    
    echo
    osh_log_info "Selected backup: $(basename "$selected_backup")"
    echo
    echo "${BOLD}${YELLOW}⚠️  Warning:${NORMAL} This will replace your current configuration!"
    read -r "confirm?Are you sure you want to restore this backup? (y/N): "
    
    if [[ "$confirm" =~ ^[Yy] ]]; then
      if restore_from_backup "$config_file" "$selected_backup"; then
        echo
        osh_log_success "Configuration restored successfully!"
        echo "${BOLD}${BLUE}Next step:${NORMAL} Restart your terminal or run: ${CYAN}source $config_file${NORMAL}"
      else
        osh_log_error "Failed to restore backup"
        return 1
      fi
    else
      osh_log_info "Backup restoration cancelled"
    fi
  else
    osh_log_error "Invalid selection: $choice"
    return 1
  fi
}

# Reset OSH configuration
reset_config() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  
  echo "${BOLD}${YELLOW}🔄 Reset OSH Configuration${NORMAL}"
  echo
  
  if ! has_osh_config "$config_file"; then
    osh_log_warning "No OSH configuration found to reset"
    return 0
  fi
  
  echo "${BOLD}Current configuration:${NORMAL}"
  get_current_osh_config "$config_file" | sed 's/^/  /'
  echo
  
  echo "${BOLD}${YELLOW}⚠️  Warning:${NORMAL} This will remove OSH configuration from $config_file"
  echo "A backup will be created automatically."
  echo
  read -r "confirm?Are you sure you want to reset OSH configuration? (y/N): "
  
  if [[ "$confirm" =~ ^[Yy] ]]; then
    if remove_osh_config "$config_file"; then
      echo
      osh_log_success "OSH configuration removed successfully!"
      echo "${BOLD}${BLUE}To reinstall OSH:${NORMAL}"
      echo "  Run the installation script again or use: ${CYAN}osh config install${NORMAL}"
    else
      osh_log_error "Failed to remove OSH configuration"
      return 1
    fi
  else
    osh_log_info "Configuration reset cancelled"
  fi
}

# Install/reinstall OSH configuration
install_config() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  local osh_dir="${OSH:-$HOME/.osh}"
  
  echo "${BOLD}${CYAN}🔧 Install OSH Configuration${NORMAL}"
  echo
  
  if has_osh_config "$config_file"; then
    echo "${BOLD}${YELLOW}⚠️  OSH configuration already exists${NORMAL}"
    echo
    read -r "overwrite?Do you want to overwrite the existing configuration? (y/N): "
    if [[ ! "$overwrite" =~ ^[Yy] ]]; then
      osh_log_info "Installation cancelled"
      return 0
    fi
  fi
  
  # Get available plugins
  local available_plugins
  mapfile -t available_plugins < <(get_available_plugins)
  
  if [[ ${#available_plugins[@]} -eq 0 ]]; then
    osh_log_error "No plugins found in $osh_dir/plugins/"
    return 1
  fi
  
  # Interactive plugin selection
  echo "${BOLD}Select plugins to enable:${NORMAL}"
  local selected_plugins
  read -ra selected_plugins <<< "$(interactive_plugin_selection "${available_plugins[@]}")"
  
  # Update configuration
  if update_osh_config "$config_file" "$osh_dir" "${selected_plugins[@]}"; then
    echo
    osh_log_success "OSH configuration installed successfully!"
    echo "${BOLD}${BLUE}Next step:${NORMAL} Restart your terminal or run: ${CYAN}source $config_file${NORMAL}"
  else
    osh_log_error "Failed to install OSH configuration"
    return 1
  fi
}

# Validate current configuration
validate_config() {
  local config_file="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"
  local osh_dir="${OSH:-$HOME/.osh}"
  local issues=()
  
  echo "${BOLD}${CYAN}🔍 Validate OSH Configuration${NORMAL}"
  echo
  
  # Check if OSH directory exists
  if [[ ! -d "$osh_dir" ]]; then
    issues+=("OSH directory not found: $osh_dir")
  fi
  
  # Check if main OSH script exists
  if [[ ! -f "$osh_dir/osh.sh" ]]; then
    issues+=("Main OSH script not found: $osh_dir/osh.sh")
  fi
  
  # Check configuration file
  if [[ ! -f "$config_file" ]]; then
    issues+=("Configuration file not found: $config_file")
  elif ! has_osh_config "$config_file"; then
    issues+=("No OSH configuration found in $config_file")
  else
    # Validate plugins
    local current_plugins
    mapfile -t current_plugins < <(get_current_plugins "$config_file")
    
    for plugin in "${current_plugins[@]}"; do
      local plugin_file="$osh_dir/plugins/$plugin/$plugin.plugin.zsh"
      if [[ ! -f "$plugin_file" ]]; then
        issues+=("Plugin file not found: $plugin_file")
      fi
    done
  fi
  
  # Report results
  if [[ ${#issues[@]} -eq 0 ]]; then
    osh_log_success "Configuration validation passed!"
    echo "  ✅ OSH directory exists"
    echo "  ✅ Main script exists"
    echo "  ✅ Configuration file exists"
    echo "  ✅ All plugins are available"
  else
    osh_log_error "Configuration validation failed!"
    echo
    echo "${BOLD}Issues found:${NORMAL}"
    for issue in "${issues[@]}"; do
      echo "  ❌ $issue"
    done
    echo
    echo "${BOLD}${BLUE}Suggested actions:${NORMAL}"
    echo "  • Run: ${CYAN}upgrade_myshell${NORMAL} to update OSH"
    echo "  • Run: ${CYAN}osh config install${NORMAL} to reinstall configuration"
    echo "  • Check plugin availability with: ${CYAN}osh plugin list${NORMAL}"
  fi
  echo
}

# Main OSH config command
osh_config() {
  local action="$1"
  shift
  
  case "$action" in
    "show"|"status"|"")
      show_current_config
      ;;
    "install"|"setup")
      install_config "$@"
      ;;
    "reset"|"remove")
      reset_config "$@"
      ;;
    "backup"|"backups")
      show_backups "$@"
      ;;
    "restore")
      restore_backup_interactive "$@"
      ;;
    "validate"|"check")
      validate_config "$@"
      ;;
    "plugin"|"plugins")
      osh_plugin_manager "$@"
      ;;
    "help"|"--help")
      cat << EOF
${BOLD}OSH Configuration Manager${NORMAL}

${BOLD}USAGE:${NORMAL}
  osh config [COMMAND] [OPTIONS]

${BOLD}COMMANDS:${NORMAL}
  show                 Show current OSH configuration (default)
  install              Install/reinstall OSH configuration
  reset                Remove OSH configuration from shell config
  backup               List available configuration backups
  restore              Restore configuration from backup
  validate             Validate current configuration
  plugin               Manage plugins (alias for 'osh plugin')
  help                 Show this help message

${BOLD}EXAMPLES:${NORMAL}
  osh config           # Show current configuration
  osh config install   # Install/reinstall configuration
  osh config reset     # Remove OSH configuration
  osh config backup    # List backups
  osh config restore   # Restore from backup
  osh config validate  # Check configuration health
  osh config plugin    # Manage plugins interactively

${BOLD}PLUGIN MANAGEMENT:${NORMAL}
  osh config plugin list              # List all plugins
  osh config plugin enable weather    # Enable specific plugin
  osh config plugin disable acw       # Disable specific plugin
  osh config plugin                   # Interactive plugin management

${BOLD}SAFETY FEATURES:${NORMAL}
  • Automatic backups before any changes
  • Safe configuration block management
  • Non-destructive updates
  • Easy restoration from backups

For more information, visit: https://github.com/oiahoon/osh
EOF
      ;;
    *)
      osh_log_error "Unknown command: $action"
      echo "Use 'osh config help' for usage information."
      return 1
      ;;
  esac
}

# Create alias for easier access
alias oshconfig='osh_config'

# Main entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
  osh_config "$@"
fi
