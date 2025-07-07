# Self-Update Design for OSH.IT

## Problem Statement

OSH.IT faced a "chicken-and-egg" problem with its upgrade mechanism:
- Users run local `upgrade.sh` to upgrade the system
- If local `upgrade.sh` has bugs, the upgrade fails
- Users cannot fix the upgrade script through the upgrade process itself

## Solution: Self-Updating Scripts

Both `install.sh` and `upgrade.sh` now implement a self-update mechanism that ensures they are always running the latest version before proceeding with their main tasks.

## Design Principles

### 1. Always Update Scripts First
- Download the latest version of the script from the remote repository
- Compare with the current running script
- If different, replace and re-execute with the latest version
- Only then proceed with the main installation/upgrade process

### 2. Fail-Safe Mechanisms
- Validate downloaded scripts before execution (syntax check)
- Preserve original arguments when re-executing
- Graceful fallback if self-update fails
- Clean up temporary files

### 3. User Experience
- Transparent process with clear logging
- Minimal interruption to user workflow
- Preserve all command-line arguments and options

## Implementation Details

### Install Script Self-Update

```bash
update_installer_script() {
  # Skip in dry-run mode
  if [[ "$DRY_RUN" == "true" ]]; then
    return 0
  fi
  
  log_info "🔄 Ensuring installer is up to date..."
  local temp_installer="/tmp/osh_install_latest.sh"
  
  if download_file "${OSH_REPO_BASE}/install.sh" "$temp_installer"; then
    # Verify downloaded file is valid
    if [[ -s "$temp_installer" ]] && bash -n "$temp_installer" 2>/dev/null; then
      # Check if current script is different from latest
      if ! diff -q "$0" "$temp_installer" >/dev/null 2>&1; then
        log_info "📥 Updating installer to latest version..."
        log_success "✅ Installer updated, restarting with latest version..."
        echo
        
        # Re-execute with updated script, preserving all arguments
        exec bash "$temp_installer" "$@"
      else
        log_success "✅ Installer is already up to date"
      fi
    else
      log_warning "⚠️  Downloaded installer appears invalid, continuing with current version"
    fi
    
    # Clean up temp file
    rm -f "$temp_installer" 2>/dev/null || true
  else
    log_warning "⚠️  Could not download latest installer, continuing with current version"
  fi
}
```

### Upgrade Script Self-Update

```bash
update_upgrade_script() {
  log_info "🔄 Ensuring upgrade script is up to date..."
  local temp_upgrade="/tmp/osh_upgrade_latest.sh"
  
  if download_file "${OSH_REPO_BASE}/upgrade.sh" "$temp_upgrade"; then
    # Verify downloaded file is valid
    if [[ -s "$temp_upgrade" ]] && bash -n "$temp_upgrade" 2>/dev/null; then
      # Check if current script is different from latest
      if ! diff -q "$0" "$temp_upgrade" >/dev/null 2>&1; then
        log_info "📥 Updating upgrade script to latest version..."
        
        # Backup current script
        cp "$OSH_DIR/upgrade.sh" "$OSH_DIR/upgrade.sh.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
        
        # Replace with latest version
        cp "$temp_upgrade" "$OSH_DIR/upgrade.sh"
        chmod +x "$OSH_DIR/upgrade.sh"
        
        log_success "✅ Upgrade script updated, restarting..."
        echo
        
        # Re-execute with updated script
        exec "$OSH_DIR/upgrade.sh" "$@"
      else
        log_success "✅ Upgrade script is already up to date"
      fi
    else
      log_warning "⚠️  Downloaded upgrade script appears invalid, continuing with current version"
    fi
    
    # Clean up temp file
    rm -f "$temp_upgrade" 2>/dev/null || true
  else
    log_warning "⚠️  Could not download latest upgrade script, continuing with current version"
  fi
}
```

## Benefits

### 1. Automatic Bug Fixes
- Users automatically get bug fixes in installation/upgrade scripts
- No manual intervention required
- Eliminates the "broken upgrade script" problem

### 2. Feature Updates
- New installation/upgrade features are automatically available
- Improved user experience with each release
- Better error handling and progress reporting

### 3. Consistency
- All users run the same version of scripts
- Reduces support burden from version inconsistencies
- Easier debugging and troubleshooting

### 4. Security
- Users always get the latest security fixes
- Reduces attack surface from outdated scripts
- Maintains integrity of the installation process

## Edge Cases Handled

### 1. Network Failures
- Graceful fallback to current script version
- Clear warning messages to users
- Process continues with existing functionality

### 2. Invalid Downloads
- Syntax validation before script replacement
- File size and content checks
- Automatic cleanup of failed downloads

### 3. Permission Issues
- Proper error handling for file operations
- Backup creation before replacement
- Fallback mechanisms for restricted environments

### 4. Argument Preservation
- All command-line arguments are preserved during re-execution
- Environment variables maintained
- User context preserved

## Testing Scenarios

### 1. Normal Operation
- Script is up to date: continues normally
- Script needs update: downloads, replaces, re-executes

### 2. Network Issues
- Cannot download: warns and continues with current version
- Partial download: detects and falls back

### 3. File System Issues
- Cannot write temp file: warns and continues
- Cannot replace script: warns and continues

### 4. Script Validation
- Invalid syntax: rejects and continues with current version
- Empty file: rejects and continues with current version

## Future Enhancements

### 1. Version Checking
- Compare version numbers instead of file differences
- Skip download if version is already latest
- Better performance for frequent runs

### 2. Checksum Validation
- Verify file integrity with checksums
- Detect corrupted downloads
- Enhanced security

### 3. Rollback Mechanism
- Keep multiple backup versions
- Automatic rollback on failure
- User-initiated rollback option

### 4. Update Notifications
- Inform users about script updates
- Show changelog for script updates
- Optional update confirmation

## Conclusion

The self-update mechanism ensures that OSH.IT installation and upgrade processes are always reliable and up-to-date. This design eliminates the common problem of broken upgrade scripts and provides a better user experience with automatic bug fixes and feature updates.
