#!/usr/bin/env zsh
# OSH Configuration Manager
# Safe zshrc management with installation, update, and removal capabilities
# Version: 1.0.0

# Configuration constants
OSH_CONFIG_MARKER_START="# === OSH Configuration Start ==="
OSH_CONFIG_MARKER_END="# === OSH Configuration End ==="
OSH_BACKUP_PREFIX="osh-backup"

# Logging functions
config_log_info() { printf "\033[34mℹ️  %s\033[0m\n" "$*"; }
config_log_success() { printf "\033[32m✅ %s\033[0m\n" "$*"; }
config_log_warning() { printf "\033[33m⚠️  %s\033[0m\n" "$*"; }
config_log_error() { printf "\033[31m❌ %s\033[0m\n" "$*" >&2; }

# Create a safe backup of the config file
create_config_backup() {
  local config_file="$1"
  local backup_suffix="${2:-$(date +%Y%m%d_%H%M%S)}"
  
  if [[ ! -f "$config_file" ]]; then
    return 0
  fi
  
  local backup_file="${config_file}.${OSH_BACKUP_PREFIX}.${backup_suffix}"
  
  if cp "$config_file" "$backup_file"; then
    config_log_success "Backup created: $backup_file"
    echo "$backup_file"
    return 0
  else
    config_log_error "Failed to create backup of $config_file"
    return 1
  fi
}

# Check if OSH configuration exists in the config file
has_osh_config() {
  local config_file="$1"
  
  [[ -f "$config_file" ]] && grep -q "$OSH_CONFIG_MARKER_START" "$config_file"
}

# Extract current OSH configuration from config file
get_current_osh_config() {
  local config_file="$1"
  
  if [[ ! -f "$config_file" ]]; then
    return 1
  fi
  
  sed -n "/$OSH_CONFIG_MARKER_START/,/$OSH_CONFIG_MARKER_END/p" "$config_file"
}

# Extract current plugins from config file
get_current_plugins() {
  local config_file="$1"
  
  if ! has_osh_config "$config_file"; then
    return 1
  fi
  
  local plugins_line
  plugins_line=$(get_current_osh_config "$config_file" | grep "^oplugins=" | head -1)
  
  if [[ -n "$plugins_line" ]]; then
    # Extract plugins from oplugins=(plugin1 plugin2 plugin3)
    echo "$plugins_line" | sed -E 's/^oplugins=\(([^)]+)\)/\1/' | tr -d '"' | tr ' ' '\n' | grep -v '^$'
  fi
}

# Generate OSH configuration block
generate_osh_config() {
  local osh_dir="$1"
  local plugins=("${@:2}")
  
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local plugins_formatted=""
  
  if [[ ${#plugins[@]} -gt 0 ]]; then
    # Format plugins array with proper spacing
    plugins_formatted="(\n"
    for plugin in "${plugins[@]}"; do
      plugins_formatted+="  $plugin\n"
    plugins_formatted+=")"
  else
    plugins_formatted="()"
  fi
  
  cat << EOF
$OSH_CONFIG_MARKER_START
# OSH (Oh Shell) Configuration
# Generated on: $timestamp
# Do not edit this block manually - use 'osh config' command instead

# OSH installation directory
export OSH="$osh_dir"

# Plugin selection
oplugins=$plugins_formatted

# Load OSH framework
source \$OSH/osh.sh
$OSH_CONFIG_MARKER_END
EOF
}

# Safely add or update OSH configuration in config file
update_osh_config() {
  local config_file="$1"
  local osh_dir="$2"
  local plugins=("${@:3}")
  local dry_run="${DRY_RUN:-false}"
  
  # Create backup first
  local backup_file
  if [[ "$dry_run" != "true" ]]; then
    backup_file=$(create_config_backup "$config_file")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
  fi
  
  # Generate new configuration
  local new_config
  new_config=$(generate_osh_config "$osh_dir" "${plugins[@]}")
  
  if [[ "$dry_run" == "true" ]]; then
    config_log_info "DRY RUN: Would update $config_file with:"
    echo "$new_config" | sed 's/^/    /'
    return 0
  fi
  
  # Create config file if it doesn't exist
  if [[ ! -f "$config_file" ]]; then
    touch "$config_file"
  fi
  
  if has_osh_config "$config_file"; then
    # Update existing configuration
    config_log_info "Updating existing OSH configuration in $config_file"
    
    # Create temporary file with updated content
    local temp_file=$(mktemp)
    
    # Copy everything before OSH config
    sed "/$OSH_CONFIG_MARKER_START/,/$OSH_CONFIG_MARKER_END/d" "$config_file" > "$temp_file"
    
    # Add new OSH config
    echo "$new_config" >> "$temp_file"
    
    # Replace original file
    if mv "$temp_file" "$config_file"; then
      config_log_success "OSH configuration updated successfully"
    else
      config_log_error "Failed to update configuration"
      rm -f "$temp_file"
      return 1
    fi
  else
    # Add new configuration
    config_log_info "Adding OSH configuration to $config_file"
    
    # Add a blank line before OSH config if file is not empty
    if [[ -s "$config_file" ]]; then
      echo "" >> "$config_file"
    fi
    
    echo "$new_config" >> "$config_file"
    config_log_success "OSH configuration added successfully"
  fi
  
  return 0
}

# Safely remove OSH configuration from config file
remove_osh_config() {
  local config_file="$1"
  local dry_run="${DRY_RUN:-false}"
  
  if [[ ! -f "$config_file" ]]; then
    config_log_warning "Config file $config_file does not exist"
    return 0
  fi
  
  if ! has_osh_config "$config_file"; then
    config_log_warning "No OSH configuration found in $config_file"
    return 0
  fi
  
  # Create backup first
  local backup_file
  if [[ "$dry_run" != "true" ]]; then
    backup_file=$(create_config_backup "$config_file")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
  fi
  
  if [[ "$dry_run" == "true" ]]; then
    config_log_info "DRY RUN: Would remove OSH configuration from $config_file"
    config_log_info "Current OSH configuration:"
    get_current_osh_config "$config_file" | sed 's/^/    /'
    return 0
  fi
  
  # Remove OSH configuration block
  local temp_file=$(mktemp)
  
  # Remove OSH config block and any blank lines immediately before it
  sed "/$OSH_CONFIG_MARKER_START/,/$OSH_CONFIG_MARKER_END/{
    # If this is the start marker, check if previous line is blank
    /$OSH_CONFIG_MARKER_START/{
      # Look back one line
      x
      /^$/d
      x
    }
    d
  }" "$config_file" > "$temp_file"
  
  if mv "$temp_file" "$config_file"; then
    config_log_success "OSH configuration removed from $config_file"
    config_log_info "Backup available at: $backup_file"
  else
    config_log_error "Failed to remove OSH configuration"
    rm -f "$temp_file"
    return 1
  fi
  
  return 0
}

# Interactive plugin selection
interactive_plugin_selection() {
  local available_plugins=("$@")
  local selected_plugins=()
  local current_plugins=()
  
  # Get current plugins if config exists
  if has_osh_config "${SHELL_CONFIG_FILE:-$HOME/.zshrc}"; then
    mapfile -t current_plugins < <(get_current_plugins "${SHELL_CONFIG_FILE:-$HOME/.zshrc}")
  fi
  
  config_log_info "Interactive Plugin Selection"
  echo
  
  if [[ ${#current_plugins[@]} -gt 0 ]]; then
    config_log_info "Currently enabled plugins: ${current_plugins[*]}"
    echo
  fi
  
  echo "Available plugins:"
  for i in "${!available_plugins[@]}"; do
    local plugin="${available_plugins[$i]}"
    local status=""
    
    # Check if plugin is currently enabled
    if [[ " ${current_plugins[*]} " =~ " $plugin " ]]; then
      status=" ${GREEN}(currently enabled)${NORMAL}"
    fi
    
    printf "  %d) %s%s\n" $((i + 1)) "$plugin" "$status"
  done
  
  echo
  echo "Select plugins (space-separated numbers, 'a' for all, 'n' for none, 'c' to keep current):"
  read -r selection
  
  case "$selection" in
    "a"|"all")
      selected_plugins=("${available_plugins[@]}")
      ;;
    "n"|"none")
      selected_plugins=()
      ;;
    "c"|"current")
      selected_plugins=("${current_plugins[@]}")
      ;;
    *)
      # Parse number selection
      for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#available_plugins[@]} ]]; then
          selected_plugins+=("${available_plugins[$((num - 1))]}")
        fi
      done
      ;;
  esac
  
  # Remove duplicates
  selected_plugins=($(printf '%s\n' "${selected_plugins[@]}" | sort -u))
  
  echo "${selected_plugins[@]}"
}

# Validate plugins exist
validate_plugins() {
  local osh_dir="$1"
  local plugins=("${@:2}")
  local invalid_plugins=()
  
  for plugin in "${plugins[@]}"; do
    local plugin_file="$osh_dir/plugins/$plugin/$plugin.plugin.zsh"
    if [[ ! -f "$plugin_file" ]]; then
      invalid_plugins+=("$plugin")
    fi
  done
  
  if [[ ${#invalid_plugins[@]} -gt 0 ]]; then
    config_log_error "Invalid plugins found: ${invalid_plugins[*]}"
    return 1
  fi
  
  return 0
}

# List all backups for a config file
list_config_backups() {
  local config_file="$1"
  local config_dir=$(dirname "$config_file")
  local config_name=$(basename "$config_file")
  
  find "$config_dir" -name "${config_name}.${OSH_BACKUP_PREFIX}.*" -type f 2>/dev/null | sort -r
}

# Restore from backup
restore_from_backup() {
  local config_file="$1"
  local backup_file="$2"
  
  if [[ ! -f "$backup_file" ]]; then
    config_log_error "Backup file not found: $backup_file"
    return 1
  fi
  
  local current_backup
  current_backup=$(create_config_backup "$config_file" "pre-restore")
  
  if cp "$backup_file" "$config_file"; then
    config_log_success "Configuration restored from $backup_file"
    config_log_info "Previous config backed up to: $current_backup"
  else
    config_log_error "Failed to restore from backup"
    return 1
  fi
}
