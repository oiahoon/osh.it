#!/usr/bin/env zsh
# OSH.IT - A Lightweight Zsh Plugin Framework
# Version: 1.0.0
# Author: oiahoon
# License: MIT

# Ensure we're running in Zsh
if [[ -z "$ZSH_VERSION" ]]; then
  echo "Error: OSH.IT requires Zsh. Please install Zsh and try again."
  return 1
fi

# OSH Configuration
OSH_VERSION="1.1.0"
OSH_MIN_ZSH_VERSION="5.0"

# Default paths
OSH_DEFAULT_DIR="$HOME/.osh"
OSH_CUSTOM_DEFAULT="$HOME/.osh-custom"

# Set OSH directory if not already set
if [[ -z "$OSH" ]]; then
  OSH="$OSH_DEFAULT_DIR"
fi

# Set custom directory if not already set
if [[ -z "$OSH_CUSTOM" ]]; then
  OSH_CUSTOM="$OSH_CUSTOM_DEFAULT"
fi

# Debug mode
OSH_DEBUG="${OSH_DEBUG:-0}"

# Load common libraries
if [[ -f "$OSH/lib/colors.zsh" ]]; then
  source "$OSH/lib/colors.zsh"
fi

if [[ -f "$OSH/lib/common.zsh" ]]; then
  source "$OSH/lib/common.zsh"
fi

# Load caching system
if [[ -f "$OSH/lib/cache.zsh" ]]; then
  source "$OSH/lib/cache.zsh"
fi

# Load vintage design system
if [[ -f "$OSH/lib/vintage.zsh" ]]; then
  source "$OSH/lib/vintage.zsh"
fi

# Logging functions
osh_log() {
  local level="$1"
  shift
  local message="$*"

  case "$level" in
    "ERROR")
      osh_vintage_error "$message" >&2
      ;;
    "WARN")
      osh_vintage_warning "$message" >&2
      ;;
    "INFO")
      if [[ "$OSH_DEBUG" == "1" ]]; then
        osh_vintage_info "$message"
      fi
      ;;
    "DEBUG")
      if [[ "$OSH_DEBUG" == "1" ]]; then
        osh_vintage_info "[DEBUG] $message"
      fi
      ;;
  esac
}

# Version comparison function
osh_version_compare() {
  local version1="$1"
  local version2="$2"

  if [[ "$version1" == "$version2" ]]; then
    return 0
  fi

  # Split versions into arrays
  local IFS=.
  local ver1=($version1)
  local ver2=($version2)

  # Get the maximum length
  local max_len=${#ver1[@]}
  if [[ ${#ver2[@]} -gt $max_len ]]; then
    max_len=${#ver2[@]}
  fi

  # Compare each component
  for ((i=0; i<max_len; i++)); do
    local v1=${ver1[i]:-0}
    local v2=${ver2[i]:-0}

    if ((10#$v1 > 10#$v2)); then
      return 1
    elif ((10#$v1 < 10#$v2)); then
      return 2
    fi
  done

  return 0
}

# Check Zsh version compatibility
osh_check_zsh_version() {
  local current_version="${ZSH_VERSION%%-*}"  # Remove any suffix like -dev

  osh_version_compare "$current_version" "$OSH_MIN_ZSH_VERSION"
  local result=$?

  if [[ $result -eq 2 ]]; then
    osh_log "ERROR" "Zsh version $current_version is not supported. Minimum required: $OSH_MIN_ZSH_VERSION"
    return 1
  fi

  osh_log "DEBUG" "Zsh version $current_version is compatible"
  return 0
}

# Check if a plugin exists
osh_is_plugin() {
  local base_dir="$1"
  local name="$2"

  if [[ -z "$base_dir" || -z "$name" ]]; then
    osh_log "DEBUG" "Invalid parameters for plugin check: base_dir='$base_dir', name='$name'"
    return 1
  fi

  # Check for main plugin file
  if [[ -f "$base_dir/plugins/$name/$name.plugin.zsh" ]]; then
    osh_log "DEBUG" "Found plugin file: $base_dir/plugins/$name/$name.plugin.zsh"
    return 0
  fi

  # Check for completion file (legacy support)
  if [[ -f "$base_dir/plugins/$name/_$name" ]]; then
    osh_log "DEBUG" "Found completion file: $base_dir/plugins/$name/_$name"
    return 0
  fi

  osh_log "DEBUG" "Plugin '$name' not found in '$base_dir'"
  return 1
}

# Load a single plugin (legacy function, kept for compatibility)
osh_load_plugin() {
  osh_load_plugin_immediate "$@"
}

# Load a single plugin immediately (internal function) - moved above


# Add plugin directories to fpath
osh_setup_fpath() {
  osh_log "DEBUG" "Setting up fpath for plugins"

  if [[ -z "$oplugins" ]]; then
    osh_log "DEBUG" "No plugins defined in oplugins array"
    return 0
  fi

  # Add function path
  if [[ -d "$OSH/functions" ]]; then
    fpath=("$OSH/functions" $fpath)
    osh_log "DEBUG" "Added to fpath: $OSH/functions"
  fi

  # Add plugin directories to fpath
  for plugin in $oplugins; do
    # Custom plugins
    if [[ -d "$OSH_CUSTOM" ]] && osh_is_plugin "$OSH_CUSTOM" "$plugin"; then
      fpath=("$OSH_CUSTOM/plugins/$plugin" $fpath)
      osh_log "DEBUG" "Added to fpath: $OSH_CUSTOM/plugins/$plugin"
    # OSH plugins
    elif osh_is_plugin "$OSH" "$plugin"; then
      fpath=("$OSH/plugins/$plugin" $fpath)
      osh_log "DEBUG" "Added to fpath: $OSH/plugins/$plugin"
    fi
  done
}

# Lazy loading support
OSH_LAZY_PLUGINS=()
OSH_LOADED_PLUGINS=()


# Load a single plugin immediately (internal function)
osh_load_plugin_immediate() {
  local plugin="$1"
  local plugin_loaded=0

  if [[ -z "$plugin" ]]; then
    osh_log "WARN" "Empty plugin name provided"
    return 1
  fi

  osh_log "DEBUG" "Loading plugin immediately: $plugin"

  # Try custom directory first
  if [[ -d "$OSH_CUSTOM" ]] && osh_is_plugin "$OSH_CUSTOM" "$plugin"; then
    local plugin_file="$OSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
    if [[ -f "$plugin_file" ]]; then
      osh_log "DEBUG" "Loading custom plugin: $plugin_file"
      source "$plugin_file"
      plugin_loaded=1
    fi
  fi

  # Try main OSH directory if not loaded from custom
  if [[ $plugin_loaded -eq 0 ]] && osh_is_plugin "$OSH" "$plugin"; then
    local plugin_file="$OSH/plugins/$plugin/$plugin.plugin.zsh"
    if [[ -f "$plugin_file" ]]; then
      osh_log "DEBUG" "Loading OSH plugin: $plugin_file"
      source "$plugin_file"
      plugin_loaded=1
    fi
  fi

  if [[ $plugin_loaded -eq 0 ]]; then
    osh_log "ERROR" "Plugin '$plugin' not found"
    return 1
  fi

  return 0
}

# Generic lazy loading function
osh_lazy_load() {
  local plugin="$1"
  
  # Check if plugin is in lazy plugins list
  if [[ ! " ${OSH_LAZY_PLUGINS[*]} " =~ " $plugin " ]]; then
    return 0  # Plugin not registered for lazy loading
  fi
  
  # Check if already loaded
  if [[ " ${OSH_LOADED_PLUGINS[*]} " =~ " $plugin " ]]; then
    return 0  # Already loaded
  fi
  
  osh_log "DEBUG" "Lazy loading plugin: $plugin"
  if osh_load_plugin_immediate "$plugin"; then
    OSH_LOADED_PLUGINS+=("$plugin")
    osh_log "DEBUG" "Successfully lazy loaded: $plugin"
    return 0
  else
    osh_log "ERROR" "Failed to lazy load: $plugin"
    return 1
  fi
}

# Load all plugins (with true lazy loading support)
osh_load_plugins() {
  if [[ -z "$oplugins" ]]; then
    osh_log "INFO" "No plugins to load"
    return 0
  fi

  local loaded_count=0
  local lazy_count=0
  local failed_count=0

  osh_log "INFO" "Processing plugins: ${oplugins[*]}"

  # Check for lazy loading preference
  local lazy_loading="${OSH_LAZY_LOADING:-true}"
  
  for plugin in $oplugins; do
    # Check if plugin should be loaded immediately or lazily
    local load_immediately=false
    
    # Always load essential plugins immediately
    case "$plugin" in
      "greeting"|"proxy")
        load_immediately=true
        ;;
      *)
        if [[ "$lazy_loading" != "true" ]]; then
          load_immediately=true
        fi
        ;;
    esac
    
    if [[ "$load_immediately" == "true" ]]; then
      if osh_load_plugin_immediate "$plugin"; then
        OSH_LOADED_PLUGINS+=("$plugin")
        ((loaded_count++))
      else
        ((failed_count++))
      fi
    else
      # Register for lazy loading (don't load the plugin file yet)
      OSH_LAZY_PLUGINS+=("$plugin")
      ((lazy_count++))
    fi
  done

  # Load lazy loading stubs if lazy loading is enabled
  if [[ "$lazy_loading" == "true" ]] && [[ ${#OSH_LAZY_PLUGINS[@]} -gt 0 ]]; then
    if [[ -f "$OSH/lib/lazy_stubs.zsh" ]]; then
      source "$OSH/lib/lazy_stubs.zsh"
      osh_log "DEBUG" "Loaded lazy loading stubs for: ${OSH_LAZY_PLUGINS[*]}"
    fi
  fi

  osh_log "INFO" "Plugin processing complete: $loaded_count loaded immediately, $lazy_count registered for lazy loading, $failed_count failed"

  if [[ $failed_count -gt 0 ]]; then
    return 1
  fi
  return 0
}

# Upgrade function
osh_upgrade() {
  osh_log "INFO" "Starting OSH upgrade"

  if [[ ! -d "$OSH" ]]; then
    osh_log "ERROR" "OSH directory not found: $OSH"
    return 1
  fi

  if [[ ! -f "$OSH/upgrade.sh" ]]; then
    osh_log "ERROR" "Upgrade script not found: $OSH/upgrade.sh"
    return 1
  fi

  env OSH="$OSH" sh "$OSH/upgrade.sh"
}

# Show OSH.IT welcome information with beautiful logo
osh_welcome() {
  if [[ -f "$OSH/lib/display.sh" ]]; then
    source "$OSH/lib/display.sh"
    show_osh_welcome
  else
    echo "OSH Display Library not found"
    osh_info
  fi
}

# Main upgrade function (for backward compatibility)
upgrade_myshell() {
  osh_upgrade
}

# OSH.IT doctor command
osh_doctor() {
  if [[ -f "$OSH/scripts/osh_doctor.sh" ]]; then
    "$OSH/scripts/osh_doctor.sh" "$@"
  else
    osh_log "ERROR" "OSH.IT doctor script not found: $OSH/scripts/osh_doctor.sh"
    return 1
  fi
}

# Alias for convenience
alias doctor="osh_doctor"

# OSH information function
osh_info() {
  echo "OSH.IT - A Lightweight Zsh Plugin Framework"
  echo "Version: $OSH_VERSION"
  echo "Zsh Version: $ZSH_VERSION"
  echo "OSH Directory: $OSH"
  echo "Custom Directory: $OSH_CUSTOM"
  echo "Debug Mode: $([[ "$OSH_DEBUG" == "1" ]] && echo "ON" || echo "OFF")"
  echo ""
  echo "Loaded Plugins:"
  if [[ -n "$oplugins" ]]; then
    for plugin in $oplugins; do
      echo "  - $plugin"
    done
  else
    echo "  (none)"
  fi
}

# Help function
osh_help() {
  cat << 'EOF'
OSH.IT - A Lightweight Zsh Plugin Framework

Usage:
  osh_info              Show OSH.IT information
  osh_welcome           Show OSH.IT welcome screen with logo
  osh_doctor            Run health check and diagnostics
  osh_help              Show this help message
  upgrade_myshell       Upgrade OSH.IT to latest version

Health & Diagnostics:
  osh_doctor            Run comprehensive health check
  osh_doctor --fix      Auto-fix common issues
  osh_doctor --perf     Include performance test
  doctor                Alias for osh_doctor

Environment Variables:
  OSH                   OSH.IT installation directory (default: ~/.osh)
  OSH_CUSTOM           Custom plugins directory (default: ~/.osh-custom)
  OSH_DEBUG            Enable debug output (0 or 1)
  OSH_MIRROR           Mirror source (github, gitee, custom)
  oplugins             Array of plugins to load

Configuration:
  Add to your ~/.zshrc:
    export OSH=$HOME/.osh
    oplugins=(plugin1 plugin2 plugin3)
    source $OSH/osh.sh

For more information, visit: https://github.com/oiahoon/osh.it
EOF
}

# Initialize OSH
osh_init() {
  osh_log "DEBUG" "Initializing OSH v$OSH_VERSION"

  # Check Zsh version
  if ! osh_check_zsh_version; then
    return 1
  fi

  # Verify OSH directory exists
  if [[ ! -d "$OSH" ]]; then
    osh_log "ERROR" "OSH directory not found: $OSH"
    osh_log "ERROR" "Please run the installation script or set OSH to the correct path"
    return 1
  fi

  # Setup fpath before loading plugins
  osh_setup_fpath

  # Load all plugins
  osh_load_plugins

  osh_log "DEBUG" "OSH initialization complete"
}

# Run initialization
osh_init