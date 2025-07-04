#!/bin/bash

echo "🔍 OSH.IT GitHub Pages 部署诊断"
echo "================================"
echo ""

echo "📊 仓库信息:"
echo "- 仓库: oiahoon/osh.it"
echo "- 主分支: main"
echo "- Pages状态: $(curl -s https://api.github.com/repos/oiahoon/osh.it | jq -r '.has_pages')"
echo ""

echo "🌐 测试网站访问:"
echo "- 主域名: https://oiahoon.github.io/osh.it"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://oiahoon.github.io/osh.it)
echo "- HTTP状态: $STATUS"

if [ "$STATUS" = "200" ]; then
    echo "✅ 网站可以访问！"
elif [ "$STATUS" = "404" ]; then
    echo "❌ 网站未找到 - Pages可能未正确部署"
else
    echo "⚠️  网站状态异常: $STATUS"
fi
echo ""

echo "🔧 建议的解决步骤:"
echo "1. 访问: https://github.com/oiahoon/osh.it/settings/pages"
echo "2. 确保Source设置为'GitHub Actions'或'Deploy from branch'"
echo "3. 如果选择分支部署，选择'gh-pages'分支"
echo "4. 检查Actions运行状态: https://github.com/oiahoon/osh.it/actions"
echo ""

echo "📋 当前工作流:"
echo "- pages.yml (GitHub Actions部署)"
echo "- simple-deploy.yml (gh-pages分支部署)"
echo "- deploy-website.yml (完整功能部署)"
echo ""

echo "🎯 推荐操作:"
echo "手动启用GitHub Pages，然后重新运行Actions工作流"
