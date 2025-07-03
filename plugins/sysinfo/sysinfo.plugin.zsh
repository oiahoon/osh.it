#!/usr/bin/env zsh
# System Info Plugin for OSH - Fixed Version
# A neofetch-inspired system information display tool

# Load common libraries
if [[ -z "${OSH_COMMON_LOADED:-}" ]] && [[ -f "${OSH}/lib/common.zsh" ]]; then
  source "${OSH}/lib/common.zsh"
fi

# Force color output with printf and echo -e
_sysinfo_print_color() {
  local color_code="$1"
  local text="$2"
  local reset="\033[0m"
  
  # Always output colors - let terminal handle it
  echo -e "${color_code}${text}${reset}"
}

# Enhanced color functions with vintage gradient support
_logo_red() { echo -e "\033[1;31m$1\033[0m"; }      # Bright red
_logo_green() { echo -e "\033[1;32m$1\033[0m"; }    # Bright green  
_logo_yellow() { echo -e "\033[1;33m$1\033[0m"; }   # Bright yellow
_logo_blue() { echo -e "\033[1;34m$1\033[0m"; }     # Bright blue
_logo_magenta() { echo -e "\033[1;35m$1\033[0m"; }  # Bright magenta
_logo_cyan() { echo -e "\033[1;36m$1\033[0m"; }     # Bright cyan
_logo_white() { echo -e "\033[1;37m$1\033[0m"; }    # Bright white

# Vintage/Retro gradient colors - softer and more muted
_vintage_1() { echo -e "\033[38;5;124m$1\033[0m"; }  # Dark red
_vintage_2() { echo -e "\033[38;5;130m$1\033[0m"; }  # Dark orange
_vintage_3() { echo -e "\033[38;5;136m$1\033[0m"; }  # Muted yellow-orange
_vintage_4() { echo -e "\033[38;5;142m$1\033[0m"; }  # Olive yellow
_vintage_5() { echo -e "\033[38;5;100m$1\033[0m"; }  # Dark yellow-green
_vintage_6() { echo -e "\033[38;5;64m$1\033[0m"; }   # Forest green
_vintage_7() { echo -e "\033[38;5;65m$1\033[0m"; }   # Teal green
_vintage_8() { echo -e "\033[38;5;66m$1\033[0m"; }   # Dark teal
_vintage_9() { echo -e "\033[38;5;67m$1\033[0m"; }   # Steel blue
_vintage_10() { echo -e "\033[38;5;68m$1\033[0m"; }  # Muted blue
_vintage_11() { echo -e "\033[38;5;69m$1\033[0m"; }  # Slate blue
_vintage_12() { echo -e "\033[38;5;61m$1\033[0m"; }  # Dark blue
_vintage_13() { echo -e "\033[38;5;97m$1\033[0m"; }  # Muted purple
_vintage_14() { echo -e "\033[38;5;96m$1\033[0m"; }  # Vintage purple
_vintage_15() { echo -e "\033[38;5;95m$1\033[0m"; }  # Dark magenta

_info_label() { echo -e "\033[1;36m$1\033[0m"; }    # Bright cyan
_info_value() { echo -e "\033[0;37m$1\033[0m"; }    # White
_info_accent() { echo -e "\033[1;33m$1\033[0m"; }   # Bright yellow

# Function to calculate actual display length without ANSI codes
_get_display_length() {
  local text="$1"
  # More comprehensive ANSI code removal including all escape sequences
  local clean_text=$(echo "$text" | sed -E 's/\x1b\[[0-9;]*[mK]//g' | sed -E 's/\x1b\[38;5;[0-9]+m//g' | sed -E 's/\x1b\[0m//g')
  echo ${#clean_text}
}

# Debug function to show actual lengths
_debug_lengths() {
  local logo_lines=()
  while IFS= read -r line; do
    logo_lines+=("$line")
  done < <(_get_logo_lines)
  
  echo "Logo line lengths:"
  for ((i=0; i<${#logo_lines[@]}; i++)); do
    local len=$(_get_display_length "${logo_lines[$i]}")
    echo "Line $i: $len chars"
  done
}

# Function to truncate text if too long
_truncate_text() {
  local text="$1"
  local max_length="${2:-50}"
  
  if [[ ${#text} -gt $max_length ]]; then
    echo "${text:0:$((max_length-3))}..."
  else
    echo "$text"
  fi
}

# Get system information functions with caching
_get_os_info() {
  osh_cache_exec "os_info" 86400 "sysinfo" _get_os_info_fresh
}

_get_os_info_fresh() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local version=$(sw_vers -productVersion)
    local build=$(sw_vers -buildVersion)
    echo "macOS ${version} ${build} $(uname -m)"
  elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$PRETTY_NAME"
  else
    uname -s
  fi
}

_get_host_info() {
  osh_cache_exec "host_info" 86400 "sysinfo" _get_host_info_fresh
}

_get_host_info_fresh() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d: -f2 | sed 's/^ *//'
  else
    cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || echo "Unknown"
  fi
}

_get_kernel_info() {
  osh_cache_exec "kernel_info" 86400 "sysinfo" uname -r
}

_get_uptime_info() {
  # Don't cache uptime as it changes frequently
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local uptime_seconds=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
    local current_time=$(date +%s)
    local uptime=$((current_time - uptime_seconds))
    local days=$((uptime / 86400))
    local hours=$(((uptime % 86400) / 3600))
    local minutes=$(((uptime % 3600) / 60))
    
    if [[ $days -gt 0 ]]; then
      echo "${days} days, ${hours} hours, ${minutes} mins"
    elif [[ $hours -gt 0 ]]; then
      echo "${hours} hours, ${minutes} mins"
    else
      echo "${minutes} mins"
    fi
  else
    uptime -p 2>/dev/null | sed 's/up //' || uptime | sed 's/.*up \([^,]*\).*/\1/'
  fi
}

_get_packages_info() {
  osh_cache_exec "packages_info" 3600 "sysinfo" _get_packages_info_fresh
}

_get_packages_info_fresh() {
  if command -v brew >/dev/null 2>&1; then
    local brew_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    echo "${brew_count} (brew)"
  else
    echo "Unknown"
  fi
}

_get_shell_info() {
  osh_cache_exec "shell_info" 86400 "sysinfo" _get_shell_info_fresh
}

_get_shell_info_fresh() {
  echo "${SHELL##*/} ${ZSH_VERSION:-${BASH_VERSION:-unknown}}"
}

_get_resolution_info() {
  osh_cache_exec "resolution_info" 3600 "sysinfo" _get_resolution_info_fresh
}

_get_resolution_info_fresh() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local resolution=$(system_profiler SPDisplaysDataType | grep Resolution | head -1 | sed 's/.*Resolution: //' | cut -d',' -f1)
    echo "$(_truncate_text "${resolution:-Unknown}" 30)"
  else
    echo "Unknown"
  fi
}

_get_terminal_info() {
  echo "${TERM_PROGRAM:-${TERM:-unknown}}"
}

_get_cpu_info() {
  osh_cache_exec "cpu_info" 86400 "sysinfo" _get_cpu_info_fresh
}

_get_cpu_info_fresh() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown CPU")
    echo "$(_truncate_text "$cpu" 35)"
  else
    local cpu=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ *//' 2>/dev/null || echo "Unknown CPU")
    echo "$(_truncate_text "$cpu" 35)"
  fi
}

_get_gpu_info() {
  osh_cache_exec "gpu_info" 86400 "sysinfo" _get_gpu_info_fresh
}

_get_gpu_info_fresh() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local gpu=$(system_profiler SPDisplaysDataType | grep "Chipset Model" | head -1 | cut -d: -f2 | sed 's/^ *//')
    echo "$(_truncate_text "${gpu:-Unknown GPU}" 35)"
  else
    echo "Unknown GPU"
  fi
}

_get_memory_info() {
  # Don't cache memory info as it changes frequently
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local total_mem=$(sysctl -n hw.memsize 2>/dev/null)
    local used_mem=$(vm_stat | grep "Pages active\|Pages inactive\|Pages speculative\|Pages wired down" | awk '{sum += $3} END {print sum * 4096}')
    if [[ -n "$total_mem" && -n "$used_mem" ]]; then
      local total_gb=$((total_mem / 1024 / 1024))
      local used_gb=$((used_mem / 1024 / 1024))
      echo "${used_gb}MiB / ${total_gb}MiB"
    else
      echo "Unknown"
    fi
  else
    free -m 2>/dev/null | grep "Mem:" | awk '{printf "%dMiB / %dMiB", $3, $2}'
  fi
}

# OSH.IT ASCII Logo with vintage gradient colors
_get_logo_lines() {
  # Using vintage/retro colors for a softer, more muted effect
  printf "%s\n" \
    "" \
    "" \
    "$(_vintage_1 '        ██████╗ ███████╗██╗  ██╗   ██╗████████╗')" \
    "$(_vintage_2 '       ██╔═══██╗██╔════╝██║  ██║   ██║╚══██╔══╝')" \
    "$(_vintage_4 '       ██║   ██║███████╗███████║   ██║   ██║   ')" \
    "$(_vintage_6 '       ██║   ██║╚════██║██╔══██║   ██║   ██║   ')" \
    "$(_vintage_8 '       ╚██████╔╝███████║██║  ██║██╗██║   ██║   ')" \
    "$(_vintage_10 '        ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝╚═╝   ╚═╝   ')" \
    "" \
    "$(_vintage_12 '     ╔════════════════════════════════════════╗')" \
    "$(_vintage_13 '     ║      Lightweight Zsh Framework         ║')" \
    "$(_vintage_14 '     ║        Fast • Simple • Cool            ║')" \
    "$(_vintage_15 '     ╚════════════════════════════════════════╝')" \
    "" \
    "$(_vintage_3 '       ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄')" \
    "$(_vintage_3 '      ▐ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ▌')" \
    "$(_vintage_3 '       ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀')" \
    "" \
    "" \
    "" \
    "" \
    ""
}

# Get system info lines with color palette on the right
_get_info_lines() {
  local username=$(whoami)
  local hostname=$(hostname -s)
  
  # Create color palette lines
  local palette_line1="   "
  local palette_line2="   "
  for i in {0..7}; do
    palette_line1+="\033[4${i}m   \033[0m"
    palette_line2+="\033[10${i}m   \033[0m"
  done
  
  printf "%s\n" \
    "$(_info_accent "${username}@${hostname}")" \
    "$(_info_accent "$(printf '%*s' ${#username}+${#hostname}+1 '' | tr ' ' '-')")" \
    "$(_info_label 'OS: ')$(_info_value "$(_get_os_info)")" \
    "$(_info_label 'Host: ')$(_info_value "$(_get_host_info)")" \
    "$(_info_label 'Kernel: ')$(_info_value "$(_get_kernel_info)")" \
    "$(_info_label 'Uptime: ')$(_info_value "$(_get_uptime_info)")" \
    "$(_info_label 'Packages: ')$(_info_value "$(_get_packages_info)")" \
    "$(_info_label 'Shell: ')$(_info_value "$(_get_shell_info)")" \
    "$(_info_label 'Resolution: ')$(_info_value "$(_get_resolution_info)")" \
    "$(_info_label 'Terminal: ')$(_info_value "$(_get_terminal_info)")" \
    "$(_info_label 'CPU: ')$(_info_value "$(_get_cpu_info)")" \
    "$(_info_label 'GPU: ')$(_info_value "$(_get_gpu_info)")" \
    "$(_info_label 'Memory: ')$(_info_value "$(_get_memory_info)")" \
    "" \
    "$(_info_accent 'OSH.IT Framework:')" \
    "$(_info_label 'Version: ')$(_info_value "$(cat ${OSH}/VERSION 2>/dev/null || echo 'Development')")" \
    "$(_info_label 'Location: ')$(_info_value "${OSH}")" \
    "$(_info_label 'Plugins: ')$(_info_value "$(find "${OSH}/plugins" -name "*.plugin.zsh" 2>/dev/null | wc -l | tr -d ' ') installed")" \
    "$(if [[ ${#oplugins[@]} -gt 0 ]]; then echo "$(_info_label 'Active: ')$(_info_value "$(_truncate_text "${oplugins[*]}" 40)")"; fi)" \
    "" \
    "$(_info_accent 'Colors:')" \
    "$(echo -e "$palette_line1")" \
    "$(echo -e "$palette_line2")" \
    ""
}

# Color palette display
_show_color_palette() {
  echo ""
  echo ""
  
  # Standard colors
  printf "   "
  for i in {0..7}; do
    printf "\033[4${i}m   \033[0m"
  done
  echo ""
  
  # Bright colors  
  printf "   "
  for i in {0..7}; do
    printf "\033[10${i}m   \033[0m"
  done
  echo ""
  echo ""
}

# Fixed side-by-side display with perfect alignment
_show_side_by_side() {
  # Get all lines first
  local logo_lines=()
  local info_lines=()
  
  # Read logo lines into array
  while IFS= read -r line; do
    logo_lines+=("$line")
  done < <(_get_logo_lines)
  
  # Read info lines into array  
  while IFS= read -r line; do
    info_lines+=("$line")
  done < <(_get_info_lines)
  
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

# Main sysinfo function
sysinfo() {
  _sysinfo_main "$@"
}

# Internal sysinfo function
_sysinfo_main() {
  local show_logo=true
  local debug_mode=false
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --no-logo)
        show_logo=false
        shift
        ;;
      --debug)
        debug_mode=true
        shift
        ;;
      -h|--help)
        echo "Usage: sysinfo [options]"
        echo ""
        echo "Options:"
        echo "  --no-logo    Hide the OSH.IT logo"
        echo "  --debug      Show debug information"
        echo "  -h, --help   Show this help message"
        return 0
        ;;
      *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
  done
  
  # Debug mode output
  if [[ "$debug_mode" == "true" ]]; then
    echo "Debug Info:"
    echo "TERM: $TERM"
    echo "TERM_PROGRAM: ${TERM_PROGRAM:-not set}"
    echo "Color test:"
    _logo_red "RED"
    _logo_green "GREEN" 
    _logo_blue "BLUE"
    echo ""
    _debug_lengths
    echo ""
  fi
  
  if [[ "$show_logo" == "true" ]]; then
    _show_side_by_side
  else
    _get_info_lines
  fi
}

# Aliases for convenience
alias neofetch-osh="sysinfo"
alias oshinfo="sysinfo"
