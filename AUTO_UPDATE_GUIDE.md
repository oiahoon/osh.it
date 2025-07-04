# OSH.IT 网站自动更新机制

## 🔄 **自动更新概述**

OSH.IT网站具有智能的自动更新系统，能够检测仓库中的变化并自动更新网站内容，无需手动维护。

## ✅ **自动更新的内容**

### 1. **版本信息**
- **来源**: `VERSION` 文件或 `package.json`
- **更新位置**: 网站标题栏、页脚统计
- **触发**: 任何版本文件的更改

### 2. **插件信息**
- **来源**: `plugins/` 目录扫描
- **检测内容**:
  - 插件数量统计
  - 插件分类（stable/beta/experimental）
  - 插件描述和版本
  - 插件元数据
- **更新位置**: 插件展示区域、统计数据

### 3. **功能列表**
- **来源**: `README.md` 的 Features 部分
- **更新位置**: 功能展示卡片
- **格式**: 自动提取 `- ` 开头的功能列表

### 4. **最新更改**
- **来源**: `CHANGELOG.md` 的 Unreleased 部分
- **更新位置**: 更新日志展示
- **数量**: 最新5条更改

## 🚀 **触发机制**

### GitHub Actions 触发条件
```yaml
on:
  push:
    branches: [ main ]
    paths:
      - 'docs/**'        # 网站文件更改
      - 'plugins/**'     # 插件更改
      - 'README.md'      # 功能描述更改
      - 'CHANGELOG.md'   # 更新日志更改
      - 'VERSION'        # 版本更改
      - 'package.json'   # 包信息更改
```

### 自动部署流程
1. **代码推送** → 触发GitHub Actions
2. **内容检测** → 扫描仓库变化
3. **内容生成** → 更新网站内容
4. **网站部署** → 自动发布到GitHub Pages

## 📋 **添加新插件的自动更新**

### 插件元数据格式
在插件文件中添加注释元数据：

```bash
#!/bin/zsh
# Description: 插件功能描述
# Version: 1.0.0
# Category: stable|beta|experimental
# Author: 作者名称
# Tags: tag1, tag2, tag3

# 插件代码...
```

### 示例：添加新插件
1. **创建插件目录**:
   ```bash
   mkdir plugins/myplugin
   ```

2. **创建插件文件**:
   ```bash
   # plugins/myplugin/myplugin.plugin.zsh
   #!/bin/zsh
   # Description: My awesome plugin for terminal productivity
   # Version: 1.0.0
   # Category: beta
   # Author: Your Name
   
   myplugin_hello() {
       echo "Hello from my plugin!"
   }
   ```

3. **创建README** (可选):
   ```bash
   # plugins/myplugin/README.md
   # My Plugin
   
   This plugin does amazing things...
   ```

4. **提交并推送**:
   ```bash
   git add plugins/myplugin/
   git commit -m "feat: Add myplugin for terminal productivity"
   git push origin main
   ```

5. **自动更新结果**:
   - ✅ 插件数量自动增加
   - ✅ 插件分类自动更新
   - ✅ 网站内容自动重新生成
   - ✅ 自动部署到网站

## 🎯 **添加新功能的自动更新**

### 在README.md中添加功能
```markdown
## ✨ Features

- 🚀 **Lightning Fast**: Minimal overhead with smart plugin loading
- ⚡ **Advanced Lazy Loading**: 92% faster startup
- 🔌 **Smart Plugin System**: Intelligent plugin discovery
- 🆕 **Your New Feature**: Description of your new feature
```

### 自动更新结果
- ✅ 功能卡片自动更新
- ✅ 功能数量统计更新
- ✅ 网站内容重新生成

## 📊 **版本更新的自动更新**

### 更新版本号
```bash
# 方法1: 更新VERSION文件
echo "1.5.0" > VERSION

# 方法2: 更新package.json
npm version 1.5.0

# 提交更改
git add VERSION package.json
git commit -m "bump: version 1.5.0"
git push origin main
```

### 自动更新结果
- ✅ 网站标题栏版本更新
- ✅ 页脚版本信息更新
- ✅ 元数据版本更新

## 🔍 **监控和验证**

### 检查自动更新状态
1. **GitHub Actions**: 查看工作流运行状态
   - 访问: `https://github.com/oiahoon/osh.it/actions`

2. **生成报告**: 查看详细的检测报告
   - 文件: `docs/enhanced-report.json`
   - 包含所有检测到的内容统计

3. **网站验证**: 确认更新已生效
   - 访问: `https://osh.it.miaowu.org`
   - 检查相关内容是否已更新

### 调试自动更新
```bash
# 本地测试内容生成
cd docs
node enhanced-content-generator.js

# 查看生成报告
cat enhanced-report.json

# 检查HTML更新
grep -n "v1.4.0" index.html
```

## 🎨 **自定义自动更新**

### 扩展检测规则
可以修改 `docs/enhanced-content-generator.js` 来添加新的检测规则：

```javascript
// 添加新的内容检测
const detectCustomContent = () => {
  // 你的自定义检测逻辑
};
```

### 添加新的触发路径
在 `.github/workflows/pages.yml` 中添加新的触发路径：

```yaml
paths:
  - 'your-custom-path/**'
```

## 🎉 **总结**

OSH.IT的自动更新机制确保了：

- ✅ **零维护**: 添加插件或功能后网站自动更新
- ✅ **实时同步**: 代码变更立即反映到网站
- ✅ **智能检测**: 自动识别插件元数据和功能描述
- ✅ **完整统计**: 准确的插件数量和功能统计
- ✅ **SEO友好**: 自动更新元数据和结构化数据

这意味着你只需要专注于开发OSH.IT的功能，网站会自动保持最新状态！🚀
