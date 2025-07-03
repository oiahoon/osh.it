#!/bin/zsh

# OSH.IT Greeting Plugin
# A simple greeting function for OSH.IT users

# Load vintage design system
if [[ -z "${OSH_VINTAGE_LOADED:-}" ]] && [[ -f "${OSH}/lib/vintage.zsh" ]]; then
  source "${OSH}/lib/vintage.zsh"
fi

osh_greet() {
    local user_name="${USER:-$(whoami)}"
    local current_time=$(date +"%H")
    local greeting_time
    
    # Determine greeting based on time of day
    if [[ $current_time -lt 12 ]]; then
        greeting_time="Good morning"
    elif [[ $current_time -lt 17 ]]; then
        greeting_time="Good afternoon"
    else
        greeting_time="Good evening"
    fi
    
    osh_vintage_brand "🚀 OSH.IT Framework"
    osh_vintage_info "$greeting_time, $user_name!"
    osh_vintage_success "Ready to boost your productivity? 💪"
    
    # Show current directory
    osh_vintage_info "📁 Current directory: $(pwd)"
    
    # Show git status if in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        if [[ -n "$branch" ]]; then
            osh_vintage_info "🌿 Git branch: $branch"
        fi
    fi
    
    osh_vintage_brand "✨ Happy coding!"
}

# Auto-greet when plugin loads (optional - can be commented out)
# osh_greet
