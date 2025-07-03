#!/usr/bin/env bash
# OSH Installation Script Improvements
# This file contains suggested enhancements for better user experience

# Enhanced network connectivity check
check_network_connectivity() {
  local test_urls=(
    "https://github.com"
    "https://raw.githubusercontent.com"
    "https://gitee.com"
  )
  
  log_info "🌐 检查网络连接..."
  
  for url in "${test_urls[@]}"; do
    if curl -s --connect-timeout 5 --max-time 10 "$url" >/dev/null 2>&1; then
      log_success "网络连接正常"
      return 0
    fi
  done
  
  log_error "网络连接失败，请检查以下项目："
  echo "  • 网络连接是否正常"
  echo "  • 防火墙设置是否阻止访问"
  echo "  • 代理设置是否正确"
  echo ""
  echo "如果在中国大陆，可以尝试使用镜像源："
  echo "  export OSH_MIRROR=gitee"
  echo "  $0"
  
  return 1
}

# Mirror source support
setup_mirror_source() {
  local mirror="${OSH_MIRROR:-github}"
  
  case "$mirror" in
    "github")
      OSH_REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh/master"
      log_info "使用GitHub源"
      ;;
    "gitee")
      OSH_REPO_BASE="https://gitee.com/oiahoon/osh/raw/master"
      log_info "使用Gitee镜像源"
      ;;
    "custom")
      if [[ -z "$OSH_CUSTOM_REPO" ]]; then
        log_error "使用自定义源时需要设置 OSH_CUSTOM_REPO 环境变量"
        return 1
      fi
      OSH_REPO_BASE="$OSH_CUSTOM_REPO"
      log_info "使用自定义源: $OSH_CUSTOM_REPO"
      ;;
    *)
      log_warning "未知的镜像源: $mirror，使用默认GitHub源"
      OSH_REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh/master"
      ;;
  esac
}

# Enhanced dependency check
check_dependencies() {
  log_info "🔍 检查系统依赖..."
  
  local missing_deps=()
  local optional_deps=()
  
  # Essential dependencies
  local essential_deps=("curl" "git")
  for cmd in "${essential_deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_deps+=("$cmd")
    fi
  done
  
  # Optional but recommended dependencies
  local recommended_deps=("zsh" "python3")
  for cmd in "${recommended_deps[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      optional_deps+=("$cmd")
    fi
  done
  
  # Report missing essential dependencies
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log_error "缺少必要依赖: ${missing_deps[*]}"
    echo ""
    echo "请安装缺少的依赖："
    
    # Provide OS-specific installation instructions
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  macOS (使用Homebrew):"
      for dep in "${missing_deps[@]}"; do
        echo "    brew install $dep"
      done
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      echo "  Ubuntu/Debian:"
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "curl") echo "    sudo apt-get install curl" ;;
          "git") echo "    sudo apt-get install git" ;;
        esac
      done
      echo ""
      echo "  CentOS/RHEL:"
      for dep in "${missing_deps[@]}"; do
        case "$dep" in
          "curl") echo "    sudo yum install curl" ;;
          "git") echo "    sudo yum install git" ;;
        esac
      done
    fi
    
    return 1
  fi
  
  # Report missing optional dependencies
  if [[ ${#optional_deps[@]} -gt 0 ]]; then
    log_warning "建议安装以下依赖以获得最佳体验: ${optional_deps[*]}"
    
    if [[ " ${optional_deps[*]} " =~ " zsh " ]]; then
      echo "  • zsh: OSH专为zsh设计，强烈建议安装"
    fi
    
    if [[ " ${optional_deps[*]} " =~ " python3 " ]]; then
      echo "  • python3: taskman插件需要Python支持"
    fi
    echo ""
  fi
  
  log_success "✅ 依赖检查完成"
  return 0
}

# Progress bar function
show_progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  
  printf "\r${BLUE}["
  printf "%*s" $filled | tr ' ' '█'
  printf "%*s" $((width - filled)) | tr ' ' '░'
  printf "] %d%% (%d/%d)${NORMAL}" $percentage $current $total
}

# Plugin preview function
preview_plugin() {
  local plugin="$1"
  
  echo "${BOLD}${CYAN}🔌 $plugin${NORMAL}"
  
  case "$plugin" in
    "proxy")
      echo "  ${DIM}功能: 网络代理管理${NORMAL}"
      echo "  ${GREEN}示例: proxyctl${NORMAL} - 切换代理开关"
      echo "  ${GREEN}示例: proxy_status${NORMAL} - 查看代理状态"
      ;;
    "sysinfo")
      echo "  ${DIM}功能: 系统信息显示${NORMAL}"
      echo "  ${GREEN}示例: sysinfo${NORMAL} - 显示系统信息和OSH标志"
      echo "  ${GREEN}示例: oshinfo${NORMAL} - 别名命令"
      ;;
    "weather")
      echo "  ${DIM}功能: 天气预报显示${NORMAL}"
      echo "  ${GREEN}示例: weather${NORMAL} - 显示当前位置天气"
      echo "  ${GREEN}示例: weather -l Tokyo${NORMAL} - 显示东京天气"
      echo "  ${GREEN}示例: forecast${NORMAL} - 详细天气预报"
      ;;
    "taskman")
      echo "  ${DIM}功能: 终端任务管理器${NORMAL}"
      echo "  ${GREEN}示例: tm${NORMAL} - 启动任务管理器"
      echo "  ${GREEN}示例: tasks add '完成文档'${NORMAL} - 添加任务"
      echo "  ${GREEN}示例: tasks list${NORMAL} - 列出所有任务"
      ;;
    "acw")
      echo "  ${DIM}功能: Git + JIRA工作流自动化${NORMAL}"
      echo "  ${GREEN}示例: acw feature${NORMAL} - 创建功能分支"
      echo "  ${GREEN}示例: ggco keyword${NORMAL} - 智能分支切换"
      ;;
    "fzf")
      echo "  ${DIM}功能: 增强的模糊查找器${NORMAL}"
      echo "  ${GREEN}示例: pp filename${NORMAL} - 预览文件"
      echo "  ${GREEN}示例: fcommit${NORMAL} - 交互式Git提交浏览"
      ;;
    *)
      echo "  ${DIM}插件描述暂不可用${NORMAL}"
      ;;
  esac
  echo
}

# Enhanced plugin selection with preview
interactive_plugin_selection_enhanced() {
  local available_plugins=(proxy sysinfo weather taskman acw fzf)
  
  {
    echo "${BOLD}${CYAN}🔌 插件选择向导${NORMAL}"
    echo
    echo "OSH提供多个实用插件，您可以选择需要的插件进行安装："
    echo
    
    # Show plugins with detailed preview
    echo "${BOLD}可用插件:${NORMAL}"
    for i in "${!available_plugins[@]}"; do
      local plugin="${available_plugins[$i]}"
      printf "  ${CYAN}%d)${NORMAL} " $((i + 1))
      preview_plugin "$plugin"
    done
    
    echo "${BOLD}选择方式:${NORMAL}"
    echo "  • 输入 ${CYAN}数字${NORMAL} (空格分隔): ${DIM}1 2 3${NORMAL}"
    echo "  • 输入 ${CYAN}'a'${NORMAL} 或 ${CYAN}'all'${NORMAL}: 安装所有插件"
    echo "  • 输入 ${CYAN}'r'${NORMAL} 或 ${CYAN}'recommended'${NORMAL}: 安装推荐插件"
    echo "  • 输入 ${CYAN}'m'${NORMAL} 或 ${CYAN}'minimal'${NORMAL}: 最小安装"
    echo "  • 直接 ${CYAN}回车${NORMAL}: 使用推荐配置"
    echo
  } >&2
  
  while true; do
    printf "${BOLD}您的选择${NORMAL} [${GREEN}推荐${NORMAL}]: " >&2
    read -r selection
    
    # Default to recommended if empty
    if [[ -z "$selection" ]]; then
      selection="r"
    fi
    
    case "$selection" in
      "a"|"all")
        echo "proxy sysinfo weather taskman acw fzf"
        return 0
        ;;
      "r"|"recommended")
        echo "proxy sysinfo weather taskman"
        return 0
        ;;
      "m"|"minimal")
        echo "proxy sysinfo"
        return 0
        ;;
      "n"|"none")
        echo ""
        return 0
        ;;
      *)
        # Parse number selection with validation
        local valid_selection=true
        local temp_plugins=()
        
        for num in $selection; do
          if [[ "$num" =~ ^[0-9]+$ ]] && [[ $num -ge 1 ]] && [[ $num -le ${#available_plugins[@]} ]]; then
            temp_plugins+=("${available_plugins[$((num - 1))]}")
          else
            echo "${RED}无效选择: $num (必须是 1-${#available_plugins[@]})${NORMAL}" >&2
            valid_selection=false
            break
          fi
        done
        
        if [[ "$valid_selection" == "true" ]]; then
          # Remove duplicates
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
    
    echo "${YELLOW}请重新选择${NORMAL}" >&2
  done
}

# Installation verification
verify_installation() {
  log_info "🔍 验证安装完整性..."
  
  local verification_failed=false
  
  # Check core files
  local core_files=("osh.sh" "lib/common.zsh" "lib/colors.zsh")
  for file in "${core_files[@]}"; do
    if [[ ! -f "$OSH_DIR/$file" ]]; then
      log_error "核心文件缺失: $file"
      verification_failed=true
    fi
  done
  
  # Check if OSH can be loaded
  if ! timeout 10 zsh -c "
    export OSH='$OSH_DIR'
    source '$OSH_DIR/osh.sh' 2>/dev/null && 
    echo 'OSH loaded successfully'
  " >/dev/null 2>&1; then
    log_warning "OSH加载测试失败，可能需要手动检查配置"
    verification_failed=true
  fi
  
  # Check plugin loading
  local selected_plugins=("$@")
  for plugin in "${selected_plugins[@]}"; do
    if [[ -n "$plugin" ]]; then
      local plugin_file="$OSH_DIR/plugins/$plugin/$plugin.plugin.zsh"
      if [[ ! -f "$plugin_file" ]]; then
        log_warning "插件文件缺失: $plugin_file"
        verification_failed=true
      fi
    fi
  done
  
  if [[ "$verification_failed" == "true" ]]; then
    log_warning "⚠️  安装验证发现问题，但OSH应该仍可正常使用"
    echo "如果遇到问题，请尝试重新安装或联系支持"
    return 1
  else
    log_success "✅ 安装验证通过"
    return 0
  fi
}

# Cleanup failed installation
cleanup_failed_installation() {
  if [[ -d "$OSH_DIR.backup" ]]; then
    log_info "🔄 检测到安装失败，正在恢复..."
    
    if rm -rf "$OSH_DIR" 2>/dev/null && mv "$OSH_DIR.backup" "$OSH_DIR" 2>/dev/null; then
      log_success "✅ 已恢复到安装前状态"
    else
      log_error "恢复失败，请手动检查 $OSH_DIR.backup"
    fi
  fi
}

# Configuration wizard
run_configuration_wizard() {
  echo "${BOLD}${MAGENTA}🎨 OSH配置向导${NORMAL}"
  echo
  
  # Git configuration check
  if ! git config --global user.name >/dev/null 2>&1; then
    echo "检测到Git用户信息未配置，这对某些OSH插件很重要。"
    printf "是否现在配置Git用户信息？ [${GREEN}Y${NORMAL}/n]: "
    read -r setup_git
    
    if [[ "$setup_git" != "n" && "$setup_git" != "N" ]]; then
      printf "请输入您的姓名: "
      read -r git_name
      printf "请输入您的邮箱: "
      read -r git_email
      
      if [[ -n "$git_name" && -n "$git_email" ]]; then
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        log_success "✅ Git配置完成"
      fi
    fi
    echo
  fi
  
  # Shell recommendation
  if [[ "$CURRENT_SHELL" != "zsh" ]] && command -v zsh >/dev/null 2>&1; then
    echo "检测到您的系统已安装zsh，但当前使用的是 $CURRENT_SHELL。"
    echo "OSH专为zsh设计，建议切换到zsh以获得最佳体验。"
    printf "是否现在切换到zsh？ [${GREEN}Y${NORMAL}/n]: "
    read -r switch_shell
    
    if [[ "$switch_shell" != "n" && "$switch_shell" != "N" ]]; then
      if chsh -s "$(which zsh)"; then
        log_success "✅ 已切换到zsh，请重新打开终端"
        CURRENT_SHELL="zsh"
        SHELL_CONFIG_FILE="$HOME/.zshrc"
      else
        log_warning "切换shell失败，请手动执行: chsh -s \$(which zsh)"
      fi
    fi
    echo
  fi
}

# OSH health check command
osh_doctor() {
  echo "${BOLD}${CYAN}🏥 OSH健康检查${NORMAL}"
  echo
  
  local issues_found=0
  
  # Check installation integrity
  echo "${BOLD}1. 检查安装完整性${NORMAL}"
  if verify_installation >/dev/null 2>&1; then
    log_success "  ✅ 安装完整"
  else
    log_error "  ❌ 安装不完整"
    issues_found=$((issues_found + 1))
  fi
  
  # Check configuration
  echo "${BOLD}2. 检查配置文件${NORMAL}"
  if [[ -f "$SHELL_CONFIG_FILE" ]] && grep -q "OSH" "$SHELL_CONFIG_FILE"; then
    log_success "  ✅ 配置文件正常"
  else
    log_error "  ❌ 配置文件问题"
    issues_found=$((issues_found + 1))
  fi
  
  # Check plugin status
  echo "${BOLD}3. 检查插件状态${NORMAL}"
  local plugin_issues=0
  for plugin_dir in "$OSH_DIR"/plugins/*/; do
    if [[ -d "$plugin_dir" ]]; then
      local plugin_name=$(basename "$plugin_dir")
      local plugin_file="$plugin_dir/$plugin_name.plugin.zsh"
      if [[ ! -f "$plugin_file" ]]; then
        log_warning "  ⚠️  插件文件缺失: $plugin_name"
        plugin_issues=$((plugin_issues + 1))
      fi
    fi
  done
  
  if [[ $plugin_issues -eq 0 ]]; then
    log_success "  ✅ 所有插件正常"
  else
    log_warning "  ⚠️  发现 $plugin_issues 个插件问题"
  fi
  
  # Performance test
  echo "${BOLD}4. 性能测试${NORMAL}"
  local startup_time
  startup_time=$(time (zsh -i -c exit) 2>&1 | grep real | awk '{print $2}')
  if [[ -n "$startup_time" ]]; then
    echo "  启动时间: $startup_time"
  else
    echo "  无法测量启动时间"
  fi
  
  echo
  if [[ $issues_found -eq 0 ]]; then
    log_success "🎉 OSH运行状态良好！"
  else
    log_warning "发现 $issues_found 个问题，建议重新安装OSH"
    echo "重新安装命令:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh/master/install.sh)\""
  fi
}

# Export functions for use in main install script
# These functions can be sourced and used to enhance the existing install.sh
