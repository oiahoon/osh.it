#!/usr/bin/env bash
# Fix OSH upgrade.sh missing function issue
# This script fixes the missing show_progress_with_file function in upgrade.sh

set -e

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
OSH_REPO_BASE="${OSH_REPO_BASE:-https://raw.githubusercontent.com/oiahoon/osh.it/main}"

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

# Main fix function
fix_upgrade_script() {
  setup_colors
  
  log_info "🔧 Fixing OSH upgrade script..."
  
  # Check if OSH is installed
  if [[ ! -d "$OSH_DIR" ]]; then
    log_error "OSH is not installed at $OSH_DIR"
    exit 1
  fi
  
  # Create backup of current upgrade.sh
  if [[ -f "$OSH_DIR/upgrade.sh" ]]; then
    local backup_file="$OSH_DIR/upgrade.sh.backup.$(date +%Y%m%d_%H%M%S)"
    log_info "📦 Creating backup: $backup_file"
    cp "$OSH_DIR/upgrade.sh" "$backup_file"
  fi
  
  # Download the fixed upgrade.sh
  log_info "📥 Downloading fixed upgrade script..."
  if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "${OSH_REPO_BASE}/upgrade.sh" -o "$OSH_DIR/upgrade.sh"; then
      log_success "✅ Fixed upgrade script downloaded successfully"
    else
      log_error "❌ Failed to download fixed upgrade script"
      exit 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    if wget -q "${OSH_REPO_BASE}/upgrade.sh" -O "$OSH_DIR/upgrade.sh"; then
      log_success "✅ Fixed upgrade script downloaded successfully"
    else
      log_error "❌ Failed to download fixed upgrade script"
      exit 1
    fi
  else
    log_error "❌ Neither curl nor wget is available"
    exit 1
  fi
  
  # Set proper permissions
  chmod +x "$OSH_DIR/upgrade.sh"
  
  log_success "🎉 OSH upgrade script has been fixed!"
  log_info "💡 You can now run 'osh upgrade' again"
}

# Run the fix
fix_upgrade_script "$@"
