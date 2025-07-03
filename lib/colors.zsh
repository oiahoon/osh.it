#!/usr/bin/env zsh
# OSH Color Library
# Provides consistent color definitions across all plugins

# Text colors
export OSH_COLOR_RESET="\033[0m"
export OSH_COLOR_BLACK="\033[30m"
export OSH_COLOR_RED="\033[31m"
export OSH_COLOR_GREEN="\033[32m"
export OSH_COLOR_YELLOW="\033[33m"
export OSH_COLOR_BLUE="\033[34m"
export OSH_COLOR_PURPLE="\033[35m"
export OSH_COLOR_CYAN="\033[36m"
export OSH_COLOR_WHITE="\033[37m"
export OSH_COLOR_GRAY="\033[90m"

# Background colors
export OSH_BG_BLACK="\033[40m"
export OSH_BG_RED="\033[41m"
export OSH_BG_GREEN="\033[42m"
export OSH_BG_YELLOW="\033[43m"
export OSH_BG_BLUE="\033[44m"
export OSH_BG_PURPLE="\033[45m"
export OSH_BG_CYAN="\033[46m"
export OSH_BG_WHITE="\033[47m"

# Text styles
export OSH_STYLE_BOLD="\033[1m"
export OSH_STYLE_DIM="\033[2m"
export OSH_STYLE_ITALIC="\033[3m"
export OSH_STYLE_UNDERLINE="\033[4m"
export OSH_STYLE_BLINK="\033[5m"
export OSH_STYLE_REVERSE="\033[7m"
export OSH_STYLE_STRIKETHROUGH="\033[9m"

# Backward compatibility aliases for existing plugins
export NOCOLOR="${OSH_COLOR_RESET}"
export RED="${OSH_COLOR_RED}"
export GREEN="${OSH_COLOR_GREEN}"
export YELLOW="${OSH_COLOR_YELLOW}"
export BLUE="${OSH_COLOR_BLUE}"
export PURPLE="${OSH_COLOR_PURPLE}"
export CYAN="${OSH_COLOR_CYAN}"
export WHITE="${OSH_COLOR_WHITE}"
export GRAY="${OSH_COLOR_BLACK}"

# Background compatibility
export B_GRAY="${OSH_BG_WHITE}"
export B_BLUE="${OSH_BG_BLUE}"
export B_PURPLE="${OSH_BG_PURPLE}"

# Mark colors as loaded
export OSH_COLORS_LOADED=1
