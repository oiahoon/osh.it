#!/usr/bin/env bash
# OSH.IT Permission Fix Script
# Ensures all OSH.IT files have correct permissions

set -e

# Configuration
OSH_DIR="${OSH:-$HOME/.osh}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_fix() { echo -e "${CYAN}🔧 $*${NC}"; }

echo -e "${CYAN}🔧 OSH.IT Permission Fix${NC}"
echo "========================"
echo ""

if [[ ! -d "$OSH_DIR" ]]; then
    echo "❌ OSH.IT not found at $OSH_DIR"
    exit 1
fi

log_fix "Fixing file permissions..."

# Main scripts
if [[ -f "$OSH_DIR/osh.sh" ]]; then
    chmod +x "$OSH_DIR/osh.sh" 2>/dev/null || true
    log_info "Fixed: osh.sh"
fi

if [[ -f "$OSH_DIR/upgrade.sh" ]]; then
    chmod +x "$OSH_DIR/upgrade.sh" 2>/dev/null || true
    log_info "Fixed: upgrade.sh"
fi

# Bin directory
if [[ -f "$OSH_DIR/bin/osh" ]]; then
    chmod +x "$OSH_DIR/bin/osh" 2>/dev/null || true
    log_info "Fixed: bin/osh"
fi

# Scripts directory
if [[ -d "$OSH_DIR/scripts" ]]; then
    chmod +x "$OSH_DIR/scripts/"*.sh 2>/dev/null || true
    log_info "Fixed: scripts/*.sh"
fi

# Set correct permissions for .zsh files
find "$OSH_DIR" -name "*.zsh" -exec chmod 644 {} \; 2>/dev/null || true

log_success "All permissions fixed!"

# Verify critical files
echo ""
log_info "Verifying critical files:"

if [[ -x "$OSH_DIR/bin/osh" ]]; then
    echo "  ✅ bin/osh is executable"
else
    echo "  ❌ bin/osh is not executable"
fi

if [[ -x "$OSH_DIR/scripts/osh_cli.sh" ]]; then
    echo "  ✅ scripts/osh_cli.sh is executable"
else
    echo "  ❌ scripts/osh_cli.sh is not executable"
fi

if [[ -x "$OSH_DIR/scripts/osh_doctor.sh" ]]; then
    echo "  ✅ scripts/osh_doctor.sh is executable"
else
    echo "  ❌ scripts/osh_doctor.sh is not executable"
fi

echo ""
log_success "Permission fix completed!"
echo ""
log_info "🌐 Resources:"
echo "  • Official Website: https://oiahoon.github.io/osh.it/"
echo "  • Documentation: https://github.com/oiahoon/osh.it/wiki"
echo "  • Support: https://github.com/oiahoon/osh.it/issues"
