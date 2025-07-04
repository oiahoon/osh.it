#!/usr/bin/env bash
# Fix malformed .zshrc plugin configuration

set -e

ZSHRC_FILE="$HOME/.zshrc"
BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NORMAL='\033[0m'

log_info() { printf "${BLUE}ℹ️  %s${NORMAL}\n" "$*"; }
log_success() { printf "${GREEN}✅ %s${NORMAL}\n" "$*"; }
log_warning() { printf "${YELLOW}⚠️  %s${NORMAL}\n" "$*"; }
log_error() { printf "${RED}❌ %s${NORMAL}\n" "$*"; }

echo "🔧 OSH.IT .zshrc Plugin Configuration Fix"
echo "========================================"
echo

# Check if .zshrc exists
if [[ ! -f "$ZSHRC_FILE" ]]; then
    log_error ".zshrc file not found at $ZSHRC_FILE"
    exit 1
fi

# Check if the malformed configuration exists
if ! grep -q "oplugins=(.*)" "$ZSHRC_FILE"; then
    log_warning "No oplugins configuration found in .zshrc"
    log_info "Your .zshrc might already be correct or OSH is not configured"
    exit 0
fi

# Create backup
log_info "Creating backup: $BACKUP_FILE"
cp "$ZSHRC_FILE" "$BACKUP_FILE"
log_success "Backup created successfully"

# Detect the malformed pattern
if grep -A10 "oplugins=(" "$ZSHRC_FILE" | grep -q "^  [a-z]"; then
    log_warning "Detected malformed oplugins configuration!"
    
    # Show current configuration
    echo
    log_info "Current malformed configuration:"
    echo "================================"
    grep -A15 "oplugins=(" "$ZSHRC_FILE" | head -10
    echo "================================"
    echo
    
    # Extract plugin names
    log_info "Extracting plugin names..."
    
    # Get plugins from the malformed configuration
    plugins=$(grep -A10 "oplugins=(" "$ZSHRC_FILE" | grep -E "^  [a-z]|oplugins=\(" | sed 's/oplugins=(//' | sed 's/)//' | tr -d ' ' | grep -v '^$' | sort -u)
    
    # Also get plugins from the initial line
    initial_plugins=$(grep "oplugins=(" "$ZSHRC_FILE" | sed 's/.*oplugins=(//' | sed 's/).*//' | tr ' ' '\n' | grep -v '^$')
    
    # Combine and deduplicate
    all_plugins=$(echo -e "$initial_plugins\n$plugins" | sort -u | grep -v '^$' | tr '\n' ' ')
    
    log_info "Found plugins: $all_plugins"
    
    # Create corrected configuration
    log_info "Creating corrected configuration..."
    
    # Create temporary file with corrected configuration
    temp_file=$(mktemp)
    
    # Copy everything before OSH configuration
    sed '/# OSH installation directory/,$d' "$ZSHRC_FILE" > "$temp_file"
    
    # Add corrected OSH configuration
    cat >> "$temp_file" << EOF

# OSH installation directory
export OSH="\$HOME/.osh"

# Plugin selection
oplugins=($all_plugins)

# Load OSH framework
source \$OSH/osh.sh
EOF
    
    # Add anything after OSH configuration (if any)
    if grep -q "# === OSH Configuration End ===" "$ZSHRC_FILE"; then
        sed -n '/# === OSH Configuration End ===/,$p' "$ZSHRC_FILE" | tail -n +2 >> "$temp_file"
    fi
    
    # Replace original file
    mv "$temp_file" "$ZSHRC_FILE"
    
    log_success "Configuration fixed successfully!"
    
    echo
    log_info "New configuration:"
    echo "=================="
    grep -A5 "# Plugin selection" "$ZSHRC_FILE"
    echo "=================="
    echo
    
    log_success "✅ Fix completed successfully!"
    log_info "💡 Please restart your shell or run: source ~/.zshrc"
    log_info "📦 Backup saved as: $BACKUP_FILE"
    
else
    log_success "Your oplugins configuration appears to be correct"
    log_info "Current configuration:"
    grep -A3 "oplugins=" "$ZSHRC_FILE"
fi

echo
log_info "🔍 If you still experience issues:"
echo "  1. Check your shell configuration: source ~/.zshrc"
echo "  2. Verify OSH status: osh status"
echo "  3. Test taskman: tasks --help"
echo "  4. Report persistent issues to: https://github.com/oiahoon/osh.it/issues"
