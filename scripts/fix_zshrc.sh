#!/usr/bin/env zsh
# OSH.IT .zshrc Fix Script
# Fixes the "-e" bug in shell configuration

set -e

# Colors
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED="" GREEN="" YELLOW="" BLUE="" BOLD="" NORMAL=""
fi

# Logging functions
log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*"; }

# Configuration
ZSHRC_FILE="$HOME/.zshrc"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"

show_header() {
  echo
  echo "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════╗${NORMAL}"
  echo "${BOLD}${BLUE}║                    OSH.IT .zshrc Fix Tool                    ║${NORMAL}"
  echo "${BOLD}${BLUE}║              Fixes the '-e' configuration bug                ║${NORMAL}"
  echo "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════╝${NORMAL}"
  echo
}

check_issue() {
  log_info "Checking for .zshrc configuration issue..."
  
  if [[ ! -f "$ZSHRC_FILE" ]]; then
    log_error ".zshrc file not found: $ZSHRC_FILE"
    return 1
  fi
  
  # Check if the bug exists
  if grep -q "^-e # OSH.IT Configuration" "$ZSHRC_FILE"; then
    log_warning "Found '-e' bug in $ZSHRC_FILE"
    return 0
  else
    log_success "No '-e' bug found in $ZSHRC_FILE"
    return 1
  fi
}

fix_zshrc() {
  log_info "Fixing .zshrc configuration..."
  
  # Create backup
  local backup_file="${ZSHRC_FILE}${BACKUP_SUFFIX}"
  if cp "$ZSHRC_FILE" "$backup_file"; then
    log_success "Created backup: $backup_file"
  else
    log_error "Failed to create backup"
    return 1
  fi
  
  # Fix the issue by removing the problematic line and replacing it
  local temp_file="/tmp/zshrc_fix_$$"
  
  # Process the file line by line
  local in_osh_block=false
  local fixed=false
  
  while IFS= read -r line; do
    if [[ "$line" == "-e # OSH.IT Configuration - Added by installer" ]]; then
      # Replace the buggy line with the correct one
      echo "# OSH.IT Configuration - Added by installer"
      fixed=true
    else
      echo "$line"
    fi
  done < "$ZSHRC_FILE" > "$temp_file"
  
  if [[ "$fixed" == "true" ]]; then
    # Replace the original file
    if mv "$temp_file" "$ZSHRC_FILE"; then
      log_success "Fixed .zshrc configuration"
      log_info "Backup saved as: $backup_file"
      return 0
    else
      log_error "Failed to replace .zshrc file"
      rm -f "$temp_file"
      return 1
    fi
  else
    log_warning "No fixes were needed"
    rm -f "$temp_file"
    return 1
  fi
}

verify_fix() {
  log_info "Verifying the fix..."
  
  if ! grep -q "^-e # OSH.IT Configuration" "$ZSHRC_FILE" && \
     grep -q "^# OSH.IT Configuration - Added by installer" "$ZSHRC_FILE"; then
    log_success "Fix verified successfully!"
    return 0
  else
    log_error "Fix verification failed"
    return 1
  fi
}

show_next_steps() {
  echo
  echo "${BOLD}${GREEN}🎉 Fix completed successfully!${NORMAL}"
  echo
  echo "${BOLD}${BLUE}📋 Next Steps:${NORMAL}"
  echo "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NORMAL}"
  echo "  2. Test OSH.IT functionality: ${YELLOW}osh_info${NORMAL}"
  echo "  3. Run health check: ${YELLOW}osh doctor${NORMAL}"
  echo
  echo "${BOLD}${BLUE}📁 Backup Information:${NORMAL}"
  echo "  Your original .zshrc was backed up with timestamp"
  echo "  You can restore it if needed: ${YELLOW}cp ~/.zshrc.backup.* ~/.zshrc${NORMAL}"
  echo
}

show_help() {
  cat << EOF
${BOLD}OSH.IT .zshrc Fix Tool${NORMAL}

This tool fixes the '-e' bug in .zshrc configuration that was introduced
in an earlier version of the OSH.IT installer.

${BOLD}USAGE:${NORMAL}
  fix_zshrc.sh [OPTIONS]

${BOLD}OPTIONS:${NORMAL}
  --check, -c       Only check for the issue, don't fix
  --help, -h        Show this help message

${BOLD}WHAT IT FIXES:${NORMAL}
  Replaces: "-e # OSH.IT Configuration - Added by installer"
  With:     "# OSH.IT Configuration - Added by installer"

${BOLD}SAFETY:${NORMAL}
  • Creates automatic backup before making changes
  • Verifies fix after completion
  • Can be safely run multiple times

For more information, visit: https://github.com/oiahoon/osh.it
EOF
}

main() {
  local check_only=false
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --check|-c)
        check_only=true
        shift
        ;;
      --help|-h)
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
  
  show_header
  
  # Check for the issue
  if check_issue; then
    if [[ "$check_only" == "true" ]]; then
      log_info "Issue found. Run without --check to fix it."
      exit 1
    fi
    
    # Fix the issue
    if fix_zshrc && verify_fix; then
      show_next_steps
      exit 0
    else
      log_error "Fix failed"
      exit 1
    fi
  else
    log_info "No issues found. Your .zshrc is already correct."
    exit 0
  fi
}

# Run main function
main "$@"
