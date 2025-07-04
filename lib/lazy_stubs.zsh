#!/usr/bin/env zsh
# OSH Lazy Loading Function Stubs
# Provides lightweight function definitions that load plugins on demand

# Helper function to load plugin and replace stub
_osh_load_and_call() {
  local plugin="$1"
  local func_name="$2"
  shift 2
  
  # Load the plugin
  if osh_lazy_load "$plugin"; then
    # The plugin should now define the real function
    # Check if the function exists and is not our stub
    if declare -f "$func_name" >/dev/null && [[ "$(declare -f "$func_name")" != *"_osh_load_and_call"* ]]; then
      # Call the real function
      "$func_name" "$@"
    else
      echo "Plugin $plugin loaded but function $func_name not found" >&2
      return 1
    fi
  else
    echo "Failed to load $plugin plugin" >&2
    return 1
  fi
}

# Sysinfo lazy stub
sysinfo() {
  _osh_load_and_call "sysinfo" "sysinfo" "$@"
}

# Weather lazy stub  
weather() {
  _osh_load_and_call "weather" "weather" "$@"
}

# Tasks lazy stub
tasks() {
  _osh_load_and_call "taskman" "tasks" "$@"
}

# ACW lazy stubs
acw() {
  _osh_load_and_call "acw" "acw" "$@"
}

ggco() {
  _osh_load_and_call "acw" "ggco" "$@"
}

newb() {
  _osh_load_and_call "acw" "newb" "$@"
}

# Aliases
alias tm="TASKMAN_EXPLICIT_CALL=1 tasks ui"  # tm always launches UI explicitly
alias taskman="TASKMAN_EXPLICIT_CALL=1 tasks"
alias wtr="weather"
alias forecast="weather -d"
alias oshinfo="sysinfo"
alias neofetch-osh="sysinfo"
