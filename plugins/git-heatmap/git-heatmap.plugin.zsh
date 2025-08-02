#!/usr/bin/env zsh
# Git Heatmap Plugin for OSH.IT
# Version: 1.0.0
# Author: OSH.IT Team
# Description: Display GitHub-style contribution heatmap in terminal

# Cyberpunk color definitions
if [[ -t 1 ]]; then
    # GitHub-style colors with cyberpunk touch
    HEATMAP_COLOR_0=$'\033[38;2;235;237;240m'  # #ebedf0 - No contributions
    HEATMAP_COLOR_1=$'\033[38;2;155;233;168m'  # #9be9a8 - Low contributions  
    HEATMAP_COLOR_2=$'\033[38;2;64;196;99m'    # #40c463 - Medium contributions
    HEATMAP_COLOR_3=$'\033[38;2;48;161;78m'    # #30a14e - High contributions
    HEATMAP_COLOR_4=$'\033[38;2;33;110;57m'    # #216e39 - Very high contributions
    HEATMAP_RESET=$'\033[0m'
    HEATMAP_CYAN=$'\033[38;2;0;255;255m'       # Cyberpunk cyan
    HEATMAP_BLUE=$'\033[38;2;0;255;255m'       # Cyberpunk blue
    HEATMAP_GREEN=$'\033[38;2;0;255;65m'       # Cyberpunk green
    HEATMAP_BOLD=$'\033[1m'
else
    # Fallback for terminals without color support
    HEATMAP_COLOR_0=""
    HEATMAP_COLOR_1=""
    HEATMAP_COLOR_2=""
    HEATMAP_COLOR_3=""
    HEATMAP_COLOR_4=""
    HEATMAP_RESET=""
    HEATMAP_CYAN=""
    HEATMAP_BLUE=""
    HEATMAP_GREEN=""
    HEATMAP_BOLD=""
fi

# Get color by index
_get_heatmap_color() {
    case $1 in
        0) echo "$HEATMAP_COLOR_0" ;;
        1) echo "$HEATMAP_COLOR_1" ;;
        2) echo "$HEATMAP_COLOR_2" ;;
        3) echo "$HEATMAP_COLOR_3" ;;
        4) echo "$HEATMAP_COLOR_4" ;;
        *) echo "$HEATMAP_COLOR_0" ;;
    esac
}

# Heatmap symbols
HEATMAP_SYMBOL_0="▢"
HEATMAP_SYMBOL_1="░"
HEATMAP_SYMBOL_2="▒"
HEATMAP_SYMBOL_3="▓"
HEATMAP_SYMBOL_4="■"

# Get symbol by index
_get_heatmap_symbol() {
    case $1 in
        0) echo "$HEATMAP_SYMBOL_0" ;;
        1) echo "$HEATMAP_SYMBOL_1" ;;
        2) echo "$HEATMAP_SYMBOL_2" ;;
        3) echo "$HEATMAP_SYMBOL_3" ;;
        4) echo "$HEATMAP_SYMBOL_4" ;;
        *) echo "$HEATMAP_SYMBOL_0" ;;
    esac
}

# Main git_heatmap function
git_heatmap() {
    local days=365
    local style="default"
    local view="year"
    local help=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --days)
                days="$2"
                shift 2
                ;;
            --style)
                style="$2"
                shift 2
                ;;
            --view)
                view="$2"
                shift 2
                ;;
            --help|-h)
                help=true
                shift
                ;;
            *)
                echo "${HEATMAP_COLOR_0}${HEATMAP_BOLD}[ERROR]${HEATMAP_RESET} Unknown option: $1" >&2
                return 1
                ;;
        esac
    done
    
    if [[ "$help" == "true" ]]; then
        _git_heatmap_help
        return 0
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "${HEATMAP_COLOR_0}${HEATMAP_BOLD}[ERROR]${HEATMAP_RESET} Not in a git repository" >&2
        return 1
    fi
    
    case $view in
        "year")
            _git_heatmap_year "$days" "$style"
            ;;
        "month")
            _git_heatmap_month "$style"
            ;;
        *)
            echo "${HEATMAP_COLOR_0}${HEATMAP_BOLD}[ERROR]${HEATMAP_RESET} Unknown view: $view" >&2
            return 1
            ;;
    esac
}

# Show help
_git_heatmap_help() {
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}Git Heatmap Plugin${HEATMAP_RESET}"
    echo
    echo "${HEATMAP_BOLD}USAGE:${HEATMAP_RESET}"
    echo "  git-heatmap [OPTIONS]"
    echo
    echo "${HEATMAP_BOLD}OPTIONS:${HEATMAP_RESET}"
    echo "  --days NUM      Number of days to show (default: 365)"
    echo "  --style STYLE   Display style: default, compact (default: default)"
    echo "  --view VIEW     View type: year, month (default: year)"
    echo "  --help, -h      Show this help message"
    echo
    echo "${HEATMAP_BOLD}EXAMPLES:${HEATMAP_RESET}"
    echo "  git-heatmap                    # Show last year"
    echo "  git-heatmap --days 90          # Show last 90 days"
    echo "  git-heatmap --view month       # Show current month"
    echo "  git-heatmap --style compact    # Compact view"
}

# Generate year view heatmap
_git_heatmap_year() {
    local days="$1"
    local style="$2"
    
    # Get commit data for the specified period
    local -A commit_counts
    local total_commits=0
    local active_days=0
    local max_commits=0
    
    # Use a simpler approach for date range
    local end_date=$(date +%Y-%m-%d)
    local start_date
    
    # Calculate start date (cross-platform)
    if date --version >/dev/null 2>&1; then
        # GNU date (Linux)
        start_date=$(date -d "$end_date - $days days" +%Y-%m-%d)
    else
        # BSD date (macOS)
        start_date=$(date -v-${days}d +%Y-%m-%d)
    fi
    
    # Fetch git log data efficiently
    local git_output
    git_output=$(git log --since="$start_date" --until="$end_date" --pretty=format:"%ad" --date=short 2>/dev/null | sort | uniq -c | sort -k2)
    
    # Parse git data
    if [[ -n "$git_output" ]]; then
        while read -r count date_str; do
            if [[ -n "$date_str" && "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                commit_counts["$date_str"]=$count
                total_commits=$((total_commits + count))
                active_days=$((active_days + 1))
                [[ $count -gt $max_commits ]] && max_commits=$count
            fi
        done <<< "$git_output"
    fi
    
    # Calculate thresholds based on data
    local threshold1=1
    local threshold2=3
    local threshold3=6
    local threshold4=10
    
    if [[ $max_commits -gt 0 ]]; then
        threshold2=$((max_commits / 4))
        threshold3=$((max_commits / 2))
        threshold4=$((max_commits * 3 / 4))
        [[ $threshold2 -lt 2 ]] && threshold2=2
        [[ $threshold3 -lt 4 ]] && threshold3=4
        [[ $threshold4 -lt 7 ]] && threshold4=7
    fi
    
    # Display heatmap based on style
    if [[ "$style" == "compact" ]]; then
        _display_compact_heatmap "$start_date" "$end_date" "$threshold1" "$threshold2" "$threshold3" "$threshold4" commit_counts
    else
        _display_default_heatmap "$start_date" "$end_date" "$threshold1" "$threshold2" "$threshold3" "$threshold4" commit_counts
    fi
    
    # Display statistics
    echo
    echo "${HEATMAP_COLOR_1}Less${HEATMAP_RESET} $(_get_heatmap_symbol 0) $(_get_heatmap_symbol 1) $(_get_heatmap_symbol 2) $(_get_heatmap_symbol 3) $(_get_heatmap_symbol 4) ${HEATMAP_COLOR_4}More${HEATMAP_RESET}    ${HEATMAP_BOLD}$total_commits${HEATMAP_RESET} contributions in $(date +%Y)"
    echo "${HEATMAP_CYAN}Active days:${HEATMAP_RESET} ${active_days}/${days} ${HEATMAP_CYAN}•${HEATMAP_RESET} ${HEATMAP_CYAN}Total commits:${HEATMAP_RESET} ${total_commits}"
}

# Display default heatmap (simplified version)
_display_default_heatmap() {
    local start_date="$1"
    local end_date="$2"
    local t1="$3" t2="$4" t3="$5" t4="$6"
    local commits_array_name="$7"
    
    echo
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}Contribution Graph - Last $(($(date +%s) - $(date -d "$start_date" +%s) + 86400)) seconds${HEATMAP_RESET}"
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│${HEATMAP_BLUE}  Jan   Feb   Mar   Apr   May   Jun   Jul   Aug   Sep   Oct   Nov   Dec${HEATMAP_RESET}│"
    echo "├─────────────────────────────────────────────────────────────────────┤"
    echo "│                                                                     │"
    
    # Simplified heatmap display - just show recent activity pattern
    local row_data=""
    local check_date="$start_date"
    local day_count=0
    
    # Generate sample data for demonstration
    for ((i=0; i<52; i++)); do
        local commits=0
        # Simple array access workaround
        eval "commits=\${${commits_array_name}[$check_date]:-0}"
        local symbol_idx=0
        
        if [[ $commits -ge $t4 ]]; then
            symbol_idx=4
        elif [[ $commits -ge $t3 ]]; then
            symbol_idx=3
        elif [[ $commits -ge $t2 ]]; then
            symbol_idx=2
        elif [[ $commits -ge $t1 ]]; then
            symbol_idx=1
        fi
        
        row_data+="$(_get_heatmap_color $symbol_idx)$(_get_heatmap_symbol $symbol_idx)${HEATMAP_RESET}"
        
        # Move to next week
        if date --version >/dev/null 2>&1; then
            check_date=$(date -d "$check_date + 7 days" +%Y-%m-%d 2>/dev/null)
        else
            check_date=$(date -v+7d -j -f "%Y-%m-%d" "$check_date" +%Y-%m-%d 2>/dev/null)
        fi
        
        [[ "$check_date" > "$end_date" ]] && break
    done
    
    # Display the row
    printf "│%-65s│\n" "$row_data"
    
    echo "│                                                                     │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
}

# Display compact heatmap
_display_compact_heatmap() {
    local start_date="$1"
    local end_date="$2"
    local t1="$3" t2="$4" t3="$5" t4="$6"
    local commits_array_name="$7"
    
    echo
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}$(date +%Y) Contribution Activity${HEATMAP_RESET}"
    echo "┌──────────────────────────────────────────────────────────┐"
    echo "│${HEATMAP_BLUE} J F M A M J J A S O N D                                  ${HEATMAP_RESET}│"
    echo "├──────────────────────────────────────────────────────────┤"
    
    # Generate compact view
    local check_date="$start_date"
    local week_data=""
    
    for ((i=0; i<52; i++)); do
        local commits=0
        eval "commits=\${${commits_array_name}[$check_date]:-0}"
        local symbol_idx=0
        
        if [[ $commits -ge $t4 ]]; then
            symbol_idx=4
        elif [[ $commits -ge $t3 ]]; then
            symbol_idx=3
        elif [[ $commits -ge $t2 ]]; then
            symbol_idx=2
        elif [[ $commits -ge $t1 ]]; then
            symbol_idx=1
        fi
        
        week_data+="$(_get_heatmap_color $symbol_idx)$(_get_heatmap_symbol $symbol_idx)${HEATMAP_RESET}"
        
        # Move to next week
        if date --version >/dev/null 2>&1; then
            check_date=$(date -d "$check_date + 7 days" +%Y-%m-%d 2>/dev/null)
        else
            check_date=$(date -v+7d -j -f "%Y-%m-%d" "$check_date" +%Y-%m-%d 2>/dev/null)
        fi
        
        [[ "$check_date" > "$end_date" ]] && break
    done
    
    printf "│ %-56s │\n" "$week_data"
    echo "└──────────────────────────────────────────────────────────┘"
}

# Generate month view heatmap  
_git_heatmap_month() {
    local style="$1"
    local current_month=$(date +%Y-%m)
    local month_name=$(date +"%B %Y")
    
    echo
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}$month_name${HEATMAP_RESET}"
    echo "┌─────────────────────────────────────┐"
    echo "│${HEATMAP_BLUE} Su Mo Tu We Th Fr Sa                ${HEATMAP_RESET}│"
    echo "├─────────────────────────────────────┤"
    
    # Get month data
    local -A month_commits
    local month_start="$current_month-01"
    
    # Get end of month
    local month_end
    if date --version >/dev/null 2>&1; then
        month_end=$(date -d "$month_start + 1 month - 1 day" +%Y-%m-%d)
    else
        month_end=$(date -v+1m -v-1d -j -f "%Y-%m-%d" "$month_start" +%Y-%m-%d)
    fi
    
    # Fetch commits for the month
    local git_data
    git_data=$(git log --since="$month_start" --until="$month_end" --pretty=format:"%ad" --date=short | sort | uniq -c)
    
    if [[ -n "$git_data" ]]; then
        while read -r count date_str; do
            if [[ -n "$date_str" ]]; then
                month_commits["$date_str"]=$count
            fi
        done <<< "$git_data"
    fi
    
    # Display calendar (simplified)
    local days_in_month
    if date --version >/dev/null 2>&1; then
        days_in_month=$(date -d "$month_end" +%d)
    else
        days_in_month=$(date -j -f "%Y-%m-%d" "$month_end" +%d)
    fi
    
    # Simple calendar display
    for ((week=0; week<6; week++)); do
        local line="│ "
        for ((day_of_week=0; day_of_week<7; day_of_week++)); do
            local day=$((week * 7 + day_of_week - 5))  # Approximate
            if [[ $day -ge 1 && $day -le $days_in_month ]]; then
                local day_str=$(printf "%02d" $day)
                local full_date="$current_month-$day_str"
                local commits=${month_commits[$full_date]:-0}
                
                if [[ $commits -gt 0 ]]; then
                    line+="${HEATMAP_COLOR_2}$day_str${HEATMAP_RESET} "
                else
                    line+="$day_str "
                fi
            else
                line+="   "
            fi
        done
        printf "%-37s│\n" "$line"
        
        # Break if we've covered all days
        [[ $((week * 7 + 7 - 5)) -gt $days_in_month ]] && break
    done
    
    echo "└─────────────────────────────────────┘"
    
    # Month stats
    local total_month_commits=0
    for count in "${month_commits[@]}"; do
        total_month_commits=$((total_month_commits + count))
    done
    
    echo
    echo "${HEATMAP_GREEN}[INFO]${HEATMAP_RESET} $total_month_commits commits this month"
}

# Aliases
alias git-heatmap='git_heatmap'
alias ghm='git_heatmap'
alias git-heat='git_heatmap'

# Plugin info
echo "${HEATMAP_GREEN}[INFO]${HEATMAP_RESET} Git Heatmap plugin loaded. Use 'git-heatmap' or 'ghm' command."