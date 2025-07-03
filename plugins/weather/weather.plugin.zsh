#!/bin/zsh
# OSH Weather Plugin - Optimized Version
# Provides weather forecast functionality with ASCII art representation

# Load vintage design system
if [[ -z "${OSH_VINTAGE_LOADED:-}" ]] && [[ -f "${OSH}/lib/vintage.zsh" ]]; then
  source "${OSH}/lib/vintage.zsh"
fi

# Weather configuration
WEATHER_API_URL="https://wttr.in"
WEATHER_CACHE_TTL=1800  # 30 minutes

# Check dependencies
_weather_check_deps() {
  if ! command -v curl &>/dev/null; then
    osh_vintage_error "Weather requires curl. Install with: brew install curl"
    return 1
  fi
  return 0
}

# Get location with caching
_weather_get_location() {
  local provided_location="$1"
  
  if [[ -n "$provided_location" ]]; then
    echo "$provided_location"
    return 0
  fi
  
  # Try to get from cache first
  local cached_location
  if cached_location=$(osh_cache_get "user_location" 86400 "weather"); then
    echo "$cached_location"
    return 0
  fi
  
  # Get location from IP
  local detected_location
  if detected_location=$(curl -s -m 5 "https://ipinfo.io/city" 2>/dev/null); then
    if [[ -n "$detected_location" && "$detected_location" != "null" ]]; then
      osh_cache_set "user_location" "$detected_location" "weather"
      echo "$detected_location"
      return 0
    fi
  fi
  
  # Fallback
  echo "New York"
}

# Fetch weather data with progress indicator
_weather_fetch_data() {
  local location="$1"
  local format="${2:-%l|%c|%t|%w|%p|%h}"
  
  # Check cache first
  local cache_key="weather_${location// /_}"
  local cached_data
  if cached_data=$(osh_cache_get "$cache_key" "$WEATHER_CACHE_TTL" "weather"); then
    echo "$cached_data"
    return 0
  fi
  
  # Show loading indicator
  printf "🌤️  Getting weather for %s..." "$location"
  
  # Fetch fresh data
  local weather_data
  if weather_data=$(curl -s -m 10 "$WEATHER_API_URL/$location?format=$format" 2>/dev/null); then
    if [[ -n "$weather_data" && "$weather_data" != *"error"* && "$weather_data" != *"Unknown location"* ]]; then
      printf "\r\033[K"  # Clear loading indicator
      osh_cache_set "$cache_key" "$weather_data" "weather"
      echo "$weather_data"
      return 0
    fi
  fi
  
  printf "\r\033[K"  # Clear loading indicator
  return 1
}

# Display weather with ASCII art
_weather_display() {
  local weather_data="$1"
  local location="$2"
  
  # Parse weather data
  local condition=$(echo "$weather_data" | cut -d'|' -f2 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  local temperature=$(echo "$weather_data" | cut -d'|' -f3 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  local wind=$(echo "$weather_data" | cut -d'|' -f4 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  local precipitation=$(echo "$weather_data" | cut -d'|' -f5 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  local humidity=$(echo "$weather_data" | cut -d'|' -f6 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  
  # Header
  osh_vintage_info "Weather for ${location}"
  echo ""
  
  # ASCII art based on condition
  case "$condition" in
    *"Clear"*|*"Sunny"*)
      osh_vintage_print "$OSH_VINTAGE_YELLOW" '    \   /    '
      osh_vintage_print "$OSH_VINTAGE_YELLOW" '     .-.     '
      osh_vintage_print "$OSH_VINTAGE_YELLOW" '  ― (   ) ―  '
      osh_vintage_print "$OSH_VINTAGE_YELLOW" '     `-`     '
      osh_vintage_print "$OSH_VINTAGE_YELLOW" '    /   \    '
      ;;
    *"Cloudy"*)
      osh_vintage_print "$OSH_VINTAGE_BLUE" '   \  /       '
      osh_vintage_print "$OSH_VINTAGE_BLUE" ' _ /"".-.     '
      osh_vintage_print "$OSH_VINTAGE_BLUE" '   \_(   ).   '
      osh_vintage_print "$OSH_VINTAGE_BLUE" '   /(``-``).   '
      ;;
    *"Rain"*)
      osh_vintage_print "$OSH_VINTAGE_TEAL" '     .-.     '
      osh_vintage_print "$OSH_VINTAGE_TEAL" '    (   ).   '
      osh_vintage_print "$OSH_VINTAGE_TEAL" '   (___(__)  '
      osh_vintage_print "$OSH_VINTAGE_BLUE" '    ` ` `   '
      osh_vintage_print "$OSH_VINTAGE_BLUE" '   ` ` `    '
      ;;
    *)
      osh_vintage_print "$OSH_VINTAGE_ACCENT" '    .--.     '
      osh_vintage_print "$OSH_VINTAGE_ACCENT" '   /    \    '
      osh_vintage_print "$OSH_VINTAGE_ACCENT" '   \    /    '
      osh_vintage_print "$OSH_VINTAGE_ACCENT" '    `--`     '
      ;;
  esac
  
  echo ""
  osh_vintage_print "$OSH_VINTAGE_GREEN" "Condition:     $condition"
  osh_vintage_print "$OSH_VINTAGE_RED" "Temperature:   $temperature"
  osh_vintage_print "$OSH_VINTAGE_BLUE" "Wind:          $wind"
  osh_vintage_print "$OSH_VINTAGE_TEAL" "Precipitation: $precipitation"
  osh_vintage_print "$OSH_VINTAGE_YELLOW" "Humidity:      $humidity"
}

# Get detailed weather with ASCII art
_weather_get_detailed() {
  local location="$1"
  
  # Check cache first
  local cache_key="weather_detailed_${location// /_}"
  local cached_data
  if cached_data=$(osh_cache_get "$cache_key" "$WEATHER_CACHE_TTL" "weather"); then
    echo "$cached_data"
    return 0
  fi
  
  # Show loading indicator
  printf "🌤️  Getting detailed weather for %s..." "$location"
  
  # Fetch detailed data
  local weather_data
  if weather_data=$(curl -s -m 15 "$WEATHER_API_URL/$location?1nqF&m" 2>/dev/null); then
    if [[ -n "$weather_data" && "$weather_data" != *"error"* && "$weather_data" != *"Unknown location"* ]]; then
      printf "\r\033[K"  # Clear loading indicator
      osh_cache_set "$cache_key" "$weather_data" "weather"
      echo "$weather_data"
      return 0
    fi
  fi
  
  printf "\r\033[K"  # Clear loading indicator
  return 1
}

# Main weather function
weather() {
  _weather_main "$@"
}

# Internal weather function
_weather_main() {
  # Check dependencies
  _weather_check_deps || return 1
  
  local location=""
  local detailed=0
  
  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -l|--location)
        location="$2"
        shift 2
        ;;
      -d|--detailed)
        detailed=1
        shift
        ;;
      -h|--help)
        echo "Usage: weather [options]"
        echo ""
        echo "Options:"
        echo "  -l, --location LOCATION   Specify location"
        echo "  -d, --detailed            Show detailed forecast"
        echo "  -h, --help                Show this help"
        return 0
        ;;
      *)
        location="$1"
        shift
        ;;
    esac
  done
  
  # Get location
  location=$(_weather_get_location "$location")
  
  # Get and display weather
  if [[ $detailed -eq 1 ]]; then
    local weather_data
    if weather_data=$(_weather_get_detailed "$location"); then
      echo "$weather_data"
    else
      osh_vintage_error "Failed to get detailed weather for $location"
      return 1
    fi
  else
    local weather_data
    if weather_data=$(_weather_fetch_data "$location"); then
      _weather_display "$weather_data" "$location"
    else
      osh_vintage_error "Failed to get weather for $location"
      osh_vintage_info "💡 Check your internet connection or try a different location"
      return 1
    fi
  fi
}

# Aliases for quick access
alias wtr="weather"
alias forecast="weather -d"

# Add completions to fpath
if [[ -d "${0:h}/completions" ]]; then
  fpath=("${0:h}/completions" $fpath)
  autoload -U compinit
  compinit -i
fi
