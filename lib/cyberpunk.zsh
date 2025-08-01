#!/usr/bin/env zsh
# OSH.IT Cyberpunk Design System
# Unified cyberpunk styling and color palette for geek/hacker aesthetic
# Version: 1.0.0

# Ensure this library is only loaded once
if [[ -n "${OSH_CYBERPUNK_LOADED:-}" ]]; then
  return 0
fi

# ============================================================================
# CYBERPUNK COLOR PALETTE
# ============================================================================
# Inspired by cyberpunk aesthetics: neon lights, matrix code, hacker terminals

# Primary Cyberpunk Colors (True Color + 256-color fallback)
export OSH_CYBER_NEON_BLUE=$'\033[38;2;0;255;255m'      # Electric blue - Primary UI
export OSH_CYBER_MATRIX_GREEN=$'\033[38;2;0;255;65m'    # Matrix green - Success
export OSH_CYBER_ALERT_RED=$'\033[38;2;255;0;64m'       # Alert red - Errors
export OSH_CYBER_PURPLE=$'\033[38;2;138;43;226m'        # UV purple - Special
export OSH_CYBER_ORANGE=$'\033[38;2;255;165;0m'         # Neon orange - Warnings
export OSH_CYBER_PINK=$'\033[38;2;255;20;147m'          # Hot pink - Highlights
export OSH_CYBER_YELLOW=$'\033[38;2;255;255;0m'         # Electric yellow - Info

# Background and text colors
export OSH_CYBER_DARK_BG=$'\033[48;2;10;10;10m'         # Deep black background
export OSH_CYBER_DARK_GRAY=$'\033[38;2;64;64;64m'       # Dark gray - Secondary text
export OSH_CYBER_LIGHT_GRAY=$'\033[38;2;192;192;192m'   # Light gray - Primary text
export OSH_CYBER_WHITE=$'\033[38;2;255;255;255m'        # Pure white - Emphasis

# 256-color fallbacks for older terminals
export OSH_CYBER_NEON_BLUE_256=$'\033[38;5;51m'         # Bright cyan
export OSH_CYBER_MATRIX_GREEN_256=$'\033[38;5;46m'      # Bright green
export OSH_CYBER_ALERT_RED_256=$'\033[38;5;196m'        # Bright red
export OSH_CYBER_PURPLE_256=$'\033[38;5;129m'           # Medium purple
export OSH_CYBER_ORANGE_256=$'\033[38;5;208m'           # Orange
export OSH_CYBER_PINK_256=$'\033[38;5;199m'             # Hot pink
export OSH_CYBER_YELLOW_256=$'\033[38;5;226m'           # Yellow

# Special effects
export OSH_CYBER_BOLD=$'\033[1m'                         # Bold text
export OSH_CYBER_DIM=$'\033[2m'                          # Dimmed text
export OSH_CYBER_BLINK=$'\033[5m'                        # Blinking text (use sparingly)
export OSH_CYBER_REVERSE=$'\033[7m'                      # Reverse video
export OSH_CYBER_RESET=$'\033[0m'                        # Reset all formatting

# Semantic color mappings
export OSH_CYBER_SUCCESS="$OSH_CYBER_MATRIX_GREEN"
export OSH_CYBER_ERROR="$OSH_CYBER_ALERT_RED"
export OSH_CYBER_WARNING="$OSH_CYBER_ORANGE"
export OSH_CYBER_INFO="$OSH_CYBER_NEON_BLUE"
export OSH_CYBER_ACCENT="$OSH_CYBER_PURPLE"
export OSH_CYBER_HIGHLIGHT="$OSH_CYBER_PINK"

# ASCII art elements
export OSH_CYBER_BORDER_TOP="========================================================================"
export OSH_CYBER_SEPARATOR="------------------------------------------------------------------------"
export OSH_CYBER_BORDER_BOTTOM="========================================================================"

# ============================================================================
# TERMINAL CAPABILITY DETECTION
# ============================================================================

# Check if terminal supports true color (24-bit)
osh_cyber_supports_truecolor() {
  # Check COLORTERM environment variable
  [[ "$COLORTERM" == "truecolor" ]] || [[ "$COLORTERM" == "24bit" ]] && return 0
  
  # Check TERM variable for known true color terminals
  case "$TERM" in
    *-256color|*-24bit|xterm-kitty|alacritty) return 0 ;;
  esac
  
  # Check if we're in a modern terminal
  [[ -n "$ITERM_SESSION_ID" ]] && return 0  # iTerm2
  [[ -n "$VSCODE_PID" ]] && return 0        # VS Code terminal
  
  return 1
}

# Check if colors should be used
osh_cyber_colors_enabled() {
  [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -n "${TERM:-}" ]]
}

# Get appropriate color based on terminal capabilities
osh_cyber_get_color() {
  local color_name="$1"
  
  if ! osh_cyber_colors_enabled; then
    return 1
  fi
  
  if osh_cyber_supports_truecolor; then
    case "$color_name" in
      "blue") echo "$OSH_CYBER_NEON_BLUE" ;;
      "green") echo "$OSH_CYBER_MATRIX_GREEN" ;;
      "red") echo "$OSH_CYBER_ALERT_RED" ;;
      "purple") echo "$OSH_CYBER_PURPLE" ;;
      "orange") echo "$OSH_CYBER_ORANGE" ;;
      "pink") echo "$OSH_CYBER_PINK" ;;
      "yellow") echo "$OSH_CYBER_YELLOW" ;;
      *) echo "$OSH_CYBER_NEON_BLUE" ;;
    esac
  else
    # Fallback to 256 colors
    case "$color_name" in
      "blue") echo "$OSH_CYBER_NEON_BLUE_256" ;;
      "green") echo "$OSH_CYBER_MATRIX_GREEN_256" ;;
      "red") echo "$OSH_CYBER_ALERT_RED_256" ;;
      "purple") echo "$OSH_CYBER_PURPLE_256" ;;
      "orange") echo "$OSH_CYBER_ORANGE_256" ;;
      "pink") echo "$OSH_CYBER_PINK_256" ;;
      "yellow") echo "$OSH_CYBER_YELLOW_256" ;;
      *) echo "$OSH_CYBER_NEON_BLUE_256" ;;
    esac
  fi
}

# ============================================================================
# CYBERPUNK OUTPUT FUNCTIONS
# ============================================================================

# Safe printf that handles colors properly
osh_cyber_printf() {
  if osh_cyber_colors_enabled; then
    printf "$@"
  else
    # Strip color codes and output plain text
    local format="$1"
    shift
    format="${format//\\033\[[0-9;]*m/}"
    printf "$format" "$@"
  fi
}

# Print text with cyberpunk color
osh_cyber_print() {
  local color="${1}"
  local message="${2}"
  
  if osh_cyber_colors_enabled; then
    printf '%b%s%b\n' "${color}" "${message}" "${OSH_CYBER_RESET}"
  else
    printf '%s\n' "${message}"
  fi
}

# Cyberpunk message functions with icons
osh_cyber_success() {
  local color=$(osh_cyber_get_color "green")
  osh_cyber_print "${color}${OSH_CYBER_BOLD}" "▶ SUCCESS: $*"
}

osh_cyber_error() {
  local color=$(osh_cyber_get_color "red")
  osh_cyber_print "${color}${OSH_CYBER_BOLD}" "▶ ERROR: $*"
}

osh_cyber_warning() {
  local color=$(osh_cyber_get_color "orange")
  osh_cyber_print "${color}${OSH_CYBER_BOLD}" "▶ WARNING: $*"
}

osh_cyber_info() {
  local color=$(osh_cyber_get_color "blue")
  osh_cyber_print "${color}" "▶ INFO: $*"
}

osh_cyber_accent() {
  local color=$(osh_cyber_get_color "purple")
  osh_cyber_print "${color}${OSH_CYBER_BOLD}" "▶ $*"
}

osh_cyber_highlight() {
  local color=$(osh_cyber_get_color "pink")
  osh_cyber_print "${color}${OSH_CYBER_BOLD}" "▶ $*"
}

# Mark as loaded
export OSH_CYBERPUNK_LOADED=1
