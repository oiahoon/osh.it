# OSH.IT 插件管理完整指南

## 📦 可用插件列表

### 🟢 稳定版插件 (Stable)
推荐所有用户使用，经过充分测试：

| 插件名 | 版本 | 描述 | 依赖 |
|--------|------|------|------|
| **sysinfo** | v1.1.0 | 系统信息显示，带 OSH 品牌 | 无 |
| **weather** | v1.3.0 | 美观的天气预报，带 ASCII 艺术 | curl |
| **taskman** | v2.0.0 | 高级终端任务管理器，生产力工具 | python3 |

### 🟡 测试版插件 (Beta)
适合高级用户，功能相对稳定：

| 插件名 | 版本 | 描述 | 依赖 |
|--------|------|------|------|
| **acw** | v0.9.0 | 高级代码工作流 - Git + JIRA 集成 | git, curl |
| **fzf** | v0.8.0 | 增强的模糊查找器，带预览功能 | fzf |

### 🔴 实验版插件 (Experimental)
谨慎使用，可能不稳定：

| 插件名 | 版本 | 描述 | 依赖 |
|--------|------|------|------|
| **greeting** | v0.5.0 | OSH 用户友好欢迎消息 | 无 |

## 🔧 插件管理方法

### 方法 1: 编辑配置文件 (推荐)

#### 查看当前插件配置
```bash
# 查看当前配置
grep "oplugins=" ~/.zshrc
```

#### 添加插件
```bash
# 编辑配置文件
vim ~/.zshrc

# 找到这一行：
oplugins=(sysinfo weather taskman)

# 添加新插件，例如添加 acw：
oplugins=(sysinfo weather taskman acw)

# 保存并重新加载
source ~/.zshrc
```

#### 移除插件
```bash
# 从配置中移除插件
oplugins=(sysinfo weather)  # 移除了 taskman

# 重新加载配置
source ~/.zshrc
```

### 方法 2: 重新运行安装脚本

#### 交互式重新配置
```bash
# 重新运行安装脚本，会提示选择插件
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh | bash
```

#### 指定插件安装
```bash
# 安装特定插件组合
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh | bash -s -- --plugins "sysinfo,weather,acw"

# 使用预设配置
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh | bash -s -- --plugins "preset:developer"
```

### 方法 3: 手动下载插件文件

#### 下载单个插件
```bash
# 创建插件目录
mkdir -p ~/.osh/plugins/pluginname

# 下载插件文件
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/plugins/pluginname/pluginname.plugin.zsh \
  -o ~/.osh/plugins/pluginname/pluginname.plugin.zsh

# 添加到配置
echo 'oplugins+=(pluginname)' >> ~/.zshrc
source ~/.zshrc
```

## 📋 预设配置

OSH.IT 提供了几种预设的插件组合：

### minimal (最小化)
```bash
oplugins=(sysinfo)
```
- 只包含系统信息显示
- 适合资源受限环境

### recommended (推荐，默认)
```bash
oplugins=(sysinfo weather taskman)
```
- 包含最常用的稳定插件
- 适合大多数用户

### developer (开发者)
```bash
oplugins=(sysinfo weather taskman acw fzf)
```
- 包含开发相关工具
- 适合程序员和开发者

### full (完整)
```bash
oplugins=(sysinfo weather taskman acw fzf greeting)
```
- 包含所有可用插件
- 适合想要体验所有功能的用户

## 🔍 插件信息查询

### 查看插件详情
```bash
# 查看稳定插件列表
bash ~/.osh/scripts/plugin_manifest_manager.sh stable

# 查看特定插件信息
bash ~/.osh/scripts/plugin_manifest_manager.sh info weather

# 查看所有类别
bash ~/.osh/scripts/plugin_manifest_manager.sh --help
```

### 检查插件状态
```bash
# 查看当前加载的插件
echo $oplugins

# 检查插件文件是否存在
ls ~/.osh/plugins/
```

## 🛠️ 插件功能说明

### sysinfo - 系统信息
```bash
sysinfo          # 显示系统信息
oshinfo          # 别名
neofetch-osh     # 别名
sysinfo --no-logo # 不显示 logo
```

### weather - 天气预报
```bash
weather                    # 显示当前位置天气
weather -l Tokyo          # 显示指定城市天气
weather -d                 # 显示详细预报
forecast                   # 别名
```

### taskman - 任务管理
```bash
tm                         # 启动任务管理器
tasks setup               # 运行设置向导
tasks config              # 查看配置
```

### acw - 代码工作流 (Beta)
```bash
acw [base-branch]         # 创建功能分支
ggco <keyword>            # 智能分支切换
newb [base-branch]        # 创建通用分支
```

### fzf - 模糊查找 (Beta)
```bash
pp                        # 预览文件
fcommit                   # 交互式 git 提交浏览
```

### greeting - 欢迎消息 (Experimental)
```bash
# 自动在新终端会话中显示欢迎消息
```

## 🔧 故障排除

### 插件无法加载
```bash
# 检查插件文件是否存在
ls ~/.osh/plugins/pluginname/

# 检查配置语法
grep "oplugins=" ~/.zshrc

# 重新加载配置
source ~/.zshrc
```

### 插件冲突
```bash
# 逐个测试插件
oplugins=(sysinfo)        # 只加载一个插件测试
source ~/.zshrc

# 逐步添加其他插件找出冲突源
```

### 依赖缺失
```bash
# 检查系统依赖
which curl git python3 fzf

# 安装缺失依赖 (macOS)
brew install curl git python3 fzf

# 安装缺失依赖 (Ubuntu/Debian)
sudo apt install curl git python3 fzf
```

## 📚 高级用法

### 自定义插件加载顺序
```bash
# 插件按数组顺序加载
oplugins=(
    sysinfo    # 首先加载
    weather    # 然后加载
    taskman    # 最后加载
)
```

### 条件加载插件
```bash
# 在 .zshrc 中添加条件逻辑
if [[ "$USER" == "developer" ]]; then
    oplugins=(sysinfo weather taskman acw fzf)
else
    oplugins=(sysinfo weather)
fi
```

### 临时禁用插件
```bash
# 临时注释掉插件
# oplugins=(sysinfo weather taskman)
oplugins=(sysinfo weather)  # 临时禁用 taskman
```

## 🔄 更新插件

### 更新所有插件
```bash
# 运行升级脚本
bash ~/.osh/upgrade.sh

# 或重新运行安装脚本
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/install.sh | bash
```

### 更新单个插件
```bash
# 重新下载插件文件
curl -fsSL https://raw.githubusercontent.com/oiahoon/osh.it/main/plugins/weather/weather.plugin.zsh \
  -o ~/.osh/plugins/weather/weather.plugin.zsh

# 重新加载
source ~/.zshrc
```

---

## 💡 最佳实践

1. **从推荐配置开始**: 新用户建议使用 `preset:recommended`
2. **逐步添加插件**: 不要一次性安装所有插件
3. **定期更新**: 使用 `upgrade.sh` 保持插件最新
4. **备份配置**: 修改前备份 `.zshrc` 文件
5. **测试新插件**: 在测试环境中先试用 beta 和实验性插件

## 🆘 获取帮助

- **文档**: [GitHub Wiki](https://github.com/oiahoon/osh.it/wiki)
- **问题报告**: [GitHub Issues](https://github.com/oiahoon/osh.it/issues)
- **讨论**: [GitHub Discussions](https://github.com/oiahoon/osh.it/discussions)
