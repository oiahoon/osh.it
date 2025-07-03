#!/usr/bin/env bash
# OSH Uninstallation Script
# Safe removal of OSH with configuration cleanup
# Version: 1.0.0
# Author: oiahoon
# License: MIT

set -e  # Exit on any error

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
SHELL_CONFIG_FILE="${SHELL_CONFIG_FILE:-$HOME/.zshrc}"

# Uninstall options
DRY_RUN=false
KEEP_CONFIG=false
KEEP_BACKUPS=false
INTERACTIVE=true

# Configuration markers
OSH_CONFIG_MARKER_START="# === OSH Configuration Start ==="
OSH_CONFIG_MARKER_END="# === OSH Configuration End ==="

# Colors
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  NORMAL="$(tput sgr0)"
else
  RED="" GREEN="" YELLOW="" BLUE="" BOLD="" DIM="" NORMAL=""
fi

# Logging functions
log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*" >&2; }
log_dry_run() { printf "${BLUE}🔍 [DRY RUN] %s${NORMAL}\n" "$*"; }

# Check if OSH configuration exists
has_osh_config() {
  local config_file="$1"
  [[ -f "$config_file" ]] && grep -q "$OSH_CONFIG_MARKER_START" "$config_file"
}

# Create backup before removal
create_backup() {
  local config_file="$1"
  local backup_file="${config_file}.osh-uninstall-backup.$(date +%Y%m%d_%H%M%S)"
  
  if [[ ! -f "$config_file" ]]; then
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would create backup: $backup_file"
    return 0
  fi
  
  if cp "$config_file" "$backup_file"; then
    log_success "Backup created: $backup_file"
    echo "$backup_file"
    return 0
  else
    log_error "Failed to create backup of $config_file"
    return 1
  fi
}

# Remove OSH configuration from shell config file
remove_osh_config() {
  local config_file="$1"
  
  if [[ ! -f "$config_file" ]]; then
    log_warning "Config file $config_file does not exist"
    return 0
  fi
  
  if ! has_osh_config "$config_file"; then
    log_warning "No OSH configuration found in $config_file"
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would remove OSH configuration from $config_file"
    return 0
  fi
  
  # Create backup first
  local backup_file
  backup_file=$(create_backup "$config_file")
  if [[ $? -ne 0 ]]; then
    return 1
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
    log_success "OSH configuration removed from $config_file"
    if [[ -n "$backup_file" ]]; then
      log_info "Backup available at: $backup_file"
    fi
  else
    log_error "Failed to remove OSH configuration"
    rm -f "$temp_file"
    return 1
  fi
  
  return 0
}

# Remove OSH directory
remove_osh_directory() {
  local osh_dir="$1"
  
  if [[ ! -d "$osh_dir" ]]; then
    log_warning "OSH directory $osh_dir does not exist"
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would remove OSH directory: $osh_dir"
    return 0
  fi
  
  log_info "Removing OSH directory: $osh_dir"
  
  if rm -rf "$osh_dir"; then
    log_success "OSH directory removed successfully"
  else
    log_error "Failed to remove OSH directory"
    return 1
  fi
  
  return 0
}

# Clean up OSH-related environment variables and aliases
cleanup_environment() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would clean up OSH environment variables"
    return 0
  fi
  
  # Unset OSH-related environment variables
  unset OSH OSH_CUSTOM OSH_DEBUG
  
  # Remove OSH-related aliases (if any were set globally)
  unalias upgrade_myshell 2>/dev/null || true
  unalias oshconfig 2>/dev/null || true
  
  log_info "Environment variables and aliases cleaned up"
}

# Remove OSH configuration backups
remove_backups() {
  local config_file="$1"
  local config_dir=$(dirname "$config_file")
  local config_name=$(basename "$config_file")
  
  local backups
  mapfile -t backups < <(find "$config_dir" -name "${config_name}.osh-backup.*" -type f 2>/dev/null)
  
  if [[ ${#backups[@]} -eq 0 ]]; then
    log_info "No OSH configuration backups found"
    return 0
  fi
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would remove ${#backups[@]} OSH configuration backups"
    for backup in "${backups[@]}"; do
      log_dry_run "  - $(basename "$backup")"
    done
    return 0
  fi
  
  log_info "Removing ${#backups[@]} OSH configuration backups..."
  
  local removed=0
  for backup in "${backups[@]}"; do
    if rm -f "$backup"; then
      removed=$((removed + 1))
      log_info "  Removed: $(basename "$backup")"
    else
      log_warning "  Failed to remove: $(basename "$backup")"
    fi
  done
  
  log_success "Removed $removed OSH configuration backups"
}

# Show what will be uninstalled
show_uninstall_preview() {
  echo "${BOLD}${BLUE}🔍 OSH Uninstallation Preview${NORMAL}"
  echo
  
  # Check OSH directory
  if [[ -d "$OSH_DIR" ]]; then
    local dir_size=$(du -sh "$OSH_DIR" 2>/dev/null | cut -f1 || echo "unknown")
    echo "${BOLD}OSH Directory:${NORMAL} $OSH_DIR ${DIM}($dir_size)${NORMAL}"
    echo "  ✅ Will be removed"
  else
    echo "${BOLD}OSH Directory:${NORMAL} $OSH_DIR"
    echo "  ⚠️  Not found"
  fi
  echo
  
  # Check configuration
  if has_osh_config "$SHELL_CONFIG_FILE"; then
    echo "${BOLD}Shell Configuration:${NORMAL} $SHELL_CONFIG_FILE"
    echo "  ✅ OSH configuration found - will be removed"
    echo "  📦 Backup will be created automatically"
  else
    echo "${BOLD}Shell Configuration:${NORMAL} $SHELL_CONFIG_FILE"
    echo "  ⚠️  No OSH configuration found"
  fi
  echo
  
  # Check backups
  local config_dir=$(dirname "$SHELL_CONFIG_FILE")
  local config_name=$(basename "$SHELL_CONFIG_FILE")
  local backup_count
  backup_count=$(find "$config_dir" -name "${config_name}.osh-backup.*" -type f 2>/dev/null | wc -l)
  
  echo "${BOLD}Configuration Backups:${NORMAL} $backup_count found"
  if [[ "$KEEP_BACKUPS" == "true" ]]; then
    echo "  📦 Will be preserved"
  else
    echo "  🗑️  Will be removed"
  fi
  echo
}

# Interactive confirmation
confirm_uninstall() {
  if [[ "$INTERACTIVE" != "true" ]]; then
    return 0
  fi
  
  echo "${BOLD}${YELLOW}⚠️  Warning: This will completely remove OSH from your system!${NORMAL}"
  echo
  
  show_uninstall_preview
  
  echo "${BOLD}What will happen:${NORMAL}"
  echo "  1. Remove OSH directory and all files"
  echo "  2. Remove OSH configuration from shell config file"
  echo "  3. Create backup of current shell configuration"
  if [[ "$KEEP_BACKUPS" != "true" ]]; then
    echo "  4. Remove existing OSH configuration backups"
  fi
  echo "  5. Clean up environment variables"
  echo
  
  read -r "confirm?Are you sure you want to uninstall OSH? (y/N): "
  
  if [[ ! "$confirm" =~ ^[Yy] ]]; then
    log_info "Uninstallation cancelled by user"
    exit 0
  fi
}

# Main uninstallation function
uninstall_osh() {
  log_info "Starting OSH uninstallation..."
  echo
  
  # Remove OSH configuration from shell config
  if [[ "$KEEP_CONFIG" != "true" ]]; then
    remove_osh_config "$SHELL_CONFIG_FILE"
    echo
  fi
  
  # Remove OSH directory
  remove_osh_directory "$OSH_DIR"
  echo
  
  # Remove configuration backups
  if [[ "$KEEP_BACKUPS" != "true" ]]; then
    remove_backups "$SHELL_CONFIG_FILE"
    echo
  fi
  
  # Clean up environment
  cleanup_environment
  echo
  
  log_success "OSH uninstallation completed successfully!"
}

# Show completion message
show_completion() {
  echo
  echo "${BOLD}${GREEN}🎉 OSH Uninstallation Complete!${NORMAL}"
  echo
  echo "${BOLD}${BLUE}What was removed:${NORMAL}"
  echo "  ✅ OSH framework files and directory"
  if [[ "$KEEP_CONFIG" != "true" ]]; then
    echo "  ✅ OSH configuration from shell config file"
  fi
  if [[ "$KEEP_BACKUPS" != "true" ]]; then
    echo "  ✅ OSH configuration backups"
  fi
  echo "  ✅ Environment variables and aliases"
  echo
  
  if [[ "$KEEP_CONFIG" == "true" ]]; then
    echo "${BOLD}${YELLOW}⚠️  Note:${NORMAL} OSH configuration remains in $SHELL_CONFIG_FILE"
    echo "You may want to remove it manually or comment it out."
    echo
  fi
  
  echo "${BOLD}${BLUE}Next steps:${NORMAL}"
  echo "  1. Restart your terminal or run: ${CYAN}source $SHELL_CONFIG_FILE${NORMAL}"
  echo "  2. Your shell will return to its previous configuration"
  echo
  
  if [[ "$KEEP_BACKUPS" == "true" ]]; then
    echo "${BOLD}${BLUE}Backups preserved:${NORMAL}"
    echo "  Configuration backups are still available if you need to restore anything."
    echo
  fi
  
  echo "${BOLD}${BLUE}To reinstall OSH:${NORMAL}"
  echo "  Run the installation script from: ${CYAN}https://github.com/oiahoon/osh${NORMAL}"
  echo
}

# Show help
show_help() {
  cat << EOF
${BOLD}OSH Uninstallation Script${NORMAL}

${BOLD}DESCRIPTION:${NORMAL}
  Safely remove OSH (Oh Shell) framework from your system with automatic
  backup creation and configuration cleanup.

${BOLD}USAGE:${NORMAL}
  $0 [OPTIONS]

${BOLD}OPTIONS:${NORMAL}
  --dry-run              Preview uninstallation without making changes
  --yes                  Non-interactive uninstallation
  --keep-config          Keep OSH configuration in shell config file
  --keep-backups         Preserve existing configuration backups
  --help                 Show this help message

${BOLD}SAFETY FEATURES:${NORMAL}
  • Automatic backup creation before any changes
  • Preview mode to see what will be removed
  • Interactive confirmation by default
  • Selective removal options

${BOLD}EXAMPLES:${NORMAL}
  # Interactive uninstallation (recommended)
  $0

  # Preview what will be removed
  $0 --dry-run

  # Non-interactive uninstallation
  $0 --yes

  # Remove OSH but keep configuration
  $0 --keep-config

  # Remove OSH but preserve backups
  $0 --keep-backups

${BOLD}WHAT GETS REMOVED:${NORMAL}
  • OSH directory and all framework files
  • OSH configuration block from shell config file
  • OSH-related environment variables and aliases
  • OSH configuration backups (unless --keep-backups is used)

${BOLD}WHAT IS PRESERVED:${NORMAL}
  • Your original shell configuration (outside OSH blocks)
  • Custom aliases and functions not related to OSH
  • Other shell frameworks or configurations

For more information, visit: https://github.com/oiahoon/osh
EOF
}

# Parse command line arguments
parse_arguments() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --yes)
        INTERACTIVE=false
        shift
        ;;
      --keep-config)
        KEEP_CONFIG=true
        shift
        ;;
      --keep-backups)
        KEEP_BACKUPS=true
        shift
        ;;
      --help)
        show_help
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
    esac
  done
}

# Main function
main() {
  parse_arguments "$@"
  
  # Show header
  echo "${BOLD}${RED}🗑️  OSH Uninstallation${NORMAL}"
  echo
  
  # Check if OSH is installed
  if [[ ! -d "$OSH_DIR" ]] && ! has_osh_config "$SHELL_CONFIG_FILE"; then
    log_warning "OSH does not appear to be installed"
    echo "  • OSH directory not found: $OSH_DIR"
    echo "  • No OSH configuration in: $SHELL_CONFIG_FILE"
    echo
    echo "If you believe this is incorrect, you can:"
    echo "  • Specify custom paths with environment variables"
    echo "  • Use --dry-run to see what would be removed"
    exit 0
  fi
  
  # Show preview if dry run
  if [[ "$DRY_RUN" == "true" ]]; then
    show_uninstall_preview
    log_info "This was a dry run - no changes were made"
    exit 0
  fi
  
  # Confirm uninstallation
  confirm_uninstall
  
  # Perform uninstallation
  uninstall_osh
  
  # Show completion message
  show_completion
}

# Run main function
main "$@"
