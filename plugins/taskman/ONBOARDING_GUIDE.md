# 🎯 Taskman 新人引导系统

## 概述

Taskman 现在包含一个友好的新人引导系统，为首次使用的用户提供简单而强大的配置体验。用户可以通过简单的问答来自定义他们的任务管理环境，也可以直接使用默认设置开始使用。

## ✨ 主要特性

### 🚀 零配置开始
- 所有设置都有合理的默认值
- 用户可以直接按回车使用默认配置
- 无需任何设置即可开始使用

### 🎨 友好的交互界面
- 彩色的终端界面，美观易读
- 清晰的问题描述和选项说明
- 支持 Ctrl+C 随时取消设置

### 📁 灵活的存储选项
- **默认模式**: 存储在 `~/.taskman`
- **自定义模式**: 用户指定任意目录
- **便携模式**: 存储在插件目录，随插件移动

### ⚙️ 全面的配置选项
- 数据存储位置
- UI风格选择 (Vintage/Classic)
- Dino动画助手开关
- 默认任务优先级
- 日期显示格式
- 自动保存设置

## 🎯 用户体验流程

### 首次使用
```bash
# 用户首次运行
tm

# 系统检测到首次使用
🎯 First time using Taskman?
Let's set up your task management system!

Run setup wizard now? (Y/n): 
```

### 设置向导界面
```
╔══════════════════════════════════════════════════════════════╗
║                    🎨 OSH TASKMAN SETUP                     ║
║                                                              ║
║           Welcome to your new task management system!       ║
╚══════════════════════════════════════════════════════════════╝

📁 DATA STORAGE CONFIGURATION

Where would you like to store your tasks?
ℹ️  Tasks will be saved as JSON files in this directory.
Current default: /Users/username/.taskman

Options:
  1. Default location (/Users/username/.taskman)
  2. Custom location (you'll specify the path)
  3. Portable mode (store in plugin directory)

Enter your choice (default: 1): 
```

### 配置完成
```
📋 CONFIGURATION SUMMARY

  📁 Data Directory: /Users/username/.taskman
  🎨 Vintage Mode: ✅ Enabled
  🦕 Dino Animation: ✅ Enabled
  💾 Auto-save: ✅ Enabled
  ⭐ Default Priority: Normal
  📅 Date Format: Relative

Save this configuration? (Y/n): 

✅ Configuration saved!

🚀 YOU'RE ALL SET!

🎯 Quick Start Commands:
  tm                    # Launch the beautiful task manager UI
  tasks add "My task"   # Add a new task from command line
  tasks list            # List all tasks
  tasks help            # Show all available commands
```

## 🔧 技术实现

### 核心组件

#### 1. 设置向导 (`taskman_setup.py`)
```python
class TaskmanSetupWizard:
    def __init__(self):
        self.config_file = Path.home() / ".taskman" / "config.json"
        self.setup_complete_file = Path.home() / ".taskman" / ".setup_complete"
        
    def run_setup(self):
        # 完整的交互式设置流程
```

#### 2. 插件集成 (`taskman.plugin.zsh`)
```bash
# 检查首次设置
_taskman_check_first_time_setup() {
    local setup_complete_file="$TASKMAN_DATA_DIR/.setup_complete"
    [[ ! -f "$setup_complete_file" ]]
}

# 加载配置
_taskman_load_config() {
    # 从 config.json 读取配置
}
```

#### 3. CLI集成 (`task_cli.py`)
```python
class TaskCLI:
    def __init__(self):
        self.config = self._load_config()
        data_dir = self.config.get('data_directory', '~/.taskman')
        self.task_manager = TaskManager(data_file=f"{data_dir}/tasks.json")
```

### 配置文件格式
```json
{
  "data_directory": "/Users/username/.taskman",
  "vintage_mode": true,
  "dino_animation": true,
  "auto_save": true,
  "default_priority": "normal",
  "date_format": "relative",
  "theme": "vintage",
  "setup_version": "1.0",
  "setup_date": "2025-06-25T10:26:17.001230"
}
```

## 📋 命令参考

### 新增命令
```bash
tasks setup          # 运行设置向导
tasks config         # 显示当前配置
```

### 现有命令 (保持不变)
```bash
tm                    # 启动任务管理器UI
tasks                 # 同上
tasks add "任务"      # 添加任务
tasks list            # 列出任务
tasks done <id>       # 完成任务
tasks delete <id>     # 删除任务
```

## 🎨 设计原则

### 1. 渐进式配置
- 默认值覆盖所有常见使用场景
- 高级用户可以深度自定义
- 配置可以随时重新运行

### 2. 非侵入性
- 不影响现有用户的使用
- 向后完全兼容
- 可选的引导流程

### 3. 用户友好
- 清晰的视觉界面
- 详细的选项说明
- 容错和取消支持

### 4. 灵活存储
- 支持多种存储模式
- 便携性考虑
- 路径自动扩展和验证

## 🔄 向后兼容性

### 现有用户
- 无任何影响，继续使用现有配置
- 可选择运行设置向导来享受新功能
- 所有现有命令和功能保持不变

### 环境变量支持
```bash
# 仍然支持环境变量覆盖
export TASKMAN_DATA_DIR="/custom/path"
export TASKMAN_VINTAGE=false
```

## 🧪 测试和验证

### 功能测试
- ✅ 设置向导完整流程
- ✅ 配置文件读写
- ✅ CLI配置集成
- ✅ 向后兼容性
- ✅ 错误处理和恢复

### 用户体验测试
- ✅ 首次使用流程
- ✅ 默认值使用
- ✅ 自定义配置
- ✅ 设置重新运行
- ✅ 配置查看

## 🚀 未来扩展

### 可能的增强功能
- 配置导入/导出
- 多配置文件支持
- 团队配置共享
- 云同步集成
- 主题系统扩展

### 配置选项扩展
- 快捷键自定义
- 通知设置
- 备份策略
- 性能调优选项

## 📝 总结

新人引导系统为 Taskman 带来了：

- 🎯 **更好的首次体验** - 友好的设置向导
- 🔧 **灵活的配置** - 支持多种使用场景  
- 📁 **智能存储** - 自适应的数据管理
- 🎨 **美观界面** - 与OSH风格一致
- 🔄 **完全兼容** - 不影响现有用户

这个系统让新用户能够快速上手，同时为高级用户提供了强大的自定义能力。
