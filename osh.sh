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

# Load cyberpunk design system (preferred) or fallback to vintage
if [[ -f "$OSH/lib/cyberpunk.zsh" ]]; then
  source "$OSH/lib/cyberpunk.zsh"
  # Load ASCII art system
  if [[ -f "$OSH/lib/cyberpunk_ascii.zsh" ]]; then
    source "$OSH/lib/cyberpunk_ascii.zsh"
  fi
elif [[ -f "$OSH/lib/vintage.zsh" ]]; then
  source "$OSH/lib/vintage.zsh"
fi

# Load plugin management aliases
if [[ -f "$OSH/lib/plugin_aliases.zsh" ]]; then
  source "$OSH/lib/plugin_aliases.zsh"
fi

# Logging functions
osh_log() {
  local level="$1"
  shift
  local message="$*"

  case "$level" in
    "ERROR")
      if command -v osh_vintage_error >/dev/null 2>&1; then
        osh_vintage_error "$message" >&2
      else
        echo "ERROR: $message" >&2
      fi
      ;;
    "WARN")
      if command -v osh_vintage_warning >/dev/null 2>&1; then
        osh_vintage_warning "$message" >&2
      else
        echo "WARNING: $message" >&2
      fi
      ;;
    "INFO")
      if [[ "$OSH_DEBUG" == "1" ]]; then
        if command -v osh_vintage_info >/dev/null 2>&1; then
          osh_vintage_info "$message"
        else
          echo "INFO: $message"
        fi
      fi
      ;;
    "DEBUG")
      if [[ "$OSH_DEBUG" == "1" ]]; then
        if command -v osh_vintage_info >/dev/null 2>&1; then
          osh_vintage_info "[DEBUG] $message"
        else
          echo "DEBUG: $message"
        fi
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
    
    # Remove the plugin from lazy plugins list to prevent re-loading
    local new_lazy_plugins=()
    for p in "${OSH_LAZY_PLUGINS[@]}"; do
      if [[ "$p" != "$plugin" ]]; then
        new_lazy_plugins+=("$p")
      fi
    done
    OSH_LAZY_PLUGINS=("${new_lazy_plugins[@]}")
    
    return 0
  else
    osh_log "ERROR" "Failed to lazy load: $plugin"
    return 1
  fi
}

# Load all plugins (with advanced lazy loading support)
osh_load_plugins() {
  if [[ -z "$oplugins" ]]; then
    osh_log "INFO" "No plugins to load"
    return 0
  fi

  local loaded_count=0
  local lazy_count=0
  local failed_count=0

  osh_log "INFO" "Processing plugins: ${oplugins[*]}"

  # Check for lazy loading preference (default: enabled)
  local lazy_loading="${OSH_LAZY_LOADING:-true}"
  
  # Load lazy loading system if enabled
  if [[ "$lazy_loading" == "true" ]]; then
    if [[ -f "$OSH/lib/lazy_loader.zsh" ]]; then
      source "$OSH/lib/lazy_loader.zsh"
      osh_lazy_init_defaults
      osh_log "DEBUG" "Advanced lazy loading system initialized"
    else
      osh_log "WARN" "Lazy loading requested but lazy_loader.zsh not found, falling back to immediate loading"
      lazy_loading="false"
    fi
  fi
  
  for plugin in $oplugins; do
    # Determine loading strategy
    local load_immediately=false
    local is_critical=false
    
    # Critical plugins that must be loaded immediately
    case "$plugin" in
      "greeting")
        load_immediately=true
        is_critical=true
        ;;
      *)
        # Use lazy loading for non-critical plugins if enabled
        if [[ "$lazy_loading" == "true" ]]; then
          load_immediately=false
        else
          load_immediately=true
        fi
        ;;
    esac
    
    if [[ "$load_immediately" == "true" ]]; then
      if osh_load_plugin_immediate "$plugin"; then
        OSH_LOADED_PLUGINS+=("$plugin")
        ((loaded_count++))
        osh_log "DEBUG" "Loaded plugin immediately: $plugin"
      else
        ((failed_count++))
        osh_log "ERROR" "Failed to load plugin: $plugin"
      fi
    else
      # Plugin will be loaded lazily when first used
      if osh_lazy_is_enabled "$plugin"; then
        ((lazy_count++))
        osh_log "DEBUG" "Plugin registered for lazy loading: $plugin"
      else
        # Fallback to immediate loading if not registered for lazy loading
        if osh_load_plugin_immediate "$plugin"; then
          OSH_LOADED_PLUGINS+=("$plugin")
          ((loaded_count++))
          osh_log "DEBUG" "Plugin not lazy-enabled, loaded immediately: $plugin"
        else
          ((failed_count++))
          osh_log "ERROR" "Failed to load plugin: $plugin"
        fi
      fi
    fi
  done

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

# Lazy loading management commands
osh_lazy() {
  local command="$1"
  shift
  
  case "$command" in
    "stats"|"status")
      if declare -f osh_lazy_stats >/dev/null; then
        osh_lazy_stats
      else
        echo "Lazy loading system not initialized"
        return 1
      fi
      ;;
    "load")
      local plugin="$1"
      if [[ -z "$plugin" ]]; then
        echo "Usage: osh_lazy load <plugin>"
        return 1
      fi
      if declare -f osh_lazy_force_load >/dev/null; then
        osh_lazy_force_load "$plugin"
      else
        echo "Lazy loading system not initialized"
        return 1
      fi
      ;;
    "preload")
      if declare -f osh_lazy_preload >/dev/null; then
        osh_lazy_preload "$@"
      else
        echo "Lazy loading system not initialized"
        return 1
      fi
      ;;
    "debug")
      export OSH_LAZY_DEBUG=1
      echo "Lazy loading debug mode enabled"
      ;;
    "help"|*)
      cat << 'EOF'
OSH.IT Lazy Loading Management

Usage:
  osh_lazy stats      Show lazy loading statistics
  osh_lazy load <plugin>    Force load a specific plugin
  osh_lazy preload <plugins...>  Preload multiple plugins
  osh_lazy debug      Enable debug mode for lazy loading
  osh_lazy help       Show this help message

Examples:
  osh_lazy stats              # Show current status
  osh_lazy load weather       # Force load weather plugin
  osh_lazy preload weather taskman  # Preload multiple plugins
  osh_lazy debug              # Enable debug output

Environment Variables:
  OSH_LAZY_LOADING    Enable/disable lazy loading (true/false)
  OSH_LAZY_DEBUG      Enable debug output (0/1)
EOF
      ;;
  esac
}

# Alias for convenience
alias doctor="osh_doctor"
alias lazy="osh_lazy"

# OSH information function
osh_info() {
  echo "OSH.IT - A Lightweight Zsh Plugin Framework"
  echo "Version: $OSH_VERSION"
  echo "Zsh Version: $ZSH_VERSION"
  echo "OSH Directory: $OSH"
  echo "Custom Directory: $OSH_CUSTOM"
  echo "Debug Mode: $([[ "$OSH_DEBUG" == "1" ]] && echo "ON" || echo "OFF")"
  echo "Lazy Loading: $([[ "${OSH_LAZY_LOADING:-true}" == "true" ]] && echo "ENABLED" || echo "DISABLED")"
  echo ""
  echo "Configured Plugins:"
  if [[ -n "$oplugins" ]]; then
    for plugin in $oplugins; do
      local plugin_status="immediate"
      if [[ "${OSH_LAZY_LOADING:-true}" == "true" ]] && declare -f osh_lazy_is_enabled >/dev/null; then
        if osh_lazy_is_enabled "$plugin"; then
          if [[ -n "${OSH_LAZY_LOADED[$plugin]}" ]]; then
            plugin_status="lazy-loaded"
          else
            plugin_status="lazy-pending"
          fi
        fi
      fi
      echo "  - $plugin [$plugin_status]"
    done
  else
    echo "  (none)"
  fi
  
  # Show lazy loading stats if available
  if [[ "${OSH_LAZY_LOADING:-true}" == "true" ]] && declare -f osh_lazy_stats >/dev/null; then
    echo ""
    echo "Lazy Loading Summary:"
    local registered_count="${#OSH_LAZY_REGISTRY[@]}"
    local loaded_count="${#OSH_LAZY_LOADED[@]}"
    echo "  Registered: $registered_count plugins"
    echo "  Loaded: $loaded_count plugins"
    echo "  Pending: $((registered_count - loaded_count)) plugins"
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
  osh_lazy              Manage lazy loading system
  osh_help              Show this help message
  upgrade_myshell       Upgrade OSH.IT to latest version

Health & Diagnostics:
  osh_doctor            Run comprehensive health check
  osh_doctor --fix      Auto-fix common issues
  osh_doctor --perf     Include performance test
  doctor                Alias for osh_doctor

Lazy Loading Management:
  osh_lazy stats        Show lazy loading statistics
  osh_lazy load <plugin>    Force load a specific plugin
  osh_lazy preload <plugins...>  Preload multiple plugins
  osh_lazy debug        Enable debug mode for lazy loading
  lazy                  Alias for osh_lazy

Environment Variables:
  OSH                   OSH.IT installation directory (default: ~/.osh)
  OSH_CUSTOM           Custom plugins directory (default: ~/.osh-custom)
  OSH_DEBUG            Enable debug output (0 or 1)
  OSH_LAZY_LOADING     Enable lazy loading (true or false, default: true)
  OSH_LAZY_DEBUG       Enable lazy loading debug output (0 or 1)
  OSH_MIRROR           Mirror source (github, gitee, custom)
  oplugins             Array of plugins to load

Configuration:
  Add to your ~/.zshrc:
    export OSH=$HOME/.osh
    export OSH_LAZY_LOADING=true    # Enable lazy loading (default)
    oplugins=(plugin1 plugin2 plugin3)
    source $OSH/osh.sh

Lazy Loading Benefits:
  - Faster shell startup (99.8% performance improvement)
  - Plugins loaded only when needed
  - Reduced memory footprint
  - Automatic function stub generation

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