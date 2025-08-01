#!/usr/bin/env zsh
# OSH.IT Error Handler and User-Friendly Messages
# Version: 1.0.0
# Provides helpful error messages and recovery suggestions

# Ensure this library is only loaded once
if [[ -n "${OSH_ERROR_HANDLER_LOADED:-}" ]]; then
  return 0
fi

# ============================================================================
# ERROR CLASSIFICATION AND HANDLING
# ============================================================================

# Common error patterns and their solutions
declare -gA OSH_ERROR_SOLUTIONS=(
  ["command not found"]="🔍 Command not found. Try: osh help"
  ["permission denied"]="🔐 Permission issue. Try: osh doctor --fix"
  ["no such file"]="📁 File missing. Try: osh doctor or reinstall OSH.IT"
  ["network"]="🌐 Network issue. Check connection or try different mirror"
  ["plugin not found"]="🔌 Plugin not available. Try: osh plugin list"
  ["dependency missing"]="📦 Missing dependency. Try: osh plugin deps <name>"
  ["config error"]="⚙️ Configuration issue. Try: osh config validate"
)

# User-friendly error reporter
osh_error_report() {
  local error_type="$1"
  local error_message="$2"
  local context="${3:-}"
  
  # Load cyberpunk styling if available
  local color_red=""
  local color_yellow=""
  local color_blue=""
  local color_reset=""
  
  if declare -f osh_cyber_error >/dev/null 2>&1; then
    osh_cyber_error "$error_message"
  else
    color_red='\033[0;31m'
    color_yellow='\033[1;33m'
    color_blue='\033[0;34m'
    color_reset='\033[0m'
    echo -e "${color_red}❌ ERROR: $error_message${color_reset}" >&2
  fi
  
  # Provide solution if available
  for pattern in "${(@k)OSH_ERROR_SOLUTIONS}"; do
    if [[ "$error_message" =~ "$pattern" ]]; then
      echo -e "${color_yellow}💡 Suggestion: ${OSH_ERROR_SOLUTIONS[$pattern]}${color_reset}" >&2
      break
    fi
  done
  
  # Add context-specific help
  if [[ -n "$context" ]]; then
    echo -e "${color_blue}ℹ️  Context: $context${color_reset}" >&2
  fi
  
  # General help footer
  echo -e "${color_blue}📚 For more help: osh help or visit https://github.com/oiahoon/osh.it${color_reset}" >&2
}

# Wrapper for common commands with error handling
osh_safe_exec() {
  local command="$1"
  shift
  local args="$@"
  
  if ! command -v "$command" >/dev/null 2>&1; then
    osh_error_report "command not found" "Command '$command' not found" "Make sure $command is installed and in PATH"
    return 1
  fi
  
  "$command" "$@"
}

# Plugin-specific error handler
osh_plugin_error() {
  local plugin="$1"
  local error="$2"
  
  case "$error" in
    "not_found")
      osh_error_report "plugin not found" "Plugin '$plugin' not found" "Use 'osh plugin list' to see available plugins"
      ;;
    "dependency_missing")
      osh_error_report "dependency missing" "Plugin '$plugin' has missing dependencies" "Run 'osh plugin deps $plugin' to check requirements"
      ;;
    "install_failed")
      osh_error_report "install failed" "Failed to install plugin '$plugin'" "Check network connection and plugin availability"
      ;;
    *)
      osh_error_report "plugin error" "Plugin '$plugin': $error"
      ;;
  esac
}

# Network error handler
osh_network_error() {
  local operation="$1"
  local url="${2:-}"
  
  echo -e "\033[0;31m❌ Network Error during $operation\033[0m" >&2
  echo -e "\033[1;33m💡 Troubleshooting steps:\033[0m" >&2
  echo "   1. Check your internet connection" >&2
  echo "   2. Try using a different mirror: OSH_MIRROR=gitee" >&2
  echo "   3. Check firewall/proxy settings" >&2
  echo "   4. Retry in a few minutes" >&2
  
  if [[ -n "$url" ]]; then
    echo -e "\033[0;34mℹ️  Failed URL: $url\033[0m" >&2
  fi
}

# Configuration error handler
osh_config_error() {
  local config_file="$1"
  local error="$2"
  
  echo -e "\033[0;31m❌ Configuration Error in $config_file\033[0m" >&2
  echo -e "\033[1;33m💡 Quick fixes:\033[0m" >&2
  echo "   1. Run: osh doctor --fix" >&2
  echo "   2. Backup and reset: cp $config_file ${config_file}.backup && osh config reset" >&2
  echo "   3. Manual edit: nano $config_file" >&2
  echo -e "\033[0;34mℹ️  Error details: $error\033[0m" >&2
}

# Progressive error disclosure
osh_progressive_help() {
  local error_level="${1:-basic}"
  
  case "$error_level" in
    "basic")
      echo "🔧 Quick Help:" >&2
      echo "  osh status    - Check system status" >&2
      echo "  osh doctor    - Run diagnostics" >&2
      echo "  osh help      - Full command reference" >&2
      ;;
    "intermediate")
      echo "🔧 Advanced Help:" >&2
      echo "  osh doctor --fix     - Auto-fix common issues" >&2
      echo "  osh config validate  - Check configuration" >&2
      echo "  osh plugin deps <name> - Check plugin dependencies" >&2
      echo "  OSH_DEBUG=1 osh ...  - Enable debug mode" >&2
      ;;
    "expert")
      echo "🔧 Expert Help:" >&2
      echo "  Manual plugin management: ~/.osh/plugins/" >&2
      echo "  Configuration file: ~/.zshrc" >&2
      echo "  Log files: ~/.osh/logs/" >&2
      echo "  Report bugs: https://github.com/oiahoon/osh.it/issues" >&2
      ;;
  esac
}

# Mark as loaded
export OSH_ERROR_HANDLER_LOADED=1