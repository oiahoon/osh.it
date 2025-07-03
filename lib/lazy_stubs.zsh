#!/usr/bin/env zsh
# OSH Lazy Loading Function Stubs
# Provides lightweight function definitions that load plugins on demand

# Sysinfo lazy stub
sysinfo() {
  # Load the actual plugin
  if osh_lazy_load "sysinfo"; then
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
    acw "$@"
  else
    echo "Failed to load acw plugin" >&2
    return 1
  fi
}

ggco() {
  if osh_lazy_load "acw"; then
    ggco "$@"
  else
    echo "Failed to load acw plugin" >&2
    return 1
  fi
}

newb() {
  if osh_lazy_load "acw"; then
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
