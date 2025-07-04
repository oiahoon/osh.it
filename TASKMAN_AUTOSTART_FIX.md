# 🔧 Taskman Auto-Start Issue Fix Guide

## 🐛 Problem Description

If you're experiencing taskman automatically launching when you open a new shell session, this is likely due to a malformed `.zshrc` configuration.

### Symptoms
- Taskman UI launches automatically when opening terminal
- New shell sessions hang or show unexpected behavior
- Plugin loading errors or warnings

## 🔍 Root Cause

The issue is caused by malformed `oplugins` array syntax in your `.zshrc` file:

**❌ Incorrect (Broken) Configuration:**
```bash
# Plugin selection
oplugins=(sysinfo weather taskman)
  proxy
  sysinfo
  weather
  taskman
  fzf
)
```

**✅ Correct Configuration:**
```bash
# Plugin selection
oplugins=(sysinfo weather taskman proxy fzf)
```

## 🛠️ Quick Fix Solutions

### Option 1: Automatic Fix (Recommended)

Run our automated fix script:

```bash
# Download and run the fix script
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_zshrc.sh | zsh

# Or if you have OSH.IT installed locally
$OSH/scripts/fix_zshrc.sh
```

### Option 2: Manual Fix

1. **Backup your current configuration:**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. **Edit your `.zshrc` file:**
   ```bash
   nano ~/.zshrc
   # or
   vim ~/.zshrc
   ```

3. **Find the malformed section** (usually looks like):
   ```bash
   oplugins=(sysinfo weather taskman)
     proxy
     sysinfo
     weather
     taskman
     fzf
   )
   ```

4. **Replace it with correct syntax:**
   ```bash
   # OSH installation directory
   export OSH="$HOME/.osh"
   
   # Plugin selection
   oplugins=(sysinfo weather taskman proxy fzf)
   
   # Load OSH framework
   source $OSH/osh.sh
   ```

5. **Save and reload:**
   ```bash
   source ~/.zshrc
   ```

### Option 3: Plugin-Specific Fix

If you only have plugin configuration issues:

```bash
# Run the plugin-specific fix
$OSH/scripts/fix_zshrc_plugins.sh
```

## 🧪 Verification

After applying the fix, verify it works:

1. **Check configuration syntax:**
   ```bash
   grep -A3 "oplugins=" ~/.zshrc
   ```
   Should show: `oplugins=(plugin1 plugin2 plugin3)`

2. **Test new shell session:**
   ```bash
   zsh
   ```
   Should not auto-launch taskman

3. **Test taskman manually:**
   ```bash
   tasks --help    # Should show help
   tm              # Should launch UI only when called
   ```

## 🔧 Prevention

To prevent this issue in the future:

1. **Always use proper array syntax:**
   ```bash
   # Good
   oplugins=(plugin1 plugin2 plugin3)
   
   # Also good (multi-line)
   oplugins=(
     plugin1
     plugin2
     plugin3
   )
   ```

2. **Avoid manual editing** of OSH configuration when possible
3. **Use OSH commands** for plugin management:
   ```bash
   osh plugin add weather
   osh plugin remove taskman
   ```

## 🆘 Troubleshooting

### Issue: Fix script doesn't work
**Solution:** Try manual fix or check file permissions

### Issue: Still auto-starting after fix
**Solution:** 
1. Check for multiple `.zshrc` files
2. Verify shell configuration: `echo $SHELL`
3. Check for other shell initialization files

### Issue: Plugins not loading
**Solution:**
1. Verify OSH installation: `osh status`
2. Check plugin availability: `osh plugin list`
3. Reload configuration: `source ~/.zshrc`

## 📞 Support

If you continue experiencing issues:

1. **Check OSH status:** `osh status`
2. **View configuration:** `cat ~/.zshrc | grep -A10 oplugins`
3. **Report issue:** [GitHub Issues](https://github.com/oiahoon/osh.it/issues)

Include this information in your report:
- Your shell: `echo $SHELL`
- OSH version: `cat $OSH/VERSION`
- Configuration snippet: `grep -A5 -B5 oplugins ~/.zshrc`

## 📚 Related Documentation

- [Plugin Management Guide](PLUGIN_MANAGEMENT.md)
- [Installation Guide](../README.md#installation)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

---

**Last Updated:** December 2024  
**OSH.IT Version:** 1.4.0+
