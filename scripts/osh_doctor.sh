#!/usr/bin/env zsh
# OSH.IT Doctor - Health Check and Diagnostic Tool
# Version: 1.0.0
# Author: OSH.IT Team

set -e

# Configuration
OSH_DOCTOR_VERSION="1.0.0"
OSH="${OSH:-$HOME/.osh}"

# Colors
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  MAGENTA="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  NORMAL="$(tput sgr0)"
else
  RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN=""
  BOLD="" DIM="" NORMAL=""
fi

# Logging functions
log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*"; }
log_check() { printf "${CYAN}🔍 %s${NORMAL}" "$*"; }

# Health check results
HEALTH_SCORE=0
TOTAL_CHECKS=0
ISSUES_FOUND=()
WARNINGS_FOUND=()

# Increment health score
add_check() {
  TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

add_success() {
  HEALTH_SCORE=$((HEALTH_SCORE + 1))
}

# Check lazy loading system
check_lazy_loading() {
  add_check
  log_check "Checking lazy loading system... "
  
  local lazy_enabled="${OSH_LAZY_LOADING:-true}"
  
  if [[ "$lazy_enabled" == "true" ]]; then
    if [[ -f "$OSH/lib/lazy_loader.zsh" ]]; then
      printf "${GREEN}✓${NORMAL}\n"
      add_success
      log_info "  Lazy loading system: Available"
      
      # Test if lazy loading functions are accessible
      if source "$OSH/lib/lazy_loader.zsh" 2>/dev/null; then
        if declare -f osh_lazy_register >/dev/null; then
          log_info "  Lazy loading functions: Working"
        else
          log_warning "  Lazy loading functions: Not properly loaded"
          add_warning "Lazy loading functions not accessible"
        fi
      else
        log_warning "  Lazy loading system: Failed to load"
        add_warning "Failed to source lazy_loader.zsh"
      fi
      
      # Check if test script exists
      if [[ -f "$OSH/scripts/test_lazy_loading.sh" ]]; then
        log_info "  Lazy loading tests: Available"
      else
        log_warning "  Lazy loading tests: Not found"
      fi
      
    else
      printf "${RED}✗${NORMAL}\n"
      add_issue "Lazy loading enabled but lazy_loader.zsh not found"
      log_error "  Lazy loading system file missing: $OSH/lib/lazy_loader.zsh"
    fi
  else
    printf "${YELLOW}⚠${NORMAL}\n"
    log_warning "  Lazy loading is disabled (OSH_LAZY_LOADING=false)"
    log_info "  To enable: export OSH_LAZY_LOADING=true"
  fi
}

add_issue() {
  ISSUES_FOUND+=("$1")
}

add_warning() {
  WARNINGS_FOUND+=("$1")
}

# Show OSH.IT Doctor header
show_header() {
  echo
  echo "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NORMAL}"
  echo "${BOLD}${CYAN}║                     OSH.IT Doctor v$OSH_DOCTOR_VERSION                     ║${NORMAL}"
  echo "${BOLD}${CYAN}║              Health Check & Diagnostic Tool                  ║${NORMAL}"
  echo "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NORMAL}"
  echo
}

# Check OSH.IT installation
check_installation() {
  log_check "Checking OSH.IT installation... "
  add_check
  
  if [[ ! -d "$OSH" ]]; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "OSH.IT directory not found: $OSH"
    return 1
  fi
  
  if [[ ! -f "$OSH/osh.sh" ]]; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "Core OSH.IT file missing: $OSH/osh.sh"
    return 1
  fi
  
  echo "${GREEN}OK${NORMAL}"
  add_success
  return 0
}

# Check Zsh installation and version
check_zsh() {
  log_check "Checking Zsh installation... "
  add_check
  
  if ! command -v zsh >/dev/null 2>&1; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "Zsh is not installed"
    return 1
  fi
  
  local zsh_version="${ZSH_VERSION:-unknown}"
  echo "${GREEN}OK${NORMAL} (version: $zsh_version)"
  add_success
  
  # Check if Zsh is the default shell
  if [[ "$SHELL" != *"zsh" ]]; then
    add_warning "Zsh is not your default shell (current: $SHELL)"
  fi
  
  return 0
}

# Check shell configuration
check_shell_config() {
  log_check "Checking shell configuration... "
  add_check
  
  local config_file="$HOME/.zshrc"
  
  if [[ ! -f "$config_file" ]]; then
    echo "${YELLOW}WARNING${NORMAL}"
    add_warning "Shell configuration file not found: $config_file"
    return 1
  fi
  
  if ! grep -q "source.*osh.sh" "$config_file"; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "OSH.IT not configured in $config_file"
    return 1
  fi
  
  echo "${GREEN}OK${NORMAL}"
  add_success
  return 0
}

# Check plugins
check_plugins() {
  log_check "Checking plugins... "
  add_check
  
  local plugin_dir="$OSH/plugins"
  
  if [[ ! -d "$plugin_dir" ]]; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "Plugin directory not found: $plugin_dir"
    return 1
  fi
  
  local plugin_count=$(find "$plugin_dir" -name "*.plugin.zsh" 2>/dev/null | wc -l | tr -d ' ')
  
  if [[ $plugin_count -eq 0 ]]; then
    echo "${YELLOW}WARNING${NORMAL}"
    add_warning "No plugins found"
    return 1
  fi
  
  echo "${GREEN}OK${NORMAL} ($plugin_count plugins found)"
  add_success
  
  # Check if plugins are properly loaded
  if [[ -n "${oplugins:-}" ]]; then
    log_info "Active plugins: ${oplugins[*]}"
  else
    add_warning "No plugins are currently active"
  fi
  
  return 0
}

# Check lazy loading system
check_lazy_loading() {
  add_check
  log_check "Checking lazy loading system... "
  
  local lazy_enabled="${OSH_LAZY_LOADING:-true}"
  
  if [[ "$lazy_enabled" == "true" ]]; then
    if [[ -f "$OSH/lib/lazy_loader.zsh" ]]; then
      printf "${GREEN}✓${NORMAL}\n"
      add_success
      log_info "  Lazy loading system: Available"
      
      # Test if lazy loading functions are accessible
      if source "$OSH/lib/lazy_loader.zsh" 2>/dev/null; then
        if declare -f osh_lazy_register >/dev/null; then
          log_info "  Lazy loading functions: Working"
        else
          log_warning "  Lazy loading functions: Not properly loaded"
          add_warning "Lazy loading functions not accessible"
        fi
      else
        log_warning "  Lazy loading system: Failed to load"
        add_warning "Failed to source lazy_loader.zsh"
      fi
      
      # Check if test script exists
      if [[ -f "$OSH/scripts/test_lazy_loading.sh" ]]; then
        log_info "  Lazy loading tests: Available"
        log_info "  Run: $OSH/scripts/test_lazy_loading.sh"
      else
        log_warning "  Lazy loading tests: Not found"
      fi
      
    else
      printf "${RED}✗${NORMAL}\n"
      add_issue "Lazy loading enabled but lazy_loader.zsh not found"
      log_error "  Lazy loading system file missing: $OSH/lib/lazy_loader.zsh"
    fi
  else
    printf "${YELLOW}⚠${NORMAL}\n"
    log_warning "  Lazy loading is disabled (OSH_LAZY_LOADING=false)"
    log_info "  To enable: export OSH_LAZY_LOADING=true"
  fi
}

# Check dependencies
check_dependencies() {
  log_check "Checking system dependencies... "
  add_check
  
  local deps=("curl" "git")
  local missing_deps=()
  
  for dep in "${deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_deps+=("$dep")
    fi
  done
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "Missing dependencies: ${missing_deps[*]}"
    return 1
  fi
  
  echo "${GREEN}OK${NORMAL}"
  add_success
  return 0
}

# Check network connectivity
check_network() {
  log_check "Checking network connectivity... "
  add_check
  
  if ! curl -fsSL --connect-timeout 5 --max-time 10 "https://github.com" >/dev/null 2>&1; then
    echo "${RED}FAILED${NORMAL}"
    add_issue "Cannot connect to GitHub"
    return 1
  fi
  
  echo "${GREEN}OK${NORMAL}"
  add_success
  return 0
}

# Performance test
performance_test() {
  log_info "🚀 Running performance test..."
  
  local start_time=$(date +%s%N)
  
  # Source OSH.IT to measure startup time
  if [[ -f "$OSH/osh.sh" ]]; then
    source "$OSH/osh.sh" >/dev/null 2>&1
  fi
  
  local end_time=$(date +%s%N)
  local startup_time=$(( (end_time - start_time) / 1000000 ))
  
  log_info "Startup time: ${startup_time}ms"
  
  if [[ $startup_time -lt 100 ]]; then
    log_success "Excellent performance (< 100ms)"
  elif [[ $startup_time -lt 500 ]]; then
    log_success "Good performance (< 500ms)"
  elif [[ $startup_time -lt 1000 ]]; then
    log_warning "Moderate performance (< 1s)"
  else
    add_warning "Slow startup time: ${startup_time}ms"
  fi
}

# Auto-fix common issues
auto_fix() {
  log_info "🔧 Attempting to fix common issues..."
  
  local fixed_count=0
  
  # Fix missing shell configuration
  if grep -q "OSH.IT not configured" <<< "${ISSUES_FOUND[*]}"; then
    log_info "Fixing shell configuration..."
    
    local config_file="$HOME/.zshrc"
    if [[ -f "$config_file" ]] && ! grep -q "source.*osh.sh" "$config_file"; then
      echo "" >> "$config_file"
      echo "# OSH.IT Configuration - Added by osh doctor" >> "$config_file"
      echo "export OSH=\"$OSH\"" >> "$config_file"
      echo "source \$OSH/osh.sh" >> "$config_file"
      
      log_success "Added OSH.IT configuration to $config_file"
      fixed_count=$((fixed_count + 1))
    fi
  fi
  
  # Fix file permissions
  if [[ -f "$OSH/osh.sh" ]]; then
    chmod +x "$OSH/osh.sh" 2>/dev/null
    chmod +x "$OSH/upgrade.sh" 2>/dev/null
    find "$OSH" -name "*.sh" -exec chmod +x {} \; 2>/dev/null
    log_success "Fixed file permissions"
    fixed_count=$((fixed_count + 1))
  fi
  
  if [[ $fixed_count -gt 0 ]]; then
    log_success "Fixed $fixed_count issues"
    log_info "Please restart your terminal or run: source ~/.zshrc"
  else
    log_info "No auto-fixable issues found"
  fi
}

# Show health report
show_report() {
  echo
  echo "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${NORMAL}"
  echo "${BOLD}${CYAN}║                        Health Report                         ║${NORMAL}"
  echo "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${NORMAL}"
  echo
  
  # Calculate health percentage
  local health_percentage=0
  if [[ $TOTAL_CHECKS -gt 0 ]]; then
    health_percentage=$(( (HEALTH_SCORE * 100) / TOTAL_CHECKS ))
  fi
  
  # Show overall health
  echo "${BOLD}Overall Health: "
  if [[ $health_percentage -ge 90 ]]; then
    echo "${GREEN}$health_percentage% - Excellent! 🎉${NORMAL}"
  elif [[ $health_percentage -ge 70 ]]; then
    echo "${YELLOW}$health_percentage% - Good 👍${NORMAL}"
  elif [[ $health_percentage -ge 50 ]]; then
    echo "${YELLOW}$health_percentage% - Needs Attention ⚠️${NORMAL}"
  else
    echo "${RED}$health_percentage% - Critical Issues ❌${NORMAL}"
  fi
  echo
  
  # Show detailed results
  echo "${BOLD}Check Results:${NORMAL}"
  echo "  ✅ Passed: $HEALTH_SCORE/$TOTAL_CHECKS"
  echo "  ❌ Issues: ${#ISSUES_FOUND[@]}"
  echo "  ⚠️  Warnings: ${#WARNINGS_FOUND[@]}"
  echo
  
  # Show issues
  if [[ ${#ISSUES_FOUND[@]} -gt 0 ]]; then
    echo "${BOLD}${RED}Issues Found:${NORMAL}"
    for issue in "${ISSUES_FOUND[@]}"; do
      echo "  ❌ $issue"
    done
    echo
  fi
  
  # Show warnings
  if [[ ${#WARNINGS_FOUND[@]} -gt 0 ]]; then
    echo "${BOLD}${YELLOW}Warnings:${NORMAL}"
    for warning in "${WARNINGS_FOUND[@]}"; do
      echo "  ⚠️  $warning"
    done
    echo
  fi
  
  # Show recommendations
  if [[ ${#ISSUES_FOUND[@]} -gt 0 ]] || [[ ${#WARNINGS_FOUND[@]} -gt 0 ]]; then
    echo "${BOLD}${BLUE}Recommendations:${NORMAL}"
    echo "  1. Run: ${CYAN}osh doctor --fix${NORMAL} to auto-fix common issues"
    echo "  2. Check the OSH.IT documentation: ${CYAN}https://github.com/oiahoon/osh.it${NORMAL}"
    echo "  3. Update OSH.IT: ${CYAN}upgrade_myshell${NORMAL}"
    echo
  fi
}

# Show help
show_help() {
  cat << EOF
${BOLD}OSH.IT Doctor v$OSH_DOCTOR_VERSION${NORMAL}

${BOLD}USAGE:${NORMAL}
  osh doctor [OPTIONS]

${BOLD}OPTIONS:${NORMAL}
  --fix, -f         Attempt to auto-fix common issues
  --perf, -p        Run performance test
  --verbose, -v     Show detailed output
  --help, -h        Show this help message

${BOLD}EXAMPLES:${NORMAL}
  osh doctor                # Run health check
  osh doctor --fix          # Run health check and auto-fix issues
  osh doctor --perf         # Include performance test
  osh doctor --verbose      # Show detailed information

${BOLD}HEALTH CHECKS:${NORMAL}
  • OSH.IT installation integrity
  • Zsh installation and configuration
  • Shell configuration
  • Plugin system
  • System dependencies
  • Network connectivity

For more information, visit: https://github.com/oiahoon/osh.it
EOF
}

# Main function
main() {
  local auto_fix=false
  local run_perf=false
  local verbose=false
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --fix|-f)
        auto_fix=true
        shift
        ;;
      --perf|-p)
        run_perf=true
        shift
        ;;
      --verbose|-v)
        verbose=true
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
  
  # Run health checks
  log_info "Running OSH.IT health checks..."
  echo
  
  check_installation
  check_zsh
  check_shell_config
  check_plugins
  check_lazy_loading
  check_dependencies
  check_network
  
  echo
  
  # Run performance test if requested
  if [[ "$run_perf" == "true" ]]; then
    performance_test
    echo
  fi
  
  # Auto-fix if requested
  if [[ "$auto_fix" == "true" ]]; then
    auto_fix
    echo
  fi
  
  # Show final report
  show_report
  
  # Exit with appropriate code
  if [[ ${#ISSUES_FOUND[@]} -gt 0 ]]; then
    exit 1
  else
    exit 0
  fi
}

# Export function for global access
osh_doctor() {
  "$OSH/scripts/osh_doctor.sh" "$@"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
  main "$@"
fi
