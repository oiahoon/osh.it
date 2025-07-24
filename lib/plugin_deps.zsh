#!/usr/bin/env zsh
# OSH.IT Plugin Dependency Management System
# Automatic dependency detection, installation, and conflict resolution
# Version: 1.0.0

# Ensure required libraries are loaded
if [[ -z "${OSH_CYBERPUNK_LOADED:-}" ]] && [[ -f "${OSH}/lib/cyberpunk.zsh" ]]; then
  source "${OSH}/lib/cyberpunk.zsh"
fi

if [[ -z "${OSH_PLUGIN_DISCOVERY_LOADED:-}" ]] && [[ -f "${OSH}/lib/plugin_discovery.zsh" ]]; then
  source "${OSH}/lib/plugin_discovery.zsh"
fi

# ============================================================================
# DEPENDENCY DETECTION
# ============================================================================

# Check if a command exists
osh_deps_command_exists() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1
}

# Check system dependencies for a plugin
osh_deps_check_plugin() {
  local plugin="$1"
  local missing_deps=()
  local available_deps=()
  
  # Get plugin dependencies
  local deps=$(osh_plugin_get_dependencies "$plugin")
  
  if [[ -z "$deps" ]]; then
    return 0  # No dependencies
  fi
  
  for dep in $deps; do
    if osh_deps_command_exists "$dep"; then
      available_deps+=("$dep")
    else
      missing_deps+=("$dep")
    fi
  done
  
  # Store results in global arrays for caller to use
  OSH_DEPS_MISSING=("${missing_deps[@]}")
  OSH_DEPS_AVAILABLE=("${available_deps[@]}")
  
  return ${#missing_deps[@]}
}

# Check dependencies for multiple plugins
osh_deps_check_multiple() {
  local plugins=("$@")
  local all_missing=()
  local all_available=()
  
  for plugin in "${plugins[@]}"; do
    osh_deps_check_plugin "$plugin"
    
    # Merge results
    all_missing+=("${OSH_DEPS_MISSING[@]}")
    all_available+=("${OSH_DEPS_AVAILABLE[@]}")
  done
  
  # Remove duplicates
  all_missing=($(printf '%s\n' "${all_missing[@]}" | sort -u))
  all_available=($(printf '%s\n' "${all_available[@]}" | sort -u))
  
  OSH_DEPS_MISSING=("${all_missing[@]}")
  OSH_DEPS_AVAILABLE=("${all_available[@]}")
  
  return ${#all_missing[@]}
}

# ============================================================================
# DEPENDENCY INSTALLATION HELPERS
# ============================================================================

# Get installation command for a dependency
osh_deps_get_install_cmd() {
  local dep="$1"
  local os=$(uname -s)
  
  case "$dep" in
    "curl")
      case "$os" in
        "Darwin") echo "brew install curl" ;;
        "Linux") 
          if command -v apt-get >/dev/null 2>&1; then
            echo "sudo apt-get install curl"
          elif command -v yum >/dev/null 2>&1; then
            echo "sudo yum install curl"
          elif command -v pacman >/dev/null 2>&1; then
            echo "sudo pacman -S curl"
          else
            echo "# Please install curl using your package manager"
          fi
          ;;
        *) echo "# Please install curl for your system" ;;
      esac
      ;;
    "python3")
      case "$os" in
        "Darwin") echo "brew install python3" ;;
        "Linux")
          if command -v apt-get >/dev/null 2>&1; then
            echo "sudo apt-get install python3"
          elif command -v yum >/dev/null 2>&1; then
            echo "sudo yum install python3"
          elif command -v pacman >/dev/null 2>&1; then
            echo "sudo pacman -S python"
          else
            echo "# Please install python3 using your package manager"
          fi
          ;;
        *) echo "# Please install python3 for your system" ;;
      esac
      ;;
    "git")
      case "$os" in
        "Darwin") echo "brew install git" ;;
        "Linux")
          if command -v apt-get >/dev/null 2>&1; then
            echo "sudo apt-get install git"
          elif command -v yum >/dev/null 2>&1; then
            echo "sudo yum install git"
          elif command -v pacman >/dev/null 2>&1; then
            echo "sudo pacman -S git"
          else
            echo "# Please install git using your package manager"
          fi
          ;;
        *) echo "# Please install git for your system" ;;
      esac
      ;;
    "fzf")
      case "$os" in
        "Darwin") echo "brew install fzf" ;;
        "Linux")
          if command -v apt-get >/dev/null 2>&1; then
            echo "sudo apt-get install fzf"
          elif command -v yum >/dev/null 2>&1; then
            echo "sudo yum install fzf"
          elif command -v pacman >/dev/null 2>&1; then
            echo "sudo pacman -S fzf"
          else
            echo "# Please install fzf using your package manager"
          fi
          ;;
        *) echo "# Please install fzf for your system" ;;
      esac
      ;;
    *)
      echo "# Please install $dep manually"
      ;;
  esac
}

# ============================================================================
# DEPENDENCY REPORTING
# ============================================================================

# Display dependency status for a plugin
osh_deps_show_status() {
  local plugin="$1"
  
  if ! osh_plugin_exists "$plugin"; then
    osh_cyber_error "Plugin '$plugin' not found"
    return 1
  fi
  
  osh_deps_check_plugin "$plugin"
  local missing_count=$?
  
  if command -v osh_cyber_accent >/dev/null 2>&1; then
    osh_cyber_accent "DEPENDENCY STATUS: $plugin"
  else
    echo "Dependency Status: $plugin"
  fi
  
  echo ""
  
  if [[ ${#OSH_DEPS_AVAILABLE[@]} -gt 0 ]]; then
    if command -v osh_cyber_success >/dev/null 2>&1; then
      osh_cyber_success "Available dependencies:"
    else
      echo "✓ Available dependencies:"
    fi
    
    for dep in "${OSH_DEPS_AVAILABLE[@]}"; do
      echo "  ✓ $dep"
    done
    echo ""
  fi
  
  if [[ ${#OSH_DEPS_MISSING[@]} -gt 0 ]]; then
    if command -v osh_cyber_warning >/dev/null 2>&1; then
      osh_cyber_warning "Missing dependencies:"
    else
      echo "⚠ Missing dependencies:"
    fi
    
    for dep in "${OSH_DEPS_MISSING[@]}"; do
      local install_cmd=$(osh_deps_get_install_cmd "$dep")
      echo "  ✗ $dep"
      echo "    Install: $install_cmd"
    done
    echo ""
  fi
  
  if [[ $missing_count -eq 0 ]]; then
    if command -v osh_cyber_success >/dev/null 2>&1; then
      osh_cyber_success "All dependencies satisfied"
    else
      echo "✓ All dependencies satisfied"
    fi
  else
    if command -v osh_cyber_error >/dev/null 2>&1; then
      osh_cyber_error "$missing_count missing dependencies"
    else
      echo "✗ $missing_count missing dependencies"
    fi
  fi
  
  return $missing_count
}

# Display dependency summary for multiple plugins
osh_deps_show_summary() {
  local plugins=("$@")
  
  if [[ ${#plugins[@]} -eq 0 ]]; then
    osh_cyber_error "No plugins specified"
    return 1
  fi
  
  osh_deps_check_multiple "${plugins[@]}"
  local missing_count=$?
  
  if command -v osh_cyber_accent >/dev/null 2>&1; then
    osh_cyber_accent "DEPENDENCY SUMMARY"
  else
    echo "Dependency Summary"
  fi
  
  echo ""
  echo "Plugins: ${plugins[*]}"
  echo ""
  
  if [[ ${#OSH_DEPS_AVAILABLE[@]} -gt 0 ]]; then
    if command -v osh_cyber_success >/dev/null 2>&1; then
      osh_cyber_success "Available dependencies (${#OSH_DEPS_AVAILABLE[@]}):"
    else
      echo "✓ Available dependencies (${#OSH_DEPS_AVAILABLE[@]}):"
    fi
    
    for dep in "${OSH_DEPS_AVAILABLE[@]}"; do
      echo "  ✓ $dep"
    done
    echo ""
  fi
  
  if [[ ${#OSH_DEPS_MISSING[@]} -gt 0 ]]; then
    if command -v osh_cyber_warning >/dev/null 2>&1; then
      osh_cyber_warning "Missing dependencies (${#OSH_DEPS_MISSING[@]}):"
    else
      echo "⚠ Missing dependencies (${#OSH_DEPS_MISSING[@]}):"
    fi
    
    for dep in "${OSH_DEPS_MISSING[@]}"; do
      local install_cmd=$(osh_deps_get_install_cmd "$dep")
      echo "  ✗ $dep"
      echo "    Install: $install_cmd"
    done
    echo ""
  fi
  
  if [[ $missing_count -eq 0 ]]; then
    if command -v osh_cyber_success >/dev/null 2>&1; then
      osh_cyber_success "All dependencies satisfied for ${#plugins[@]} plugins"
    else
      echo "✓ All dependencies satisfied for ${#plugins[@]} plugins"
    fi
  else
    if command -v osh_cyber_error >/dev/null 2>&1; then
      osh_cyber_error "$missing_count missing dependencies across ${#plugins[@]} plugins"
    else
      echo "✗ $missing_count missing dependencies across ${#plugins[@]} plugins"
    fi
  fi
  
  return $missing_count
}

# ============================================================================
# INTERACTIVE DEPENDENCY INSTALLATION
# ============================================================================

# Interactive dependency installer
osh_deps_install_interactive() {
  local plugin="$1"
  
  if ! osh_plugin_exists "$plugin"; then
    osh_cyber_error "Plugin '$plugin' not found"
    return 1
  fi
  
  osh_deps_check_plugin "$plugin"
  local missing_count=$?
  
  if [[ $missing_count -eq 0 ]]; then
    osh_cyber_success "All dependencies for '$plugin' are already satisfied"
    return 0
  fi
  
  osh_cyber_info "Plugin '$plugin' has missing dependencies"
  echo ""
  
  for dep in "${OSH_DEPS_MISSING[@]}"; do
    local install_cmd=$(osh_deps_get_install_cmd "$dep")
    
    echo "Missing dependency: $dep"
    echo "Install command: $install_cmd"
    echo ""
    
    if [[ "$install_cmd" != "#"* ]]; then
      read -q "REPLY?Install $dep now? (y/n): "
      echo ""
      
      if [[ "$REPLY" == "y" ]]; then
        echo "Running: $install_cmd"
        eval "$install_cmd"
        
        if osh_deps_command_exists "$dep"; then
          osh_cyber_success "Successfully installed $dep"
        else
          osh_cyber_error "Failed to install $dep"
        fi
      else
        osh_cyber_info "Skipped installation of $dep"
      fi
    else
      osh_cyber_warning "Manual installation required for $dep"
    fi
    
    echo ""
  done
  
  # Re-check dependencies
  osh_deps_check_plugin "$plugin"
  return $?
}

# Batch dependency checker for presets
osh_deps_check_preset() {
  local preset="$1"
  local plugins=()
  
  case "$preset" in
    "minimal")
      plugins=("sysinfo")
      ;;
    "recommended")
      plugins=("sysinfo" "weather" "taskman")
      ;;
    "developer")
      plugins=("sysinfo" "weather" "taskman" "acw" "fzf")
      ;;
    "full")
      plugins=("sysinfo" "weather" "taskman" "acw" "fzf" "greeting")
      ;;
    *)
      osh_cyber_error "Unknown preset: $preset"
      return 1
      ;;
  esac
  
  osh_deps_show_summary "${plugins[@]}"
}

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

# Global arrays to store dependency check results
typeset -ga OSH_DEPS_MISSING
typeset -ga OSH_DEPS_AVAILABLE

# Mark as loaded
export OSH_PLUGIN_DEPS_LOADED=1
