#!/usr/bin/env bash
# Progress Bar Demo for OSH.IT
# Demonstrates the progress bar functionality

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NORMAL='\033[0m'

# Progress bar function with file info
show_progress_with_file() {
  local current=$1
  local total=$2
  local filename="$3"
  local status="$4"  # "downloading", "success", "failed"
  local width=30
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  
  # Clear the line and show progress
  printf "\r\033[K"  # Clear entire line
  
  # Show progress bar
  printf "${BLUE}["
  printf "%*s" $filled | tr ' ' '█'
  printf "%*s" $((width - filled)) | tr ' ' '░'
  printf "] %3d%% (%d/%d)${NORMAL} " $percentage $current $total
  
  # Show current file and status
  case "$status" in
    "downloading")
      printf "Downloading %s..." "$filename"
      ;;
    "success")
      printf "Downloaded %s ${GREEN}✓${NORMAL}" "$filename"
      ;;
    "failed")
      printf "Failed %s ${RED}✗${NORMAL}" "$filename"
      ;;
  esac
  
  # If completed, add newline
  if [[ $current -eq $total ]]; then
    printf "\n"
  fi
}

# Simulate file download with inline progress
simulate_download_with_progress() {
  local current=$1
  local total=$2
  local filename="$3"
  local delay="$4"
  
  # Show downloading
  show_progress_with_file $current $total "$filename" "downloading"
  sleep "$delay"
  
  # Show result
  if [[ $((RANDOM % 10)) -lt 9 ]]; then
    show_progress_with_file $current $total "$filename" "success"
    sleep 0.1
    return 0
  else
    show_progress_with_file $current $total "$filename" "failed"
    sleep 0.3
    return 1
  fi
}

# Demo installation process
demo_installation() {
  echo "🚀 OSH.IT Installation Progress Demo"
  echo "===================================="
  echo
  
  # Core files download
  echo "📦 Downloading OSH core files..."
  local core_files=("osh.sh" "upgrade.sh" "VERSION" "LICENSE" "lib/colors.zsh" "lib/common.zsh")
  local total_core=${#core_files[@]}
  
  for i in $(seq 1 $total_core); do
    simulate_download_with_progress $i $total_core "${core_files[$((i-1))]}" 0.3
  done
  
  echo
  echo "${GREEN}✅ Core files downloaded successfully!${NORMAL}"
  echo
  
  # Plugin files download
  echo "🔌 Downloading selected plugins..."
  local plugins=("sysinfo" "weather" "taskman")
  local plugin_count=0
  local total_plugins=${#plugins[@]}
  
  for plugin in "${plugins[@]}"; do
    plugin_count=$((plugin_count + 1))
    echo
    printf "${BLUE}[%d/%d]${NORMAL} Installing plugin: %s\n" "$plugin_count" "$total_plugins" "$plugin"
    
    # Simulate plugin files
    local plugin_files=("${plugin}.plugin.zsh" "README.md")
    local file_count=0
    local total_plugin_files=${#plugin_files[@]}
    
    for plugin_file in "${plugin_files[@]}"; do
      file_count=$((file_count + 1))
      printf "  "
      simulate_download_with_progress $file_count $total_plugin_files "$plugin_file" 0.2
    done
    
    echo
    echo "  ${GREEN}✅ Plugin $plugin installed successfully!${NORMAL}"
  done
  
  echo
  echo "${GREEN}✅ All plugins downloaded successfully!${NORMAL}"
  echo
  
  # Final setup
  echo "🔧 Setting up file permissions..."
  sleep 1
  echo "${GREEN}✅ File permissions configured${NORMAL}"
  echo
  
  echo "${GREEN}🎉 OSH.IT installation completed successfully!${NORMAL}"
}

# Demo upgrade process
demo_upgrade() {
  echo "🔄 OSH.IT Upgrade Progress Demo"
  echo "==============================="
  echo
  
  echo "🔍 Checking versions..."
  sleep 0.5
  echo "📦 Current version: 1.3.0"
  echo "🆕 Latest version: 1.4.0"
  echo
  
  echo "📦 Creating backup..."
  sleep 0.8
  echo "${GREEN}✅ Backup created successfully${NORMAL}"
  echo
  
  echo "📥 Updating OSH essential files..."
  local files=("osh.sh" "upgrade.sh" "VERSION" "lib/colors.zsh" "lib/common.zsh" "plugins/weather/weather.plugin.zsh")
  local total_files=${#files[@]}
  
  for i in $(seq 1 $total_files); do
    simulate_download_with_progress $i $total_files "${files[$((i-1))]}" 0.2
  done
  
  echo
  echo "${GREEN}✅ All files updated successfully!${NORMAL}"
  echo
  
  echo "🔧 Setting file permissions..."
  sleep 0.5
  echo "${GREEN}✅ Permissions updated${NORMAL}"
  echo
  
  echo "${GREEN}🎉 OSH.IT upgraded successfully from 1.3.0 to 1.4.0!${NORMAL}"
}

# Main demo
main() {
  case "${1:-install}" in
    "install")
      demo_installation
      ;;
    "upgrade")
      demo_upgrade
      ;;
    "both")
      demo_installation
      echo
      echo "Press Enter to continue with upgrade demo..."
      read -r
      echo
      demo_upgrade
      ;;
    *)
      echo "Usage: $0 [install|upgrade|both]"
      echo "  install - Demo installation progress"
      echo "  upgrade - Demo upgrade progress"
      echo "  both    - Demo both processes"
      ;;
  esac
}

main "$@"
