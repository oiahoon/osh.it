#!/usr/bin/env zsh
# OSH.IT Cyberpunk ASCII Art System
# ASCII art, icons, and visual elements for cyberpunk aesthetic
# Version: 1.0.0

# Ensure cyberpunk colors are loaded
if [[ -z "${OSH_CYBERPUNK_LOADED:-}" ]]; then
  source "${OSH}/lib/cyberpunk.zsh"
fi

# ============================================================================
# CYBERPUNK ASCII LOGO
# ============================================================================

osh_cyber_logo() {
  local color_blue=$(osh_cyber_get_color "blue")
  local color_green=$(osh_cyber_get_color "green")
  local color_purple=$(osh_cyber_get_color "purple")
  local color_pink=$(osh_cyber_get_color "pink")
  
  if osh_cyber_colors_enabled; then
    cat << EOF
${color_blue}${OSH_CYBER_BOLD}
    ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
    ${color_green}██${color_blue}╔═══════════════════════════════════════════════════════════════════════${color_green}██
    ${color_green}██${color_purple}║  ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄  ▄▄   ▄▄       ▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ${color_green}║██
    ${color_green}██${color_purple}║ ▐░░░░░░░▌▐░░░░░░░░▌▐░░▌ ▐░░▌     ▐░░░░░░░░▌▐░░░░░░░░░░░░░░░░░░░░░░░▌ ${color_green}║██
    ${color_green}██${color_purple}║ ▐░█▀▀▀▀▀ ▐░█▀▀▀▀▀█░▌▐░▌░▌▐░▌     ▐░█▀▀▀▀▀█░▌▀▀▀▀█░█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ${color_green}║██
    ${color_green}██${color_purple}║ ▐░▌      ▐░▌     ▐░▌▐░▌▐░▌▐░▌     ▐░▌     ▐░▌    ▐░▌               ${color_green}║██
    ${color_green}██${color_pink}║ ▐░▌      ▐░█▄▄▄▄▄█░▌▐░▌ ▐░▐░▌     ▐░▌     ▐░▌    ▐░▌               ${color_green}║██
    ${color_green}██${color_pink}║ ▐░▌      ▐░░░░░░░░▌ ▐░▌  ▐░░▌     ▐░▌     ▐░▌    ▐░▌               ${color_green}║██
    ${color_green}██${color_pink}║ ▐░▌      ▐░█▀▀▀▀▀█░▌▐░▌   ▐░▌     ▐░▌     ▐░▌    ▐░▌               ${color_green}║██
    ${color_green}██${color_pink}║ ▐░█▄▄▄▄▄ ▐░▌     ▐░▌▐░▌    ▐░▌ ▄▄▄▐░█▄▄▄▄▄█░▌▄▄▄▄█░█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ${color_green}║██
    ${color_green}██${color_pink}║ ▐░░░░░░░▌▐░▌     ▐░▌▐░▌     ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░░░░░░░░░░░░░▌ ${color_green}║██
    ${color_green}██${color_blue}║  ▀▀▀▀▀▀▀  ▀       ▀  ▀       ▀  ▀▀▀▀▀▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ${color_green}║██
    ${color_green}██${color_blue}╚═══════════════════════════════════════════════════════════════════════${color_green}██
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
${OSH_CYBER_RESET}
EOF
  else
    cat << 'EOF'
    ====================================================================
    ||  ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄  ▄▄   ▄▄       ▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ||
    || ▐░░░░░░░▌▐░░░░░░░░▌▐░░▌ ▐░░▌     ▐░░░░░░░░▌▐░░░░░░░░░░░░░░░░░░░░░░░▌ ||
    || ▐░█▀▀▀▀▀ ▐░█▀▀▀▀▀█░▌▐░▌░▌▐░▌     ▐░█▀▀▀▀▀█░▌▀▀▀▀█░█▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ||
    || ▐░▌      ▐░▌     ▐░▌▐░▌▐░▌▐░▌     ▐░▌     ▐░▌    ▐░▌               ||
    || ▐░▌      ▐░█▄▄▄▄▄█░▌▐░▌ ▐░▐░▌     ▐░▌     ▐░▌    ▐░▌               ||
    || ▐░▌      ▐░░░░░░░░▌ ▐░▌  ▐░░▌     ▐░▌     ▐░▌    ▐░▌               ||
    || ▐░▌      ▐░█▀▀▀▀▀█░▌▐░▌   ▐░▌     ▐░▌     ▐░▌    ▐░▌               ||
    || ▐░█▄▄▄▄▄ ▐░▌     ▐░▌▐░▌    ▐░▌ ▄▄▄▐░█▄▄▄▄▄█░▌▄▄▄▄█░█▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ||
    || ▐░░░░░░░▌▐░▌     ▐░▌▐░▌     ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░░░░░░░░░░░░░▌ ||
    ||  ▀▀▀▀▀▀▀  ▀       ▀  ▀       ▀  ▀▀▀▀▀▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  ||
    ====================================================================
EOF
  fi
}

# ============================================================================
# CYBERPUNK ICONS AND SYMBOLS
# ============================================================================

# Status icons
export OSH_CYBER_ICON_SUCCESS="▶"
export OSH_CYBER_ICON_ERROR="▶"
export OSH_CYBER_ICON_WARNING="▶"
export OSH_CYBER_ICON_INFO="▶"
export OSH_CYBER_ICON_LOADING="▶"
export OSH_CYBER_ICON_PLUGIN="◆"
export OSH_CYBER_ICON_INSTALLED="●"
export OSH_CYBER_ICON_AVAILABLE="○"
export OSH_CYBER_ICON_ARROW="→"
export OSH_CYBER_ICON_BULLET="▸"

# Plugin category icons
export OSH_CYBER_ICON_STABLE="◆"
export OSH_CYBER_ICON_BETA="◇"
export OSH_CYBER_ICON_EXPERIMENTAL="△"

# Special symbols
export OSH_CYBER_SEPARATOR="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
export OSH_CYBER_BORDER_TOP="▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄"
export OSH_CYBER_BORDER_BOTTOM="▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀"

# ============================================================================
# CYBERPUNK PROGRESS BAR
# ============================================================================

osh_cyber_progress_bar() {
  local current="$1"
  local total="$2"
  local width="${3:-50}"
  local label="${4:-Progress}"
  
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  
  local color_blue=$(osh_cyber_get_color "blue")
  local color_green=$(osh_cyber_get_color "green")
  local color_gray="$OSH_CYBER_DARK_GRAY"
  
  # Create progress bar
  local bar=""
  for ((i=0; i<filled; i++)); do
    bar+="█"
  done
  for ((i=0; i<empty; i++)); do
    bar+="░"
  done
  
  if osh_cyber_colors_enabled; then
    printf "\r${color_blue}${OSH_CYBER_BOLD}%s${OSH_CYBER_RESET} ${color_green}[${bar}]${OSH_CYBER_RESET} ${color_blue}%d%%${OSH_CYBER_RESET}" \
           "$label" "$percentage"
  else
    printf "\r%s [%s] %d%%" "$label" "$bar" "$percentage"
  fi
}

# ============================================================================
# CYBERPUNK TABLE DISPLAY
# ============================================================================

osh_cyber_table_header() {
  local color_blue=$(osh_cyber_get_color "blue")
  local color_green=$(osh_cyber_get_color "green")
  
  if osh_cyber_colors_enabled; then
    echo "${color_green}${OSH_CYBER_BORDER_TOP}${OSH_CYBER_RESET}"
    printf "${color_blue}${OSH_CYBER_BOLD}%-20s %-10s %-15s %-30s${OSH_CYBER_RESET}\n" \
           "PLUGIN" "STATUS" "CATEGORY" "DESCRIPTION"
    echo "${color_green}${OSH_CYBER_SEPARATOR}${OSH_CYBER_RESET}"
  else
    echo "========================================================================"
    printf "%-20s %-10s %-15s %-30s\n" "PLUGIN" "STATUS" "CATEGORY" "DESCRIPTION"
    echo "------------------------------------------------------------------------"
  fi
}

osh_cyber_table_row() {
  local plugin="$1"
  local status="$2"
  local category="$3"
  local description="$4"
  
  local color_white="$OSH_CYBER_LIGHT_GRAY"
  local status_color
  local status_icon
  
  case "$status" in
    "INSTALLED")
      if osh_cyber_colors_enabled; then
        status_color=$(osh_cyber_get_color "green")
      else
        status_color=""
      fi
      status_icon="$OSH_CYBER_ICON_INSTALLED"
      ;;
    "AVAILABLE")
      if osh_cyber_colors_enabled; then
        status_color=$(osh_cyber_get_color "blue")
      else
        status_color=""
      fi
      status_icon="$OSH_CYBER_ICON_AVAILABLE"
      ;;
    *)
      status_color="$OSH_CYBER_DARK_GRAY"
      status_icon="$OSH_CYBER_ICON_AVAILABLE"
      ;;
  esac
  
  local category_icon
  case "$category" in
    "stable") category_icon="$OSH_CYBER_ICON_STABLE" ;;
    "beta") category_icon="$OSH_CYBER_ICON_BETA" ;;
    "experimental") category_icon="$OSH_CYBER_ICON_EXPERIMENTAL" ;;
    *) category_icon="$OSH_CYBER_ICON_PLUGIN" ;;
  esac
  
  if osh_cyber_colors_enabled; then
    printf "${color_white}%-20s ${status_color}%s %-9s${OSH_CYBER_RESET} ${color_white}%s %-14s %-30s${OSH_CYBER_RESET}\n" \
           "$plugin" "$status_icon" "$status" "$category_icon" "$category" "$description"
  else
    printf "%-20s %s %-9s %s %-14s %-30s\n" \
           "$plugin" "$status_icon" "$status" "$category_icon" "$category" "$description"
  fi
}

osh_cyber_table_footer() {
  local color_green=$(osh_cyber_get_color "green")
  
  if osh_cyber_colors_enabled; then
    echo "${color_green}${OSH_CYBER_BORDER_BOTTOM}${OSH_CYBER_RESET}"
  else
    echo "========================================================================"
  fi
}

# ============================================================================
# CYBERPUNK ANIMATIONS
# ============================================================================

osh_cyber_loading_animation() {
  local message="${1:-Loading}"
  local duration="${2:-3}"
  
  local frames=("▰▱▱▱▱▱▱" "▰▰▱▱▱▱▱" "▰▰▰▱▱▱▱" "▰▰▰▰▱▱▱" "▰▰▰▰▰▱▱" "▰▰▰▰▰▰▱" "▰▰▰▰▰▰▰")
  local color_blue=$(osh_cyber_get_color "blue")
  local color_green=$(osh_cyber_get_color "green")
  
  local end_time=$((SECONDS + duration))
  local frame_index=0
  
  while [[ $SECONDS -lt $end_time ]]; do
    local frame="${frames[$((frame_index % ${#frames[@]}))]}"
    
    if osh_cyber_colors_enabled; then
      printf "\r${color_blue}${OSH_CYBER_BOLD}%s${OSH_CYBER_RESET} ${color_green}[%s]${OSH_CYBER_RESET}" \
             "$message" "$frame"
    else
      printf "\r%s [%s]" "$message" "$frame"
    fi
    
    sleep 0.1
    ((frame_index++))
  done
  
  echo ""
}

# Mark as loaded
export OSH_CYBERPUNK_ASCII_LOADED=1
