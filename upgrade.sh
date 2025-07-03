#!/usr/bin/env bash
# OSH Upgrade Script - Optimized for End Users
# Version: 1.1.0
# Author: oiahoon
# License: MIT

set -e  # Exit on any error

# Configuration
OSH_REPO_BASE="${OSH_REPO_BASE:-https://raw.githubusercontent.com/oiahoon/osh/master}"
OSH_DIR="${OSH:-$HOME/.osh}"

# Color definitions
setup_colors() {
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    local ncolors
    ncolors=$(tput colors 2>/dev/null || echo 0)
    if [[ $ncolors -ge 8 ]]; then
      RED="$(tput setaf 1)"
      GREEN="$(tput setaf 2)"
      YELLOW="$(tput setaf 3)"
      BLUE="$(tput setaf 4)"
      BOLD="$(tput bold)"
      NORMAL="$(tput sgr0)"
    fi
  fi

  RED="${RED:-}"
  GREEN="${GREEN:-}"
  YELLOW="${YELLOW:-}"
  BLUE="${BLUE:-}"
  BOLD="${BOLD:-}"
  NORMAL="${NORMAL:-}"
}

# Logging functions
log_info() { printf "${BLUE}%s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}%s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}%s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}%s${NORMAL}\n" "$*" >&2; }

# Download function
download_file() {
  local url="$1"
  local output="$2"
  
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$output"
  else
    log_error "Neither curl nor wget is available"
    return 1
  fi
}

# Essential files to update (same as installation)
declare -a ESSENTIAL_FILES=(
  "osh.sh"
  "upgrade.sh"
  "VERSION"
  "LICENSE"
  ".zshrc.example"
  "lib/colors.zsh"
  "lib/common.zsh"
  "lib/display.sh"
  "lib/lazy_stubs.zsh"
  "plugins/proxy/proxy.plugin.zsh"
  "plugins/sysinfo/sysinfo.plugin.zsh"
  "plugins/weather/weather.plugin.zsh"
  "plugins/taskman/taskman.plugin.zsh"
  "plugins/taskman/taskman_ui.zsh"
  "plugins/acw/acw.plugin.zsh"
  "plugins/fzf/fzf.plugin.zsh"
  "plugins/weather/completions/_weather"
  "plugins/taskman/config/taskman.conf"
)

# Check if OSH is installed
check_installation() {
  if [[ ! -d "$OSH_DIR" ]]; then
    log_error "OSH is not installed at $OSH_DIR"
    log_info "Please run the installation script first:"
    log_info "sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh/master/install.sh)\""
    exit 1
  fi
  
  if [[ ! -f "$OSH_DIR/osh.sh" ]]; then
    log_error "OSH installation appears to be corrupted"
    exit 1
  fi
}

# Get current and latest versions
check_versions() {
  log_info "🔍 Checking versions..."
  
  # Get current version
  if [[ -f "$OSH_DIR/VERSION" ]]; then
    CURRENT_VERSION=$(cat "$OSH_DIR/VERSION" 2>/dev/null || echo "unknown")
  else
    CURRENT_VERSION="unknown"
  fi
  
  # Get latest version
  if ! LATEST_VERSION=$(download_file "${OSH_REPO_BASE}/VERSION" /dev/stdout 2>/dev/null); then
    log_error "Failed to check latest version"
    exit 1
  fi
  
  log_info "📦 Current version: $CURRENT_VERSION"
  log_info "🆕 Latest version: $LATEST_VERSION"
  
  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    log_success "✅ OSH is already up to date!"
    exit 0
  fi
}

# Create backup
create_backup() {
  local backup_dir="${OSH_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
  log_info "📦 Creating backup: $backup_dir"
  
  if ! cp -r "$OSH_DIR" "$backup_dir"; then
    log_error "Failed to create backup"
    exit 1
  fi
  
  log_success "✅ Backup created successfully"
}

# Update essential files
update_files() {
  log_info "📥 Updating OSH essential files..."
  
  local failed_files=()
  local total_files=${#ESSENTIAL_FILES[@]}
  local current=0
  
  for file in "${ESSENTIAL_FILES[@]}"; do
    current=$((current + 1))
    printf "\r${BLUE}[%d/%d]${NORMAL} Updating %s..." "$current" "$total_files" "$file"
    
    local url="${OSH_REPO_BASE}/${file}"
    local output="${OSH_DIR}/${file}"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    if ! download_file "$url" "$output"; then
      failed_files+=("$file")
    fi
  done
  
  echo  # New line after progress
  
  if [[ ${#failed_files[@]} -gt 0 ]]; then
    log_error "❌ Failed to update some files:"
    printf '%s\n' "${failed_files[@]}"
    exit 1
  fi
  
  log_success "✅ All files updated successfully"
  log_info "💡 Excluded: docs/, tools/, .github/ (not needed for users)"
}

# Set permissions
fix_permissions() {
  log_info "🔧 Fixing permissions..."
  
  chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
  chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
  
  find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true
  find "$OSH_DIR" -name "*.sh" -exec chmod 644 {} \; 2>/dev/null || true
  
  log_success "✅ Permissions fixed"
}

# Main upgrade function
main() {
  setup_colors
  
  log_info "🚀 OSH Upgrade Starting..."
  log_info "📁 OSH directory: $OSH_DIR"
  echo
  
  check_installation
  check_versions
  create_backup
  update_files
  fix_permissions
  
  echo
  log_success "🎉 OSH upgrade completed successfully!"
  log_success "📦 Updated to version: $LATEST_VERSION"
  echo
  log_info "💡 Restart your terminal or run: source ~/.zshrc"
  echo
  log_success "Happy shell customization! 🐚✨"
}

# Export upgrade function for global access
upgrade_myshell() {
  main "$@"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
