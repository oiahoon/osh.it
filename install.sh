#!/usr/bin/env bash
# OSH Installation Script - Shell Detection Fixed
# Version: 1.2.5
# Author: oiahoon
# License: MIT

set -e  # Exit on any error

# Network connectivity and mirror support
OSH_MIRROR="${OSH_MIRROR:-github}"
OSH_NETWORK_TIMEOUT="${OSH_NETWORK_TIMEOUT:-10}"

# Mirror configuration
setup_mirror_source() {
  case "${OSH_MIRROR}" in
    "github")
      OSH_REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh.it/main"
      ;;
    "gitee")
      OSH_REPO_BASE="https://gitee.com/oiahoon/osh.it/raw/main"
      ;;
    "custom")
      OSH_REPO_BASE="${OSH_CUSTOM_REPO:-https://raw.githubusercontent.com/oiahoon/osh.it/main}"
      ;;
    *)
      OSH_REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh.it/main"
      ;;
  esac
  
  log_info "MIRROR CONFIG - Using mirror: $OSH_MIRROR ($OSH_REPO_BASE)"
}

# Network connectivity check
check_network_connectivity() {
  log_info "NETWORK SCAN - Checking network connectivity..."
  
  local test_urls=(
    "https://github.com"
    "https://raw.githubusercontent.com"
  )
  
  # Add Gitee for Chinese users
  if [[ "${LANG:-}" =~ zh_CN ]] || [[ "${LC_ALL:-}" =~ zh_CN ]]; then
    test_urls+=("https://gitee.com")
  fi
  
  local connected=false
  local fastest_mirror=""
  local best_time=999
  
  for url in "${test_urls[@]}"; do
    log_info "Testing connection to $url..."
    
    local start_time=$(date +%s)
    if curl -fsSL --connect-timeout "$OSH_NETWORK_TIMEOUT" --max-time "$OSH_NETWORK_TIMEOUT" "$url" >/dev/null 2>&1; then
      local end_time=$(date +%s)
      local response_time=$((end_time - start_time))
      
      log_success "NETWORK OK - Connected to $url (${response_time}s)"
      connected=true
      
      # Track fastest mirror
      if [[ $response_time -lt $best_time ]]; then
        best_time=$response_time
        if [[ "$url" =~ gitee ]]; then
          fastest_mirror="gitee"
        else
          fastest_mirror="github"
        fi
      fi
    else
      log_warning "NETWORK FAIL - Failed to connect to $url"
    fi
  done
  
  if [[ "$connected" == "false" ]]; then
    log_error "NETWORK ERROR - Network connectivity check failed"
    echo
    echo "${CYBER_BOLD}${CYBER_NEON_YELLOW}Network Troubleshooting:${CYBER_RESET}"
    echo "1. Check your internet connection"
    echo "2. Verify DNS settings"
    echo "3. Check firewall/proxy settings"
    echo "4. Try using a different network"
    echo "5. Use manual installation method"
    echo
    return 1
  fi
  
  # Auto-select fastest mirror
  if [[ -n "$fastest_mirror" ]] && [[ "$OSH_MIRROR" == "github" ]]; then
    if [[ "$fastest_mirror" == "gitee" ]] && [[ $best_time -lt 3 ]]; then
      log_info "MIRROR AUTO - Auto-selecting faster mirror: $fastest_mirror"
      OSH_MIRROR="$fastest_mirror"
    fi
  fi
  
  return 0
}

# Dependency check with OS-specific guidance
check_dependencies() {
  log_info "DEPENDENCY SCAN - Checking system dependencies..."
  
  local essential_deps=("curl" "git")
  local recommended_deps=("zsh" "python3")
  local missing_essential=()
  local missing_recommended=()
  
  # Check essential dependencies
  for dep in "${essential_deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_essential+=("$dep")
      log_error "DEPENDENCY MISSING - Missing essential dependency: $dep"
    else
      log_success "DEPENDENCY OK - Found: $dep"
    fi
  done
  
  # Check recommended dependencies
  for dep in "${recommended_deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_recommended+=("$dep")
      log_warning "DEPENDENCY WARN - Missing recommended dependency: $dep"
    else
      log_success "DEPENDENCY OK - Found: $dep"
    fi
  done
  
  # Provide installation guidance
  if [[ ${#missing_essential[@]} -gt 0 ]] || [[ ${#missing_recommended[@]} -gt 0 ]]; then
    echo
    echo "${CYBER_NEON_BLUE}${CYBER_BOLD}DEPENDENCY INSTALL GUIDE:${CYBER_RESET}"
    
    # Detect OS and provide specific instructions
    local os_type=""
    if [[ "$OSTYPE" =~ darwin ]]; then
      os_type="macOS"
      echo "${CYBER_BOLD}macOS (Homebrew):${CYBER_RESET}"
      [[ ${#missing_essential[@]} -gt 0 ]] && echo "  brew install ${missing_essential[*]}"
      [[ ${#missing_recommended[@]} -gt 0 ]] && echo "  brew install ${missing_recommended[*]}"
    elif [[ "$OSTYPE" =~ linux ]]; then
      os_type="Linux"
      echo "${CYBER_BOLD}Ubuntu/Debian:${CYBER_RESET}"
      [[ ${#missing_essential[@]} -gt 0 ]] && echo "  sudo apt update && sudo apt install ${missing_essential[*]}"
      [[ ${#missing_recommended[@]} -gt 0 ]] && echo "  sudo apt install ${missing_recommended[*]}"
      echo
      echo "${CYBER_BOLD}CentOS/RHEL/Fedora:${CYBER_RESET}"
      [[ ${#missing_essential[@]} -gt 0 ]] && echo "  sudo yum install ${missing_essential[*]} # or dnf"
      [[ ${#missing_recommended[@]} -gt 0 ]] && echo "  sudo yum install ${missing_recommended[*]}"
    fi
    echo
  fi
  
  # Fail if essential dependencies are missing
  if [[ ${#missing_essential[@]} -gt 0 ]]; then
    log_error "Cannot continue without essential dependencies: ${missing_essential[*]}"
    return 1
  fi
  
  # Warn about recommended dependencies
  if [[ ${#missing_recommended[@]} -gt 0 ]]; then
    log_warning "Some recommended dependencies are missing: ${missing_recommended[*]}"
    log_info "OSH.IT will work but some features may be limited"
    
    if [[ "$INTERACTIVE" == "true" ]]; then
      printf "${CYBER_NEON_YELLOW}Continue anyway? [y/N]: ${CYBER_RESET}"
      local confirm
      read -r confirm
      case "$confirm" in
        [yY]|[yY][eE][sS])
          log_info "Continuing with missing recommended dependencies"
          ;;
        *)
          log_info "Installation cancelled. Please install missing dependencies first."
          return 1
          ;;
      esac
    fi
  fi
  
  return 0
}

# Configuration
OSH_REPO_BASE="${OSH_REPO_BASE:-https://raw.githubusercontent.com/oiahoon/osh.it/main}"
OSH_DIR="${OSH_DIR:-$HOME/.osh}"
OSH_BACKUP_SUFFIX="${OSH_BACKUP_SUFFIX:-pre-osh}"

# Installation options
DRY_RUN=false
INTERACTIVE=true
SKIP_SHELL_CONFIG=false
CUSTOM_PLUGINS=""

# Environment detection
CURRENT_SHELL=""
SHELL_CONFIG_FILE=""
SUPPORTS_COLOR=false
TERM_WIDTH=80

# Detect current environment - FIXED VERSION
detect_environment() {
  # First, check the user's default shell from $SHELL environment variable
  # This is more reliable than checking the current execution environment
  case "$SHELL" in
    */zsh)
      CURRENT_SHELL="zsh"
      SHELL_CONFIG_FILE="$HOME/.zshrc"
      ;;
    */bash)
      CURRENT_SHELL="bash"
      SHELL_CONFIG_FILE="$HOME/.bashrc"
      ;;
    *)
      # Fallback: check if we're currently running in zsh or bash
      if [[ -n "$ZSH_VERSION" ]]; then
        CURRENT_SHELL="zsh"
        SHELL_CONFIG_FILE="$HOME/.zshrc"
      elif [[ -n "$BASH_VERSION" ]]; then
        CURRENT_SHELL="bash"
        SHELL_CONFIG_FILE="$HOME/.bashrc"
      else
        # Final fallback
        CURRENT_SHELL="unknown"
        SHELL_CONFIG_FILE="$HOME/.profile"
      fi
      ;;
  esac
  
  # Special handling for OSH: if user has zsh available, prefer it
  if command -v zsh >/dev/null 2>&1 && [[ "$CURRENT_SHELL" != "zsh" ]]; then
    # Check if user has a .zshrc file, indicating they use zsh
    if [[ -f "$HOME/.zshrc" ]]; then
      CURRENT_SHELL="zsh"
      SHELL_CONFIG_FILE="$HOME/.zshrc"
    fi
  fi
  
  # Detect color support
  if [[ -t 1 ]]; then
    if command -v tput >/dev/null 2>&1; then
      local ncolors
      ncolors=$(tput colors 2>/dev/null || echo 0)
      [[ $ncolors -ge 8 ]] && SUPPORTS_COLOR=true
    elif [[ "$TERM" =~ (xterm|screen|tmux|color) ]]; then
      SUPPORTS_COLOR=true
    fi
  fi
  
  # Get terminal width
  if command -v tput >/dev/null 2>&1; then
    TERM_WIDTH=$(tput cols 2>/dev/null || echo 80)
  fi
}

# Cyberpunk color setup for installation
setup_colors() {
  if [[ "$SUPPORTS_COLOR" == "true" ]]; then
    # Cyberpunk color palette
    CYBER_NEON_BLUE=$'\033[38;2;0;255;255m'     # Electric blue
    CYBER_NEON_CYAN=$'\033[38;2;0;255;255m'     # Same as blue for consistency
    CYBER_MATRIX_GREEN=$'\033[38;2;0;255;65m'   # Matrix green  
    CYBER_ALERT_RED=$'\033[38;2;255;0;64m'      # Alert red
    CYBER_PURPLE=$'\033[38;2;138;43;226m'       # UV purple
    CYBER_ORANGE=$'\033[38;2;255;165;0m'        # Neon orange
    CYBER_NEON_YELLOW=$'\033[38;2;255;255;0m'   # Neon yellow
    CYBER_PINK=$'\033[38;2;255;20;147m'         # Hot pink
    CYBER_WHITE=$'\033[38;2;255;255;255m'       # Pure white
    CYBER_DARK_GRAY=$'\033[38;2;64;64;64m'      # Dark gray
    CYBER_BOLD=$'\033[1m'
    CYBER_DIM=$'\033[2m'
    CYBER_RESET=$'\033[0m'
  else
    # Fallback to empty strings for non-color terminals
    CYBER_NEON_BLUE=""
    CYBER_NEON_CYAN=""
    CYBER_MATRIX_GREEN=""
    CYBER_ALERT_RED=""
    CYBER_PURPLE=""
    CYBER_ORANGE=""
    CYBER_NEON_YELLOW=""
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
log_dry_run() { 
  printf "%b[%bDRY-RUN%b] %s%b\n" "${CYBER_PURPLE}${CYBER_BOLD}" "${CYBER_PURPLE}" "${CYBER_RESET}${CYBER_DIM}" "$*" "${CYBER_RESET}"
}
log_progress() { 
  printf "%bDOWNLOAD%b %s" "${CYBER_PINK}${CYBER_BOLD}" "${CYBER_RESET}" "$*"
}

# Vintage gradient colors for logo (with fallback)
vintage_color() {
  local color_code="$1"
  local text="$2"
  
  if [[ "$SUPPORTS_COLOR" == "true" ]]; then
    printf "\033[38;5;%sm%s\033[0m" "$color_code" "$text"
  else
    printf "%s" "$text"
  fi
}

# Beautiful OSH.IT ASCII Logo with environment-aware colors
show_logo() {
  local logo_width=60
  local padding=$(( (TERM_WIDTH - logo_width) / 2 ))
  local pad_str=""
  
  # Create padding string
  if [[ $padding -gt 0 ]]; then
    pad_str=$(printf "%*s" $padding "")
  fi
  
  echo
  echo "${pad_str}$(vintage_color 124 '        ██████╗ ███████╗██╗  ██╗   ██╗████████╗')"
  echo "${pad_str}$(vintage_color 130 '       ██╔═══██╗██╔════╝██║  ██║   ██║╚══██╔══╝')"
  echo "${pad_str}$(vintage_color 136 '       ██║   ██║███████╗███████║   ██║   ██║   ')"
  echo "${pad_str}$(vintage_color 100 '       ██║   ██║╚════██║██╔══██║   ██║   ██║   ')"
  echo "${pad_str}$(vintage_color 64 '       ╚██████╔╝███████║██║  ██║██╗██║   ██║   ')"
  echo "${pad_str}$(vintage_color 66 '        ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝   ╚═╝   ')"
  echo
  echo "${pad_str}${CYBER_NEON_BLUE}${CYBER_BOLD}      A Modern Zsh Framework${CYBER_RESET}"
  echo "${pad_str}${CYBER_DARK_GRAY}      Lightweight Alternative to Oh My Zsh${CYBER_RESET}"
  echo
}

# Download function with inline progress
download_file() {
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

# Progress bar function with file info
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

# Load plugin discovery system
load_plugin_discovery() {
  if [[ -f "$OSH_DIR/lib/plugin_discovery.zsh" ]]; then
    source "$OSH_DIR/lib/plugin_discovery.zsh" 2>/dev/null || true
    source "$OSH_DIR/lib/cyberpunk.zsh" 2>/dev/null || true
    osh_plugin_init_db 2>/dev/null || true
  fi
}

# Interactive plugin selection
interactive_plugin_selection() {
  echo >&2
  log_info "PLUGIN SELECT - Plugin Selection" >&2
  echo >&2
  
  # Load plugin discovery system
  load_plugin_discovery
  
  # Display available plugins dynamically
  if command -v osh_plugin_list_all >/dev/null 2>&1; then
    echo "Available plugins:" >&2
    local plugin_count=1
    local plugin_list=()
    
    # Get plugins from discovery system
    while IFS='|' read -r name category description; do
      if [[ -n "$name" ]]; then
        echo "  ${CYBER_BOLD}${plugin_count}.${CYBER_RESET} ${name}  - ${description}" >&2
        plugin_list+=("$name")
        ((plugin_count++))
      fi
    done < <(osh_plugin_list_all 2>/dev/null | grep -v "^$" | head -10)
    
    # Fallback to static list if discovery system fails
    if [[ ${#plugin_list[@]} -eq 0 ]]; then
      echo "  ${CYBER_BOLD}1.${CYBER_RESET} sysinfo  - System information display with OSH.IT branding" >&2
      echo "  ${CYBER_BOLD}2.${CYBER_RESET} weather  - Beautiful weather forecast with ASCII art" >&2
      echo "  ${CYBER_BOLD}3.${CYBER_RESET} taskman  - Advanced terminal task manager" >&2
      echo "  ${CYBER_BOLD}4.${CYBER_RESET} acw      - Advanced Code Workflow (Git + JIRA integration)" >&2
      echo "  ${CYBER_BOLD}5.${CYBER_RESET} fzf      - Enhanced fuzzy finder with preview" >&2
      echo "  ${CYBER_BOLD}6.${CYBER_RESET} greeting - Friendly welcome message" >&2
    fi
  else
    # Static fallback list
    echo "Available plugins:" >&2
    echo "  ${CYBER_BOLD}1.${CYBER_RESET} sysinfo  - System information display with OSH.IT branding" >&2
    echo "  ${CYBER_BOLD}2.${CYBER_RESET} weather  - Beautiful weather forecast with ASCII art" >&2
    echo "  ${CYBER_BOLD}3.${CYBER_RESET} taskman  - Advanced terminal task manager" >&2
    echo "  ${CYBER_BOLD}4.${CYBER_RESET} acw      - Advanced Code Workflow (Git + JIRA integration)" >&2
    echo "  ${CYBER_BOLD}5.${CYBER_RESET} fzf      - Enhanced fuzzy finder with preview" >&2
    echo "  ${CYBER_BOLD}6.${CYBER_RESET} greeting - Friendly welcome message" >&2
  fi
  echo >&2
  echo "Installation presets:" >&2
  echo "  ${CYBER_NEON_CYAN}preset:minimal${CYBER_RESET}     - sysinfo only" >&2
  echo "  ${CYBER_NEON_CYAN}preset:recommended${CYBER_RESET} - sysinfo, weather, taskman (default)" >&2
  echo "  ${CYBER_NEON_CYAN}preset:developer${CYBER_RESET}   - recommended + acw, fzf" >&2
  echo "  ${CYBER_NEON_CYAN}preset:full${CYBER_RESET}        - All plugins including experimental" >&2
  echo >&2
  echo "Selection options:" >&2
  echo "  • Enter numbers: ${CYBER_NEON_YELLOW}1 2 3${CYBER_RESET} (space-separated)" >&2
  echo "  • Use presets: ${CYBER_NEON_YELLOW}preset:recommended${CYBER_RESET}" >&2
  echo "  • Install all: ${CYBER_NEON_YELLOW}all${CYBER_RESET} or ${CYBER_NEON_YELLOW}a${CYBER_RESET}" >&2
  echo "  • Default: Press ${CYBER_NEON_YELLOW}Enter${CYBER_RESET} for recommended preset" >&2
  echo >&2
  
  local selection
  printf "${CYBER_NEON_BLUE}Your choice: ${CYBER_RESET}" >&2
  read -r selection
  
  # Handle empty input (default)
  if [[ -z "$selection" ]]; then
    selection="preset:recommended"
  fi
  
  # Process selection
  case "$selection" in
    "preset:minimal")
      echo "sysinfo"
      ;;
    "preset:recommended")
      echo "sysinfo weather taskman"
      ;;
    "preset:developer")
      echo "sysinfo weather taskman acw fzf"
      ;;
    "preset:full")
      echo "sysinfo weather taskman acw fzf greeting"
      ;;
    "all"|"a")
      echo "sysinfo weather taskman acw fzf greeting"
      ;;
    *)
      # Convert numbers to plugin names
      local plugins=""
      for num in $selection; do
        case "$num" in
          1) plugins="$plugins sysinfo" ;;
          2) plugins="$plugins weather" ;;
          3) plugins="$plugins taskman" ;;
          4) plugins="$plugins acw" ;;
          5) plugins="$plugins fzf" ;;
          6) plugins="$plugins greeting" ;;
          *) log_warning "Unknown selection: $num" >&2 ;;
        esac
      done
      echo "$plugins"
      ;;
  esac
}

# Show installation summary
show_installation_summary() {
  local selected_plugins=("$@")
  
  echo
  log_info "📋 Installation Summary"
  echo
  echo "${CYBER_BOLD}What will be installed:${CYBER_RESET}"
  echo "  • OSH.IT core framework"
  echo "  • Essential libraries and utilities"
  
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    echo "  • Selected plugins: ${CYBER_NEON_CYAN}${selected_plugins[*]}${CYBER_RESET}"
  else
    echo "  • ${CYBER_DIM}No plugins selected${CYBER_RESET}"
  fi
  
  echo
  echo "${CYBER_BOLD}Installation location:${CYBER_RESET} $OSH_DIR"
  echo "${CYBER_BOLD}Shell configuration:${CYBER_RESET} $SHELL_CONFIG_FILE"
  echo
  
  if [[ "$INTERACTIVE" == "true" ]]; then
    printf "${CYBER_NEON_YELLOW}Continue with installation? [Y/n]: ${CYBER_RESET}"
    local confirm
    read -r confirm
    
    case "$confirm" in
      [nN]|[nN][oO])
        log_info "Installation cancelled by user"
        exit 0
        ;;
      *)
        log_success "Installation confirmed!"
        ;;
    esac
  fi
}
ESSENTIAL_FILES=(
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

# Plugin files mapping - FIXED to match actual file structure
get_plugin_files() {
  local plugin="$1"
  
  case "$plugin" in
    "sysinfo")
      echo "plugins/sysinfo/sysinfo.plugin.zsh"
      ;;
    "weather")
      echo "plugins/weather/weather.plugin.zsh"
      echo "plugins/weather/completions/_weather"
      ;;
    "taskman")
      echo "plugins/taskman/taskman.plugin.zsh"
      echo "plugins/taskman/task_manager_modern.py"
      echo "plugins/taskman/task_manager_vintage.py"
      echo "plugins/taskman/task_cli.py"
      echo "plugins/taskman/taskman_setup.py"
      echo "plugins/taskman/dino_animation.py"
      ;;
    "acw")
      echo "plugins/acw/acw.plugin.zsh"
      ;;
    "fzf")
      echo "plugins/fzf/fzf.plugin.zsh"
      ;;
    "greeting")
      echo "plugins/greeting/greeting.plugin.zsh"
      ;;
    *)
      log_error "Unknown plugin: $plugin" >&2
      return 1
      ;;
  esac
}

# Plugin descriptions
get_plugin_description() {
  local plugin="$1"
  
  case "$plugin" in
    *)
      log_info "Starting installation..."
      ;;
  esac
}

# Configure shell integration
# Helper function to update plugin configuration in existing .zshrc
_update_plugin_configuration() {
  local selected_plugins=("$@")
  
  if [[ ! -f "$SHELL_CONFIG_FILE" ]]; then
    log_error "Shell configuration file not found: $SHELL_CONFIG_FILE"
    return 1
  fi
  
  # Create backup
  local backup_file="${SHELL_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  if cp "$SHELL_CONFIG_FILE" "$backup_file"; then
    log_success "Created backup: $backup_file"
  else
    log_error "Failed to create backup of $SHELL_CONFIG_FILE"
    return 1
  fi
  
  # Create temporary file for processing
  local temp_file="/tmp/osh_update_$$"
  local new_plugins_line="oplugins=(${selected_plugins[*]})"
  local updated=false
  
  # Process the file line by line
  while IFS= read -r line; do
    if [[ "$line" =~ ^oplugins= ]]; then
      # Replace the oplugins line
      echo "$new_plugins_line"
      updated=true
    else
      echo "$line"
    fi
  done < "$SHELL_CONFIG_FILE" > "$temp_file"
  
  # If no oplugins line was found, add it after the export OSH line
  if [[ "$updated" == "false" ]]; then
    # Create a new temp file with the plugin line added
    local temp_file2="/tmp/osh_update2_$$"
    while IFS= read -r line; do
      echo "$line"
      if [[ "$line" =~ ^export\ OSH= ]]; then
        echo "$new_plugins_line"
        updated=true
      fi
    done < "$temp_file" > "$temp_file2"
    mv "$temp_file2" "$temp_file"
  fi
  
  if [[ "$updated" == "true" ]]; then
    # Replace the original file
    if mv "$temp_file" "$SHELL_CONFIG_FILE"; then
      log_success "Updated plugin configuration in $SHELL_CONFIG_FILE"
      log_info "New plugins: ${selected_plugins[*]}"
    else
      log_error "Failed to update $SHELL_CONFIG_FILE"
      rm -f "$temp_file"
      return 1
    fi
  else
    log_warning "Could not find appropriate location to add plugin configuration"
    rm -f "$temp_file"
    return 1
  fi
  
  return 0
}

configure_shell() {
  local selected_plugins=("$@")
  
  if [[ "$SKIP_SHELL_CONFIG" == "true" ]]; then
    log_info "Skipping shell configuration as requested"
    return 0
  fi
  
  if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    log_warning "OSH.IT is optimized for Zsh. Current shell: $CURRENT_SHELL"
    return 0
  fi
  
  echo
  log_info "SHELL CONFIG - Configuring shell integration..."
  
  # Check if OSH is already configured
  if [[ -f "$SHELL_CONFIG_FILE" ]] && grep -q "source.*osh.sh" "$SHELL_CONFIG_FILE"; then
    log_info "OSH.IT is already configured in $SHELL_CONFIG_FILE"
    
    # Check if we need to update plugin configuration
    if [[ ${#selected_plugins[@]} -gt 0 ]]; then
      log_info "Checking if plugin configuration needs updating..."
      
      # Check if oplugins line exists and matches current selection
      local current_plugins_line=""
      if grep -q "^oplugins=" "$SHELL_CONFIG_FILE"; then
        current_plugins_line=$(grep "^oplugins=" "$SHELL_CONFIG_FILE" | head -1)
        log_info "Current plugins line: $current_plugins_line"
        
        local expected_line="oplugins=(${selected_plugins[*]})"
        log_info "Expected plugins line: $expected_line"
        
        if [[ "$current_plugins_line" == "$expected_line" ]]; then
          log_info "Plugin configuration is already up to date"
          return 0
        else
          log_info "Plugin configuration needs updating"
        fi
      else
        log_info "No oplugins configuration found, will add it"
      fi
      
      # Update plugin configuration
      if [[ "$INTERACTIVE" == "true" ]]; then
        echo
        printf "${CYBER_NEON_YELLOW}Update plugin configuration to: ${selected_plugins[*]}? [Y/n]: ${CYBER_RESET}"
        local confirm
        read -r confirm
        
        case "$confirm" in
          [nN]|[nN][oO])
            log_info "Skipping plugin configuration update"
            return 0
            ;;
        esac
      fi
      
      # Update the oplugins line
      if [[ "$DRY_RUN" == "true" ]]; then
        log_dry_run "Would update plugin configuration to: oplugins=(${selected_plugins[*]})"
      else
        _update_plugin_configuration "${selected_plugins[@]}"
      fi
    else
      log_info "No plugins selected, keeping existing configuration"
    fi
    
    return 0
  fi
  
  # Prepare configuration
  local config_block=""
  config_block+="# OSH.IT Configuration - Added by installer\n"
  config_block+="export OSH=\"\$HOME/.osh\"\n"
  config_block+="export PATH=\"\$OSH/bin:\$PATH\"\n"
  
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    config_block+="oplugins=(${selected_plugins[*]})\n"
  else
    config_block+="oplugins=()\n"
  fi
  
  config_block+="source \$OSH/osh.sh\n"
  config_block+="# End OSH.IT Configuration\n"
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_dry_run "Would add the following to $SHELL_CONFIG_FILE:"
    printf "%b\n" "$config_block"
    return 0
  fi
  
  # Ask for confirmation in interactive mode
  if [[ "$INTERACTIVE" == "true" ]]; then
    echo
    echo "${CYBER_BOLD}Shell Configuration:${CYBER_RESET}"
    echo "The installer can automatically add OSH.IT configuration to your $SHELL_CONFIG_FILE"
    echo
    echo "Configuration to be added:"
    printf "${CYBER_DIM}%b${CYBER_RESET}\n" "$config_block"
    
    printf "${CYBER_NEON_YELLOW}Add OSH.IT configuration to $SHELL_CONFIG_FILE? [Y/n]: ${CYBER_RESET}"
    local confirm
    read -r confirm
    
    case "$confirm" in
      [nN]|[nN][oO])
        log_info "Skipping automatic shell configuration"
        echo
        echo "${CYBER_BOLD}${CYBER_NEON_BLUE}Manual Configuration Required:${CYBER_RESET}"
        echo "Add the following to your $SHELL_CONFIG_FILE:"
        echo
        printf "${CYBER_NEON_CYAN}%b${CYBER_RESET}\n" "$config_block"
        return 0
        ;;
    esac
  fi
  
  # Create backup if file exists
  if [[ -f "$SHELL_CONFIG_FILE" ]]; then
    local backup_file="${SHELL_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    if cp "$SHELL_CONFIG_FILE" "$backup_file"; then
      log_success "Created backup: $backup_file"
    else
      log_error "Failed to create backup of $SHELL_CONFIG_FILE"
      return 1
    fi
  fi
  
  # Add configuration
  echo >> "$SHELL_CONFIG_FILE"
  printf "%b\n" "$config_block" >> "$SHELL_CONFIG_FILE"
  
  log_success "OSH.IT configuration added to $SHELL_CONFIG_FILE"
  return 0
}

# Main installation function with progress tracking
install_osh() {
  local selected_plugins=("$@")
  
  echo
  log_info "Creating OSH directory structure..."
  
  # Create OSH directory
  if [[ "$DRY_RUN" != "true" ]]; then
    mkdir -p "$OSH_DIR"
    log_success "Created directory: $OSH_DIR"
  else
    log_dry_run "Would create directory: $OSH_DIR"
  fi
  
  # Download essential files with progress
  echo
  log_info "CORE DOWNLOAD - Downloading OSH core files..."
  local total_files=${#ESSENTIAL_FILES[@]}
  local current=0
  
  for file in "${ESSENTIAL_FILES[@]}"; do
    current=$((current + 1))
    local filename=$(basename "$file")
    
    if [[ "$DRY_RUN" == "true" ]]; then
      log_dry_run "[$current/$total_files] Would download: $file"
    else
      # Show downloading status
      show_progress_with_file $current $total_files "$filename" "downloading"
      
      local url="${OSH_REPO_BASE}/${file}"
      local output="${OSH_DIR}/${file}"
      
      mkdir -p "$(dirname "$output")"
      
      # Download and update status
      if download_file "$url" "$output"; then
        show_progress_with_file $current $total_files "$filename" "success"
        sleep 0.1  # Brief pause to show success status
      else
        show_progress_with_file $current $total_files "$filename" "failed"
        sleep 0.5  # Longer pause to show error
        log_error "Failed to download $file"
        return 1
      fi
    fi
  done
  
  if [[ "$DRY_RUN" != "true" ]]; then
    echo
    log_success "CORE COMPLETE - Core files downloaded successfully!"
  fi
  
  # Download plugin files with progress
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    echo
    log_info "PLUGIN DOWNLOAD - Downloading selected plugins..."
    
    local plugin_count=0
    local total_plugins=${#selected_plugins[@]}
    
    for plugin in "${selected_plugins[@]}"; do
      # Skip empty plugin names
      if [[ -z "$plugin" ]]; then
        continue
      fi
      
      plugin_count=$((plugin_count + 1))
      echo
      printf "${CYBER_NEON_CYAN}[%d/%d]${CYBER_RESET} Installing plugin: ${CYBER_BOLD}%s${CYBER_RESET}\n" "$plugin_count" "$total_plugins" "$plugin"
      
      local plugin_files
      plugin_files=$(get_plugin_files "$plugin" 2>/dev/null)
      
      if [[ $? -eq 0 && -n "$plugin_files" ]]; then
        local file_count=0
        local total_plugin_files=$(echo "$plugin_files" | wc -l | tr -d ' ')
        
        while read -r plugin_file; do
          if [[ -n "$plugin_file" ]]; then
            file_count=$((file_count + 1))
            local filename=$(basename "$plugin_file")
            
            if [[ "$DRY_RUN" == "true" ]]; then
              log_dry_run "  [$file_count/$total_plugin_files] Would download: $plugin_file"
            else
              # Show downloading status
              printf "  "
              show_progress_with_file $file_count $total_plugin_files "$filename" "downloading"
              
              local url="${OSH_REPO_BASE}/${plugin_file}"
              local output="${OSH_DIR}/${plugin_file}"
              
              mkdir -p "$(dirname "$output")"
              
              # Download and update status
              if download_file "$url" "$output"; then
                printf "  "
                show_progress_with_file $file_count $total_plugin_files "$filename" "success"
                sleep 0.1
              else
                printf "  "
                show_progress_with_file $file_count $total_plugin_files "$filename" "failed"
                sleep 0.3
                log_warning "Failed to download $plugin_file (plugin: $plugin)"
              fi
            fi
          fi
        done <<< "$plugin_files"
        
        if [[ "$DRY_RUN" != "true" ]]; then
          echo
          log_success "  PLUGIN OK - Plugin $plugin installed successfully!"
        fi
      else
        log_warning "Plugin '$plugin' not found or invalid"
      fi
    done
    
    if [[ "$DRY_RUN" != "true" ]]; then
      echo
      log_success "PLUGIN COMPLETE - All plugins downloaded successfully!"
    fi
  fi
  
  # Set permissions
  echo
  log_info "PERMISSIONS - Setting up file permissions..."
  if [[ "$DRY_RUN" != "true" ]]; then
    chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
    chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
    chmod +x "$OSH_DIR/bin/osh" 2>/dev/null || true
    chmod +x "$OSH_DIR/scripts/"*.sh 2>/dev/null || true
    find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true
    log_success "File permissions configured"
  else
    log_dry_run "Would set executable permissions on scripts"
  fi
  
  echo
  log_success "OSH installation completed successfully!"
  
  # Configure shell integration
  configure_shell "${selected_plugins[@]}"
}

# Parse command line arguments
parse_args() {
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
      --skip-shell-config)
        SKIP_SHELL_CONFIG=true
        shift
        ;;
      --plugins)
        CUSTOM_PLUGINS="$2"
        shift 2
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

# Show help
show_help() {
  show_logo
  
  cat << EOF
${CYBER_BOLD}OSH Installation Script${CYBER_RESET}

${CYBER_BOLD}DESCRIPTION:${CYBER_RESET}
  OSH is a lightweight, high-performance Zsh plugin framework designed as a
  modern alternative to Oh My Zsh with 99.8% faster startup times.

${CYBER_BOLD}USAGE:${CYBER_RESET}
  $0 [OPTIONS]

${CYBER_BOLD}OPTIONS:${CYBER_RESET}
  --dry-run              Preview installation without making changes
  --yes                  Non-interactive installation with defaults
  --skip-shell-config    Skip automatic shell configuration
  --plugins PLUGINS      Comma-separated list of plugins to install
  --help                 Show this help message

${CYBER_BOLD}EXAMPLES:${CYBER_RESET}
  # Interactive installation (recommended)
  $0

  # Quick non-interactive install
  $0 --yes

  # Install with specific plugins
  $0 --plugins "weather,taskman"

  # Preview installation
  $0 --dry-run

${CYBER_BOLD}AVAILABLE PLUGINS:${CYBER_RESET}
  • 
  • sysinfo  - System information display
  • weather  - Beautiful weather forecast
  • taskman  - Advanced task manager
  • acw      - Git + JIRA workflow automation
  • fzf      - Enhanced fuzzy finder

For more information, visit: https://github.com/oiahoon/osh.it
EOF
}

# Main function
# Update installer script itself first
update_installer_script() {
  # Skip self-update in dry-run mode
  if [[ "$DRY_RUN" == "true" ]]; then
    return 0
  fi
  
  log_info "🔄 Ensuring installer is up to date..."
  local temp_installer="/tmp/osh_install_latest.sh"
  
  if download_file "${OSH_REPO_BASE}/install.sh" "$temp_installer"; then
    # Verify downloaded file is valid
    if [[ -s "$temp_installer" ]] && bash -n "$temp_installer" 2>/dev/null; then
      # Check if current script is different from latest
      if ! diff -q "$0" "$temp_installer" >/dev/null 2>&1; then
        log_info "INSTALLER UPDATE - Updating installer to latest version..."
        log_success "INSTALLER UPDATED - Installer updated, restarting with latest version..."
        echo
        
        # Re-execute with updated script, preserving all arguments
        exec bash "$temp_installer" "$@"
      else
        log_success "INSTALLER OK - Installer is already up to date"
      fi
    else
      log_warning "INSTALLER ERROR - Downloaded installer appears invalid, continuing with current version"
    fi
    
    # Clean up temp file
    rm -f "$temp_installer" 2>/dev/null || true
  else
    log_warning "DOWNLOAD ERROR - Could not download latest installer, continuing with current version"
  fi
}

main() {
  detect_environment
  setup_colors
  parse_args "$@"
  
  # Show logo and welcome
  show_logo
  echo "${CYBER_BOLD}${CYBER_MATRIX_GREEN}Welcome to OSH.IT Installation!${CYBER_RESET}"
  echo
  
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "${CYBER_PURPLE}${CYBER_BOLD}DRY-RUN MODE - Running in Dry-Run Mode${CYBER_RESET}"
    echo "${CYBER_DIM}No changes will be made to your system${CYBER_RESET}"
    echo
  fi
  
  # Setup mirror source
  setup_mirror_source
  
  # Update installer script itself first
  update_installer_script
  
  # Check network connectivity (skip in dry-run for faster testing)
  if [[ "$DRY_RUN" != "true" ]]; then
    if ! check_network_connectivity; then
      exit 1
    fi
    echo
  fi
  
  # Check system dependencies
  if ! check_dependencies; then
    exit 1
  fi
  echo
  
  # Show environment info
  echo "${CYBER_NEON_BLUE}${CYBER_BOLD}ENVIRONMENT INFO:${CYBER_RESET}"
  echo "  Default Shell: $SHELL"
  echo "  Target Shell: $CURRENT_SHELL"
  echo "  Config File: $SHELL_CONFIG_FILE"
  echo "  Color Support: $([ "$SUPPORTS_COLOR" == "true" ] && echo "${CYBER_MATRIX_GREEN}Yes${CYBER_RESET}" || echo "${CYBER_NEON_YELLOW}No${CYBER_RESET}")"
  echo
  
  # Get selected plugins BEFORE starting installation
  local selected_plugins=()
  if [[ -n "$CUSTOM_PLUGINS" ]]; then
    IFS=',' read -ra selected_plugins <<< "$CUSTOM_PLUGINS"
    log_info "Using specified plugins: ${selected_plugins[*]}"
  elif [[ "$INTERACTIVE" == "true" ]]; then
    local plugin_selection
    plugin_selection=$(interactive_plugin_selection)
    if [[ -n "$plugin_selection" ]] && [[ "$plugin_selection" != " " ]]; then
      # Trim whitespace and split into array
      plugin_selection=$(echo "$plugin_selection" | xargs)
      if [[ -n "$plugin_selection" ]]; then
        read -ra selected_plugins <<< "$plugin_selection"
      fi
    fi
  else
    selected_plugins=(sysinfo weather taskman)
    log_info "Using default plugins: ${selected_plugins[*]}"
  fi
  
  # Show what was selected
  echo
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    log_success "Selected plugins: ${selected_plugins[*]}"
  else
    log_info "No plugins selected - OSH will be installed with core functionality only"
  fi
  
  # Show installation summary and get confirmation
  show_installation_summary "${selected_plugins[@]}"
  
  # Install OSH with selected plugins
  install_osh "${selected_plugins[@]}"
  
  # Show completion message
  if [[ "$DRY_RUN" != "true" ]]; then
    echo
    echo "${CYBER_MATRIX_GREEN}${CYBER_BOLD}INSTALLATION COMPLETE!${CYBER_RESET}"
    echo
    echo "${CYBER_BOLD}${CYBER_NEON_BLUE}📋 Next Steps:${CYBER_RESET}"
    echo "  1. Restart your terminal or run: ${CYBER_NEON_CYAN}source $SHELL_CONFIG_FILE${CYBER_RESET}"
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
      echo "  2. Try these OSH commands:"
      echo "     ${CYBER_NEON_CYAN}osh status${CYBER_RESET}           # Check OSH.IT status"
      echo "     ${CYBER_NEON_CYAN}osh plugin list${CYBER_RESET}      # List available plugins"
      if [[ " ${selected_plugins[*]} " =~ " weather " ]]; then
        echo "     ${CYBER_NEON_CYAN}weather${CYBER_RESET}              # Beautiful weather display"
      fi
      if [[ " ${selected_plugins[*]} " =~ " sysinfo " ]]; then
        echo "     ${CYBER_NEON_CYAN}sysinfo${CYBER_RESET}             # System info with OSH branding"
      fi
      if [[ " ${selected_plugins[*]} " =~ " taskman " ]]; then
        echo "     ${CYBER_NEON_CYAN}tm${CYBER_RESET}                  # Advanced task manager"
      fi

      echo "  3. Manage OSH:"
      echo "     ${CYBER_NEON_CYAN}osh plugin add <name>${CYBER_RESET} # Add a plugin"
      echo "     ${CYBER_NEON_CYAN}osh upgrade${CYBER_RESET}          # Update OSH.IT"
      echo "     ${CYBER_NEON_CYAN}osh help${CYBER_RESET}             # Show all commands"
    else
      echo "  2. For best experience, consider switching to Zsh:"
      echo "     ${CYBER_NEON_CYAN}chsh -s \$(which zsh)${CYBER_RESET}"
    fi
    echo
    echo "${CYBER_NEON_BLUE}${CYBER_BOLD}NETWORK RESOURCES:${CYBER_RESET}"
    echo "  • Official Website: ${CYBER_NEON_CYAN}https://oiahoon.github.io/osh.it/${CYBER_RESET}"
    echo "  • Documentation: ${CYBER_NEON_CYAN}https://github.com/oiahoon/osh.it/wiki${CYBER_RESET}"
    echo "  • Support: ${CYBER_NEON_CYAN}https://github.com/oiahoon/osh.it/issues${CYBER_RESET}"
    echo
  else
    echo
    log_success "Dry run completed successfully!"
    echo
    echo "${CYBER_BOLD}${CYBER_NEON_BLUE}What would happen:${CYBER_RESET}"
    echo "  1. Download OSH framework files with progress indication"
    echo "  2. Download selected plugin files"
    echo "  3. Set up file permissions"
    echo "  4. Configure shell integration (if not skipped)"
  fi
}

# Run main function
main "$@"
