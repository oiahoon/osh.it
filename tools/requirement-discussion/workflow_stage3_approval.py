#!/usr/bin/env python3
"""
Workflow Stage 3: User Approval and Amazon Q Trigger
Detects user approval and triggers Amazon Q Developer
"""

import os
import sys
import json
import subprocess
import traceback

def main():
    """Main approval processing function"""
    
    try:
        # Get environment variables
        comment_body = os.environ.get('COMMENT_BODY', '')
        issue_number = os.environ.get('ISSUE_NUMBER', '')
        repo_name = os.environ.get('REPO_NAME', '')
        github_token = os.environ.get('GITHUB_TOKEN', '')
        
        print('🔍 Checking for implementation approval keywords')
        print(f'📊 Issue #{issue_number}')
        print(f'📝 Comment: {comment_body[:100]}...')
        
        # Check for approval keywords
        approval_keywords = [
            '可以开发了', '同意实现', '确认开发', '开始实现', '批准',
            'approve', 'confirmed', 'go ahead', 'proceed', 'start development'
        ]
        
        should_trigger = False
        matched_keyword = ""
        
        comment_lower = comment_body.lower()
        for keyword in approval_keywords:
            if keyword.lower() in comment_lower:
                should_trigger = True
                matched_keyword = keyword
                break
        
        if should_trigger:
            print(f"✅ 检测到触发关键词: '{matched_keyword}'")
            print("🚀 触发Amazon Q Developer自动实现")
            
            # Add Amazon Q development agent label
            add_label_cmd = [
                'curl', '-X', 'POST',
                '-H', f'Authorization: token {github_token}',
                '-H', 'Accept: application/vnd.github.v3+json',
                f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels',
                '-d', '{"labels":["Amazon Q development agent"]}'
            ]
            
            result = subprocess.run(add_label_cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ Added Amazon Q development agent label")
            else:
                print(f"⚠️ Failed to add Amazon Q label: {result.stderr}")
            
            # Remove ready-for-implementation label
            remove_label_cmd = [
                'curl', '-X', 'DELETE',
                '-H', f'Authorization: token {github_token}',
                f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels/ready-for-implementation'
            ]
            
            subprocess.run(remove_label_cmd, capture_output=True)
            print("✅ Removed ready-for-implementation label")
            
            # Create confirmation comment
            confirmation_comment = """## 🚀 Amazon Q Developer 已激活

✅ **状态**: 用户已确认实现方案
🤖 **Amazon Q Developer**: 正在自动实现功能
⏳ **预计时间**: 5-10分钟

请等待Amazon Q Developer创建Pull Request。

---
*🧠 由OSH AI需求分析师提供 | 阶段: 自动实现 (4/4)*"""
            
            create_comment_cmd = [
                'curl', '-X', 'POST',
                '-H', f'Authorization: token {github_token}',
                '-H', 'Accept: application/vnd.github.v3+json',
                f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/comments',
                '-d', json.dumps({'body': confirmation_comment})
            ]
            
            result = subprocess.run(create_comment_cmd, capture_output=True, text=True)
            if result.returncode == 0:
                print("✅ Posted Amazon Q activation confirmation")
            else:
                print(f"⚠️ Failed to post confirmation: {result.stderr}")
            
            print("🎯 Amazon Q Developer activation completed")
            
        else:
            print("ℹ️ 未检测到确认关键词")
            print("💡 用户可以回复以下关键词来触发实现:")
            print("   中文: 可以开发了, 同意实现, 确认开发")
            print("   英文: approve, confirmed, go ahead")
        
        print("🎯 Stage 3 approval check completed successfully")
        
    except Exception as e:
        print(f"❌ Approval processing failed: {e}")
        traceback.print_exc()

if __name__ == "__main__":
    main()
