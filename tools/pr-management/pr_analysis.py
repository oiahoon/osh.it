#!/usr/bin/env python3
"""
PR Analysis Tool
Analyzes Pull Request implementation against original requirements
"""

import os
import sys
import requests
import json
from typing import Dict, List

def analyze_pr_implementation():
    """Analyze PR implementation quality and completeness"""
    
    # Get environment variables
    github_token = os.environ.get('GITHUB_TOKEN')
    pr_title = os.environ.get('PR_TITLE', '')
    pr_body = os.environ.get('PR_BODY', '')
    pr_number = os.environ.get('PR_NUMBER', '')
    repo_name = os.environ.get('REPO_NAME', '')
    
    print(f"🔍 Analyzing PR #{pr_number}: {pr_title}")
    
    # Get PR files and changes
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    try:
        # Get PR files
        files_url = f"https://api.github.com/repos/{repo_name}/pulls/{pr_number}/files"
        files_response = requests.get(files_url, headers=headers)
        
        if files_response.status_code == 200:
            files = files_response.json()
            
            # Analyze implementation
            analysis_result = analyze_implementation_quality(files, pr_title, pr_body)
            
            # Post analysis comment
            post_pr_analysis_comment(github_token, repo_name, pr_number, analysis_result)
            
        else:
            print(f"❌ Failed to get PR files: {files_response.status_code}")
            
    except Exception as e:
        print(f"❌ PR analysis failed: {e}")

def analyze_implementation_quality(files: List[Dict], pr_title: str, pr_body: str) -> Dict:
    """Analyze the quality of the implementation"""
    
    analysis = {
        'files_changed': len(files),
        'plugin_files': [],
        'documentation_files': [],
        'test_files': [],
        'quality_score': 0,
        'recommendations': []
    }
    
    for file in files:
        filename = file['filename']
        
        if filename.endswith('.plugin.zsh'):
            analysis['plugin_files'].append(filename)
        elif filename.endswith('.md') or 'README' in filename:
            analysis['documentation_files'].append(filename)
        elif 'test' in filename.lower():
            analysis['test_files'].append(filename)
    
    # Calculate quality score
    score = 0
    if analysis['plugin_files']:
        score += 40  # Main implementation
    if analysis['documentation_files']:
        score += 30  # Documentation
    if analysis['test_files']:
        score += 20  # Tests
    if len(files) <= 10:
        score += 10  # Focused changes
    
    analysis['quality_score'] = score
    
    # Generate recommendations
    if not analysis['plugin_files']:
        analysis['recommendations'].append("❌ 没有发现插件文件(.plugin.zsh)")
    if not analysis['documentation_files']:
        analysis['recommendations'].append("⚠️ 建议添加README.md文档")
    if not analysis['test_files']:
        analysis['recommendations'].append("💡 建议添加测试文件")
    
    return analysis

def post_pr_analysis_comment(github_token: str, repo_name: str, pr_number: str, analysis: Dict):
    """Post PR analysis comment"""
    
    quality_emoji = "🟢" if analysis['quality_score'] >= 80 else "🟡" if analysis['quality_score'] >= 60 else "🔴"
    
    comment = f"""## 🤖 OSH AI代码审查 - PR实现分析

### 📊 实现质量评估
{quality_emoji} **质量评分**: {analysis['quality_score']}/100

### 📁 文件变更分析
- **总文件数**: {analysis['files_changed']}
- **插件文件**: {len(analysis['plugin_files'])} 个
- **文档文件**: {len(analysis['documentation_files'])} 个  
- **测试文件**: {len(analysis['test_files'])} 个

### 📋 发现的文件
**插件文件**:
{chr(10).join([f"- {f}" for f in analysis['plugin_files']]) if analysis['plugin_files'] else "- 无"}

**文档文件**:
{chr(10).join([f"- {f}" for f in analysis['documentation_files']]) if analysis['documentation_files'] else "- 无"}

### 💡 改进建议
{chr(10).join(analysis['recommendations']) if analysis['recommendations'] else "✅ 实现质量良好，无特殊建议"}

### 🎯 下一步
- 请确保所有功能都已正确实现
- 建议进行手动测试验证
- 如有问题请及时修复

---
*🤖 由OSH AI代码审查系统提供*"""
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    comment_url = f"https://api.github.com/repos/{repo_name}/pulls/{pr_number}/comments"
    response = requests.post(comment_url, headers=headers, json={'body': comment})
    
    if response.status_code == 201:
        print("✅ PR analysis comment posted")
    else:
        print(f"❌ Failed to post comment: {response.status_code}")

if __name__ == "__main__":
    analyze_pr_implementation()
