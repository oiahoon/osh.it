#!/usr/bin/env zsh
# Git Heatmap Plugin for OSH.IT
# Version: 1.0.0
# Author: OSH.IT Team
# Description: Display GitHub-style contribution heatmap in terminal

# GitHub-style colors
if [[ -t 1 ]]; then
    # GitHub colors (compatible with both light and dark themes)
    HEATMAP_COLOR_0=$'\033[38;2;22;27;34m'     # #161b22 - No contributions (dark gray)
    HEATMAP_COLOR_1=$'\033[38;2;14;68;41m'     # #0e4429 - Low contributions (dark green)
    HEATMAP_COLOR_2=$'\033[38;2;0;109;50m'     # #006d32 - Medium-low contributions
    HEATMAP_COLOR_3=$'\033[38;2;38;166;65m'    # #26a641 - Medium-high contributions  
    HEATMAP_COLOR_4=$'\033[38;2;57;211;83m'    # #39d353 - High contributions (bright green)
    HEATMAP_RESET=$'\033[0m'
    HEATMAP_CYAN=$'\033[38;2;0;255;255m'       # Cyberpunk cyan
    HEATMAP_BOLD=$'\033[1m'
    HEATMAP_DIM=$'\033[2m'
else
    # Fallback for terminals without color support
    HEATMAP_COLOR_0=""
    HEATMAP_COLOR_1=""
    HEATMAP_COLOR_2=""
    HEATMAP_COLOR_3=""
    HEATMAP_COLOR_4=""
    HEATMAP_RESET=""
    HEATMAP_CYAN=""
    HEATMAP_BOLD=""
    HEATMAP_DIM=""
fi

# Get color by intensity level
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

# GitHub-style squares using Unicode
HEATMAP_SQUARE="■"

# Main git_heatmap function with xtrace suppression
git_heatmap() {
    # Disable xtrace for clean output
    local xtrace_was_on=false
    if [[ -o xtrace ]]; then
        xtrace_was_on=true
        set +x
    fi
    
    local days=365
    local style="default"
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
            --help|-h)
                help=true
                shift
                ;;
            *)
                echo "${HEATMAP_COLOR_1}${HEATMAP_BOLD}[ERROR]${HEATMAP_RESET} Unknown option: $1" >&2
                # Restore xtrace if needed
                [[ "$xtrace_was_on" == "true" ]] && set -x
                return 1
                ;;
        esac
    done
    
    if [[ "$help" == "true" ]]; then
        _git_heatmap_help
        # Restore xtrace if needed
        [[ "$xtrace_was_on" == "true" ]] && set -x
        return 0
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "${HEATMAP_COLOR_1}${HEATMAP_BOLD}[ERROR]${HEATMAP_RESET} Not a git repository" >&2
        # Restore xtrace if needed
        [[ "$xtrace_was_on" == "true" ]] && set -x
        return 1
    fi
    
    # Calculate date range
    local end_date=$(date +%Y-%m-%d)
    local start_date
    if date --version >/dev/null 2>&1; then
        # GNU date
        start_date=$(date -d "$end_date - $days days" +%Y-%m-%d)
    else
        # BSD date (macOS)
        start_date=$(date -v-${days}d +%Y-%m-%d)
    fi
    
    # Create temporary file for commit data
    local temp_file=$(mktemp)
    
    # Get git log data and process it
    {
        git log --since="$start_date" --until="$end_date" --format="%ad" --date=short 2>/dev/null | sort | uniq -c | awk '{print $2 ":" $1}' > "$temp_file"
    } 2>/dev/null
    
    # Calculate statistics
    local total_commits=0
    local active_days=0
    local max_commits=0
    
    while IFS=':' read -r date count; do
        [[ -n "$date" ]] || continue
        total_commits=$((total_commits + count))
        active_days=$((active_days + 1))
        [[ $count -gt $max_commits ]] && max_commits=$count
    done < "$temp_file"
    
    # Calculate intensity thresholds based on data
    local threshold1=$((max_commits > 0 ? 1 : 0))
    local threshold2=$((max_commits > 4 ? max_commits / 4 : 1))
    local threshold3=$((max_commits > 2 ? max_commits / 2 : 2))
    local threshold4=$((max_commits > 1 ? (max_commits * 3) / 4 : 3))
    
    # Display heatmap
    if [[ "$style" == "compact" ]]; then
        _display_compact_heatmap "$start_date" "$end_date" "$threshold1" "$threshold2" "$threshold3" "$threshold4" "$temp_file"
    else
        _display_github_heatmap "$start_date" "$end_date" "$threshold1" "$threshold2" "$threshold3" "$threshold4" "$temp_file"
    fi
    
    # Display legend and statistics
    echo
    printf "%s%-4s%s " "${HEATMAP_DIM}" "Less" "${HEATMAP_RESET}"
    printf "%s%s%s " "$(_get_heatmap_color 0)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
    printf "%s%s%s " "$(_get_heatmap_color 1)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
    printf "%s%s%s " "$(_get_heatmap_color 2)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
    printf "%s%s%s " "$(_get_heatmap_color 3)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
    printf "%s%s%s " "$(_get_heatmap_color 4)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
    printf "%s%4s%s    " "${HEATMAP_DIM}" "More" "${HEATMAP_RESET}"
    printf "%s%s%s contributions in %s\n" "${HEATMAP_BOLD}" "$total_commits" "${HEATMAP_RESET}" "$(date +%Y)"
    
    printf "%sActive days:%s %s/%s %s•%s %sTotal commits:%s %s\n" \
        "${HEATMAP_CYAN}" "${HEATMAP_RESET}" "$active_days" "$days" \
        "${HEATMAP_CYAN}" "${HEATMAP_RESET}" \
        "${HEATMAP_CYAN}" "${HEATMAP_RESET}" "$total_commits"
    
    # Clean up
    rm -f "$temp_file"
    
    # Restore xtrace if it was originally on
    [[ "$xtrace_was_on" == "true" ]] && set -x
}

# Get commit count for specific date from file
_get_commit_count() {
    local date="$1"
    local temp_file="$2"
    
    grep "^$date:" "$temp_file" 2>/dev/null | cut -d: -f2 || echo "0"
}

# Display GitHub-style heatmap
_display_github_heatmap() {
    local start_date="$1"
    local end_date="$2"
    local t1="$3" t2="$4" t3="$5" t4="$6"
    local temp_file="$7"
    
    # Completely suppress xtrace for this function
    {
        echo
        echo "${HEATMAP_CYAN}${HEATMAP_BOLD}Contribution Graph - Last $days days${HEATMAP_RESET}"
        
        # Month headers
        printf "     "
        local months=("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
        for month in "${months[@]}"; do
            printf "%s%-4s%s" "${HEATMAP_DIM}" "$month" "${HEATMAP_RESET}"
        done
        echo
        
        # Week days
        local weekdays=("" "Mon" "" "Wed" "" "Fri" "")
        
        # Calculate starting Sunday
        local current_date="$start_date"
        local day_of_week
        if date --version >/dev/null 2>&1; then
            day_of_week=$(date -d "$current_date" +%w)
            if [[ $day_of_week -ne 0 ]]; then
                current_date=$(date -d "$current_date - $day_of_week days" +%Y-%m-%d)
            fi
        else
            day_of_week=$(date -j -f "%Y-%m-%d" "$current_date" +%w)
            if [[ $day_of_week -ne 0 ]]; then
                current_date=$(date -v-${day_of_week}d -j -f "%Y-%m-%d" "$current_date" +%Y-%m-%d)
            fi
        fi
        
        # Display 7 rows (for each day of week)
        for ((row=0; row<7; row++)); do
            # Print weekday label
            printf "%s%-3s%s " "${HEATMAP_DIM}" "${weekdays[$row]}" "${HEATMAP_RESET}"
            
            # Generate 53 weeks
            for ((week=0; week<53; week++)); do
                # Calculate the date for this cell
                local days_offset=$((week * 7 + row))
                local cell_date
                
                # Suppress xtrace for variable assignments
                set +x 2>/dev/null
                if date --version >/dev/null 2>&1; then
                    cell_date=$(date -d "$current_date + $days_offset days" +%Y-%m-%d 2>/dev/null)
                else
                    cell_date=$(date -v+${days_offset}d -j -f "%Y-%m-%d" "$current_date" +%Y-%m-%d 2>/dev/null)
                fi
                [[ "$xtrace_was_on" == "true" ]] && set -x 2>/dev/null
                
                # Check if date is within our range
                if [[ -z "$cell_date" ]] || [[ "$cell_date" < "$start_date" ]] || [[ "$cell_date" > "$end_date" ]]; then
                    printf " "
                else
                    local commits=$(_get_commit_count "$cell_date" "$temp_file")
                    local intensity=0
                    
                    if [[ $commits -ge $t4 ]]; then
                        intensity=4
                    elif [[ $commits -ge $t3 ]]; then
                        intensity=3
                    elif [[ $commits -ge $t2 ]]; then
                        intensity=2
                    elif [[ $commits -ge $t1 ]]; then
                        intensity=1
                    fi
                    
                    printf "%s%s%s" "$(_get_heatmap_color $intensity)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
                fi
            done
            echo
        done
    } 2>/dev/null
}

# Display compact heatmap
_display_compact_heatmap() {
    local start_date="$1"
    local end_date="$2"
    local t1="$3" t2="$4" t3="$5" t4="$6"
    local temp_file="$7"
    
    echo
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}$(date +%Y) Contribution Activity${HEATMAP_RESET}"
    echo "┌────────────────────────────────────────────────────────┐"
    printf "│ %sJ F M A M J J A S O N D%s                           │\n" "${HEATMAP_DIM}" "${HEATMAP_RESET}"
    echo "├────────────────────────────────────────────────────────┤"
    printf "│ "
    
    # Generate 52 weeks of data
    local current_date="$start_date"
    for ((week=0; week<52; week++)); do
        local commits=$(_get_commit_count "$current_date" "$temp_file")
        local intensity=0
        
        if [[ $commits -ge $t4 ]]; then
            intensity=4
        elif [[ $commits -ge $t3 ]]; then
            intensity=3
        elif [[ $commits -ge $t2 ]]; then
            intensity=2
        elif [[ $commits -ge $t1 ]]; then
            intensity=1
        fi
        
        printf "%s%s%s" "$(_get_heatmap_color $intensity)" "$HEATMAP_SQUARE" "$HEATMAP_RESET"
        
        # Move to next week
        if date --version >/dev/null 2>&1; then
            current_date=$(date -d "$current_date + 7 days" +%Y-%m-%d 2>/dev/null)
        else
            current_date=$(date -v+7d -j -f "%Y-%m-%d" "$current_date" +%Y-%m-%d 2>/dev/null)
        fi
        
        [[ "$current_date" > "$end_date" ]] && break
    done
    
    printf " │\n"
    echo "└────────────────────────────────────────────────────────┘"
}

# Show help
_git_heatmap_help() {
    echo "${HEATMAP_CYAN}${HEATMAP_BOLD}Git Heatmap Plugin${HEATMAP_RESET}"
    echo
    echo "${HEATMAP_BOLD}USAGE:${HEATMAP_RESET}"
    echo "  git-heatmap [OPTIONS]"
    echo
    echo "${HEATMAP_BOLD}OPTIONS:${HEATMAP_RESET}"
    echo "  --days DAYS       Number of days to analyze (default: 365)"
    echo "  --style STYLE     Display style: default, compact (default: default)"
    echo "  --help, -h        Show this help message"
    echo
    echo "${HEATMAP_BOLD}EXAMPLES:${HEATMAP_RESET}"
    echo "  git-heatmap                    # Show full year heatmap"
    echo "  git-heatmap --days 90          # Show last 90 days"
    echo "  git-heatmap --style compact    # Show compact view"
    echo
    echo "${HEATMAP_BOLD}DESCRIPTION:${HEATMAP_RESET}"
    echo "  Displays a GitHub-style contribution heatmap for your git repository."
    echo "  Colors indicate contribution intensity: darker = more commits."
}

# Aliases
alias git-heatmap='git_heatmap'
alias gheatmap='git_heatmap'

# Plugin info
echo "${HEATMAP_COLOR_3}[INFO]${HEATMAP_RESET} Git Heatmap plugin loaded. Use 'git-heatmap' command."