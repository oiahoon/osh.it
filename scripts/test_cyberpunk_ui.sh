#!/usr/bin/env bash
# OSH.IT Cyberpunk UI Test Script
# Demonstrates the new cyberpunk-styled interface

set -e

# Load cyberpunk colors
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
  # Fallback for non-color terminals
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

# Progress bar function
show_progress() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  
  printf "\r%bSYNC%b [" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}${CYBER_NEON_BLUE}"
  printf "%*s" $filled | tr ' ' '█'
  printf "%*s" $((width - filled)) | tr ' ' '░'
  printf "] %d%% (%d/%d)%b" $percentage $current $total "${CYBER_RESET}"
  
  if [[ $current -eq $total ]]; then
    printf "\n"
  fi
}

# Main demo function
main() {
  echo
  printf "%b╔═══════════════════════════════════════════════════════════════════════╗%b\n" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}"
  printf "%b║                     OSH.IT CYBERPUNK UI TEST                         ║%b\n" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}"
  printf "%b╚═══════════════════════════════════════════════════════════════════════╝%b\n" "${CYBER_NEON_BLUE}${CYBER_BOLD}" "${CYBER_RESET}"
  echo
  
  log_info "SYSTEM INIT - Initializing cyberpunk interface..."
  sleep 1
  
  log_info "VERSION CHECK - Scanning remote repository..."
  sleep 1
  
  log_success "NETWORK OK - Connected to github.com (1s)"
  sleep 0.5
  
  log_info "CURRENT - Version: 1.5.0"
  log_info "REMOTE  - Version: 1.6.0"
  sleep 1
  
  log_info "UPDATE AVAILABLE - 1.5.0 >> 1.6.0"
  sleep 1
  
  log_info "BACKUP INIT - Creating backup: ~/.osh.backup.20250801_170000"
  sleep 1
  log_success "BACKUP COMPLETE - Backup created successfully"
  sleep 0.5
  
  log_info "FILE SYNC - Updating OSH essential files..."
  
  # Demo progress bar
  for i in {1..10}; do
    show_progress $i 10
    sleep 0.2
  done
  
  log_success "SYNC COMPLETE - All files updated successfully!"
  sleep 0.5
  
  log_info "PERMISSIONS - Fixing file permissions..."
  sleep 0.5
  log_success "PERMISSIONS OK - File permissions fixed"
  sleep 0.5
  
  echo
  log_success "UPGRADE COMPLETE - OSH upgrade completed successfully!"
  log_success "NEW VERSION - Updated to version: 1.6.0"
  echo
  log_info "NEXT STEP - Restart your terminal or run: source ~/.zshrc"
  echo
  log_info "NETWORK RESOURCES:"
  log_info "  >> Official Website: https://oiahoon.github.io/osh.it/"
  log_info "  >> Documentation: https://github.com/oiahoon/osh.it/wiki"
  log_info "  >> Support: https://github.com/oiahoon/osh.it/issues"
  echo
  log_success "SYSTEM READY - Happy shell customization!"
  echo
  
  # Error demo
  echo "Error handling demo:"
  log_warning "NETWORK WARN - Mirror fallback activated"
  log_error "CONNECTION ERROR - Failed to connect to mirror"
  
  echo
  printf "%b[DEMO COMPLETE]%b All cyberpunk UI elements tested successfully!%b\n" "${CYBER_PINK}${CYBER_BOLD}" "${CYBER_RESET}${CYBER_PINK}" "${CYBER_RESET}"
  echo
}

# Run demo
main "$@"