#!/usr/bin/env zsh
# ASCII Text Plugin for OSH.IT
# Version: 1.0.0
# Author: OSH.IT Team
# Description: Generate cyberpunk-style ASCII art text

# Cyberpunk color definitions matching OSH.IT theme
if [[ -t 1 ]]; then
    ASCII_CYAN=$'\033[38;2;0;255;255m'         # Electric blue
    ASCII_GREEN=$'\033[38;2;0;255;65m'         # Matrix green
    ASCII_YELLOW=$'\033[38;2;255;255;0m'       # Neon yellow
    ASCII_RED=$'\033[38;2;255;0;64m'           # Alert red
    ASCII_PURPLE=$'\033[38;2;138;43;226m'      # UV purple
    ASCII_ORANGE=$'\033[38;2;255;165;0m'       # Neon orange
    ASCII_PINK=$'\033[38;2;255;20;147m'        # Hot pink
    ASCII_WHITE=$'\033[38;2;255;255;255m'      # Pure white
    ASCII_BOLD=$'\033[1m'
    ASCII_RESET=$'\033[0m'
else
    # Fallback for terminals without color support
    ASCII_CYAN=""
    ASCII_GREEN=""
    ASCII_YELLOW=""
    ASCII_RED=""
    ASCII_PURPLE=""
    ASCII_ORANGE=""
    ASCII_PINK=""
    ASCII_WHITE=""
    ASCII_BOLD=""
    ASCII_RESET=""
fi

# Get color by name
_get_ascii_color() {
    case $1 in
        "cyan"|"blue") echo "$ASCII_CYAN" ;;
        "green") echo "$ASCII_GREEN" ;;
        "yellow") echo "$ASCII_YELLOW" ;;
        "red") echo "$ASCII_RED" ;;
        "purple") echo "$ASCII_PURPLE" ;;
        "orange") echo "$ASCII_ORANGE" ;;
        "pink") echo "$ASCII_PINK" ;;
        "white") echo "$ASCII_WHITE" ;;
        *) echo "$ASCII_CYAN" ;;  # Default to cyan
    esac
}

# Character definitions for Matrix style
_get_matrix_char() {
    case $1 in
        "a") echo -e "╔═╗\n╠═╣\n╩ ╩" ;;
        "b") echo -e "╔╗ \n╠╩╗\n╚═╝" ;;
        "c") echo -e "╔═╗\n║  \n╚═╝" ;;
        "d") echo -e "╔╦╗\n ║║\n═╩╝" ;;
        "e") echo -e "╔═╗\n║╣ \n╚═╝" ;;
        "f") echo -e "╔═╗\n║╣ \n╚  " ;;
        "g") echo -e "╔═╗\n║ ╦\n╚═╝" ;;
        "h") echo -e "╦ ╦\n╠═╣\n╩ ╩" ;;
        "i") echo -e "╦\n║\n╩" ;;
        "j") echo -e "  ╦\n  ║\n╚═╝" ;;
        "k") echo -e "╦╔═\n╠╩╗\n╩ ╩" ;;
        "l") echo -e "╦  \n║  \n╚═╝" ;;
        "m") echo -e "╔╦╗\n║║║\n╩ ╩" ;;
        "n") echo -e "╔╗╔\n║║║\n╝╚╝" ;;
        "o") echo -e "╔═╗\n║ ║\n╚═╝" ;;
        "p") echo -e "╔═╗\n╠═╝\n╩  " ;;
        "q") echo -e "╔═╗\n║ ║\n╚═╩" ;;
        "r") echo -e "╔═╗\n╠╦╝\n╩╚=" ;;
        "s") echo -e "╔═╗\n╚═╗\n╚═╝" ;;
        "t") echo -e "╔╦╗\n ║ \n ╩ " ;;
        "u") echo -e "╦ ╦\n║ ║\n╚═╝" ;;
        "v") echo -e "╦  ╦\n╚╗╔╝\n ╚╝ " ;;
        "w") echo -e "╦ ╦\n║║║\n╚╩╝" ;;
        "x") echo -e "╦ ╦\n╚╦╝\n ╩ " ;;
        "y") echo -e "╦ ╦\n╚╦╝\n ╩ " ;;
        "z") echo -e "╔═╗\n ╔╝\n╚═╝" ;;
        "0") echo -e "╔═╗\n║ ║\n╚═╝" ;;
        "1") echo -e " ╦\n ║\n ╩" ;;
        "2") echo -e "╔═╗\n ╔╝\n╚═╝" ;;
        "3") echo -e "╔═╗\n ╠╣\n╚═╝" ;;
        "4") echo -e "╦ ╦\n╚═╣\n  ╩" ;;
        "5") echo -e "╔═╗\n╚═╗\n╚═╝" ;;
        "6") echo -e "╔═╗\n╠═╗\n╚═╝" ;;
        "7") echo -e "╔═╗\n  ║\n  ╩" ;;
        "8") echo -e "╔═╗\n╠═╣\n╚═╝" ;;
        "9") echo -e "╔═╗\n╚═╣\n╚═╝" ;;
        " "|"space") echo -e "   \n   \n   " ;;
        ".") echo -e "   \n   \n ▪ " ;;
        "!") echo -e " ╦ \n ║ \n ▪ " ;;
        "?") echo -e "╔═╗\n ╔╝\n ▪ " ;;
        *) echo -e "   \n   \n   " ;;
    esac
}

# Character definitions for Circuit style
_get_circuit_char() {
    case $1 in
        "a") echo -e "┏━┓\n┣━┫\n┛ ┗" ;;
        "b") echo -e "┏━┓\n┣━┫\n┗━┛" ;;
        "c") echo -e "┏━┓\n┃  \n┗━┛" ;;
        "d") echo -e "┏━┓\n┃ ┃\n┗━┛" ;;
        "e") echo -e "┏━┓\n┣━ \n┗━┛" ;;
        "f") echo -e "┏━┓\n┣━ \n┛  " ;;
        "g") echo -e "┏━┓\n┃ ┳\n┗━┛" ;;
        "h") echo -e "┃ ┃\n┣━┫\n┛ ┗" ;;
        "i") echo -e "┳\n┃\n┻" ;;
        "j") echo -e " ┳\n ┃\n━┛" ;;
        "k") echo -e "┃ ┏\n┣━┫\n┛ ┗" ;;
        "l") echo -e "┃  \n┃  \n┗━┓" ;;
        "m") echo -e "┏┳┓\n┃┃┃\n┛ ┗" ;;
        "n") echo -e "┏┓ \n┃┃┃\n┛ ┗" ;;
        "o") echo -e "┏━┓\n┃ ┃\n┗━┛" ;;
        "p") echo -e "┏━┓\n┣━┛\n┛  " ;;
        "q") echo -e "┏━┓\n┃ ┃\n┗━┻" ;;
        "r") echo -e "┏━┓\n┣┳┛\n┛┗━" ;;
        "s") echo -e "┏━┓\n┗━┓\n┗━┛" ;;
        "t") echo -e "┏┳┓\n ┃ \n ┻ " ;;
        "u") echo -e "┃ ┃\n┃ ┃\n┗━┛" ;;
        "v") echo -e "┓ ┏\n┗┳┛\n ┻ " ;;
        "w") echo -e "┓ ┏\n┃┃┃\n┗┻┛" ;;
        "x") echo -e "┓ ┏\n┏┻┓\n┛ ┗" ;;
        "y") echo -e "┓ ┏\n ┻ \n ┃ " ;;
        "z") echo -e "┏━┓\n ┏┛\n┗━┛" ;;
        "0") echo -e "┏━┓\n┃ ┃\n┗━┛" ;;
        "1") echo -e " ┳\n ┃\n ┻" ;;
        "2") echo -e "┏━┓\n ┏┛\n┗━┛" ;;
        "3") echo -e "┏━┓\n ┣┫\n┗━┛" ;;
        "4") echo -e "┃ ┃\n┗━┫\n  ┻" ;;
        "5") echo -e "┏━┓\n┗━┓\n┗━┛" ;;
        "6") echo -e "┏━┓\n┣━┓\n┗━┛" ;;
        "7") echo -e "┏━┓\n  ┃\n  ┻" ;;
        "8") echo -e "┏━┓\n┣━┫\n┗━┛" ;;
        "9") echo -e "┏━┓\n┗━┫\n┗━┛" ;;
        " "|"space") echo -e "   \n   \n   " ;;
        ".") echo -e "   \n   \n ▪ " ;;
        "!") echo -e " ┳ \n ┃ \n ▪ " ;;
        "?") echo -e "┏━┓\n ┏┛\n ▪ " ;;
        *) echo -e "   \n   \n   " ;;
    esac
}

# Character definitions for Neon style
_get_neon_char() {
    case $1 in
        "a") echo -e "▄▀█\n█▄█\n▀ ▀" ;;
        "b") echo -e "█▄▄\n█▄█\n▀▀▀" ;;
        "c") echo -e "▄▀█\n█▄▄\n▀▀▀" ;;
        "d") echo -e "█▄█\n█ █\n▀▀▀" ;;
        "e") echo -e "█▀▀\n█▀▀\n▀▀▀" ;;
        "f") echo -e "█▀▀\n█▀▀\n▀  " ;;
        "g") echo -e "▄▀█\n█▄█\n▀▀▀" ;;
        "h") echo -e "█ █\n█▀█\n▀ ▀" ;;
        "i") echo -e "█\n█\n▀" ;;
        "j") echo -e " █\n █\n▀▀" ;;
        "k") echo -e "█ ▄\n██ \n▀ ▀" ;;
        "l") echo -e "█  \n█  \n▀▀▀" ;;
        "m") echo -e "▄▀▄\n█▀█\n▀ ▀" ;;
        "n") echo -e "▄▀▄\n█ █\n▀ ▀" ;;
        "o") echo -e "▄▀█\n█ █\n▀▀▀" ;;
        "p") echo -e "█▀▄\n█▀ \n▀  " ;;
        "q") echo -e "▄▀█\n█▄█\n▀▀▀" ;;
        "r") echo -e "█▀▄\n█▀▄\n▀ ▀" ;;
        "s") echo -e "▄▀█\n▀▀█\n▀▀▀" ;;
        "t") echo -e "▀█▀\n █ \n ▀ " ;;
        "u") echo -e "█ █\n█▄█\n▀▀▀" ;;
        "v") echo -e "█ █\n▀█▀\n ▀ " ;;
        "w") echo -e "█ █\n█▄█\n▀▀▀" ;;
        "x") echo -e "▀▄▀\n▄▀▄\n▀ ▀" ;;
        "y") echo -e "▀▄▀\n ▀ \n ▀ " ;;
        "z") echo -e "▀▀▀\n▄▀ \n▀▀▀" ;;
        "0") echo -e "▄▀█\n█ █\n▀▀▀" ;;
        "1") echo -e " █\n █\n ▀" ;;
        "2") echo -e "▄▀█\n▄▀ \n▀▀▀" ;;
        "3") echo -e "▄▀█\n ▀█\n▀▀▀" ;;
        "4") echo -e "█ █\n▀▀█\n  ▀" ;;
        "5") echo -e "▄▀█\n▀▀█\n▀▀▀" ;;
        "6") echo -e "▄▀█\n█▀█\n▀▀▀" ;;
        "7") echo -e "▀▀▀\n  █\n  ▀" ;;
        "8") echo -e "▄▀█\n█▀█\n▀▀▀" ;;
        "9") echo -e "▄▀█\n▀▀█\n▀▀▀" ;;
        " "|"space") echo -e "   \n   \n   " ;;
        ".") echo -e "   \n   \n ▪ " ;;
        "!") echo -e " █ \n █ \n ▪ " ;;
        "?") echo -e "▄▀█\n ▄▀\n ▪ " ;;
        *) echo -e "   \n   \n   " ;;
    esac
}

# Get ASCII character by style
_get_ascii_char() {
    local style="$1"
    local char="$2"
    
    # Convert to lowercase
    char=$(echo "$char" | tr '[:upper:]' '[:lower:]')
    
    case "$style" in
        "matrix") _get_matrix_char "$char" ;;
        "circuit") _get_circuit_char "$char" ;;
        "neon") _get_neon_char "$char" ;;
        *) _get_matrix_char "$char" ;;
    esac
}

# Main ascii_text function with complete xtrace isolation
ascii_text() {
    # Complete isolation using exec redirect approach
    exec 3>&2  # Save stderr
    exec 2>/dev/null  # Redirect stderr to null
    local original_xtrace=""
    if [[ -o xtrace ]]; then
        original_xtrace="on"
        set +x  # Disable xtrace
    fi
    exec 2>&3  # Restore stderr
    exec 3>&-  # Close fd 3
    
    local text=""
    local style="matrix"
    local color="cyan"
    local list_styles=false
    local preview=false
    local help=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --style)
                style="$2"
                shift 2
                ;;
            --color)
                color="$2"
                shift 2
                ;;
            --list-styles)
                list_styles=true
                shift
                ;;
            --preview)
                preview=true
                shift
                ;;
            --help|-h)
                help=true
                shift
                ;;
            *)
                text="$1"
                shift
                ;;
        esac
    done
    
    # Execute commands with clean environment
    if [[ "$help" == "true" ]]; then
        _ascii_text_help
    elif [[ "$list_styles" == "true" ]]; then
        _ascii_text_list_styles
    elif [[ "$preview" == "true" ]]; then
        _ascii_text_preview "$text"
    elif [[ -z "$text" ]]; then
        echo "${ASCII_RED}[ERROR]${ASCII_RESET} Please provide text to convert" >&2
        echo "Usage: ascii-text \"YOUR TEXT\" [OPTIONS]" >&2
        # Restore xtrace if needed
        [[ "$original_xtrace" == "on" ]] && set -x
        return 1
    else
        _generate_ascii_text "$text" "$style" "$color"
    fi
    
    # Restore xtrace if it was originally on
    [[ "$original_xtrace" == "on" ]] && set -x
}

# Show help
_ascii_text_help() {
    echo "${ASCII_CYAN}${ASCII_BOLD}ASCII Text Plugin${ASCII_RESET}"
    echo
    echo "${ASCII_BOLD}USAGE:${ASCII_RESET}"
    echo "  ascii-text \"TEXT\" [OPTIONS]"
    echo
    echo "${ASCII_BOLD}OPTIONS:${ASCII_RESET}"
    echo "  --style STYLE     ASCII font style: matrix, circuit, neon (default: matrix)"
    echo "  --color COLOR     Text color: cyan, green, yellow, red, purple, orange, pink, white (default: cyan)"
    echo "  --list-styles     List all available styles"
    echo "  --preview         Preview text in all styles"
    echo "  --help, -h        Show this help message"
    echo
    echo "${ASCII_BOLD}EXAMPLES:${ASCII_RESET}"
    echo "  ascii-text \"HELLO\"                    # Basic usage"
    echo "  ascii-text \"CYBER\" --style circuit    # Circuit style"
    echo "  ascii-text \"NEON\" --color green       # Green color"
    echo "  ascii-text \"OSH\" --preview            # Preview all styles"
    echo "  ascii-text --list-styles              # List available styles"
}

# List available styles
_ascii_text_list_styles() {
    echo "${ASCII_CYAN}${ASCII_BOLD}Available ASCII Styles:${ASCII_RESET}"
    echo
    echo "${ASCII_GREEN}matrix${ASCII_RESET}    - Matrix/digital style with Unicode box characters"
    echo "${ASCII_YELLOW}circuit${ASCII_RESET}   - Circuit board style with technical lines"
    echo "${ASCII_PURPLE}neon${ASCII_RESET}      - Neon sign style with block characters"
    echo
    echo "${ASCII_CYAN}${ASCII_BOLD}Available Colors:${ASCII_RESET}"
    echo
    echo "${ASCII_CYAN}cyan${ASCII_RESET}      - Electric blue (default)"
    echo "${ASCII_GREEN}green${ASCII_RESET}     - Matrix green"
    echo "${ASCII_YELLOW}yellow${ASCII_RESET}    - Neon yellow"
    echo "${ASCII_RED}red${ASCII_RESET}       - Alert red"
    echo "${ASCII_PURPLE}purple${ASCII_RESET}    - UV purple"
    echo "${ASCII_ORANGE}orange${ASCII_RESET}    - Neon orange"
    echo "${ASCII_PINK}pink${ASCII_RESET}      - Hot pink"
    echo "${ASCII_WHITE}white${ASCII_RESET}     - Pure white"
}

# Preview text in all styles
_ascii_text_preview() {
    local text="$1"
    if [[ -z "$text" ]]; then
        text="OSH"
    fi
    
    echo "${ASCII_CYAN}${ASCII_BOLD}ASCII Preview for: \"$text\"${ASCII_RESET}"
    echo
    
    local styles=("matrix" "circuit" "neon")
    for style in "${styles[@]}"; do
        echo "${ASCII_YELLOW}Style: $style${ASCII_RESET}"
        _generate_ascii_text "$text" "$style" "cyan"
        echo
    done
}

# Generate ASCII text with complete debug suppression
_generate_ascii_text() {
    # This function is called with xtrace already disabled from main function
    local text="$1"
    local style="$2" 
    local color="$3"
    
    # Process in a completely clean environment
    {
        # Get color code
        local color_code
        color_code=$(_get_ascii_color "$color")
        
        # Convert text to individual characters
        local chars=()
        local i=0
        while [[ $i -lt ${#text} ]]; do
            chars+=("${text:$i:1}")
            ((i++))
        done
        
        # Generate ASCII art lines
        local line1="" line2="" line3=""
        
        for char in "${chars[@]}"; do
            # Get ASCII representation
            local ascii_data
            ascii_data=$(_get_ascii_char "$style" "$char")
            
            # Extract three lines
            local l1 l2 l3
            l1=$(echo "$ascii_data" | sed -n '1p')
            l2=$(echo "$ascii_data" | sed -n '2p') 
            l3=$(echo "$ascii_data" | sed -n '3p')
            
            # Append with spacing
            line1+="$l1 "
            line2+="$l2 "
            line3+="$l3 "
        done
        
        # Output colored lines
        echo "${color_code}${line1}${ASCII_RESET}"
        echo "${color_code}${line2}${ASCII_RESET}"
        echo "${color_code}${line3}${ASCII_RESET}"
    } 2>/dev/null
}

# Aliases
alias ascii-text='ascii_text'
alias ascii='ascii_text'
alias asciit='ascii_text'

# Plugin info
echo "${ASCII_GREEN}[INFO]${ASCII_RESET} ASCII Text plugin loaded. Use 'ascii-text' or 'ascii' command."