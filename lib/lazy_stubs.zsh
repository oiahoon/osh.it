#!/usr/bin/env zsh
# OSH Lazy Loading Function Stubs
# Provides lightweight function definitions that load plugins on demand

# Sysinfo lazy stub
sysinfo() {
  # Load the actual plugin
  if osh_lazy_load "sysinfo"; then
    # Undefine this stub function to avoid recursion
    unfunction sysinfo 2>/dev/null || true
    # Call the real function
    sysinfo "$@"
  else
    echo "Failed to load sysinfo plugin" >&2
    return 1
  fi
}

# Weather lazy stub
weather() {
  # Load the actual plugin
  if osh_lazy_load "weather"; then
    # Undefine this stub function to avoid recursion
    unfunction weather 2>/dev/null || true
    # Call the real function
    weather "$@"
  else
    echo "Failed to load weather plugin" >&2
    return 1
  fi
}

# Tasks lazy stub
tasks() {
  # Load the actual plugin
  if osh_lazy_load "taskman"; then
    # Undefine this stub function to avoid recursion
    unfunction tasks 2>/dev/null || true
    # Call the real function
    tasks "$@"
  else
    echo "Failed to load taskman plugin" >&2
    return 1
  fi
}

# ACW lazy stubs
acw() {
  if osh_lazy_load "acw"; then
    unfunction acw 2>/dev/null || true
    acw "$@"
  else
    echo "Failed to load acw plugin" >&2
    return 1
  fi
}

ggco() {
  if osh_lazy_load "acw"; then
    unfunction ggco 2>/dev/null || true
    ggco "$@"
  else
    echo "Failed to load acw plugin" >&2
    return 1
  fi
}

newb() {
  if osh_lazy_load "acw"; then
    unfunction newb 2>/dev/null || true
    newb "$@"
  else
    echo "Failed to load acw plugin" >&2
    return 1
  fi
}

# Aliases
alias tm="tasks"
alias taskman="tasks"
alias wtr="weather"
alias forecast="weather -d"
alias oshinfo="sysinfo"
alias neofetch-osh="sysinfo"
