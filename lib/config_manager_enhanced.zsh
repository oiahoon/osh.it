#!/usr/bin/env zsh
# OSH Enhanced Configuration Manager
# Safe zshrc management with smart backup rotation
# Version: 1.1.0

# Source backup manager
source "${OSH}/lib/backup_manager.zsh" 2>/dev/null || {
  # Fallback if backup manager is not available
  create_smart_backup() {
    local config_file="$1"
    local reason="${2:-manual}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${config_file}.osh-backup.${timestamp}"
    
    if [[ -f "$config_file" ]] && cp "$config_file" "$backup_file"; then
      echo "Backup created: $backup_file"
      echo "$backup_file"
      return 0
    fi
    return 1
  }
}

# Configuration constants
OSH_CONFIG_MARKER_START="# === OSH Configuration Start ==="
OSH_CONFIG_MARKER_END="# === OSH Configuration End ==="

# Logging functions
config_log_info() { printf "\033[34mℹ️  %s\033[0m\n" "$*"; }
config_log_success() { printf "\033[32m✅ %s\033[0m\n" "$*"; }
config_log_warning() { printf "\033[33m⚠️  %s\033[0m\n" "$*"; }
config_log_error() { printf "\033[31m❌ %s\033[0m\n" "$*" >&2; }

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
    done
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

# Enhanced backup creation with reason tracking
create_config_backup_enhanced() {
  local config_file="$1"
  local reason="${2:-configuration-update}"
  local dry_run="${DRY_RUN:-false}"
  
  config_log_info "Creating configuration backup..."
  config_log_info "File: $(basename "$config_file")"
  config_log_info "Reason: $reason"
  
  if [[ "$dry_run" == "true" ]]; then
    config_log_info "[DRY RUN] Would create smart backup with cleanup"
    # Show what backups exist
    if command -v get_backup_files >/dev/null 2>&1; then
      local existing_backups
      mapfile -t existing_backups < <(get_backup_files "$config_file")
      config_log_info "[DRY RUN] Existing backups: ${#existing_backups[@]}"
      if [[ ${#existing_backups[@]} -ge 3 ]]; then
        config_log_info "[DRY RUN] Would clean up old backups (keeping 3 most recent)"
      fi
    fi
    return 0
  fi
  
  # Use smart backup if available, otherwise fallback
  if command -v create_smart_backup >/dev/null 2>&1; then
    create_smart_backup "$config_file" "$reason"
  else
    # Fallback backup creation
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${config_file}.osh-backup.${timestamp}"
    
    if [[ -f "$config_file" ]] && cp "$config_file" "$backup_file"; then
      config_log_success "Backup created: $(basename "$backup_file")"
      echo "$backup_file"
      return 0
    else
      config_log_error "Failed to create backup"
      return 1
    fi
  fi
}

# Safely add or update OSH configuration in config file
update_osh_config() {
  local config_file="$1"
  local osh_dir="$2"
  local plugins=("${@:3}")
  local dry_run="${DRY_RUN:-false}"
  
  config_log_info "Updating OSH configuration in $(basename "$config_file")"
  
  # Determine the reason for backup
  local backup_reason="installation"
  if has_osh_config "$config_file"; then
    backup_reason="configuration-update"
  fi
  
  # Create backup first
  local backup_file
  if [[ "$dry_run" != "true" ]]; then
    backup_file=$(create_config_backup_enhanced "$config_file" "$backup_reason")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
  else
    create_config_backup_enhanced "$config_file" "$backup_reason"
  fi
  
  # Generate new configuration
  local new_config
  new_config=$(generate_osh_config "$osh_dir" "${plugins[@]}")
  
  if [[ "$dry_run" == "true" ]]; then
    config_log_info "[DRY RUN] Would update $config_file with:"
    echo "$new_config" | sed 's/^/    /'
    return 0
  fi
  
  # Create config file if it doesn't exist
  if [[ ! -f "$config_file" ]]; then
    touch "$config_file"
    config_log_info "Created new configuration file: $config_file"
  fi
  
  if has_osh_config "$config_file"; then
    # Update existing configuration
    config_log_info "Updating existing OSH configuration"
    
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
    config_log_info "Adding new OSH configuration"
    
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
    backup_file=$(create_config_backup_enhanced "$config_file" "pre-removal")
    if [[ $? -ne 0 ]]; then
      return 1
    fi
  else
    create_config_backup_enhanced "$config_file" "pre-removal"
  fi
  
  if [[ "$dry_run" == "true" ]]; then
    config_log_info "[DRY RUN] Would remove OSH configuration from $config_file"
    config_log_info "[DRY RUN] Current OSH configuration:"
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
    config_log_info "Backup available at: $(basename "$backup_file")"
  else
    config_log_error "Failed to remove OSH configuration"
    rm -f "$temp_file"
    return 1
  fi
  
  return 0
}

# Show configuration status with backup information
show_config_status() {
  local config_file="${1:-${SHELL_CONFIG_FILE:-$HOME/.zshrc}}"
  
  echo "\033[1m\033[36m🔧 OSH Configuration Status\033[0m"
  echo
  
  # Basic info
  echo "\033[1mConfiguration File:\033[0m $config_file"
  echo "\033[1mOSH Directory:\033[0m ${OSH:-Not set}"
  echo
  
  # Check if config exists
  if has_osh_config "$config_file"; then
    echo "\033[1m\033[32m✅ OSH Configuration Found\033[0m"
    echo
    
    # Show current plugins
    local current_plugins
    mapfile -t current_plugins < <(get_current_plugins "$config_file")
    
    if [[ ${#current_plugins[@]} -gt 0 ]]; then
      echo "\033[1mEnabled Plugins:\033[0m"
      for plugin in "${current_plugins[@]}"; do
        echo "  • $plugin"
      done
    else
      echo "\033[1m\033[33mNo plugins enabled\033[0m"
    fi
    echo
  else
    echo "\033[1m\033[33m⚠️  No OSH Configuration Found\033[0m"
    echo
  fi
  
  # Show backup information
  if command -v list_backups_detailed >/dev/null 2>&1; then
    list_backups_detailed "$config_file"
  else
    # Fallback backup listing
    local backups
    mapfile -t backups < <(find "$(dirname "$config_file")" -name "$(basename "$config_file").osh-backup.*" -type f 2>/dev/null | sort -r)
    
    if [[ ${#backups[@]} -gt 0 ]]; then
      echo "\033[1m📦 Available Backups:\033[0m"
      for backup in "${backups[@]:0:3}"; do
        local backup_name=$(basename "$backup")
        local backup_date=$(echo "$backup_name" | grep -o '[0-9]\{8\}_[0-9]\{6\}' || echo "unknown")
        echo "  • $backup_name (date: $backup_date)"
      done
      
      if [[ ${#backups[@]} -gt 3 ]]; then
        echo "  \033[2m... and $((${#backups[@]} - 3)) more\033[0m"
      fi
    else
      echo "\033[1m📦 No backups found\033[0m"
    fi
    echo
  fi
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
