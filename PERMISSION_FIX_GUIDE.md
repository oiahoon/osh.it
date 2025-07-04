# OSH.IT 权限问题修复指南

## 🚨 问题描述

如果你遇到以下权限错误：

```bash
/Users/username/.osh/bin/osh: line 16: /Users/username/.osh/scripts/osh_cli.sh: Permission denied
/Users/username/.osh/bin/osh: line 16: exec: /Users/username/.osh/scripts/osh_cli.sh: cannot execute: Undefined error: 0
```

这是因为下载的脚本文件没有执行权限。

## ✅ 快速修复方案

### 方法 1：使用专用修复脚本（推荐）

```bash
# 下载并运行权限修复脚本
bash <(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_permissions.sh)
```

### 方法 2：使用 OSH.IT 修复工具

```bash
# 使用完整的安装修复脚本
bash <(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/fix_installation.sh)
```

### 方法 3：手动修复权限

```bash
# 修复所有必要文件的权限
chmod +x ~/.osh/osh.sh
chmod +x ~/.osh/upgrade.sh
chmod +x ~/.osh/bin/osh
chmod +x ~/.osh/scripts/*.sh
```

### 方法 4：重新安装

```bash
# 完全重新安装（会获得最新的修复）
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

## 🔍 验证修复

修复后，验证权限是否正确：

```bash
# 检查关键文件权限
ls -la ~/.osh/bin/osh
ls -la ~/.osh/scripts/osh_cli.sh

# 测试 osh 命令
osh help
osh status
osh doctor
```

## 🎯 预期结果

修复后，你应该看到：

```bash
# 正确的权限（注意开头的 -rwxr-xr-x）
-rwxr-xr-x  1 user  staff   358 Jul  4 14:11 /Users/user/.osh/bin/osh
-rwxr-xr-x  1 user  staff 11942 Jul  4 14:11 /Users/user/.osh/scripts/osh_cli.sh
```

## 🤔 为什么会出现这个问题？

1. **下载默认权限**：通过 `curl` 下载的文件默认没有执行权限
2. **脚本依赖**：`osh` 命令需要调用其他脚本文件
3. **权限继承**：某些系统设置可能影响文件权限

## 🛡️ 预防措施

为了避免将来出现权限问题：

1. **使用官方安装脚本**：始终使用最新的官方安装脚本
2. **定期运行诊断**：使用 `osh doctor` 检查系统状态
3. **升级时注意**：升级后如果遇到问题，运行权限修复

## 📞 仍然有问题？

如果上述方法都无法解决问题：

1. **检查系统权限**：确保你有修改 `~/.osh` 目录的权限
2. **检查文件系统**：某些文件系统（如网络驱动器）可能不支持执行权限
3. **提交问题报告**：在 [GitHub Issues](https://github.com/oiahoon/osh.it/issues) 中报告问题

## 🔧 高级故障排除

### 检查文件完整性

```bash
# 检查关键文件是否存在
ls -la ~/.osh/bin/osh
ls -la ~/.osh/scripts/osh_cli.sh
ls -la ~/.osh/scripts/osh_doctor.sh
```

### 检查 PATH 配置

```bash
# 确保 OSH bin 目录在 PATH 中
echo $PATH | grep -o '\.osh/bin' || echo "OSH bin not in PATH"

# 检查 zshrc 配置
grep -A2 'export OSH=' ~/.zshrc
```

### 重置完整安装

```bash
# 完全清理并重新安装
rm -rf ~/.osh
# 从 ~/.zshrc 中移除 OSH 配置行
# 然后重新安装
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

---

**注意**：这个权限问题已经在最新版本的安装和升级脚本中修复。使用最新版本可以避免这个问题。
