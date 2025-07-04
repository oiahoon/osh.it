#!/usr/bin/env bash
# OSH.IT Doctor - Diagnostic and Fix Tool
# Helps users diagnose and fix common OSH.IT issues

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

# Helper functions
log_info() { echo -e "${BLUE}ℹ️  $*${NC}"; }
log_success() { echo -e "${GREEN}✅ $*${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $*${NC}"; }
log_error() { echo -e "${RED}❌ $*${NC}"; }
log_fix() { echo -e "${CYAN}🔧 $*${NC}"; }

# Check functions
check_osh_installation() {
    echo -e "${CYAN}🔍 Checking OSH.IT Installation...${NC}"
    echo ""
    
    if [[ -d "$OSH_DIR" ]]; then
        log_success "OSH.IT directory found: $OSH_DIR"
    else
        log_error "OSH.IT directory not found: $OSH_DIR"
        log_fix "Run the installation script: curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh | sh"
        return 1
    fi
    
    if [[ -f "$OSH_DIR/osh.sh" ]]; then
        log_success "Main OSH.IT script found"
    else
        log_error "Main OSH.IT script missing: $OSH_DIR/osh.sh"
        return 1
    fi
    
    if [[ -f "$OSH_DIR/bin/osh" ]]; then
        log_success "OSH command found"
    else
        log_error "OSH command missing: $OSH_DIR/bin/osh"
        return 1
    fi
    
    return 0
}

check_path_configuration() {
    echo -e "${CYAN}🔍 Checking PATH Configuration...${NC}"
    echo ""
    
    if echo "$PATH" | grep -q "$OSH_DIR/bin"; then
        log_success "OSH.IT bin directory is in PATH"
    else
        log_error "OSH.IT bin directory not in PATH"
        log_fix "Add this to your ~/.zshrc:"
        echo -e "${YELLOW}  export PATH=\"\$OSH/bin:\$PATH\"${NC}"
        return 1
    fi
    
    if command -v osh >/dev/null 2>&1; then
        log_success "osh command is available"
    else
        log_error "osh command not found in PATH"
        log_fix "Restart your terminal or run: source ~/.zshrc"
        return 1
    fi
    
    return 0
}

check_shell_configuration() {
    echo -e "${CYAN}🔍 Checking Shell Configuration...${NC}"
    echo ""
    
    if [[ -f "$ZSHRC_FILE" ]]; then
        log_success "Found ~/.zshrc"
    else
        log_error "~/.zshrc not found"
        log_fix "Create ~/.zshrc file"
        return 1
    fi
    
    if grep -q "export OSH=" "$ZSHRC_FILE"; then
        log_success "OSH environment variable configured"
    else
        log_error "OSH environment variable not configured"
        log_fix "Add this to your ~/.zshrc:"
        echo -e "${YELLOW}  export OSH=\"\$HOME/.osh\"${NC}"
        return 1
    fi
    
    if grep -q "source.*osh.sh" "$ZSHRC_FILE"; then
        log_success "OSH.IT is sourced in ~/.zshrc"
    else
        log_error "OSH.IT not sourced in ~/.zshrc"
        log_fix "Add this to your ~/.zshrc:"
        echo -e "${YELLOW}  source \$OSH/osh.sh${NC}"
        return 1
    fi
    
    return 0
}

check_plugins() {
    echo -e "${CYAN}🔍 Checking Plugin Configuration...${NC}"
    echo ""
    
    if grep -q "oplugins=" "$ZSHRC_FILE"; then
        local plugins=$(grep "oplugins=" "$ZSHRC_FILE" | head -1 | sed 's/oplugins=(\(.*\))/\1/' | tr -d '()')
        log_success "Plugin configuration found"
        
        if [[ -n "$plugins" ]]; then
            echo "  Configured plugins: $plugins"
            
            # Check if plugin files exist
            for plugin in $plugins; do
                if [[ -d "$OSH_DIR/plugins/$plugin" ]]; then
                    log_success "Plugin files found: $plugin"
                else
                    log_error "Plugin files missing: $plugin"
                    log_fix "Run: osh plugin add $plugin"
                fi
            done
        else
            log_warning "No plugins configured"
            log_fix "Add plugins with: osh plugin add <name>"
        fi
    else
        log_error "Plugin configuration not found"
        log_fix "Add this to your ~/.zshrc:"
        echo -e "${YELLOW}  oplugins=(sysinfo weather taskman)${NC}"
        return 1
    fi
    
    return 0
}

check_permissions() {
    echo -e "${CYAN}🔍 Checking File Permissions...${NC}"
    echo ""
    
    if [[ -x "$OSH_DIR/bin/osh" ]]; then
        log_success "OSH command is executable"
    else
        log_error "OSH command is not executable"
        log_fix "Run: chmod +x $OSH_DIR/bin/osh"
        return 1
    fi
    
    if [[ -r "$OSH_DIR/osh.sh" ]]; then
        log_success "Main OSH script is readable"
    else
        log_error "Main OSH script is not readable"
        return 1
    fi
    
    return 0
}

# Fix functions
fix_path_configuration() {
    log_fix "Fixing PATH configuration..."
    
    if ! grep -q "export PATH.*OSH/bin" "$ZSHRC_FILE"; then
        echo 'export PATH="$OSH/bin:$PATH"' >> "$ZSHRC_FILE"
        log_success "Added OSH bin directory to PATH"
    fi
}

fix_permissions() {
    log_fix "Fixing file permissions..."
    
    chmod +x "$OSH_DIR/bin/osh" 2>/dev/null || true
    chmod +x "$OSH_DIR/scripts/"*.sh 2>/dev/null || true
    
    log_success "Fixed file permissions"
}

# Main diagnostic function
run_diagnostics() {
    local fix_mode="$1"
    local issues=0
    
    echo -e "${CYAN}🏥 OSH.IT Doctor - Diagnostic Report${NC}"
    echo "=================================="
    echo ""
    
    # Run checks
    check_osh_installation || ((issues++))
    echo ""
    
    check_path_configuration || ((issues++))
    echo ""
    
    check_shell_configuration || ((issues++))
    echo ""
    
    check_plugins || ((issues++))
    echo ""
    
    check_permissions || ((issues++))
    echo ""
    
    # Summary
    echo -e "${CYAN}📋 Diagnostic Summary${NC}"
    echo "===================="
    
    if [[ $issues -eq 0 ]]; then
        log_success "All checks passed! OSH.IT is properly configured."
        echo ""
        echo -e "${GREEN}🎉 Your OSH.IT installation is healthy!${NC}"
        echo ""
        echo "Try these commands:"
        echo -e "  ${CYAN}osh status${NC}        # Check status"
        echo -e "  ${CYAN}osh plugin list${NC}   # List plugins"
        echo -e "  ${CYAN}osh help${NC}          # Show help"
    else
        log_error "Found $issues issue(s) that need attention."
        echo ""
        
        if [[ "$fix_mode" == "--fix" ]]; then
            echo -e "${CYAN}🔧 Attempting to fix issues...${NC}"
            echo ""
            
            fix_path_configuration
            fix_permissions
            
            echo ""
            log_success "Applied fixes. Please restart your terminal or run:"
            echo -e "${CYAN}  source ~/.zshrc${NC}"
        else
            echo -e "${YELLOW}💡 To automatically fix some issues, run:${NC}"
            echo -e "${CYAN}  osh doctor --fix${NC}"
            echo ""
            echo -e "${YELLOW}💡 Or manually follow the fix suggestions above.${NC}"
        fi
    fi
    
    echo ""
}

# Performance test
run_performance_test() {
    echo -e "${CYAN}⚡ OSH.IT Performance Test${NC}"
    echo "========================="
    echo ""
    
    log_info "Testing shell startup time..."
    
    # Test with OSH.IT
    local start_time=$(date +%s%N)
    zsh -i -c 'exit' 2>/dev/null || true
    local end_time=$(date +%s%N)
    local osh_time=$(( (end_time - start_time) / 1000000 ))
    
    echo "Shell startup time: ${osh_time}ms"
    
    if [[ $osh_time -lt 500 ]]; then
        log_success "Excellent performance (< 500ms)"
    elif [[ $osh_time -lt 1000 ]]; then
        log_success "Good performance (< 1s)"
    elif [[ $osh_time -lt 2000 ]]; then
        log_warning "Acceptable performance (< 2s)"
    else
        log_error "Slow performance (> 2s)"
        log_fix "Consider reducing the number of plugins"
    fi
    
    echo ""
}

# Help function
show_help() {
    cat << 'EOF'
OSH.IT Doctor - Diagnostic and Fix Tool

USAGE:
    osh doctor [options]

OPTIONS:
    --fix       Automatically fix common issues
    --perf      Run performance test
    --help      Show this help message

EXAMPLES:
    osh doctor          # Run diagnostics
    osh doctor --fix    # Run diagnostics and fix issues
    osh doctor --perf   # Include performance test

The doctor will check:
- OSH.IT installation
- PATH configuration
- Shell configuration
- Plugin setup
- File permissions

EOF
}

# Main function
main() {
    local fix_mode=""
    local perf_test=""
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix)
                fix_mode="--fix"
                shift
                ;;
            --perf)
                perf_test="--perf"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    run_diagnostics "$fix_mode"
    
    if [[ "$perf_test" == "--perf" ]]; then
        run_performance_test
    fi
}

# Run main function
main "$@"
