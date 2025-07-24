#!/usr/bin/env bash
# OSH.IT Plugin Discovery System - Shell Compatible Version
# Advanced plugin search, discovery, and metadata management
# Version: 1.0.0

# Ensure cyberpunk styling is loaded
if [[ -z "${OSH_CYBERPUNK_LOADED:-}" ]] && [[ -f "${OSH}/lib/cyberpunk.zsh" ]]; then
  source "${OSH}/lib/cyberpunk.zsh"
fi

# ============================================================================
# PLUGIN METADATA DATABASE
# ============================================================================

# Plugin database with enhanced metadata (shell compatible)
declare -A OSH_PLUGIN_DB

# Initialize plugin database
osh_plugin_init_db() {
  # Stable plugins
  OSH_PLUGIN_DB[sysinfo]="stable|1.1.0|System information display with OSH branding|sysinfo,oshinfo,neofetch-osh||system,info,display"
  OSH_PLUGIN_DB[weather]="stable|1.3.0|Beautiful weather forecast with ASCII art|weather,forecast|curl|weather,forecast,utility"
  OSH_PLUGIN_DB[taskman]="stable|2.0.0|Advanced terminal task manager with productivity features|tm,tasks|python3|productivity,tasks,management"
  
  # Beta plugins
  OSH_PLUGIN_DB[acw]="beta|0.9.0|Advanced Code Workflow - Git + JIRA integration|acw,ggco,newb|git,curl|git,jira,workflow,development"
  OSH_PLUGIN_DB[fzf]="beta|0.8.0|Enhanced fuzzy finder with preview capabilities|pp,fcommit|fzf|search,fuzzy,finder"
  
  # Experimental plugins
  OSH_PLUGIN_DB[greeting]="experimental|0.5.0|Friendly welcome message for OSH users|auto-display||greeting,welcome,ui"
}

# Parse plugin metadata
osh_plugin_parse_metadata() {
  local plugin="$1"
  local metadata="${OSH_PLUGIN_DB[$plugin]}"
  
  if [[ -z "$metadata" ]]; then
    return 1
  fi
  
  # Split metadata: category|version|description|commands|dependencies|tags
  local IFS='|'
  local parts=($metadata)
  
  echo "CATEGORY=${parts[0]}"
  echo "VERSION=${parts[1]}"
  echo "DESCRIPTION=${parts[2]}"
  echo "COMMANDS=${parts[3]}"
  echo "DEPENDENCIES=${parts[4]}"
  echo "TAGS=${parts[5]}"
}

# ============================================================================
# PLUGIN SEARCH FUNCTIONS
# ============================================================================

# Search plugins by keyword
osh_plugin_search() {
  local search_term="$1"
  local search_type="${2:-all}"  # all, name, description, tags, commands
  
  if [[ -z "$search_term" ]]; then
    if command -v osh_cyber_error >/dev/null 2>&1; then
      osh_cyber_error "Search term required"
    else
      echo "Error: Search term required"
    fi
    return 1
  fi
  
  osh_plugin_init_db
  
  local found_plugins=()
  local search_lower=$(echo "$search_term" | tr '[:upper:]' '[:lower:]')
  
  # Shell compatible iteration over associative array keys
  for plugin in "${!OSH_PLUGIN_DB[@]}"; do
    local metadata="${OSH_PLUGIN_DB[$plugin]}"
    local IFS='|'
    local parts=($metadata)
    
    local category="${parts[0]}"
    local version="${parts[1]}"
    local description="${parts[2]}"
    local commands="${parts[3]}"
    local dependencies="${parts[4]}"
    local tags="${parts[5]}"
    
    local match=0
    
    # Check name match
    if [[ "$search_type" == "all" || "$search_type" == "name" ]]; then
      if [[ "$plugin" == *"$search_lower"* ]]; then
        match=1
      fi
    fi
    
    # Check description match
    if [[ "$search_type" == "all" || "$search_type" == "description" ]]; then
      if [[ "$(echo "$description" | tr '[:upper:]' '[:lower:]')" == *"$search_lower"* ]]; then
        match=1
      fi
    fi
    
    # Check tags match
    if [[ "$search_type" == "all" || "$search_type" == "tags" ]]; then
      if [[ "$(echo "$tags" | tr '[:upper:]' '[:lower:]')" == *"$search_lower"* ]]; then
        match=1
      fi
    fi
    
    # Check commands match
    if [[ "$search_type" == "all" || "$search_type" == "commands" ]]; then
      if [[ "$(echo "$commands" | tr '[:upper:]' '[:lower:]')" == *"$search_lower"* ]]; then
        match=1
      fi
    fi
    
    if [[ $match -eq 1 ]]; then
      found_plugins+=("$plugin:$category:$description")
    fi
  done
  
  if [[ ${#found_plugins[@]} -eq 0 ]]; then
    if command -v osh_cyber_warning >/dev/null 2>&1; then
      osh_cyber_warning "No plugins found matching '$search_term'"
    else
      echo "Warning: No plugins found matching '$search_term'"
    fi
    return 1
  fi
  
  # Display results
  if command -v osh_cyber_table_header >/dev/null 2>&1; then
    osh_cyber_table_header
    
    for result in "${found_plugins[@]}"; do
      local IFS=':'
      local parts=($result)
      local plugin="${parts[0]}"
      local category="${parts[1]}"
      local description="${parts[2]}"
      
      # Check if installed
      local status="AVAILABLE"
      if osh_plugin_is_installed "$plugin"; then
        status="INSTALLED"
      fi
      
      osh_cyber_table_row "$plugin" "$status" "$category" "$description"
    done
    
    osh_cyber_table_footer
  else
    # Fallback display
    for result in "${found_plugins[@]}"; do
      local IFS=':'
      local parts=($result)
      local plugin="${parts[0]}"
      local category="${parts[1]}"
      local description="${parts[2]}"
      
      echo "  $plugin ($category) - $description"
    done
  fi
  
  return 0
}

# List plugins by category
osh_plugin_list_by_category() {
  local category="${1:-all}"
  
  osh_plugin_init_db
  
  local plugins=()
  
  for plugin in "${!OSH_PLUGIN_DB[@]}"; do
    local metadata="${OSH_PLUGIN_DB[$plugin]}"
    local IFS='|'
    local parts=($metadata)
    local plugin_category="${parts[0]}"
    
    if [[ "$category" == "all" || "$plugin_category" == "$category" ]]; then
      plugins+=("$plugin:$plugin_category:${parts[2]}")
    fi
  done
  
  # Sort plugins by category, then by name
  IFS=$'\n' plugins=($(sort <<<"${plugins[*]}"))
  
  if command -v osh_cyber_table_header >/dev/null 2>&1; then
    osh_cyber_table_header
    
    for plugin_info in "${plugins[@]}"; do
      local IFS=':'
      local parts=($plugin_info)
      local plugin="${parts[0]}"
      local plugin_category="${parts[1]}"
      local description="${parts[2]}"
      
      # Check if installed
      local status="AVAILABLE"
      if osh_plugin_is_installed "$plugin"; then
        status="INSTALLED"
      fi
      
      osh_cyber_table_row "$plugin" "$status" "$plugin_category" "$description"
    done
    
    osh_cyber_table_footer
  else
    # Fallback display
    local current_category=""
    for plugin_info in "${plugins[@]}"; do
      local IFS=':'
      local parts=($plugin_info)
      local plugin="${parts[0]}"
      local plugin_category="${parts[1]}"
      local description="${parts[2]}"
      
      if [[ "$plugin_category" != "$current_category" ]]; then
        echo ""
        echo "$plugin_category plugins:"
        current_category="$plugin_category"
      fi
      
      echo "  $plugin - $description"
    done
  fi
}

# Get detailed plugin information
osh_plugin_get_info() {
  local plugin="$1"
  
  if [[ -z "$plugin" ]]; then
    if command -v osh_cyber_error >/dev/null 2>&1; then
      osh_cyber_error "Plugin name required"
    else
      echo "Error: Plugin name required"
    fi
    return 1
  fi
  
  osh_plugin_init_db
  
  local metadata="${OSH_PLUGIN_DB[$plugin]}"
  if [[ -z "$metadata" ]]; then
    if command -v osh_cyber_error >/dev/null 2>&1; then
      osh_cyber_error "Plugin '$plugin' not found"
    else
      echo "Error: Plugin '$plugin' not found"
    fi
    return 1
  fi
  
  local IFS='|'
  local parts=($metadata)
  
  local category="${parts[0]}"
  local version="${parts[1]}"
  local description="${parts[2]}"
  local commands="${parts[3]}"
  local dependencies="${parts[4]}"
  local tags="${parts[5]}"
  
  # Display plugin information
  if command -v osh_cyber_accent >/dev/null 2>&1; then
    osh_cyber_accent "PLUGIN INFORMATION: $plugin"
  else
    echo "Plugin Information: $plugin"
  fi
  
  echo ""
  echo "Version: $version"
  echo "Category: $category"
  echo "Description: $description"
  
  if [[ -n "$commands" ]]; then
    echo "Commands: $commands"
  fi
  
  if [[ -n "$dependencies" ]]; then
    echo "Dependencies: $dependencies"
  fi
  
  if [[ -n "$tags" ]]; then
    echo "Tags: $tags"
  fi
  
  # Check installation status
  if osh_plugin_is_installed "$plugin"; then
    if command -v osh_cyber_success >/dev/null 2>&1; then
      osh_cyber_success "Plugin is installed"
    else
      echo "Status: Installed"
    fi
  else
    if command -v osh_cyber_info >/dev/null 2>&1; then
      osh_cyber_info "Plugin is available for installation"
    else
      echo "Status: Available"
    fi
  fi
  
  echo ""
}

# ============================================================================
# PLUGIN UTILITY FUNCTIONS
# ============================================================================

# Check if plugin is installed
osh_plugin_is_installed() {
  local plugin="$1"
  local zshrc_file="$HOME/.zshrc"
  
  if [[ -f "$zshrc_file" ]]; then
    local current_plugins=$(grep "^oplugins=(" "$zshrc_file" 2>/dev/null | sed 's/oplugins=(\(.*\))/\1/' | tr -d '()')
    echo "$current_plugins" | grep -q "\b$plugin\b"
  else
    return 1
  fi
}

# Get all available plugins
osh_plugin_get_all() {
  osh_plugin_init_db
  echo "${!OSH_PLUGIN_DB[@]}"
}

# Get plugins by category
osh_plugin_get_by_category() {
  local category="$1"
  
  osh_plugin_init_db
  
  local plugins=()
  for plugin in "${!OSH_PLUGIN_DB[@]}"; do
    local metadata="${OSH_PLUGIN_DB[$plugin]}"
    local IFS='|'
    local parts=($metadata)
    local plugin_category="${parts[0]}"
    
    if [[ "$plugin_category" == "$category" ]]; then
      plugins+=("$plugin")
    fi
  done
  
  echo "${plugins[@]}"
}

# Get plugin dependencies
osh_plugin_get_dependencies() {
  local plugin="$1"
  
  osh_plugin_init_db
  
  local metadata="${OSH_PLUGIN_DB[$plugin]}"
  if [[ -n "$metadata" ]]; then
    local IFS='|'
    local parts=($metadata)
    local dependencies="${parts[4]}"
    
    if [[ -n "$dependencies" ]]; then
      echo "$dependencies" | tr ',' ' '
    fi
  fi
}

# Check if plugin exists
osh_plugin_exists() {
  local plugin="$1"
  
  osh_plugin_init_db
  
  [[ -n "${OSH_PLUGIN_DB[$plugin]}" ]]
}

# Get plugin category
osh_plugin_get_category() {
  local plugin="$1"
  
  osh_plugin_init_db
  
  local metadata="${OSH_PLUGIN_DB[$plugin]}"
  if [[ -n "$metadata" ]]; then
    local IFS='|'
    local parts=($metadata)
    echo "${parts[0]}"
  fi
}

# Mark as loaded
export OSH_PLUGIN_DISCOVERY_LOADED=1
