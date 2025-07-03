#!/usr/bin/env bash
# OSH Display Library
# Beautiful logo and information display functions

# Vintage/Retro gradient colors - softer and more muted
_vintage_1() { printf "\033[38;5;124m%s\033[0m" "$1"; }  # Dark red
_vintage_2() { printf "\033[38;5;130m%s\033[0m" "$1"; }  # Dark orange
_vintage_3() { printf "\033[38;5;136m%s\033[0m" "$1"; }  # Muted yellow-orange
_vintage_4() { printf "\033[38;5;142m%s\033[0m" "$1"; }  # Olive yellow
_vintage_5() { printf "\033[38;5;100m%s\033[0m" "$1"; }  # Dark yellow-green
_vintage_6() { printf "\033[38;5;64m%s\033[0m" "$1"; }   # Forest green
_vintage_7() { printf "\033[38;5;65m%s\033[0m" "$1"; }   # Teal green
_vintage_8() { printf "\033[38;5;66m%s\033[0m" "$1"; }   # Dark teal
_vintage_9() { printf "\033[38;5;67m%s\033[0m" "$1"; }   # Steel blue
_vintage_10() { printf "\033[38;5;68m%s\033[0m" "$1"; }  # Muted blue
_vintage_11() { printf "\033[38;5;69m%s\033[0m" "$1"; }  # Slate blue
_vintage_12() { printf "\033[38;5;61m%s\033[0m" "$1"; }  # Dark blue
_vintage_13() { printf "\033[38;5;97m%s\033[0m" "$1"; }  # Muted purple
_vintage_14() { printf "\033[38;5;96m%s\033[0m" "$1"; }  # Vintage purple
_vintage_15() { printf "\033[38;5;95m%s\033[0m" "$1"; }  # Dark magenta

# Info colors
_info_label() { printf "\033[1;36m%s\033[0m" "$1"; }    # Bright cyan
_info_value() { printf "\033[0;37m%s\033[0m" "$1"; }    # White
_info_accent() { printf "\033[1;33m%s\033[0m" "$1"; }   # Bright yellow
_info_success() { printf "\033[1;32m%s\033[0m" "$1"; }  # Bright green

# Function to calculate display length (excluding ANSI codes)
_get_display_length() {
  local text="$1"
  # More comprehensive ANSI code removal including all escape sequences
  local clean_text=$(echo "$text" | sed -E 's/\x1b\[[0-9;]*[mK]//g' | sed -E 's/\x1b\[38;5;[0-9]+m//g' | sed -E 's/\x1b\[0m//g')
  echo ${#clean_text}
}

# OSH ASCII Logo with vintage gradient colors
_get_osh_logo_lines() {
  printf "%s\n" \
    "" \
    "" \
    "$(_vintage_1 '        ██████╗ ███████╗██╗  ██╗')" \
    "$(_vintage_2 '       ██╔═══██╗██╔════╝██║  ██║')" \
    "$(_vintage_4 '       ██║   ██║███████╗███████║')" \
    "$(_vintage_6 '       ██║   ██║╚════██║██╔══██║')" \
    "$(_vintage_8 '       ╚██████╔╝███████║██║  ██║')" \
    "$(_vintage_10 '        ╚═════╝ ╚══════╝╚═╝  ╚═╝')" \
    "" \
    "$(_vintage_12 '     ╔════════════════════════════════╗')" \
    "$(_vintage_13 '     ║    Lightweight Zsh Framework   ║')" \
    "$(_vintage_14 '     ║      Fast • Simple • Cool      ║')" \
    "$(_vintage_15 '     ╚════════════════════════════════╝')" \
    "" \
    "$(_vintage_3 '       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄')" \
    "$(_vintage_3 '      ▐ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ▌')" \
    "$(_vintage_3 '       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀')" \
    "" \
    "" \
    "" \
    "" \
    ""
}

# Get OSH project information
_get_osh_info_lines() {
  local osh_dir="${OSH:-$HOME/.osh}"
  local version="Development"
  local plugin_count="0"
  local active_plugins=""
  
  # Get version if available
  if [[ -f "$osh_dir/VERSION" ]]; then
    version=$(cat "$osh_dir/VERSION" 2>/dev/null || echo "Development")
  fi
  
  # Count plugins
  if [[ -d "$osh_dir/plugins" ]]; then
    plugin_count=$(find "$osh_dir/plugins" -name "*.plugin.zsh" 2>/dev/null | wc -l | tr -d ' ')
  fi
  
  # Get active plugins
  if [[ -n "${oplugins:-}" ]] && [[ ${#oplugins[@]} -gt 0 ]]; then
    active_plugins="${oplugins[*]}"
    # Truncate if too long
    if [[ ${#active_plugins} -gt 35 ]]; then
      active_plugins="${active_plugins:0:32}..."
    fi
  else
    active_plugins="None configured"
  fi
  
  printf "%s\n" \
    "$(_info_accent 'OSH Framework Information')" \
    "$(_info_accent '=========================')" \
    "$(_info_label 'Version: ')$(_info_value "$version")" \
    "$(_info_label 'Location: ')$(_info_value "$osh_dir")" \
    "$(_info_label 'Plugins: ')$(_info_value "$plugin_count installed")" \
    "$(_info_label 'Active: ')$(_info_value "$active_plugins")" \
    "" \
    "$(_info_accent 'Repository Information')" \
    "$(_info_accent '======================')" \
    "$(_info_label 'GitHub: ')$(_info_value 'https://github.com/oiahoon/osh')" \
    "$(_info_label 'License: ')$(_info_value 'MIT License')" \
    "$(_info_label 'Author: ')$(_info_value 'oiahoon')" \
    "" \
    "$(_info_accent 'Quick Commands')" \
    "$(_info_accent '==============')" \
    "$(_info_label 'sysinfo: ')$(_info_value 'Show system information')" \
    "$(_info_label 'osh_help: ')$(_info_value 'Show help and commands')" \
    "$(_info_label 'osh_info: ')$(_info_value 'Show OSH information')" \
    "" \
    ""
}

# Display OSH logo and info side by side
show_osh_welcome() {
  local logo_lines=()
  local info_lines=()
  
  # Get logo lines using a more compatible method
  local temp_logo_file="/tmp/osh_logo_$$"
  _get_osh_logo_lines > "$temp_logo_file"
  while IFS= read -r line; do
    logo_lines+=("$line")
  done < "$temp_logo_file"
  rm -f "$temp_logo_file"
  
  # Get info lines using a more compatible method
  local temp_info_file="/tmp/osh_info_$$"
  _get_osh_info_lines > "$temp_info_file"
  while IFS= read -r line; do
    info_lines+=("$line")
  done < "$temp_info_file"
  rm -f "$temp_info_file"
  
  # Calculate max lines
  local max_logo=${#logo_lines[@]}
  local max_info=${#info_lines[@]}
  local max_lines=$((max_logo > max_info ? max_logo : max_info))
  
  # Find the maximum actual width of logo lines
  local max_logo_width=0
  for ((i=0; i<max_logo; i++)); do
    local line_width=$(_get_display_length "${logo_lines[$i]}")
    if [[ $line_width -gt $max_logo_width ]]; then
      max_logo_width=$line_width
    fi
  done
  
  # Add some padding to the max width
  local logo_column_width=$((max_logo_width + 2))
  
  # Display side by side with perfect alignment
  for ((i=0; i<max_lines; i++)); do
    local logo_line=""
    local info_line=""
    
    # Get logo line or empty string
    if [[ $i -lt $max_logo ]]; then
      logo_line="${logo_lines[$i]}"
    fi
    
    # Get info line or empty string
    if [[ $i -lt $max_info ]]; then
      info_line="${info_lines[$i]}"
    fi
    
    # Calculate actual display length (without ANSI codes)
    local actual_length=$(_get_display_length "$logo_line")
    
    # Calculate padding needed
    local padding_needed=$((logo_column_width - actual_length))
    if [[ $padding_needed -lt 0 ]]; then
      padding_needed=0
    fi
    
    # Create padding string
    local padding=""
    if [[ $padding_needed -gt 0 ]]; then
      padding=$(printf "%*s" $padding_needed "")
    fi
    
    # Output with consistent formatting
    printf "%s%s%s\n" "$logo_line" "$padding" "$info_line"
  done
}

# Show installation success message
show_install_success() {
  printf "\n"
  printf "%s\n" "$(_info_success "🎉 OSH Installation Complete!")"
  printf "\n"
  show_osh_welcome
  printf "\n"
  printf "%s\n" "$(_info_accent "Next Steps:")"
  printf "%s%s\n" "$(_info_label "1. ")" "$(_info_value "Restart your terminal or run: source ~/.zshrc")"
  printf "%s%s\n" "$(_info_label "2. ")" "$(_info_value "Run 'sysinfo' to see your system information")"
  printf "%s%s\n" "$(_info_label "3. ")" "$(_info_value "Run 'osh_help' for available commands")"
  printf "\n"
}

# Show upgrade success message
show_upgrade_success() {
  printf "\n"
  printf "%s\n" "$(_info_success "🚀 OSH Upgrade Complete!")"
  printf "\n"
  show_osh_welcome
  printf "\n"
  printf "%s\n" "$(_info_accent "What's New:")"
  printf "%s%s\n" "$(_info_label "• ")" "$(_info_value "Check changelog: https://github.com/oiahoon/osh/releases")"
  printf "%s%s\n" "$(_info_label "• ")" "$(_info_value "View commits: git log --oneline -10")"
  printf "\n"
  printf "%s\n" "$(_info_accent "Next Steps:")"
  printf "%s%s\n" "$(_info_label "1. ")" "$(_info_value "Restart your terminal or run: source ~/.zshrc")"
  printf "%s%s\n" "$(_info_label "2. ")" "$(_info_value "Run 'sysinfo' to verify your system")"
  printf "\n"
}
