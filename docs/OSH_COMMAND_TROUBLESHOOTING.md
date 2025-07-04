# OSH 命令故障排除指南

## 🚨 常见问题：`osh` 命令无法使用

如果你遇到 `osh status`、`osh plugin add weather` 等命令无法使用的问题，请按照以下步骤进行诊断和修复。

## 🔧 快速诊断

首先运行自动诊断工具：

```bash
# 如果 osh 命令可用
osh doctor

# 如果 osh 命令不可用，直接运行诊断脚本
bash ~/.osh/scripts/osh_doctor.sh
```

## 📋 手动检查步骤

### 1. 检查 OSH.IT 是否已安装

```bash
# 检查 OSH.IT 目录是否存在
ls -la ~/.osh

# 检查主要文件是否存在
ls -la ~/.osh/osh.sh
ls -la ~/.osh/bin/osh
```

**如果文件不存在**，需要重新安装：
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

### 2. 检查 PATH 配置

```bash
# 检查 PATH 中是否包含 OSH bin 目录
echo $PATH | grep -o '\.osh/bin'

# 检查 osh 命令是否可用
which osh
```

**如果 PATH 配置有问题**：

1. 检查 `~/.zshrc` 文件：
```bash
grep "export PATH.*OSH" ~/.zshrc
```

2. 如果没有找到，手动添加：
```bash
echo 'export PATH="$OSH/bin:$PATH"' >> ~/.zshrc
```

3. 重新加载配置：
```bash
source ~/.zshrc
```

### 3. 检查环境变量

```bash
# 检查 OSH 环境变量
echo $OSH

# 检查 ~/.zshrc 中的配置
grep "export OSH=" ~/.zshrc
```

**如果环境变量未设置**：
```bash
echo 'export OSH="$HOME/.osh"' >> ~/.zshrc
source ~/.zshrc
```

### 4. 检查文件权限

```bash
# 检查 osh 命令是否可执行
ls -la ~/.osh/bin/osh
```

**如果权限有问题**：
```bash
chmod +x ~/.osh/bin/osh
chmod +x ~/.osh/scripts/*.sh
```

### 5. 检查 Shell 配置

```bash
# 检查是否正确加载了 OSH.IT
grep "source.*osh.sh" ~/.zshrc
```

**如果没有正确加载**：
```bash
echo 'source $OSH/osh.sh' >> ~/.zshrc
source ~/.zshrc
```

## 🔄 完整的配置示例

你的 `~/.zshrc` 文件应该包含以下配置：

```bash
# OSH.IT Configuration
export OSH="$HOME/.osh"
export PATH="$OSH/bin:$PATH"
oplugins=(sysinfo weather taskman)
source $OSH/osh.sh
```

## 🧪 测试修复结果

修复后，测试以下命令：

```bash
# 基本命令
osh help
osh status
osh plugin list

# 插件管理
osh plugins
osh plugin add greeting
osh plugin remove greeting

# 系统命令
osh doctor
osh reload
```

## 🚀 自动修复

如果你不想手动修复，可以使用自动修复功能：

```bash
# 运行自动修复
osh doctor --fix

# 或者直接运行脚本
bash ~/.osh/scripts/osh_doctor.sh --fix
```

## 📞 仍然有问题？

如果按照上述步骤仍然无法解决问题：

1. **重新安装 OSH.IT**：
```bash
# 备份当前配置
cp ~/.zshrc ~/.zshrc.backup

# 重新安装
sh -c "$(curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh)"
```

2. **检查 Shell 类型**：
```bash
echo $SHELL
```
确保你使用的是 Zsh。如果不是，切换到 Zsh：
```bash
chsh -s $(which zsh)
```

3. **重启终端**：
完全关闭并重新打开终端应用程序。

4. **提交 Issue**：
如果问题仍然存在，请在 [GitHub Issues](https://github.com/oiahoon/osh.it/issues) 中报告问题，并包含以下信息：
- 操作系统版本
- Shell 类型和版本
- `osh doctor` 的完整输出
- 错误信息截图

## 💡 预防措施

为了避免将来出现问题：

1. **定期运行诊断**：
```bash
osh doctor
```

2. **保持更新**：
```bash
osh upgrade
```

3. **备份配置**：
```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
```

4. **使用推荐的安装方式**：
始终使用官方安装脚本，避免手动修改核心文件。
