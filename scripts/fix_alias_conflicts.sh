#!/usr/bin/env bash
# OSH.IT Alias Conflict Fix Script
# Fixes the "defining function based on alias" error

set -e

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh.it/main"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}" >&2; }
log_fix() { echo -e "${CYAN}🔧 $*${NC}"; }

echo -e "${CYAN}🔧 OSH.IT Alias Conflict Fix${NC}"
echo "============================="
echo ""

if [[ ! -d "$OSH_DIR" ]]; then
    log_error "OSH.IT not found at $OSH_DIR"
    exit 1
fi

log_info "Fixing alias conflicts in lazy loading system..."

# Download the fixed lazy_loader.zsh
log_fix "Updating lazy_loader.zsh with conflict resolution..."
curl -fsSL "$REPO_BASE/lib/lazy_loader.zsh" -o "$OSH_DIR/lib/lazy_loader.zsh" || {
    log_error "Failed to download fixed lazy_loader.zsh"
    exit 1
}

# Set correct permissions
chmod 644 "$OSH_DIR/lib/lazy_loader.zsh"

log_success "Updated lazy_loader.zsh with smart conflict resolution"

echo ""
log_info "Testing the fix..."

# Test if zsh can load the configuration without errors
if zsh -c "source ~/.zshrc" 2>/dev/null; then
    log_success "Configuration loads without errors!"
else
    log_error "Configuration still has errors. Please check manually."
    exit 1
fi

echo ""
log_success "🎉 Alias conflict fix completed!"
echo ""
echo -e "${CYAN}📋 What was fixed:${NC}"
echo "• Smart lazy loading that avoids conflicts with active plugins"
echo "• Proper alias handling for forecast, oshinfo, taskman, etc."
echo "• Prevention of 'defining function based on alias' errors"
echo ""
echo -e "${CYAN}💡 Next steps:${NC}"
echo "1. Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
echo "2. Test functionality: ${BLUE}osh status${NC}"
echo "3. Try aliases: ${BLUE}forecast${NC}, ${BLUE}oshinfo${NC}, ${BLUE}taskman${NC}"
echo ""
echo -e "${CYAN}🌐 Resources:${NC}"
echo "• Official Website: ${BLUE}https://oiahoon.github.io/osh.it/${NC}"
echo "• Documentation: ${BLUE}https://github.com/oiahoon/osh.it/wiki${NC}"
echo "• Support: ${BLUE}https://github.com/oiahoon/osh.it/issues${NC}"
