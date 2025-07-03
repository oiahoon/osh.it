#!/usr/bin/env bash
# OSH Plugin Manifest Manager
# 基于官方插件清单的管理系统

# 配置
MANIFEST_URL="${OSH_MANIFEST_URL:-https://raw.githubusercontent.com/oiahoon/osh/master/PLUGIN_MANIFEST.json}"
MANIFEST_CACHE="/tmp/osh_plugin_manifest.json"
MANIFEST_TTL=3600  # 1小时缓存

# 获取插件清单
get_plugin_manifest() {
  local force_refresh="${1:-false}"
  
  # 检查缓存
  if [[ "$force_refresh" != "true" && -f "$MANIFEST_CACHE" ]]; then
    local cache_age=$(($(date +%s) - $(stat -f %m "$MANIFEST_CACHE" 2>/dev/null || echo 0)))
    if [[ $cache_age -lt $MANIFEST_TTL ]]; then
      cat "$MANIFEST_CACHE"
      return 0
    fi
  fi
  
  # 下载新的清单
  echo "🔄 Fetching plugin manifest..." >&2
  if command -v curl >/dev/null 2>&1; then
    if curl -fsSL "$MANIFEST_URL" -o "$MANIFEST_CACHE"; then
      cat "$MANIFEST_CACHE"
      return 0
    fi
  elif command -v wget >/dev/null 2>&1; then
    if wget -q "$MANIFEST_URL" -O "$MANIFEST_CACHE"; then
      cat "$MANIFEST_CACHE"
      return 0
    fi
  fi
  
  # 如果下载失败，尝试使用本地备份
  if [[ -f "PLUGIN_MANIFEST.json" ]]; then
    echo "⚠️  Using local manifest backup..." >&2
    cp "PLUGIN_MANIFEST.json" "$MANIFEST_CACHE"
    cat "$MANIFEST_CACHE"
    return 0
  fi
  
  # 最终回退到硬编码
  echo "❌ Failed to get manifest, using fallback..." >&2
  cat << 'EOF'
{
  "categories": {
    "stable": {
      "plugins": [
        {"name": "proxy", "description": "Network proxy management"},
        {"name": "sysinfo", "description": "System information display"},
        {"name": "weather", "description": "Weather forecast"},
        {"name": "taskman", "description": "Task manager"}
      ]
    }
  },
  "presets": {
    "recommended": ["proxy", "sysinfo", "weather", "taskman"]
  }
}
EOF
}

# 解析可用插件列表
get_available_plugins_from_manifest() {
  local category="${1:-stable}"
  local manifest
  
  manifest=$(get_plugin_manifest)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  # 使用jq解析JSON (如果可用)
  if command -v jq >/dev/null 2>&1; then
    echo "$manifest" | jq -r ".categories.${category}.plugins[].name" 2>/dev/null
  else
    # 简单的grep解析 (回退方案)
    echo "$manifest" | grep -o '"name": "[^"]*"' | cut -d'"' -f4
  fi
}

# 获取插件描述
get_plugin_description_from_manifest() {
  local plugin_name="$1"
  local manifest
  
  manifest=$(get_plugin_manifest)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  if command -v jq >/dev/null 2>&1; then
    echo "$manifest" | jq -r ".categories[].plugins[] | select(.name == \"$plugin_name\") | .description" 2>/dev/null | head -1
  else
    # 简单解析
    echo "$manifest" | grep -A 5 "\"name\": \"$plugin_name\"" | grep '"description"' | cut -d'"' -f4
  fi
}

# 获取插件文件列表
get_plugin_files_from_manifest() {
  local plugin_name="$1"
  local manifest
  
  manifest=$(get_plugin_manifest)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  if command -v jq >/dev/null 2>&1; then
    echo "$manifest" | jq -r ".categories[].plugins[] | select(.name == \"$plugin_name\") | .files[]" 2>/dev/null
  else
    # 回退到硬编码映射
    case "$plugin_name" in
      "proxy") echo "plugins/proxy/proxy.plugin.zsh" ;;
      "sysinfo") echo "plugins/sysinfo/sysinfo.plugin.zsh" ;;
      "weather") 
        echo "plugins/weather/weather.plugin.zsh"
        echo "plugins/weather/completions/_weather"
        ;;
      "taskman") echo "plugins/taskman/taskman.plugin.zsh" ;;
      "acw") echo "plugins/acw/acw.plugin.zsh" ;;
      "fzf") echo "plugins/fzf/fzf.plugin.zsh" ;;
      "greeting") echo "plugins/greeting/greeting.plugin.zsh" ;;
    esac
  fi
}

# 获取预设插件列表
get_preset_plugins() {
  local preset="${1:-recommended}"
  local manifest
  
  manifest=$(get_plugin_manifest)
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  if command -v jq >/dev/null 2>&1; then
    echo "$manifest" | jq -r ".presets.${preset}[]" 2>/dev/null
  else
    # 硬编码回退
    case "$preset" in
      "minimal") echo -e "proxy\nsysinfo" ;;
      "recommended") echo -e "proxy\nsysinfo\nweather\ntaskman" ;;
      "developer") echo -e "proxy\nsysinfo\nweather\ntaskman\nacw\nfzf" ;;
      "full") echo -e "proxy\nsysinfo\nweather\ntaskman\nacw\nfzf\ngreeting" ;;
    esac
  fi
}

# 增强的插件选择界面
enhanced_plugin_selection_with_manifest() {
  local category="${PLUGIN_CATEGORY:-stable}"
  local available_plugins=()
  
  echo "🔍 Loading plugin manifest..." >&2
  
  # 从清单获取可用插件
  while IFS= read -r plugin; do
    if [[ -n "$plugin" ]]; then
      available_plugins+=("$plugin")
    fi
  done < <(get_available_plugins_from_manifest "$category")
  
  # 如果清单获取失败，回退到本地发现
  if [[ ${#available_plugins[@]} -eq 0 ]]; then
    echo "⚠️  Manifest unavailable, using local discovery..." >&2
    while IFS= read -r -d '' plugin_file; do
      local plugin_name=$(basename "$(dirname "$plugin_file")")
      available_plugins+=("$plugin_name")
    done < <(find "${OSH_DIR:-$HOME/.osh}/plugins" -name "*.plugin.zsh" -print0 2>/dev/null)
  fi
  
  if [[ ${#available_plugins[@]} -eq 0 ]]; then
    echo "❌ No plugins available" >&2
    return 1
  fi
  
  # 显示插件选择界面
  {
    echo "${BOLD}${CYAN}🔌 Plugin Selection${NORMAL}"
    echo
    echo "Available plugins from ${BOLD}${category}${NORMAL} category (${#available_plugins[@]} found):"
    echo
    
    for i in "${!available_plugins[@]}"; do
      local plugin="${available_plugins[$i]}"
      local description=$(get_plugin_description_from_manifest "$plugin")
      
      # 如果清单中没有描述，使用本地描述
      if [[ -z "$description" ]]; then
        description=$(get_plugin_description "$plugin" 2>/dev/null || echo "Plugin description not available")
      fi
      
      printf "  ${CYAN}%d)${NORMAL} ${BOLD}%s${NORMAL}\n" $((i + 1)) "$plugin"
      printf "     ${DIM}%s${NORMAL}\n" "$description"
      echo
    done
    
    echo "${BOLD}Selection options:${NORMAL}"
    echo "  • Enter ${CYAN}numbers${NORMAL} (space-separated): ${DIM}1 2 3${NORMAL}"
    echo "  • Enter ${CYAN}'preset:name'${NORMAL}: Use predefined preset"
    echo "    - ${CYAN}preset:minimal${NORMAL}: Basic plugins only"
    echo "    - ${CYAN}preset:recommended${NORMAL}: Recommended plugins (default)"
    echo "    - ${CYAN}preset:developer${NORMAL}: Developer-focused plugins"
    echo "    - ${CYAN}preset:full${NORMAL}: All stable plugins"
    echo "  • Enter ${CYAN}'a'${NORMAL} or ${CYAN}'all'${NORMAL}: Install all available plugins"
    echo "  • Press ${CYAN}Enter${NORMAL} without input: Use recommended preset"
    echo
  } >&2
  
  while true; do
    printf "${BOLD}Your choice${NORMAL} [${GREEN}preset:recommended${NORMAL}]: " >&2
    read -r selection
    
    # 默认使用推荐预设
    if [[ -z "$selection" ]]; then
      selection="preset:recommended"
    fi
    
    case "$selection" in
      preset:*)
        local preset_name="${selection#preset:}"
        local preset_plugins=()
        while IFS= read -r plugin; do
          if [[ -n "$plugin" ]]; then
            preset_plugins+=("$plugin")
          fi
        done < <(get_preset_plugins "$preset_name")
        
        if [[ ${#preset_plugins[@]} -gt 0 ]]; then
          echo "${preset_plugins[@]}"
          return 0
        else
          echo "❌ Unknown preset: $preset_name" >&2
        fi
        ;;
      "a"|"all")
        echo "${available_plugins[@]}"
        return 0
        ;;
      *)
        # 数字选择
        local valid_selection=true
        local temp_plugins=()
        
        for num in $selection; do
          if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#available_plugins[@]} ]]; then
            temp_plugins+=("${available_plugins[$((num - 1))]}")
          else
            echo "❌ Invalid selection: $num (must be 1-${#available_plugins[@]})" >&2
            valid_selection=false
            break
          fi
        done
        
        if [[ "$valid_selection" == "true" ]]; then
          # 去重
          local unique_plugins=()
          for plugin in "${temp_plugins[@]}"; do
            local found=false
            for existing in "${unique_plugins[@]}"; do
              if [[ "$existing" == "$plugin" ]]; then
                found=true
                break
              fi
            done
            if [[ "$found" == "false" ]]; then
              unique_plugins+=("$plugin")
            fi
          done
          echo "${unique_plugins[@]}"
          return 0
        fi
        ;;
    esac
    
    echo "Please try again." >&2
  done
}

# 验证插件可用性
verify_plugin_availability() {
  local plugin="$1"
  local base_url="${OSH_REPO_BASE:-https://raw.githubusercontent.com/oiahoon/osh/master}"
  
  # 从清单获取插件文件列表
  local plugin_files
  plugin_files=$(get_plugin_files_from_manifest "$plugin")
  
  if [[ -z "$plugin_files" ]]; then
    return 1
  fi
  
  # 检查每个文件是否可用
  while read -r file; do
    if [[ -n "$file" ]]; then
      local url="$base_url/$file"
      if ! curl -s -I "$url" | grep -q "200 OK"; then
        return 1
      fi
    fi
  done <<< "$plugin_files"
  
  return 0
}

# 显示清单信息
show_manifest_info() {
  local manifest
  manifest=$(get_plugin_manifest)
  
  if command -v jq >/dev/null 2>&1; then
    echo "📋 Plugin Manifest Information:"
    echo "  Version: $(echo "$manifest" | jq -r '.version')"
    echo "  Last Updated: $(echo "$manifest" | jq -r '.last_updated')"
    echo "  Categories:"
    echo "$manifest" | jq -r '.categories | keys[]' | sed 's/^/    - /'
    echo "  Presets:"
    echo "$manifest" | jq -r '.presets | keys[]' | sed 's/^/    - /'
  else
    echo "📋 Plugin Manifest loaded successfully"
    echo "  Use 'jq' for detailed information"
  fi
}

# 测试函数
test_manifest_system() {
  echo "=== 测试插件清单系统 ==="
  
  echo "1. 获取stable类别插件:"
  get_available_plugins_from_manifest "stable"
  
  echo
  echo "2. 获取推荐预设:"
  get_preset_plugins "recommended"
  
  echo
  echo "3. 获取weather插件描述:"
  get_plugin_description_from_manifest "weather"
  
  echo
  echo "4. 获取weather插件文件:"
  get_plugin_files_from_manifest "weather"
  
  echo
  echo "5. 清单信息:"
  show_manifest_info
}

# 如果直接执行此脚本，运行测试
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  cd "$(dirname "$0")"
  
  # 模拟颜色变量
  BOLD="" CYAN="" NORMAL="" GREEN="" DIM=""
  
  test_manifest_system
fi
