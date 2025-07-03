#!/usr/bin/env zsh
# OSH Common Library
# Provides shared utility functions across all plugins

# Load colors if not already loaded
if [[ -z "${OSH_COLORS_LOADED:-}" ]]; then
  source "${OSH}/lib/colors.zsh"
fi

# Color utility functions
osh_color_print() {
  local color="${1}"
  local message="${2}"
  printf '%b%s%b\n' "${color}" "${message}" "${OSH_COLOR_RESET}"
}

osh_color_error() {
  osh_color_print "${OSH_COLOR_RED}" "$*"
}

osh_color_success() {
  osh_color_print "${OSH_COLOR_GREEN}" "$*"
}

osh_color_warning() {
  osh_color_print "${OSH_COLOR_YELLOW}" "$*"
}

osh_color_info() {
  osh_color_print "${OSH_COLOR_BLUE}" "$*"
}

# Common validation functions
osh_validate_git_repo() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    osh_color_error "Error: Not in a git repository"
    return 1
  fi
  return 0
}

osh_validate_command() {
  local cmd="${1}"
  local package="${2:-${cmd}}"
  
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    osh_color_error "Error: ${cmd} is required but not installed"
    osh_color_info "Install with: brew install ${package} (macOS) or apt-get install ${package} (Linux)"
    return 1
  fi
  return 0
}

osh_validate_env_var() {
  local var_name="${1}"
  local description="${2:-${var_name}}"
  
  if [[ -z "${(P)var_name}" ]]; then
    osh_color_error "Error: ${var_name} environment variable is not set"
    osh_color_info "Please set ${description} in your shell configuration"
    return 1
  fi
  return 0
}

# Git utility functions
osh_git_current_branch() {
  git branch --show-current 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null
}

osh_git_is_clean() {
  [[ -z "$(git status --porcelain 2>/dev/null)" ]]
}

osh_git_branch_exists() {
  local branch="${1}"
  git show-ref --verify --quiet "refs/heads/${branch}" 2>/dev/null
}

osh_git_remote_branch_exists() {
  local branch="${1}"
  local remote="${2:-origin}"
  git show-ref --verify --quiet "refs/remotes/${remote}/${branch}" 2>/dev/null
}

# String utility functions
osh_string_trim() {
  local str="${1}"
  # Remove leading and trailing whitespace
  str="${str#"${str%%[![:space:]]*}"}"
  str="${str%"${str##*[![:space:]]}"}"
  printf "%s" "${str}"
}

osh_string_slugify() {
  local str="${1}"
  # Convert to lowercase, replace spaces with hyphens, remove special chars
  str="${str:l}"                    # Convert to lowercase
  str="${str// /-}"                 # Replace spaces with hyphens
  str="${str//[^a-z0-9\-]/}"        # Remove non-alphanumeric chars except hyphens
  str="${str//--/-}"                # Replace multiple hyphens with single
  str="${str#-}"                    # Remove leading hyphen
  str="${str%-}"                    # Remove trailing hyphen
  printf "%s" "${str}"
}

# Date utility functions
osh_date_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

osh_date_short() {
  date +"%Y%m%d"
}

osh_date_human() {
  date +"%Y-%m-%d %H:%M:%S"
}

# File utility functions
osh_file_backup() {
  local file="${1}"
  local backup_suffix="${2:-backup-$(date +%Y%m%d-%H%M%S)}"
  
  if [[ -f "${file}" ]]; then
    cp "${file}" "${file}.${backup_suffix}"
    osh_color_success "Backed up ${file} to ${file}.${backup_suffix}"
  fi
}

osh_file_ensure_dir() {
  local dir="${1}"
  if [[ ! -d "${dir}" ]]; then
    mkdir -p "${dir}"
    osh_color_info "Created directory: ${dir}"
  fi
}

# Network utility functions
osh_network_test_connection() {
  local host="${1:-8.8.8.8}"
  local port="${2:-53}"
  local timeout="${3:-5}"
  
  if command -v nc >/dev/null 2>&1; then
    nc -z -w "${timeout}" "${host}" "${port}" >/dev/null 2>&1
  elif command -v timeout >/dev/null 2>&1; then
    timeout "${timeout}" bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1
  else
    # Fallback using ping
    ping -c 1 -W "${timeout}" "${host}" >/dev/null 2>&1
  fi
}

# Progress indicator functions
osh_spinner() {
  local pid="${1}"
  local message="${2:-Processing...}"
  local chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  local i=0
  
  printf "%s " "${message}"
  while kill -0 "${pid}" 2>/dev/null; do
    printf "\b%s" "${chars:$((i++ % ${#chars})):1}"
    sleep 0.1
  done
  printf "\b✓\n"
}

osh_progress_bar() {
  local current="${1}"
  local total="${2}"
  local width="${3:-50}"
  local percent=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  
  printf "\r["
  printf "%*s" "${filled}" | tr ' ' '█'
  printf "%*s" "${empty}" | tr ' ' '░'
  printf "] %d%% (%d/%d)" "${percent}" "${current}" "${total}"
}

# Logging functions (enhanced versions of core logging)
osh_log_with_timestamp() {
  local level="${1}"
  shift
  local message="$*"
  local timestamp
  timestamp=$(osh_date_human)
  
  case "${level}" in
    "ERROR")
      osh_color_error "[${timestamp}] ERROR: ${message}"
      ;;
    "WARN")
      osh_color_warning "[${timestamp}] WARN: ${message}"
      ;;
    "INFO")
      osh_color_info "[${timestamp}] INFO: ${message}"
      ;;
    "SUCCESS")
      osh_color_success "[${timestamp}] SUCCESS: ${message}"
      ;;
    *)
      printf "[%s] %s: %s\n" "${timestamp}" "${level}" "${message}"
      ;;
  esac
}

# Configuration helper functions
osh_config_get() {
  local key="${1}"
  local default="${2:-}"
  local config_file="${OSH_CONFIG_FILE:-${HOME}/.oshrc}"
  
  if [[ -f "${config_file}" ]]; then
    grep "^${key}=" "${config_file}" 2>/dev/null | cut -d'=' -f2- | head -n1 || printf "%s" "${default}"
  else
    printf "%s" "${default}"
  fi
}

osh_config_set() {
  local key="${1}"
  local value="${2}"
  local config_file="${OSH_CONFIG_FILE:-${HOME}/.oshrc}"
  
  osh_file_ensure_dir "$(dirname "${config_file}")"
  
  if [[ -f "${config_file}" ]] && grep -q "^${key}=" "${config_file}"; then
    # Update existing key
    sed -i.bak "s/^${key}=.*/${key}=${value}/" "${config_file}"
  else
    # Add new key
    echo "${key}=${value}" >> "${config_file}"
  fi
  
  osh_color_success "Set ${key}=${value} in ${config_file}"
}

# Mark common library as loaded
export OSH_COMMON_LOADED=1
