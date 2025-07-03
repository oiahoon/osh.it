#!/usr/bin/env zsh
# OSH Caching System
# Provides efficient caching for system information and API calls
# Version: 1.0.0

# Ensure this library is only loaded once
if [[ -n "${OSH_CACHE_LOADED:-}" ]]; then
  return 0
fi

# Cache configuration
OSH_CACHE_DIR="${OSH_CACHE_DIR:-$HOME/.osh-cache}"
OSH_CACHE_DEFAULT_TTL="${OSH_CACHE_DEFAULT_TTL:-3600}"  # 1 hour default

# Ensure cache directory exists
osh_cache_init() {
  if [[ ! -d "$OSH_CACHE_DIR" ]]; then
    mkdir -p "$OSH_CACHE_DIR" 2>/dev/null || {
      OSH_CACHE_DIR="/tmp/osh_cache_$$"
      mkdir -p "$OSH_CACHE_DIR" 2>/dev/null || {
        echo "Warning: Cannot create cache directory, caching disabled" >&2
        return 1
      }
    }
  fi
  return 0
}

# Get file modification time (cross-platform)
osh_cache_get_mtime() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  
  # Try Linux stat first, then macOS stat
  stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null || return 1
}

# Check if cache file is valid
osh_cache_is_valid() {
  local cache_file="$1"
  local ttl="${2:-$OSH_CACHE_DEFAULT_TTL}"
  
  [[ -f "$cache_file" ]] || return 1
  
  local cache_time
  cache_time=$(osh_cache_get_mtime "$cache_file") || return 1
  
  local current_time=$(date +%s)
  local age=$((current_time - cache_time))
  
  [[ $age -lt $ttl ]]
}

# Get cache file path for a key
osh_cache_get_path() {
  local key="$1"
  local namespace="${2:-default}"
  
  # Sanitize key for filename
  local safe_key=$(echo "$key" | tr '/' '_' | tr ' ' '_' | tr -cd '[:alnum:]_.-')
  echo "$OSH_CACHE_DIR/${namespace}_${safe_key}"
}

# Get cached data
osh_cache_get() {
  local key="$1"
  local ttl="${2:-$OSH_CACHE_DEFAULT_TTL}"
  local namespace="${3:-default}"
  
  osh_cache_init || return 1
  
  local cache_file
  cache_file=$(osh_cache_get_path "$key" "$namespace")
  
  if osh_cache_is_valid "$cache_file" "$ttl"; then
    cat "$cache_file" 2>/dev/null
    return 0
  fi
  
  return 1
}

# Set cached data
osh_cache_set() {
  local key="$1"
  local data="$2"
  local namespace="${3:-default}"
  
  osh_cache_init || return 1
  
  local cache_file
  cache_file=$(osh_cache_get_path "$key" "$namespace")
  
  echo "$data" > "$cache_file" 2>/dev/null
}

# Execute command with caching
osh_cache_exec() {
  local key="$1"
  local ttl="$2"
  local namespace="$3"
  shift 3
  local command=("$@")
  
  # Try to get from cache first
  local cached_result
  if cached_result=$(osh_cache_get "$key" "$ttl" "$namespace"); then
    echo "$cached_result"
    return 0
  fi
  
  # Execute command and cache result
  local result
  if result=$("${command[@]}" 2>/dev/null); then
    osh_cache_set "$key" "$result" "$namespace"
    echo "$result"
    return 0
  fi
  
  return 1
}

# Clear cache for a key or namespace
osh_cache_clear() {
  local key="${1:-}"
  local namespace="${2:-default}"
  
  if [[ -z "$key" ]]; then
    # Clear entire namespace
    rm -f "$OSH_CACHE_DIR/${namespace}_"* 2>/dev/null
  else
    # Clear specific key
    local cache_file
    cache_file=$(osh_cache_get_path "$key" "$namespace")
    rm -f "$cache_file" 2>/dev/null
  fi
}

# Get cache statistics
osh_cache_stats() {
  osh_cache_init || return 1
  
  local total_files=$(find "$OSH_CACHE_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
  local total_size
  
  if command -v du >/dev/null 2>&1; then
    total_size=$(du -sh "$OSH_CACHE_DIR" 2>/dev/null | cut -f1)
  else
    total_size="unknown"
  fi
  
  echo "Cache Directory: $OSH_CACHE_DIR"
  echo "Total Files: $total_files"
  echo "Total Size: $total_size"
  echo "Default TTL: ${OSH_CACHE_DEFAULT_TTL}s"
}

# Cleanup expired cache files
osh_cache_cleanup() {
  osh_cache_init || return 1
  
  local current_time=$(date +%s)
  local cleaned=0
  
  find "$OSH_CACHE_DIR" -type f 2>/dev/null | while read -r cache_file; do
    local cache_time
    if cache_time=$(osh_cache_get_mtime "$cache_file"); then
      local age=$((current_time - cache_time))
      if [[ $age -gt $OSH_CACHE_DEFAULT_TTL ]]; then
        rm -f "$cache_file" 2>/dev/null && ((cleaned++))
      fi
    fi
  done
  
  echo "Cleaned $cleaned expired cache files"
}

# Mark library as loaded
export OSH_CACHE_LOADED=1

# Initialize cache on load
osh_cache_init
