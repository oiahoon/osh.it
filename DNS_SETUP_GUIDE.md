# OSH.IT 自定义域名配置指南

## 🌐 DNS配置步骤

### 方法1: CNAME记录（推荐）
在你的DNS提供商处添加以下记录：

```
类型: CNAME
名称: osh.it
值: oiahoon.github.io
TTL: 3600 (或默认)
```

### 方法2: A记录（备选）
如果不支持CNAME，使用A记录：

```
类型: A
名称: osh.it
值: 185.199.108.153
TTL: 3600

类型: A  
名称: osh.it
值: 185.199.109.153
TTL: 3600

类型: A
名称: osh.it
值: 185.199.110.153  
TTL: 3600

类型: A
名称: osh.it
值: 185.199.111.153
TTL: 3600
```

## 🔧 GitHub Pages配置

### 1. 创建CNAME文件
在docs目录创建CNAME文件，内容为你的域名

### 2. GitHub仓库设置
1. 访问: https://github.com/oiahoon/osh.it/settings/pages
2. 在Custom domain字段输入: osh.it.miaowu.org
3. 勾选"Enforce HTTPS"
4. 点击Save保存

## ⏰ 生效时间
- DNS传播通常需要几分钟到几小时
- GitHub Pages SSL证书生成需要几分钟

## 🧪 验证方法
```bash
# 检查DNS解析
nslookup osh.it.miaowu.org

# 检查网站访问
curl -I https://osh.it.miaowu.org
```

## 🔒 HTTPS配置
GitHub Pages会自动为自定义域名提供免费的SSL证书
