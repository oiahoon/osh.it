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

# Main ascii_text function
ascii_text() {
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
    
    if [[ "$help" == "true" ]]; then
        _ascii_text_help
    elif [[ "$list_styles" == "true" ]]; then
        _ascii_text_list_styles
    elif [[ "$preview" == "true" ]]; then
        _ascii_text_preview "$text"
    elif [[ -z "$text" ]]; then
        echo "${ASCII_RED}[ERROR]${ASCII_RESET} Please provide text to convert" >&2
        echo "Usage: ascii-text \"YOUR TEXT\" [OPTIONS]" >&2
        return 1
    else
        _run_clean_ascii "$text" "$style" "$color"
    fi
}

# Execute ASCII generation in completely isolated environment
_run_clean_ascii() {
    local text="$1"
    local style="$2" 
    local color="$3"
    
    # Create temporary script to avoid all xtrace issues
    local temp_script=$(mktemp)
    
cat > "$temp_script" << 'SCRIPT_EOF'
#!/usr/bin/env zsh
setopt no_xtrace 2>/dev/null
set +x 2>/dev/null

# Color definitions
ASCII_CYAN=$'\033[38;2;0;255;255m'
ASCII_GREEN=$'\033[38;2;0;255;65m'
ASCII_YELLOW=$'\033[38;2;255;255;0m'
ASCII_RED=$'\033[38;2;255;0;64m'
ASCII_PURPLE=$'\033[38;2;138;43;226m'
ASCII_ORANGE=$'\033[38;2;255;165;0m'
ASCII_PINK=$'\033[38;2;255;20;147m'
ASCII_WHITE=$'\033[38;2;255;255;255m'
ASCII_RESET=$'\033[0m'

get_color() {
    case $1 in
        cyan|blue) echo "$ASCII_CYAN" ;;
        green) echo "$ASCII_GREEN" ;;
        yellow) echo "$ASCII_YELLOW" ;;
        red) echo "$ASCII_RED" ;;
        purple) echo "$ASCII_PURPLE" ;;
        orange) echo "$ASCII_ORANGE" ;;
        pink) echo "$ASCII_PINK" ;;
        white) echo "$ASCII_WHITE" ;;
        *) echo "$ASCII_CYAN" ;;
    esac
}

get_matrix_char() {
    case $1 in
        a) echo $'╔═╗\n╠═╣\n╩ ╩' ;;
        b) echo $'╔╗ \n╠╩╗\n╚═╝' ;;
        c) echo $'╔═╗\n║  \n╚═╝' ;;
        d) echo $'╔╦╗\n ║║\n═╩╝' ;;
        e) echo $'╔═╗\n║╣ \n╚═╝' ;;
        f) echo $'╔═╗\n║╣ \n╚  ' ;;
        g) echo $'╔═╗\n║ ╦\n╚═╝' ;;
        h) echo $'╦ ╦\n╠═╣\n╩ ╩' ;;
        i) echo $'╦\n║\n╩' ;;
        j) echo $'  ╦\n  ║\n╚═╝' ;;
        k) echo $'╦╔═\n╠╩╗\n╩ ╩' ;;
        l) echo $'╦  \n║  \n╚═╝' ;;
        m) echo $'╔╦╗\n║║║\n╩ ╩' ;;
        n) echo $'╔╗╔\n║║║\n╝╚╝' ;;
        o) echo $'╔═╗\n║ ║\n╚═╝' ;;
        p) echo $'╔═╗\n╠═╝\n╩  ' ;;
        q) echo $'╔═╗\n║ ║\n╚═╩' ;;
        r) echo $'╔═╗\n╠╦╝\n╩╚=' ;;
        s) echo $'╔═╗\n╚═╗\n╚═╝' ;;
        t) echo $'╔╦╗\n ║ \n ╩ ' ;;
        u) echo $'╦ ╦\n║ ║\n╚═╝' ;;
        v) echo $'╦  ╦\n╚╗╔╝\n ╚╝ ' ;;
        w) echo $'╦ ╦\n║║║\n╚╩╝' ;;
        x) echo $'╦ ╦\n╚╦╝\n ╩ ' ;;
        y) echo $'╦ ╦\n╚╦╝\n ╩ ' ;;
        z) echo $'╔═╗\n ╔╝\n╚═╝' ;;
        0) echo $'╔═╗\n║ ║\n╚═╝' ;;
        1) echo $' ╦\n ║\n ╩' ;;
        2) echo $'╔═╗\n ╔╝\n╚═╝' ;;
        3) echo $'╔═╗\n ╠╣\n╚═╝' ;;
        4) echo $'╦ ╦\n╚═╣\n  ╩' ;;
        5) echo $'╔═╗\n╚═╗\n╚═╝' ;;
        6) echo $'╔═╗\n╠═╗\n╚═╝' ;;
        7) echo $'╔═╗\n  ║\n  ╩' ;;
        8) echo $'╔═╗\n╠═╣\n╚═╝' ;;
        9) echo $'╔═╗\n╚═╣\n╚═╝' ;;
        ' '|space) echo $'   \n   \n   ' ;;
        '.') echo $'   \n   \n ▪ ' ;;
        '!') echo $' ╦ \n ║ \n ▪ ' ;;
        '?') echo $'╔═╗\n ╔╝\n ▪ ' ;;
        *) echo $'   \n   \n   ' ;;
    esac
}

get_circuit_char() {
    case $1 in
        a) echo $'┏━┓\n┣━┫\n┛ ┗' ;;
        b) echo $'┏━┓\n┣━┫\n┗━┛' ;;
        c) echo $'┏━┓\n┃  \n┗━┛' ;;
        d) echo $'┏━┓\n┃ ┃\n┗━┛' ;;
        e) echo $'┏━┓\n┣━ \n┗━┛' ;;
        f) echo $'┏━┓\n┣━ \n┛  ' ;;
        g) echo $'┏━┓\n┃ ┳\n┗━┛' ;;
        h) echo $'┃ ┃\n┣━┫\n┛ ┗' ;;
        i) echo $'┳\n┃\n┻' ;;
        j) echo $' ┳\n ┃\n━┛' ;;
        k) echo $'┃ ┏\n┣━┫\n┛ ┗' ;;
        l) echo $'┃  \n┃  \n┗━┓' ;;
        m) echo $'┏┳┓\n┃┃┃\n┛ ┗' ;;
        n) echo $'┏┓ \n┃┃┃\n┛ ┗' ;;
        o) echo $'┏━┓\n┃ ┃\n┗━┛' ;;
        p) echo $'┏━┓\n┣━┛\n┛  ' ;;
        q) echo $'┏━┓\n┃ ┃\n┗━┻' ;;
        r) echo $'┏━┓\n┣┳┛\n┛┗━' ;;
        s) echo $'┏━┓\n┗━┓\n┗━┛' ;;
        t) echo $'┏┳┓\n ┃ \n ┻ ' ;;
        u) echo $'┃ ┃\n┃ ┃\n┗━┛' ;;
        v) echo $'┓ ┏\n┗┳┛\n ┻ ' ;;
        w) echo $'┓ ┏\n┃┃┃\n┗┻┛' ;;
        x) echo $'┓ ┏\n┏┻┓\n┛ ┗' ;;
        y) echo $'┓ ┏\n ┻ \n ┃ ' ;;
        z) echo $'┏━┓\n ┏┛\n┗━┛' ;;
        0) echo $'┏━┓\n┃ ┃\n┗━┛' ;;
        1) echo $' ┳\n ┃\n ┻' ;;
        2) echo $'┏━┓\n ┏┛\n┗━┛' ;;
        3) echo $'┏━┓\n ┣┫\n┗━┛' ;;
        4) echo $'┃ ┃\n┗━┫\n  ┻' ;;
        5) echo $'┏━┓\n┗━┓\n┗━┛' ;;
        6) echo $'┏━┓\n┣━┓\n┗━┛' ;;
        7) echo $'┏━┓\n  ┃\n  ┻' ;;
        8) echo $'┏━┓\n┣━┫\n┗━┛' ;;
        9) echo $'┏━┓\n┗━┫\n┗━┛' ;;
        ' '|space) echo $'   \n   \n   ' ;;
        '.') echo $'   \n   \n ▪ ' ;;
        '!') echo $' ┳ \n ┃ \n ▪ ' ;;
        '?') echo $'┏━┓\n ┏┛\n ▪ ' ;;
        *) echo $'   \n   \n   ' ;;
    esac
}

get_neon_char() {
    case $1 in
        a) echo $'▄▀█\n█▄█\n▀ ▀' ;;
        b) echo $'█▄▄\n█▄█\n▀▀▀' ;;
        c) echo $'▄▀█\n█▄▄\n▀▀▀' ;;
        d) echo $'█▄█\n█ █\n▀▀▀' ;;
        e) echo $'█▀▀\n█▀▀\n▀▀▀' ;;
        f) echo $'█▀▀\n█▀▀\n▀  ' ;;
        g) echo $'▄▀█\n█▄█\n▀▀▀' ;;
        h) echo $'█ █\n█▀█\n▀ ▀' ;;
        i) echo $'█\n█\n▀' ;;
        j) echo $' █\n █\n▀▀' ;;
        k) echo $'█ ▄\n██ \n▀ ▀' ;;
        l) echo $'█  \n█  \n▀▀▀' ;;
        m) echo $'▄▀▄\n█▀█\n▀ ▀' ;;
        n) echo $'▄▀▄\n█ █\n▀ ▀' ;;
        o) echo $'▄▀█\n█ █\n▀▀▀' ;;
        p) echo $'█▀▄\n█▀ \n▀  ' ;;
        q) echo $'▄▀█\n█▄█\n▀▀▀' ;;
        r) echo $'█▀▄\n█▀▄\n▀ ▀' ;;
        s) echo $'▄▀█\n▀▀█\n▀▀▀' ;;
        t) echo $'▀█▀\n █ \n ▀ ' ;;
        u) echo $'█ █\n█▄█\n▀▀▀' ;;
        v) echo $'█ █\n▀█▀\n ▀ ' ;;
        w) echo $'█ █\n█▄█\n▀▀▀' ;;
        x) echo $'▀▄▀\n▄▀▄\n▀ ▀' ;;
        y) echo $'▀▄▀\n ▀ \n ▀ ' ;;
        z) echo $'▀▀▀\n▄▀ \n▀▀▀' ;;
        0) echo $'▄▀█\n█ █\n▀▀▀' ;;
        1) echo $' █\n █\n ▀' ;;
        2) echo $'▄▀█\n▄▀ \n▀▀▀' ;;
        3) echo $'▄▀█\n ▀█\n▀▀▀' ;;
        4) echo $'█ █\n▀▀█\n  ▀' ;;
        5) echo $'▄▀█\n▀▀█\n▀▀▀' ;;
        6) echo $'▄▀█\n█▀█\n▀▀▀' ;;
        7) echo $'▀▀▀\n  █\n  ▀' ;;
        8) echo $'▄▀█\n█▀█\n▀▀▀' ;;
        9) echo $'▄▀█\n▀▀█\n▀▀▀' ;;
        ' '|space) echo $'   \n   \n   ' ;;
        '.') echo $'   \n   \n ▪ ' ;;
        '!') echo $' █ \n █ \n ▪ ' ;;
        '?') echo $'▄▀█\n ▄▀\n ▪ ' ;;
        *) echo $'   \n   \n   ' ;;
    esac
}

get_char() {
    local style="$1"
    local char="$2"
    char=$(echo "$char" | tr '[:upper:]' '[:lower:]')
    case "$style" in
        circuit) get_circuit_char "$char" ;;
        neon) get_neon_char "$char" ;;
        *) get_matrix_char "$char" ;;
    esac
}

text="$1"
style="$2"
color="$3"

color_code=$(get_color "$color")
line1=""
line2=""
line3=""

for (( i=0; i<${#text}; i++ )); do
    char="${text:$i:1}"
    char_art=$(get_char "$style" "$char")
    
    l1=$(echo "$char_art" | sed -n '1p')
    l2=$(echo "$char_art" | sed -n '2p') 
    l3=$(echo "$char_art" | sed -n '3p')
    
    line1+="$l1 "
    line2+="$l2 "
    line3+="$l3 "
done

echo "${color_code}${line1}${ASCII_RESET}"
echo "${color_code}${line2}${ASCII_RESET}"
echo "${color_code}${line3}${ASCII_RESET}"
SCRIPT_EOF

    # Execute the script and clean up
    /usr/bin/env zsh "$temp_script" "$text" "$style" "$color" 2>/dev/null
    rm -f "$temp_script"
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
        _run_clean_ascii "$text" "$style" "cyan"
        echo
    done
}

# Aliases
alias ascii-text='ascii_text'
alias ascii='ascii_text'
alias asciit='ascii_text'

# Plugin info
echo "${ASCII_GREEN}[INFO]${ASCII_RESET} ASCII Text plugin loaded. Use 'ascii-text' or 'ascii' command."