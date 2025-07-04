# OSH.IT 安装问题修复指南

## 🚨 问题描述

如果你在重新安装 OSH.IT 后遇到以下问题：

1. **懒加载错误**：
   ```
   ⚠ Lazy loading requested but lazy_loader.zsh not found, falling back to immediate loading
   ```

2. **osh 命令找不到**：
   ```
   zsh: command not found: osh
   ```

这是因为安装脚本中缺少了一些必要的文件。我们已经修复了这个问题。

## ✅ 解决方案

### 方法 1：重新安装（推荐）

使用最新的安装脚本重新安装：

```bash
# 重新安装 OSH.IT
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

### 方法 2：手动修复

如果你不想重新安装，可以手动下载缺失的文件：

```bash
# 设置 OSH 目录
OSH_DIR="$HOME/.osh"

# 下载缺失的 lib 文件
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/lib/lazy_loader.zsh -o "$OSH_DIR/lib/lazy_loader.zsh"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/lib/plugin_manager.zsh -o "$OSH_DIR/lib/plugin_manager.zsh"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/lib/plugin_aliases.zsh -o "$OSH_DIR/lib/plugin_aliases.zsh"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/lib/osh_config.zsh -o "$OSH_DIR/lib/osh_config.zsh"

# 下载 bin 目录
mkdir -p "$OSH_DIR/bin"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/bin/osh -o "$OSH_DIR/bin/osh"

# 下载 scripts 目录
mkdir -p "$OSH_DIR/scripts"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/osh_cli.sh -o "$OSH_DIR/scripts/osh_cli.sh"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/osh_doctor.sh -o "$OSH_DIR/scripts/osh_doctor.sh"
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/scripts/osh_plugin_manager.sh -o "$OSH_DIR/scripts/osh_plugin_manager.sh"

# 设置文件权限
chmod +x "$OSH_DIR/bin/osh"
chmod +x "$OSH_DIR/scripts/"*.sh
```

### 方法 3：使用诊断工具

如果你已经有部分文件，可以尝试使用诊断工具：

```bash
# 如果 osh 命令可用
osh doctor --fix

# 如果 osh 命令不可用，直接运行
bash ~/.osh/scripts/osh_doctor.sh --fix
```

## 🔧 验证修复

修复后，验证以下内容：

### 1. 检查文件是否存在

```bash
# 检查关键文件
ls -la ~/.osh/lib/lazy_loader.zsh
ls -la ~/.osh/bin/osh
ls -la ~/.osh/scripts/osh_cli.sh
ls -la ~/.osh/scripts/osh_doctor.sh
```

### 2. 检查文件权限

```bash
# 检查可执行权限
ls -la ~/.osh/bin/osh
ls -la ~/.osh/scripts/*.sh
```

### 3. 测试 osh 命令

```bash
# 重新加载配置
source ~/.zshrc

# 测试基本命令
osh help
osh status
osh doctor
```

## 🎯 预期结果

修复后，你应该能够：

- ✅ 正常加载 OSH.IT 而不出现懒加载错误
- ✅ 使用所有 `osh` 命令
- ✅ 正常管理插件
- ✅ 运行诊断工具

## 🚀 完整的配置检查

确保你的 `~/.zshrc` 包含正确的配置：

```bash
# OSH.IT Configuration
export OSH="$HOME/.osh"
export PATH="$OSH/bin:$PATH"
oplugins=(sysinfo weather taskman)
source $OSH/osh.sh
```

## 📞 仍然有问题？

如果问题仍然存在：

1. **完全重新安装**：
   ```bash
   # 删除旧安装
   rm -rf ~/.osh
   
   # 从 ~/.zshrc 中移除 OSH 配置
   # 然后重新安装
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
   ```

2. **运行完整诊断**：
   ```bash
   osh doctor --perf
   ```

3. **提交问题报告**：
   在 [GitHub Issues](https://github.com/oiahoon/osh.it/issues) 中报告问题，包含：
   - 操作系统信息
   - 错误信息截图
   - `osh doctor` 的完整输出

## 💡 预防措施

为了避免将来出现类似问题：

1. **使用官方安装脚本**：始终使用最新的官方安装脚本
2. **定期更新**：运行 `osh upgrade` 保持最新版本
3. **备份配置**：定期备份 `~/.zshrc` 文件
4. **运行诊断**：定期运行 `osh doctor` 检查系统健康状态

---

**注意**：这个问题已经在最新版本的安装脚本中修复。如果你使用的是旧版本的安装脚本，建议重新安装以获得最佳体验。
