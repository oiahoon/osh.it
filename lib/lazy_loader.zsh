#!/usr/bin/env zsh
# OSH.IT Advanced Lazy Loading System
# Version: 2.0.0
# Features: Recursive-safe, performance-optimized, error-resilient

# Global state management
typeset -gA OSH_LAZY_REGISTRY      # Plugin -> Functions mapping
typeset -gA OSH_LAZY_LOADED        # Loaded plugins tracking
typeset -gA OSH_LAZY_LOADING       # Currently loading plugins (prevent recursion)
typeset -gA OSH_LAZY_ALIASES       # Alias -> Plugin mapping
typeset -g OSH_LAZY_DEBUG="${OSH_LAZY_DEBUG:-0}"

# Logging for lazy loader
_osh_lazy_log() {
  local level="$1"
  shift
  if [[ "$OSH_LAZY_DEBUG" == "1" ]] || [[ "$level" == "ERROR" ]]; then
    printf "[OSH-LAZY-%s] %s\n" "$level" "$*" >&2
  fi
}

# Register a plugin for lazy loading
osh_lazy_register() {
  local plugin="$1"
  shift
  local functions=("$@")
  
  if [[ -z "$plugin" ]]; then
    _osh_lazy_log "ERROR" "Plugin name required for registration"
    return 1
  fi
  
  # Store function list for this plugin
  OSH_LAZY_REGISTRY[$plugin]="${functions[*]}"
  
  _osh_lazy_log "DEBUG" "Registered plugin '$plugin' with functions: ${functions[*]}"
  
  # Create lazy stubs for each function
  for func in "${functions[@]}"; do
    _osh_create_lazy_stub "$plugin" "$func"
  done
}

# Register an alias for lazy loading
osh_lazy_register_alias() {
  local alias_name="$1"
  local plugin="$2"
  local target_func="$3"
  
  if [[ -z "$alias_name" || -z "$plugin" ]]; then
    _osh_lazy_log "ERROR" "Alias name and plugin required"
    return 1
  fi
  
  # Check if alias already exists to avoid conflicts
  if alias "$alias_name" >/dev/null 2>&1; then
    _osh_lazy_log "DEBUG" "Alias '$alias_name' already exists, skipping lazy registration"
    return 0
  fi
  
  OSH_LAZY_ALIASES[$alias_name]="$plugin:${target_func:-$alias_name}"
  
  # Create alias stub only if it doesn't exist
  eval "alias $alias_name='_osh_lazy_alias_stub $alias_name'"
  
  _osh_lazy_log "DEBUG" "Registered alias '$alias_name' -> '$plugin:${target_func:-$alias_name}'"
}

# Create a lazy stub function
_osh_create_lazy_stub() {
  local plugin="$1"
  local func_name="$2"
  
  # Check if function already exists to avoid conflicts
  if declare -f "$func_name" >/dev/null 2>&1; then
    _osh_lazy_log "DEBUG" "Function '$func_name' already exists, skipping lazy stub creation"
    return 0
  fi
  
  # Create the stub function with unique name to avoid conflicts
  eval "
    $func_name() {
      _osh_lazy_load_and_call '$plugin' '$func_name' \"\$@\"
    }
  "
  
  _osh_lazy_log "DEBUG" "Created lazy stub for '$func_name' (plugin: $plugin)"
}

# Handle lazy alias calls
_osh_lazy_alias_stub() {
  local alias_name="$1"
  shift
  
  local plugin_func="${OSH_LAZY_ALIASES[$alias_name]}"
  if [[ -z "$plugin_func" ]]; then
    _osh_lazy_log "ERROR" "Alias '$alias_name' not registered"
    return 1
  fi
  
  local plugin="${plugin_func%:*}"
  local func="${plugin_func#*:}"
  
  _osh_lazy_load_and_call "$plugin" "$func" "$@"
}

# Core lazy loading function with recursion protection
_osh_lazy_load_and_call() {
  local plugin="$1"
  local func_name="$2"
  shift 2
  
  # Check for recursion
  if [[ -n "${OSH_LAZY_LOADING[$plugin]}" ]]; then
    _osh_lazy_log "ERROR" "Recursive loading detected for plugin '$plugin'"
    return 1
  fi
  
  # Check if already loaded
  if [[ -n "${OSH_LAZY_LOADED[$plugin]}" ]]; then
    _osh_lazy_log "DEBUG" "Plugin '$plugin' already loaded, calling function directly"
    if declare -f "$func_name" >/dev/null; then
      "$func_name" "$@"
      return $?
    else
      _osh_lazy_log "ERROR" "Function '$func_name' not found after plugin load"
      return 1
    fi
  fi
  
  # Mark as loading to prevent recursion
  OSH_LAZY_LOADING[$plugin]=1
  
  _osh_lazy_log "DEBUG" "Loading plugin '$plugin' for function '$func_name'"
  
  # Load the plugin
  local load_success=0
  if _osh_lazy_load_plugin "$plugin"; then
    OSH_LAZY_LOADED[$plugin]=1
    load_success=1
    _osh_lazy_log "DEBUG" "Successfully loaded plugin '$plugin'"
  else
    _osh_lazy_log "ERROR" "Failed to load plugin '$plugin'"
  fi
  
  # Clear loading flag
  unset "OSH_LAZY_LOADING[$plugin]"
  
  if [[ $load_success -eq 0 ]]; then
    return 1
  fi
  
  # Replace stub with real function and call it
  if declare -f "$func_name" >/dev/null; then
    # Verify it's not still our stub
    local func_body="$(declare -f "$func_name")"
    if [[ "$func_body" == *"_osh_lazy_load_and_call"* ]]; then
      _osh_lazy_log "ERROR" "Plugin '$plugin' did not replace stub for '$func_name'"
      return 1
    fi
    
    _osh_lazy_log "DEBUG" "Calling real function '$func_name'"
    "$func_name" "$@"
    return $?
  else
    _osh_lazy_log "ERROR" "Function '$func_name' not defined after loading plugin '$plugin'"
    return 1
  fi
}

# Load a plugin (internal function)
_osh_lazy_load_plugin() {
  local plugin="$1"
  
  # Try custom directory first
  if [[ -d "$OSH_CUSTOM" ]] && [[ -f "$OSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ]]; then
    local plugin_file="$OSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh"
    _osh_lazy_log "DEBUG" "Loading custom plugin: $plugin_file"
    source "$plugin_file" 2>/dev/null
    return $?
  fi
  
  # Try main OSH directory
  if [[ -f "$OSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
    local plugin_file="$OSH/plugins/$plugin/$plugin.plugin.zsh"
    _osh_lazy_log "DEBUG" "Loading OSH plugin: $plugin_file"
    source "$plugin_file" 2>/dev/null
    return $?
  fi
  
  _osh_lazy_log "ERROR" "Plugin file not found for '$plugin'"
  return 1
}

# Initialize lazy loading for common plugins
osh_lazy_init_defaults() {
  # Only initialize lazy loading for plugins that are NOT in the current oplugins array
  # This prevents conflicts with plugins that are loaded immediately
  
  local -a current_plugins
  if [[ -n "${oplugins[@]}" ]]; then
    current_plugins=("${oplugins[@]}")
  fi
  
  # Helper function to check if plugin is in current plugins list
  _is_plugin_active() {
    local plugin="$1"
    for active_plugin in "${current_plugins[@]}"; do
      if [[ "$active_plugin" == "$plugin" ]]; then
        return 0
      fi
    done
    return 1
  }
  
  # Weather plugin - only if not actively loaded
  if ! _is_plugin_active "weather"; then
    osh_lazy_register "weather" "weather"
    osh_lazy_register_alias "wtr" "weather" "weather"
    osh_lazy_register_alias "forecast" "weather" "weather"
  fi
  
  # Sysinfo plugin - only if not actively loaded
  if ! _is_plugin_active "sysinfo"; then
    osh_lazy_register "sysinfo" "sysinfo"
    osh_lazy_register_alias "oshinfo" "sysinfo" "sysinfo"
    osh_lazy_register_alias "neofetch-osh" "sysinfo" "sysinfo"
  fi
  
  # Taskman plugin - only if not actively loaded
  if ! _is_plugin_active "taskman"; then
    osh_lazy_register "taskman" "tasks"
    osh_lazy_register_alias "tm" "taskman" "tasks"
    osh_lazy_register_alias "taskman" "taskman" "tasks"
    osh_lazy_register_alias "task" "taskman" "tasks"
    osh_lazy_register_alias "todo" "taskman" "tasks"
  fi
  
  # ACW plugin - only if not actively loaded
  if ! _is_plugin_active "acw"; then
    osh_lazy_register "acw" "acw" "ggco" "newb"
  fi
  
  # FZF plugin - only if not actively loaded
  if ! _is_plugin_active "fzf"; then
    osh_lazy_register "fzf" "pp" "fcommit"
  fi
  
  _osh_lazy_log "DEBUG" "Default lazy loading configuration initialized (skipped active plugins: ${current_plugins[*]})"
}

# Check if lazy loading is enabled for a plugin
osh_lazy_is_enabled() {
  local plugin="$1"
  [[ -n "${OSH_LAZY_REGISTRY[$plugin]}" ]]
}

# Get lazy loading statistics
osh_lazy_stats() {
  echo "OSH.IT Lazy Loading Statistics:"
  echo "  Registered plugins: ${#OSH_LAZY_REGISTRY[@]}"
  echo "  Loaded plugins: ${#OSH_LAZY_LOADED[@]}"
  echo "  Currently loading: ${#OSH_LAZY_LOADING[@]}"
  echo ""
  
  if [[ ${#OSH_LAZY_REGISTRY[@]} -gt 0 ]]; then
    echo "Registered plugins:"
    for plugin in "${(@k)OSH_LAZY_REGISTRY}"; do
      local plugin_status="pending"
      if [[ -n "${OSH_LAZY_LOADED[$plugin]}" ]]; then
        plugin_status="loaded"
      elif [[ -n "${OSH_LAZY_LOADING[$plugin]}" ]]; then
        plugin_status="loading"
      fi
      echo "  - $plugin [$plugin_status]: ${OSH_LAZY_REGISTRY[$plugin]}"
    done
  fi
  
  if [[ ${#OSH_LAZY_ALIASES[@]} -gt 0 ]]; then
    echo ""
    echo "Registered aliases:"
    for alias_name in "${(@k)OSH_LAZY_ALIASES}"; do
      echo "  - $alias_name -> ${OSH_LAZY_ALIASES[$alias_name]}"
    done
  fi
}

# Force load a plugin (for testing/debugging)
osh_lazy_force_load() {
  local plugin="$1"
  
  if [[ -z "$plugin" ]]; then
    _osh_lazy_log "ERROR" "Plugin name required"
    return 1
  fi
  
  if [[ -n "${OSH_LAZY_LOADED[$plugin]}" ]]; then
    _osh_lazy_log "DEBUG" "Plugin '$plugin' already loaded"
    return 0
  fi
  
  _osh_lazy_log "DEBUG" "Force loading plugin '$plugin'"
  
  OSH_LAZY_LOADING[$plugin]=1
  local result=0
  if _osh_lazy_load_plugin "$plugin"; then
    OSH_LAZY_LOADED[$plugin]=1
    _osh_lazy_log "DEBUG" "Successfully force loaded plugin '$plugin'"
  else
    _osh_lazy_log "ERROR" "Failed to force load plugin '$plugin'"
    result=1
  fi
  
  unset "OSH_LAZY_LOADING[$plugin]"
  return $result
}

# Preload critical plugins (for plugins that must be loaded immediately)
osh_lazy_preload() {
  local plugins=("$@")
  
  for plugin in "${plugins[@]}"; do
    if osh_lazy_is_enabled "$plugin"; then
      _osh_lazy_log "DEBUG" "Preloading critical plugin: $plugin"
      osh_lazy_force_load "$plugin"
    fi
  done
}

# Clean up lazy loading state (for testing/debugging)
osh_lazy_reset() {
  OSH_LAZY_REGISTRY=()
  OSH_LAZY_LOADED=()
  OSH_LAZY_LOADING=()
  OSH_LAZY_ALIASES=()
  _osh_lazy_log "DEBUG" "Lazy loading state reset"
}

# Export functions for external use
autoload -U osh_lazy_register osh_lazy_register_alias osh_lazy_stats osh_lazy_force_load osh_lazy_preload
