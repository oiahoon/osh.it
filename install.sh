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
  
  log_info "Using mirror: $OSH_MIRROR ($OSH_REPO_BASE)"
}

# Network connectivity check
check_network_connectivity() {
  log_info "🌐 Checking network connectivity..."
  
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
      
      log_success "✅ Connected to $url (${response_time}s)"
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
      log_warning "❌ Failed to connect to $url"
    fi
  done
  
  if [[ "$connected" == "false" ]]; then
    log_error "❌ Network connectivity check failed"
    echo
    echo "${BOLD}${YELLOW}Network Troubleshooting:${NORMAL}"
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
      log_info "🚀 Auto-selecting faster mirror: $fastest_mirror"
      OSH_MIRROR="$fastest_mirror"
    fi
  fi
  
  return 0
}

# Dependency check with OS-specific guidance
check_dependencies() {
  log_info "🔍 Checking system dependencies..."
  
  local essential_deps=("curl" "git")
  local recommended_deps=("zsh" "python3")
  local missing_essential=()
  local missing_recommended=()
  
  # Check essential dependencies
  for dep in "${essential_deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_essential+=("$dep")
      log_error "❌ Missing essential dependency: $dep"
    else
      log_success "✅ Found: $dep"
    fi
  done
  
  # Check recommended dependencies
  for dep in "${recommended_deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_recommended+=("$dep")
      log_warning "⚠️  Missing recommended dependency: $dep"
    else
      log_success "✅ Found: $dep"
    fi
  done
  
  # Provide installation guidance
  if [[ ${#missing_essential[@]} -gt 0 ]] || [[ ${#missing_recommended[@]} -gt 0 ]]; then
    echo
    echo "${BOLD}${BLUE}📦 Dependency Installation Guide:${NORMAL}"
    
    # Detect OS and provide specific instructions
    local os_type=""
    if [[ "$OSTYPE" =~ darwin ]]; then
      os_type="macOS"
      echo "${BOLD}macOS (Homebrew):${NORMAL}"
      [[ ${#missing_essential[@]} -gt 0 ]] && echo "  brew install ${missing_essential[*]}"
      [[ ${#missing_recommended[@]} -gt 0 ]] && echo "  brew install ${missing_recommended[*]}"
    elif [[ "$OSTYPE" =~ linux ]]; then
      os_type="Linux"
      echo "${BOLD}Ubuntu/Debian:${NORMAL}"
      [[ ${#missing_essential[@]} -gt 0 ]] && echo "  sudo apt update && sudo apt install ${missing_essential[*]}"
      [[ ${#missing_recommended[@]} -gt 0 ]] && echo "  sudo apt install ${missing_recommended[*]}"
      echo
      echo "${BOLD}CentOS/RHEL/Fedora:${NORMAL}"
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
      printf "${YELLOW}Continue anyway? [y/N]: ${NORMAL}"
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

# Color setup
setup_colors() {
  if [[ "$SUPPORTS_COLOR" == "true" ]]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
    WHITE="$(tput setaf 7)"
    BOLD="$(tput bold)"
    DIM="$(tput dim)"
    NORMAL="$(tput sgr0)"
  else
    RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN="" WHITE=""
    BOLD="" DIM="" NORMAL=""
  fi
}

# Logging functions
log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*" >&2; }
log_dry_run() { printf "${CYAN}🔍${NORMAL} ${DIM}[DRY RUN]${NORMAL} %s\n" "$*"; }
log_progress() { printf "${MAGENTA}📥 %s${NORMAL}" "$*"; }

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
  echo "${pad_str}${BOLD}${CYAN}      A Modern Zsh Framework${NORMAL}"
  echo "${pad_str}${DIM}      Lightweight Alternative to Oh My Zsh${NORMAL}"
  echo
}

# Download function
download_file() {
  local url="$1"
  local output="$2"
  
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output" 2>/dev/null
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$output" 2>/dev/null
  else
    log_error "Neither curl nor wget is available"
    return 1
  fi
}

# Interactive plugin selection
interactive_plugin_selection() {
  echo
  log_info "🔌 Plugin Selection"
  echo
  echo "Available plugins:"
  echo "  ${BOLD}1.${NORMAL} sysinfo  - System information display with OSH.IT branding"
  echo "  ${BOLD}2.${NORMAL} weather  - Beautiful weather forecast with ASCII art"
  echo "  ${BOLD}3.${NORMAL} taskman  - Advanced terminal task manager"
  echo "  ${BOLD}4.${NORMAL} acw      - Advanced Code Workflow (Git + JIRA integration)"
  echo "  ${BOLD}5.${NORMAL} fzf      - Enhanced fuzzy finder with preview"
  echo "  ${BOLD}6.${NORMAL} greeting - Friendly welcome message"
  echo
  echo "Installation presets:"
  echo "  ${CYAN}preset:minimal${NORMAL}     - Basic functionality only"
  echo "  ${CYAN}preset:recommended${NORMAL} - sysinfo, weather, taskman (default)"
  echo "  ${CYAN}preset:developer${NORMAL}   - recommended + acw, fzf"
  echo "  ${CYAN}preset:full${NORMAL}        - All stable plugins"
  echo
  echo "Selection options:"
  echo "  • Enter numbers: ${YELLOW}1 2 3${NORMAL} (space-separated)"
  echo "  • Use presets: ${YELLOW}preset:recommended${NORMAL}"
  echo "  • Install all: ${YELLOW}all${NORMAL} or ${YELLOW}a${NORMAL}"
  echo "  • Default: Press ${YELLOW}Enter${NORMAL} for recommended preset"
  echo
  
  local selection
  printf "${BLUE}Your choice: ${NORMAL}"
  read -r selection
  
  # Handle empty input (default)
  if [[ -z "$selection" ]]; then
    selection="preset:recommended"
  fi
  
  # Process selection
  case "$selection" in
    "preset:minimal")
      echo ""
      ;;
    "preset:recommended")
      echo "sysinfo weather taskman"
      ;;
    "preset:developer")
      echo "sysinfo weather taskman acw fzf"
      ;;
    "preset:full")
      echo "sysinfo weather taskman acw fzf"
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
          *) log_warning "Unknown selection: $num" ;;
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
  echo "${BOLD}What will be installed:${NORMAL}"
  echo "  • OSH.IT core framework"
  echo "  • Essential libraries and utilities"
  
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    echo "  • Selected plugins: ${CYAN}${selected_plugins[*]}${NORMAL}"
  else
    echo "  • ${DIM}No plugins selected${NORMAL}"
  fi
  
  echo
  echo "${BOLD}Installation location:${NORMAL} $OSH_DIR"
  echo "${BOLD}Shell configuration:${NORMAL} $SHELL_CONFIG_FILE"
  echo
  
  if [[ "$INTERACTIVE" == "true" ]]; then
    printf "${YELLOW}Continue with installation? [Y/n]: ${NORMAL}"
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
  "lib/colors.zsh"
  "lib/common.zsh"
  "lib/display.sh"
  "lib/lazy_stubs.zsh"
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
      # Only include files that actually exist
      echo "plugins/taskman/taskman.plugin.zsh"
      # Skip taskman_ui.zsh and config/taskman.conf as they don't exist in remote repo
      ;;
    "acw")
      echo "plugins/acw/acw.plugin.zsh"
      ;;
    "fzf")
      echo "plugins/fzf/fzf.plugin.zsh"
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
  log_info "🔧 Configuring shell integration..."
  
  # Check if OSH is already configured
  if [[ -f "$SHELL_CONFIG_FILE" ]] && grep -q "source.*osh.sh" "$SHELL_CONFIG_FILE"; then
    log_info "OSH.IT is already configured in $SHELL_CONFIG_FILE"
    return 0
  fi
  
  # Prepare configuration
  local config_block=""
  config_block+="# OSH.IT Configuration - Added by installer\n"
  config_block+="export OSH=\"\$HOME/.osh\"\n"
  
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
    echo "${BOLD}Shell Configuration:${NORMAL}"
    echo "The installer can automatically add OSH.IT configuration to your $SHELL_CONFIG_FILE"
    echo
    echo "Configuration to be added:"
    printf "${DIM}%b${NORMAL}\n" "$config_block"
    
    printf "${YELLOW}Add OSH.IT configuration to $SHELL_CONFIG_FILE? [Y/n]: ${NORMAL}"
    local confirm
    read -r confirm
    
    case "$confirm" in
      [nN]|[nN][oO])
        log_info "Skipping automatic shell configuration"
        echo
        echo "${BOLD}${BLUE}Manual Configuration Required:${NORMAL}"
        echo "Add the following to your $SHELL_CONFIG_FILE:"
        echo
        printf "${CYAN}%b${NORMAL}\n" "$config_block"
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
  log_info "📦 Downloading OSH core files..."
  local total_files=${#ESSENTIAL_FILES[@]}
  local current=0
  
  for file in "${ESSENTIAL_FILES[@]}"; do
    current=$((current + 1))
    
    if [[ "$DRY_RUN" == "true" ]]; then
      log_dry_run "[$current/$total_files] Would download: $file"
    else
      printf "${BLUE}[%d/%d]${NORMAL} " "$current" "$total_files"
      
      local url="${OSH_REPO_BASE}/${file}"
      local output="${OSH_DIR}/${file}"
      
      mkdir -p "$(dirname "$output")"
      
      if ! download_file "$url" "$output"; then
        log_error "Failed to download $file"
        return 1
      fi
    fi
  done
  
  # Download plugin files with progress
  if [[ ${#selected_plugins[@]} -gt 0 ]]; then
    echo
    log_info "🔌 Downloading selected plugins..."
    
    local plugin_count=0
    
    for plugin in "${selected_plugins[@]}"; do
      # Skip empty plugin names
      if [[ -z "$plugin" ]]; then
        continue
      fi
      
      plugin_count=$((plugin_count + 1))
      echo
      log_info "[$plugin_count/${#selected_plugins[@]}] Installing plugin: ${BOLD}$plugin${NORMAL}"
      
      local plugin_files
      plugin_files=$(get_plugin_files "$plugin" 2>/dev/null)
      
      if [[ $? -eq 0 && -n "$plugin_files" ]]; then
        while read -r plugin_file; do
          if [[ -n "$plugin_file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
              log_dry_run "  Would download: $plugin_file"
            else
              printf "  "
              local url="${OSH_REPO_BASE}/${plugin_file}"
              local output="${OSH_DIR}/${plugin_file}"
              
              mkdir -p "$(dirname "$output")"
              
              if ! download_file "$url" "$output"; then
                log_warning "Failed to download $plugin_file (plugin: $plugin)"
              fi
            fi
          fi
        done <<< "$plugin_files"
      else
        log_warning "Plugin '$plugin' not found or invalid"
      fi
    done
  fi
  
  # Set permissions
  echo
  log_info "🔧 Setting up file permissions..."
  if [[ "$DRY_RUN" != "true" ]]; then
    chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
    chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
    find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true
    find "$OSH_DIR" -name "*.sh" -exec chmod 644 {} \; 2>/dev/null || true
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
${BOLD}OSH Installation Script${NORMAL}

${BOLD}DESCRIPTION:${NORMAL}
  OSH is a lightweight, high-performance Zsh plugin framework designed as a
  modern alternative to Oh My Zsh with 99.8% faster startup times.

${BOLD}USAGE:${NORMAL}
  $0 [OPTIONS]

${BOLD}OPTIONS:${NORMAL}
  --dry-run              Preview installation without making changes
  --yes                  Non-interactive installation with defaults
  --skip-shell-config    Skip automatic shell configuration
  --plugins PLUGINS      Comma-separated list of plugins to install
  --help                 Show this help message

${BOLD}EXAMPLES:${NORMAL}
  # Interactive installation (recommended)
  $0

  # Quick non-interactive install
  $0 --yes

  # Install with specific plugins
  $0 --plugins "weather,taskman"

  # Preview installation
  $0 --dry-run

${BOLD}AVAILABLE PLUGINS:${NORMAL}
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
main() {
  detect_environment
  setup_colors
  parse_args "$@"
  
  # Show logo and welcome
  show_logo
  echo "${BOLD}${GREEN}Welcome to OSH.IT Installation!${NORMAL}"
  echo
  
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "${BOLD}${MAGENTA}🔍 Running in Dry-Run Mode${NORMAL}"
    echo "${DIM}No changes will be made to your system${NORMAL}"
    echo
  fi
  
  # Setup mirror source
  setup_mirror_source
  
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
  echo "${BOLD}${BLUE}🔍 Environment Information${NORMAL}"
  echo "  Default Shell: $SHELL"
  echo "  Target Shell: $CURRENT_SHELL"
  echo "  Config File: $SHELL_CONFIG_FILE"
  echo "  Color Support: $([ "$SUPPORTS_COLOR" == "true" ] && echo "${GREEN}Yes${NORMAL}" || echo "${YELLOW}No${NORMAL}")"
  echo
  
  # Get selected plugins BEFORE starting installation
  local selected_plugins=()
  if [[ -n "$CUSTOM_PLUGINS" ]]; then
    IFS=',' read -ra selected_plugins <<< "$CUSTOM_PLUGINS"
    log_info "Using specified plugins: ${selected_plugins[*]}"
  elif [[ "$INTERACTIVE" == "true" ]]; then
    local plugin_selection
    plugin_selection=$(interactive_plugin_selection)
    if [[ -n "$plugin_selection" ]]; then
      read -ra selected_plugins <<< "$plugin_selection"
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
    echo "${BOLD}${GREEN}🎉 Installation Complete!${NORMAL}"
    echo
    echo "${BOLD}${BLUE}📋 Next Steps:${NORMAL}"
    echo "  1. Restart your terminal or run: ${CYAN}source $SHELL_CONFIG_FILE${NORMAL}"
    if [[ "$CURRENT_SHELL" == "zsh" ]]; then
      echo "  2. Try these OSH features:"
      if [[ " ${selected_plugins[*]} " =~ " weather " ]]; then
        echo "     ${CYAN}weather${NORMAL}              # Beautiful weather display"
      fi
      if [[ " ${selected_plugins[*]} " =~ " sysinfo " ]]; then
        echo "     ${CYAN}sysinfo${NORMAL}             # System info with OSH branding"
      fi
      if [[ " ${selected_plugins[*]} " =~ " taskman " ]]; then
        echo "     ${CYAN}tm${NORMAL}                  # Advanced task manager"
      fi

      echo "  3. Update OSH: ${CYAN}upgrade_myshell${NORMAL}"
    else
      echo "  2. For best experience, consider switching to Zsh:"
      echo "     ${CYAN}chsh -s \$(which zsh)${NORMAL}"
    fi
    echo
  else
    echo
    log_success "Dry run completed successfully!"
    echo
    echo "${BOLD}${BLUE}What would happen:${NORMAL}"
    echo "  1. Download OSH framework files with progress indication"
    echo "  2. Download selected plugin files"
    echo "  3. Set up file permissions"
    echo "  4. Configure shell integration (if not skipped)"
  fi
}

# Run main function
main "$@"
