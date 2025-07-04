#!/usr/bin/env bash
# OSH.IT Installation Fix Script
# Fixes common issues for existing installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"
ZSHRC_FILE="$HOME/.zshrc"
REPO_BASE="https://raw.githubusercontent.com/oiahoon/osh.it/main"

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}" >&2; }
log_fix() { echo -e "${CYAN}🔧 $*${NC}"; }

echo -e "${CYAN}🔧 OSH.IT Installation Fix Script${NC}"
echo "=================================="
echo ""

# Check if OSH.IT is installed
if [[ ! -d "$OSH_DIR" ]]; then
    log_error "OSH.IT not found at $OSH_DIR"
    log_info "Please run the installation script first:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)\""
    exit 1
fi

log_info "Found OSH.IT installation at $OSH_DIR"
echo ""

# Create missing directories
log_fix "Creating missing directories..."
mkdir -p "$OSH_DIR/bin" "$OSH_DIR/scripts" "$OSH_DIR/lib"
log_success "Directories created"

# Download missing essential files
MISSING_FILES=(
    "bin/osh"
    "scripts/osh_cli.sh"
    "scripts/osh_doctor.sh"
    "scripts/osh_plugin_manager.sh"
    "scripts/fix_permissions.sh"
    "lib/lazy_loader.zsh"
    "lib/plugin_manager.zsh"
    "lib/plugin_aliases.zsh"
    "lib/osh_config.zsh"
    "lib/config_manager.zsh"
)

log_fix "Downloading missing files..."
for file in "${MISSING_FILES[@]}"; do
    log_info "Updating $file..."
    curl -fsSL "$REPO_BASE/$file" -o "$OSH_DIR/$file" || {
        log_warning "Failed to update $file, skipping..."
        continue
    }
    
    # Set permissions immediately after download
    if [[ "$file" == "bin/osh" ]] || [[ "$file" == scripts/*.sh ]]; then
        chmod +x "$OSH_DIR/$file" 2>/dev/null || true
    fi
    
    log_success "Updated $file"
done

# Update main osh.sh with fixes
log_fix "Updating main osh.sh with latest fixes..."
curl -fsSL "$REPO_BASE/osh.sh" -o "$OSH_DIR/osh.sh" || {
    log_error "Failed to update osh.sh"
    exit 1
}
log_success "Updated osh.sh"

# Fix file permissions
log_fix "Fixing file permissions..."
chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
chmod +x "$OSH_DIR/bin/osh" 2>/dev/null || true
chmod +x "$OSH_DIR/scripts/"*.sh 2>/dev/null || true
find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true

# Use the dedicated permission fix script if available
if [[ -f "$OSH_DIR/scripts/fix_permissions.sh" ]]; then
    log_info "Running dedicated permission fix script..."
    bash "$OSH_DIR/scripts/fix_permissions.sh" || true
fi

log_success "File permissions fixed"

# Check and fix PATH configuration
log_fix "Checking PATH configuration..."
if ! grep -q 'export PATH.*OSH/bin' "$ZSHRC_FILE"; then
    log_info "Adding OSH bin directory to PATH..."
    
    # Create backup
    cp "$ZSHRC_FILE" "${ZSHRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Add PATH configuration after OSH export
    awk '/export OSH=/ {print; print "export PATH=\"$OSH/bin:$PATH\""; next} 1' "$ZSHRC_FILE" > "${ZSHRC_FILE}.tmp"
    mv "${ZSHRC_FILE}.tmp" "$ZSHRC_FILE"
    
    log_success "Added OSH bin directory to PATH"
else
    log_success "PATH configuration is correct"
fi

echo ""
log_success "🎉 Installation fix completed!"
echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo "1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
echo "2. Test the fix: ${YELLOW}osh doctor${NC}"
echo "3. Verify functionality: ${YELLOW}osh status${NC}"
echo ""
echo -e "${CYAN}💡 If you still have issues:${NC}"
echo "- Run: ${YELLOW}osh doctor --fix${NC}"
echo "- Or reinstall: ${YELLOW}sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)\"${NC}"
echo ""
