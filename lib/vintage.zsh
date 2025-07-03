#!/usr/bin/env zsh
# OSH Vintage Design System
# Unified vintage styling and color palette for all OSH plugins and features
# Version: 1.0.0

# Ensure this library is only loaded once
if [[ -n "${OSH_VINTAGE_LOADED:-}" ]]; then
  return 0
fi

# Load colors if not already loaded
if [[ -z "${OSH_COLORS_LOADED:-}" ]]; then
  source "${OSH}/lib/colors.zsh"
fi

# ============================================================================
# OSH VINTAGE COLOR PALETTE
# ============================================================================
# These colors are carefully chosen to create a cohesive vintage aesthetic
# across all OSH plugins and features. They use 256-color ANSI codes for
# maximum compatibility and visual appeal.

# Primary Vintage Colors (256-color palette)
export OSH_VINTAGE_RED=$'\033[38;5;124m'        # Dark red - High priority, errors
export OSH_VINTAGE_ORANGE=$'\033[38;5;130m'     # Dark orange - Warnings, attention
export OSH_VINTAGE_YELLOW=$'\033[38;5;136m'     # Muted yellow - Normal priority, info
export OSH_VINTAGE_OLIVE=$'\033[38;5;142m'      # Olive yellow - Secondary info
export OSH_VINTAGE_GREEN=$'\033[38;5;64m'       # Forest green - Success, completed
export OSH_VINTAGE_TEAL=$'\033[38;5;66m'        # Dark teal - Low priority, calm
export OSH_VINTAGE_BLUE=$'\033[38;5;68m'        # Muted blue - Information, neutral
export OSH_VINTAGE_PURPLE=$'\033[38;5;97m'      # Muted purple - Accent, special
export OSH_VINTAGE_MAGENTA=$'\033[38;5;95m'     # Dark magenta - Highlight, brand

# UI Element Colors
export OSH_VINTAGE_ACCENT=$'\033[1;36m'         # Bright cyan - UI accents, labels
export OSH_VINTAGE_SUCCESS=$'\033[1;32m'        # Bright green - Success messages
export OSH_VINTAGE_WARNING=$'\033[1;33m'        # Bright yellow - Warnings
export OSH_VINTAGE_ERROR=$'\033[1;31m'          # Bright red - Errors
export OSH_VINTAGE_DIM=$'\033[2m'               # Dimmed text - Secondary info
export OSH_VINTAGE_BOLD=$'\033[1m'              # Bold text - Emphasis
export OSH_VINTAGE_RESET=$'\033[0m'             # Reset all formatting

# Semantic Color Mappings
export OSH_VINTAGE_HIGH_PRIORITY="$OSH_VINTAGE_RED"
export OSH_VINTAGE_NORMAL_PRIORITY="$OSH_VINTAGE_YELLOW"
export OSH_VINTAGE_LOW_PRIORITY="$OSH_VINTAGE_TEAL"
export OSH_VINTAGE_COMPLETED="$OSH_VINTAGE_GREEN"
export OSH_VINTAGE_BRAND="$OSH_VINTAGE_PURPLE"
export OSH_VINTAGE_SECONDARY="$OSH_VINTAGE_BLUE"

# ============================================================================
# VINTAGE DESIGN FUNCTIONS
# ============================================================================

# ============================================================================
# VINTAGE COLOR OUTPUT FUNCTIONS
# ============================================================================

# Check if colors should be used
osh_vintage_colors_enabled() {
  # Check if stdout is a TTY and colors are supported
  [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ -n "${TERM:-}" ]]
}

# Safe printf that handles colors properly
osh_vintage_printf() {
  if osh_vintage_colors_enabled; then
    printf "$@"
  else
    # Strip color codes and output plain text
    local format="$1"
    shift
    # Remove color variables from format string
    format="${format//\$\{OSH_VINTAGE_[A-Z_]*\}/}"
    format="${format//\\033\[[0-9;]*m/}"
    printf "$format" "$@"
  fi
}

# Print text with vintage color
osh_vintage_print() {
  local color="${1}"
  local message="${2}"
  
  if osh_vintage_colors_enabled; then
    # Use printf with explicit escape sequence handling for cross-shell compatibility
    printf '%b%s%b\n' "${color}" "${message}" "${OSH_VINTAGE_RESET}"
  else
    # No color support, output plain text
    printf '%s\n' "${message}"
  fi
}

# Vintage message functions
osh_vintage_error() {
  osh_vintage_print "${OSH_VINTAGE_ERROR}" "✗ $*"
}

osh_vintage_success() {
  osh_vintage_print "${OSH_VINTAGE_SUCCESS}" "✓ $*"
}

osh_vintage_warning() {
  osh_vintage_print "${OSH_VINTAGE_WARNING}" "⚠ $*"
}

osh_vintage_info() {
  osh_vintage_print "${OSH_VINTAGE_ACCENT}" "ℹ $*"
}

osh_vintage_brand() {
  osh_vintage_print "${OSH_VINTAGE_BRAND}" "$*"
}

# Vintage header function
osh_vintage_header() {
  local title="${1}"
  local subtitle="${2:-}"
  local width="${3:-60}"
  
  if ! osh_vintage_colors_enabled; then
    # Plain text version
    echo "=== $title ==="
    [[ -n "$subtitle" ]] && echo "$subtitle"
    echo
    return
  fi
  
  # Calculate border
  local border_char="═"
  local border=$(printf "%*s" $((width-4)) "" | tr ' ' "$border_char")
  
  # Print header
  printf "%s╔%s╗%s\n" "${OSH_VINTAGE_PURPLE}" "$border" "${OSH_VINTAGE_RESET}"
  
  # Center title
  local title_padding=$(( (width - ${#title} - 4) / 2 ))
  local title_spaces=$(printf "%*s" $title_padding "")
  printf "%s║%s%s%s%s║%s\n" "${OSH_VINTAGE_PURPLE}" "$title_spaces" "${OSH_VINTAGE_MAGENTA}" "$title" "${OSH_VINTAGE_PURPLE}" "${OSH_VINTAGE_RESET}"
  
  # Subtitle if provided
  if [[ -n "$subtitle" ]]; then
    local subtitle_padding=$(( (width - ${#subtitle} - 4) / 2 ))
    local subtitle_spaces=$(printf "%*s" $subtitle_padding "")
    printf "%s║%s%s%s%s%s║%s\n" "${OSH_VINTAGE_PURPLE}" "$subtitle_spaces" "${OSH_VINTAGE_BLUE}" "$subtitle" "${OSH_VINTAGE_PURPLE}" "${OSH_VINTAGE_RESET}"
  fi
  
  printf "%s╚%s╝%s\n" "${OSH_VINTAGE_PURPLE}" "$border" "${OSH_VINTAGE_RESET}"
}

# Vintage separator
osh_vintage_separator() {
  local width="${1:-60}"
  local char="${2:-─}"
  local color="${3:-$OSH_VINTAGE_DIM}"
  
  if ! osh_vintage_colors_enabled; then
    # Plain text version
    local separator=$(printf "%*s" $width "" | tr ' ' "$char")
    printf "%s\n" "$separator"
    return
  fi
  
  local separator=$(printf "%*s" $width "" | tr ' ' "$char")
  printf "%s%s%s\n" "$color" "$separator" "${OSH_VINTAGE_RESET}"
}

# Vintage list item
osh_vintage_list_item() {
  local priority="${1}"  # high, normal, low
  local status="${2}"    # active, completed
  local text="${3}"
  local id="${4:-}"
  
  # Choose colors and icons based on priority and status
  local color icon
  case "$priority" in
    "high")
      icon="◆"
      color="$OSH_VINTAGE_HIGH_PRIORITY"
      ;;
    "low")
      icon="◦"
      color="$OSH_VINTAGE_LOW_PRIORITY"
      ;;
    *)
      icon="◇"
      color="$OSH_VINTAGE_NORMAL_PRIORITY"
      ;;
  esac
  
  # Dim if completed
  if [[ "$status" == "completed" ]]; then
    color="${color}${OSH_VINTAGE_DIM}"
  fi
  
  # Status icon
  local status_icon="◯"
  if [[ "$status" == "completed" ]]; then
    status_icon="✓"
  fi
  
  # Format output
  local id_part=""
  if [[ -n "$id" ]]; then
    id_part=" ${OSH_VINTAGE_DIM}(ID: $id)${OSH_VINTAGE_RESET}"
  fi
  
  printf "%s%s %s %s%s%s\n" "$color" "$status_icon" "$icon" "$text" "${OSH_VINTAGE_RESET}" "$id_part"
}

# Vintage progress bar
osh_vintage_progress() {
  local current="${1}"
  local total="${2}"
  local width="${3:-40}"
  local label="${4:-Progress}"
  
  local percentage=$(( current * 100 / total ))
  local filled=$(( current * width / total ))
  local empty=$(( width - filled ))
  
  local bar_filled=$(printf "%*s" $filled "" | tr ' ' '█')
  local bar_empty=$(printf "%*s" $empty "" | tr ' ' '░')
  
  printf "%s%s: %s[%s%s%s%s]%s %d%% (%d/%d)\n" \
    "${OSH_VINTAGE_ACCENT}" "$label" \
    "${OSH_VINTAGE_DIM}" \
    "${OSH_VINTAGE_SUCCESS}" "$bar_filled" \
    "${OSH_VINTAGE_DIM}" "$bar_empty" \
    "${OSH_VINTAGE_RESET}" \
    "$percentage" "$current" "$total"
}

# Vintage table header
osh_vintage_table_header() {
  local -a headers=("$@")
  local total_width=0
  
  # Calculate total width
  for header in "${headers[@]}"; do
    total_width=$(( total_width + ${#header} + 3 ))
  done
  
  # Print top border
  local border=$(printf "%*s" $total_width "" | tr ' ' '─')
  printf "%s┌%s┐%s\n" "${OSH_VINTAGE_PURPLE}" "$border" "${OSH_VINTAGE_RESET}"
  
  # Print headers
  printf "%s│%s" "${OSH_VINTAGE_PURPLE}" "${OSH_VINTAGE_RESET}"
  for header in "${headers[@]}"; do
    printf " %s%s%s │" "${OSH_VINTAGE_ACCENT}" "$header" "${OSH_VINTAGE_RESET}"
  done
  printf "\n"
  
  # Print separator
  printf "%s├%s┤%s\n" "${OSH_VINTAGE_PURPLE}" "$border" "${OSH_VINTAGE_RESET}"
}

# Vintage table row
osh_vintage_table_row() {
  local -a cells=("$@")
  
  printf "%s│%s" "${OSH_VINTAGE_PURPLE}" "${OSH_VINTAGE_RESET}"
  for cell in "${cells[@]}"; do
    printf " %s │" "$cell"
  done
  printf "\n"
}

# Vintage input prompt
osh_vintage_prompt() {
  local prompt="${1}"
  local default="${2:-}"
  
  if [[ -n "$default" ]]; then
    printf "%s%s%s [%s%s%s]: " \
      "${OSH_VINTAGE_ACCENT}" "$prompt" "${OSH_VINTAGE_RESET}" \
      "${OSH_VINTAGE_DIM}" "$default" "${OSH_VINTAGE_RESET}"
  else
    printf "%s%s%s: " "${OSH_VINTAGE_ACCENT}" "$prompt" "${OSH_VINTAGE_RESET}"
  fi
}

# Vintage confirmation prompt
osh_vintage_confirm() {
  local message="${1}"
  local default="${2:-n}"
  
  local prompt_text="[y/N]"
  if [[ "$default" == "y" ]]; then
    prompt_text="[Y/n]"
  fi
  
  printf "%s%s%s %s%s%s " \
    "${OSH_VINTAGE_WARNING}" "$message" "${OSH_VINTAGE_RESET}" \
    "${OSH_VINTAGE_DIM}" "$prompt_text" "${OSH_VINTAGE_RESET}"
  
  read -r response
  case "${response:-$default}" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

# ============================================================================
# VINTAGE DESIGN STANDARDS
# ============================================================================

# Standard vintage icons
export OSH_VINTAGE_ICON_HIGH="◆"      # High priority diamond
export OSH_VINTAGE_ICON_NORMAL="◇"    # Normal priority hollow diamond
export OSH_VINTAGE_ICON_LOW="◦"       # Low priority small circle
export OSH_VINTAGE_ICON_SUCCESS="✓"   # Success checkmark
export OSH_VINTAGE_ICON_ERROR="✗"     # Error cross
export OSH_VINTAGE_ICON_WARNING="⚠"   # Warning triangle
export OSH_VINTAGE_ICON_INFO="ℹ"      # Information
export OSH_VINTAGE_ICON_ACTIVE="◯"    # Active circle
export OSH_VINTAGE_ICON_BRAND="✦"     # Brand star

# Standard vintage borders
export OSH_VINTAGE_BORDER_TOP="╔═══════════════════════════════════════╗"
export OSH_VINTAGE_BORDER_BOTTOM="╚═══════════════════════════════════════╝"
export OSH_VINTAGE_BORDER_MIDDLE="╠═══════════════════════════════════════╣"
export OSH_VINTAGE_BORDER_SIDE="║"

# Standard vintage separators
export OSH_VINTAGE_SEP_LIGHT="─"
export OSH_VINTAGE_SEP_HEAVY="━"
export OSH_VINTAGE_SEP_DOUBLE="═"
export OSH_VINTAGE_SEP_DOTTED="┈"

# ============================================================================
# PLUGIN DEVELOPMENT GUIDELINES
# ============================================================================

# Function to check if vintage mode is enabled for a plugin
osh_vintage_enabled() {
  local plugin_name="${1:-}"
  local env_var="OSH_VINTAGE"
  
  # Check plugin-specific vintage setting first
  if [[ -n "$plugin_name" ]]; then
    local plugin_var="OSH_VINTAGE_$(echo "$plugin_name" | tr '[:lower:]' '[:upper:]')"
    if [[ -n "${(P)plugin_var}" ]]; then
      [[ "${(P)plugin_var}" != "false" && "${(P)plugin_var}" != "0" ]]
      return $?
    fi
  fi
  
  # Check global vintage setting (default: enabled)
  [[ "${OSH_VINTAGE:-true}" != "false" && "${OSH_VINTAGE:-true}" != "0" ]]
}

# Function to get vintage color for priority
osh_vintage_priority_color() {
  local priority="${1}"
  local task_status="${2:-active}"
  
  local color
  case "$priority" in
    "high") color="$OSH_VINTAGE_HIGH_PRIORITY" ;;
    "low") color="$OSH_VINTAGE_LOW_PRIORITY" ;;
    *) color="$OSH_VINTAGE_NORMAL_PRIORITY" ;;
  esac
  
  # Add dim effect for completed items
  if [[ "$task_status" == "completed" ]]; then
    color="${color}${OSH_VINTAGE_DIM}"
  fi
  
  echo "$color"
}

# Function to get vintage icon for priority
osh_vintage_priority_icon() {
  local priority="${1}"
  
  case "$priority" in
    "high") echo "$OSH_VINTAGE_ICON_HIGH" ;;
    "low") echo "$OSH_VINTAGE_ICON_LOW" ;;
    *) echo "$OSH_VINTAGE_ICON_NORMAL" ;;
  esac
}

# Mark library as loaded
export OSH_VINTAGE_LOADED=1

# Display vintage design system info if called directly
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]] || [[ "${ZSH_ARGZERO:-}" == "${0:-}" ]]; then
  osh_vintage_header "OSH VINTAGE DESIGN SYSTEM" "Unified styling for all OSH plugins"
  echo
  osh_vintage_info "Color palette and design functions loaded successfully"
  osh_vintage_success "Ready for use in OSH plugins and features"
  echo
  osh_vintage_separator 60
  echo
  printf "%sExample usage:%s\n" "${OSH_VINTAGE_ACCENT}" "${OSH_VINTAGE_RESET}"
  printf "  %sosh_vintage_success \"Task completed\"%s\n" "${OSH_VINTAGE_DIM}" "${OSH_VINTAGE_RESET}"
  printf "  %sosh_vintage_list_item \"high\" \"active\" \"Important task\"%s\n" "${OSH_VINTAGE_DIM}" "${OSH_VINTAGE_RESET}"
  printf "  %sosh_vintage_progress 7 10 40 \"Loading\"%s\n" "${OSH_VINTAGE_DIM}" "${OSH_VINTAGE_RESET}"
  echo
fi
