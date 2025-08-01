#!/usr/bin/env bash
# OSH Upgrade Script - Optimized for End Users
# Version: 1.1.0
# Author: oiahoon
# License: MIT

set -e  # Exit on any error

# Configuration
OSH_REPO_BASE="${OSH_REPO_BASE:-https://raw.githubusercontent.com/oiahoon/osh.it/main}"
OSH_DIR="${OSH:-$HOME/.osh}"

# Cyberpunk color system for upgrade
setup_colors() {
  if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    # Cyberpunk color palette
    CYBER_NEON_BLUE=$'\033[38;2;0;255;255m'     # Electric blue
    CYBER_MATRIX_GREEN=$'\033[38;2;0;255;65m'   # Matrix green  
    CYBER_ALERT_RED=$'\033[38;2;255;0;64m'      # Alert red
    CYBER_PURPLE=$'\033[38;2;138;43;226m'       # UV purple
    CYBER_ORANGE=$'\033[38;2;255;165;0m'        # Neon orange
    CYBER_PINK=$'\033[38;2;255;20;147m'         # Hot pink
    CYBER_WHITE=$'\033[38;2;255;255;255m'       # Pure white
    CYBER_DARK_GRAY=$'\033[38;2;64;64;64m'      # Dark gray
    CYBER_BOLD=$'\033[1m'
    CYBER_DIM=$'\033[2m'
    CYBER_RESET=$'\033[0m'
  else
    # Fallback to empty strings for non-color terminals
    CYBER_NEON_BLUE=""
    CYBER_MATRIX_GREEN=""
    CYBER_ALERT_RED=""
    CYBER_PURPLE=""
    CYBER_ORANGE=""
    CYBER_PINK=""
    CYBER_WHITE=""
    CYBER_DARK_GRAY=""
    CYBER_BOLD=""
    CYBER_DIM=""
    CYBER_RESET=""
  fi
}

# Cyberpunk logging functions
log_info() { 
  printf "%b[%bINFO%b] %s%b\n" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_NEON_BLUE}" "${CYBER_RESET}${CYBER_NEON_BLUE}" "$*" "${CYBER_RESET}"
}
log_success() { 
  printf "%b[%bOK%b] %s%b\n" "${CYBER_MATRIX_GREEN}${CYBER_BOLD}" "${CYBER_MATRIX_GREEN}" "${CYBER_RESET}${CYBER_MATRIX_GREEN}" "$*" "${CYBER_RESET}"
}
log_warning() { 
  printf "%b[%bWARN%b] %s%b\n" "${CYBER_ORANGE}${CYBER_BOLD}" "${CYBER_ORANGE}" "${CYBER_RESET}${CYBER_ORANGE}" "$*" "${CYBER_RESET}"
}
log_error() { 
  printf "%b[%bERROR%b] %s%b\n" "${CYBER_ALERT_RED}${CYBER_BOLD}" "${CYBER_ALERT_RED}" "${CYBER_RESET}${CYBER_ALERT_RED}" "$*" "${CYBER_RESET}" >&2
}

# Cyberpunk download function with progress
download_file() {
  local url="$1"
  local output="$2"
  local filename=$(basename "$output")
  
  printf "%bUPDATE%b %s... " "${CYBER_PURPLE}${CYBER_BOLD}" "${CYBER_RESET}" "$filename"
  
  if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$url" -o "$output" 2>/dev/null; then
      printf "%b[DONE]%b\n" "${CYBER_MATRIX_GREEN}${CYBER_BOLD}" "${CYBER_RESET}"
      return 0
    else
      printf "%b[FAIL]%b\n" "${CYBER_ALERT_RED}${CYBER_BOLD}" "${CYBER_RESET}"
      return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if wget -q "$url" -O "$output" 2>/dev/null; then
      printf "%b[DONE]%b\n" "${CYBER_MATRIX_GREEN}${CYBER_BOLD}" "${CYBER_RESET}"
      return 0
    else
      printf "%b[FAIL]%b\n" "${CYBER_ALERT_RED}${CYBER_BOLD}" "${CYBER_RESET}"
      return 1
    fi
  else
    printf "%b[ERROR]%b\n" "${CYBER_ALERT_RED}${CYBER_BOLD}" "${CYBER_RESET}"
    log_error "Neither curl nor wget is available"
    return 1
  fi
}

# Silent download function for version checking
download_silent() {
  local url="$1"
  local output="$2"
  
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output" 2>/dev/null
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$output" 2>/dev/null
  else
    return 1
  fi
}

# Cyberpunk progress bar function
show_progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  
  printf "\r%bPROGRESS%b [" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}${CYBER_NEON_BLUE}"
  printf "%*s" $filled | tr ' ' '█'
  printf "%*s" $((width - filled)) | tr ' ' '░'
  printf "] %d%% (%d/%d)%b" $percentage $current $total "${CYBER_RESET}"
  
  if [[ $current -eq $total ]]; then
    printf "\n"
  fi
}

# Cyberpunk progress bar function with file info
show_progress_with_file() {
  local current=$1
  local total=$2
  local filename="$3"
  local status="$4"  # "downloading", "success", "failed"
  local width=30
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  
  # Clear the line and show progress
  printf "\r\033[K"  # Clear entire line
  
  # Show cyberpunk progress bar
  printf "%bSYNC%b [" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}${CYBER_NEON_BLUE}"
  printf "%*s" $filled | tr ' ' '█'
  printf "%*s" $((width - filled)) | tr ' ' '░'
  printf "] %3d%% (%d/%d)%b " $percentage $current $total "${CYBER_RESET}"
  
  # Show current file and status with cyberpunk styling
  case "$status" in
    "downloading")
      printf "%bDL%b %s..." "${CYBER_PURPLE}${CYBER_BOLD}" "${CYBER_RESET}" "$filename"
      ;;
    "success")
      printf "%bOK%b %s" "${CYBER_MATRIX_GREEN}${CYBER_BOLD}" "${CYBER_RESET}" "$filename"
      ;;
    "failed")
      printf "%bFAIL%b %s" "${CYBER_ALERT_RED}${CYBER_BOLD}" "${CYBER_RESET}" "$filename"
      ;;
  esac
  
  # If completed, add newline
  if [[ $current -eq $total ]]; then
    printf "\n"
  fi
}

# Essential files to update (same as installation)
declare -a ESSENTIAL_FILES=(
  "osh.sh"
  "upgrade.sh"
  "VERSION"
  "LICENSE"
  ".zshrc.example"
  "bin/osh"
  "scripts/osh_cli.sh"
  "scripts/osh_doctor.sh"
  "scripts/osh_plugin_manager.sh"
  "scripts/fix_installation.sh"
  "scripts/fix_permissions.sh"
  "scripts/fix_alias_conflicts.sh"
  "lib/colors.zsh"
  "lib/common.zsh"
  "lib/display.sh"
  "lib/lazy_loader.zsh"
  "lib/lazy_stubs.zsh"
  "lib/vintage.zsh"
  "lib/cache.zsh"
  "lib/plugin_manager.zsh"
  "lib/plugin_aliases.zsh"
  "lib/osh_config.zsh"
  "lib/config_manager.zsh"
)

# Check if OSH is installed
check_installation() {
  if [[ ! -d "$OSH_DIR" ]]; then
    log_error "OSH is not installed at $OSH_DIR"
    log_info "Please run the installation script first:"
    log_info "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)\""
    exit 1
  fi
  
  if [[ ! -f "$OSH_DIR/osh.sh" ]]; then
    log_error "OSH installation appears to be corrupted"
    exit 1
  fi
}

# Get current and latest versions
check_versions() {
  log_info "VERSION CHECK - Scanning remote repository..."
  
  # Get current version
  if [[ -f "$OSH_DIR/VERSION" ]]; then
    CURRENT_VERSION=$(cat "$OSH_DIR/VERSION" 2>/dev/null | tr -d '\n\r' || echo "unknown")
  else
    CURRENT_VERSION="unknown"
  fi
  
  # Get latest version using silent download
  local temp_version="/tmp/osh_latest_version"
  if download_silent "${OSH_REPO_BASE}/VERSION" "$temp_version"; then
    LATEST_VERSION=$(cat "$temp_version" 2>/dev/null | tr -d '\n\r' || echo "unknown")
    rm -f "$temp_version" 2>/dev/null || true
  else
    log_error "NETWORK ERROR - Failed to check latest version from remote repository"
    log_info "HINT - Please check your internet connection and try again"
    exit 1
  fi
  
  log_info "CURRENT - Version: $CURRENT_VERSION"
  log_info "REMOTE  - Version: $LATEST_VERSION"
  
  # Compare versions
  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]] && [[ "$CURRENT_VERSION" != "unknown" ]]; then
    echo
    log_success "SYSTEM STATUS - OSH.IT is already up to date!"
    log_info "CURRENT BUILD - You are running the latest version: $CURRENT_VERSION"
    echo
    log_info "TROUBLESHOOTING - If you're experiencing issues, try:"
    log_info "  >> osh doctor          - Run diagnostics"
    log_info "  >> osh doctor --fix     - Auto-fix common issues"
    log_info "  >> osh status           - Check system status"
    echo
    log_info "NETWORK RESOURCES:"
    log_info "  >> Official Website: https://oiahoon.github.io/osh.it/"
    log_info "  >> Documentation: https://github.com/oiahoon/osh.it/wiki"
    log_info "  >> Support: https://github.com/oiahoon/osh.it/issues"
    echo
    exit 0
  elif [[ "$CURRENT_VERSION" == "unknown" ]]; then
    log_warning "VERSION UNKNOWN - Could not determine current version, proceeding with upgrade..."
  else
    log_info "UPDATE AVAILABLE - $CURRENT_VERSION >> $LATEST_VERSION"
  fi
}

# Create backup
create_backup() {
  local backup_dir="${OSH_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
  log_info "BACKUP INIT - Creating backup: $backup_dir"
  
  if ! cp -r "$OSH_DIR" "$backup_dir"; then
    log_error "Failed to create backup"
    exit 1
  fi
  
  log_success "BACKUP COMPLETE - Backup created successfully"
}

# Update essential files
update_files() {
  log_info "FILE SYNC - Updating OSH essential files..."
  
  local failed_files=()
  local total_files=${#ESSENTIAL_FILES[@]}
  local current=0
  
  for file in "${ESSENTIAL_FILES[@]}"; do
    current=$((current + 1))
    local filename=$(basename "$file")
    
    # Show downloading status
    show_progress_with_file $current $total_files "$filename" "downloading"
    
    local url="${OSH_REPO_BASE}/${file}"
    local output="${OSH_DIR}/${file}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    # Download and update status
    if download_file "$url" "$output"; then
      show_progress_with_file $current $total_files "$filename" "success"
      sleep 0.1  # Brief pause to show success
    else
      show_progress_with_file $current $total_files "$filename" "failed"
      failed_files+=("$file")
      sleep 0.3  # Longer pause for errors
    fi
  done
  
  echo
  
  if [[ ${#failed_files[@]} -gt 0 ]]; then
    log_warning "SYNC ERROR - Some files failed to update:"
    for file in "${failed_files[@]}"; do
      log_warning "  - $file"
    done
    log_info "RETRY - You can try running the upgrade again"
  else
    log_success "SYNC COMPLETE - All files updated successfully!"
  fi
}

# Set permissions
fix_permissions() {
  log_info "PERMISSIONS - Fixing file permissions..."
  
  chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
  chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
  chmod +x "$OSH_DIR/bin/osh" 2>/dev/null || true
  chmod +x "$OSH_DIR/scripts/"*.sh 2>/dev/null || true
  
  find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true
  
  log_success "PERMISSIONS OK - File permissions fixed"
}

# Update upgrade script itself first
update_upgrade_script() {
  log_info "SELF UPDATE - Ensuring upgrade script is up to date..."
  local temp_upgrade="/tmp/osh_upgrade_latest.sh"
  
  if download_silent "${OSH_REPO_BASE}/upgrade.sh" "$temp_upgrade"; then
    # Verify downloaded file is valid
    if [[ -s "$temp_upgrade" ]] && bash -n "$temp_upgrade" 2>/dev/null; then
      # Check if current script is different from latest
      if ! diff -q "$0" "$temp_upgrade" >/dev/null 2>&1; then
        log_info "📥 Updating upgrade script to latest version..."
        
        # Backup current script
        cp "$OSH_DIR/upgrade.sh" "$OSH_DIR/upgrade.sh.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        
        # Replace with latest version
        cp "$temp_upgrade" "$OSH_DIR/upgrade.sh"
        chmod +x "$OSH_DIR/upgrade.sh"
        
        log_success "SCRIPT UPDATED - Upgrade script updated, restarting..."
        echo
        
        # Re-execute with updated script
        exec "$OSH_DIR/upgrade.sh" "$@"
      else
        log_success "SCRIPT OK - Upgrade script is already up to date"
      fi
    else
      log_warning "SCRIPT ERROR - Downloaded upgrade script appears invalid, continuing with current version"
    fi
    
    # Clean up temp file
    rm -f "$temp_upgrade" 2>/dev/null || true
  else
    log_warning "DOWNLOAD ERROR - Could not download latest upgrade script, continuing with current version"
  fi
}

# Main upgrade function
main() {
  setup_colors
  
  log_info "UPGRADE INIT - OSH Upgrade System Starting..."
  log_info "TARGET PATH - OSH directory: $OSH_DIR"
  echo
  
  check_installation
  update_upgrade_script
  check_versions
  create_backup
  update_files
  fix_permissions
  
  echo
  log_success "UPGRADE COMPLETE - OSH upgrade completed successfully!"
  log_success "NEW VERSION - Updated to version: $LATEST_VERSION"
  echo
  log_info "NEXT STEP - Restart your terminal or run: source ~/.zshrc"
  echo
  log_info "NETWORK RESOURCES:"
  log_info "  • Official Website: https://oiahoon.github.io/osh.it/"
  log_info "  • Documentation: https://github.com/oiahoon/osh.it/wiki"
  log_info "  • Support: https://github.com/oiahoon/osh.it/issues"
  echo
  log_success "SYSTEM READY - Happy shell customization!"
}

# Export upgrade function for global access
upgrade_myshell() {
  main "$@"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
