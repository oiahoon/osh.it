#!/usr/bin/env python3
"""
PR Comment Handler
Processes comments on Pull Requests, especially from Amazon Q Developer
"""

import os
import sys
import json
import requests
import traceback
from typing import Dict, List, Optional

def get_environment_variables():
    """Get required environment variables"""
    return {
        'github_token': os.environ.get('GITHUB_TOKEN', ''),
        'comment_body': os.environ.get('COMMENT_BODY', ''),
        'pr_number': os.environ.get('PR_NUMBER', ''),
        'repo_name': os.environ.get('REPO_NAME', ''),
        'comment_author': os.environ.get('COMMENT_AUTHOR', ''),
        'deepseek_api_key': os.environ.get('DEEPSEEK_API_KEY', '')
    }

def analyze_amazon_q_comment(comment_body: str) -> Dict:
    """Analyze Amazon Q Developer comment for code suggestions"""
    
    analysis = {
        'is_code_suggestion': False,
        'has_code_blocks': False,
        'suggestion_type': 'unknown',
        'code_blocks': [],
        'summary': ''
    }
    
    # Check if it's a code suggestion
    if '```suggestion' in comment_body:
        analysis['is_code_suggestion'] = True
        analysis['suggestion_type'] = 'code_suggestion'
    elif '```' in comment_body:
        analysis['has_code_blocks'] = True
        analysis['suggestion_type'] = 'code_review'
    
    # Extract code blocks
    lines = comment_body.split('\n')
    in_code_block = False
    current_block = []
    
    for line in lines:
        if line.strip().startswith('```'):
            if in_code_block:
                # End of code block
                if current_block:
                    analysis['code_blocks'].append('\n'.join(current_block))
                current_block = []
                in_code_block = False
            else:
                # Start of code block
                in_code_block = True
        elif in_code_block:
            current_block.append(line)
    
    # Generate summary
    if analysis['is_code_suggestion']:
        analysis['summary'] = f"Amazon Q提供了代码建议，包含{len(analysis['code_blocks'])}个代码块"
    elif analysis['has_code_blocks']:
        analysis['summary'] = f"Amazon Q提供了代码审查，包含{len(analysis['code_blocks'])}个代码示例"
    else:
        analysis['summary'] = "Amazon Q提供了文本反馈"
    
    return analysis

def create_response_comment(analysis: Dict, comment_author: str) -> str:
    """Create a response comment based on the analysis"""
    
    if comment_author == 'amazon-q-developer[bot]':
        if analysis['is_code_suggestion']:
            return f"""## 🤖 Amazon Q Developer 代码建议已收到

感谢Amazon Q Developer的代码建议！

### 📊 分析结果
- **建议类型**: {analysis['suggestion_type']}
- **代码块数量**: {len(analysis['code_blocks'])}
- **总结**: {analysis['summary']}

### 🔄 下一步
请审查Amazon Q的建议并决定是否采纳。如果需要进一步讨论，请在此PR中继续评论。

---
*🤖 由OSH PR管理系统自动生成*"""
        else:
            return f"""## 🤖 Amazon Q Developer 反馈已收到

感谢Amazon Q Developer的代码审查！

### 📊 分析结果
- **反馈类型**: {analysis['suggestion_type']}
- **总结**: {analysis['summary']}

### 🔄 下一步
请审查Amazon Q的反馈并根据需要进行调整。

---
*🤖 由OSH PR管理系统自动生成*"""
    else:
        return f"""## 💬 PR评论已处理

感谢 @{comment_author} 的评论！

### 📊 评论分析
- **作者**: {comment_author}
- **类型**: 用户评论
- **包含代码**: {'是' if analysis['has_code_blocks'] else '否'}

---
*🤖 由OSH PR管理系统自动生成*"""

def post_github_comment(repo_name: str, pr_number: str, comment_body: str, github_token: str) -> bool:
    """Post a comment to the GitHub PR"""
    
    try:
        url = f'https://api.github.com/repos/{repo_name}/issues/{pr_number}/comments'
        headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
        
        data = {'body': comment_body}
        
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            print("✅ Response comment posted successfully")
            return True
        else:
            print(f"⚠️ Failed to post comment: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error posting comment: {e}")
        return False

def main():
    """Main comment processing function"""
    
    try:
        print("💬 Starting PR comment processing")
        
        # Get environment variables
        env_vars = get_environment_variables()
        
        if not all([env_vars['github_token'], env_vars['comment_body'], 
                   env_vars['pr_number'], env_vars['repo_name']]):
            print("❌ Missing required environment variables")
            return
        
        print(f"📊 Processing comment from: {env_vars['comment_author']}")
        print(f"📋 PR Number: {env_vars['pr_number']}")
        print(f"📝 Comment length: {len(env_vars['comment_body'])} characters")
        
        # Analyze the comment
        analysis = analyze_amazon_q_comment(env_vars['comment_body'])
        
        print(f"🔍 Analysis results:")
        print(f"  - Is code suggestion: {analysis['is_code_suggestion']}")
        print(f"  - Has code blocks: {analysis['has_code_blocks']}")
        print(f"  - Suggestion type: {analysis['suggestion_type']}")
        print(f"  - Code blocks found: {len(analysis['code_blocks'])}")
        
        # Create response comment
        response_comment = create_response_comment(analysis, env_vars['comment_author'])
        
        # Post response comment
        success = post_github_comment(
            env_vars['repo_name'],
            env_vars['pr_number'],
            response_comment,
            env_vars['github_token']
        )
        
        if success:
            print("🎯 PR comment processing completed successfully")
        else:
            print("⚠️ PR comment processing completed with warnings")
        
    except Exception as e:
        print(f"❌ PR comment processing failed: {e}")
        traceback.print_exc()
        
        # Try to post a fallback comment
        try:
            env_vars = get_environment_variables()
            if env_vars['github_token'] and env_vars['repo_name'] and env_vars['pr_number']:
                fallback_comment = """## 🤖 PR评论处理

感谢你的评论！我们的自动处理系统遇到了一些技术问题，但你的评论已经被记录。

我们的团队会人工审查并回复。

---
*🤖 由OSH PR管理系统提供*"""
                
                post_github_comment(
                    env_vars['repo_name'],
                    env_vars['pr_number'],
                    fallback_comment,
                    env_vars['github_token']
                )
                print("⚠️ Posted fallback comment")
        except:
            print("❌ Failed to post fallback comment")

if __name__ == "__main__":
    main()
