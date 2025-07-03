#!/usr/bin/env python3
"""
Workflow Stage 1: AI-Powered Requirement Analysis
Analyzes new issues using AI and determines development readiness
"""

import os
import sys
import json
import requests
import traceback

# Add the current directory to Python path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from ai_requirement_analyzer import AIRequirementAnalyzer

def main():
    """Main analysis function using AI-powered analyzer"""
    
    try:
        # Get environment variables
        issue_title = os.environ.get('ISSUE_TITLE', '')
        issue_body = os.environ.get('ISSUE_BODY', '')
        issue_number = os.environ.get('ISSUE_NUMBER', '')
        repo_name = os.environ.get('REPO_NAME', '')
        github_token = os.environ.get('GITHUB_TOKEN', '')
        
        print(f"🧠 Starting AI-powered requirement analysis")
        print(f"📋 Issue: {issue_title}")
        print(f"📊 Issue #{issue_number} in {repo_name}")
        
        # Initialize AI analyzer
        analyzer = AIRequirementAnalyzer()
        
        # Perform comprehensive AI analysis
        analysis = analyzer.analyze_requirement(issue_title, issue_body)
        
        print(f"📊 AI Analysis Results:")
        print(f"  Auto Dev Ready: {analysis.auto_dev_ready}")
        print(f"  Needs Clarification: {analysis.needs_clarification}")
        print(f"  Confidence Score: {analysis.confidence_score:.2f}")
        print(f"  Complexity: {analysis.development_feasibility.get('complexity_assessment', 'unknown')}")
        
        # Create GitHub API headers
        headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
        
        if analysis.needs_clarification:
            print("🔍 AI determined that clarification is needed")
            
            # Add discussing-requirements label
            label_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels'
            label_response = requests.post(label_url, headers=headers, json={'labels': ['discussing-requirements']})
            
            if label_response.status_code == 200:
                print("✅ Added discussing-requirements label")
            else:
                print(f"⚠️ Failed to add label: {label_response.status_code}")
            
            # Generate and post clarification comment
            comment_body = analyzer.generate_analysis_comment(analysis, issue_title)
            
            comment_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/comments'
            comment_response = requests.post(comment_url, headers=headers, json={'body': comment_body})
            
            if comment_response.status_code == 201:
                print("✅ AI clarification questions posted")
            else:
                print(f"⚠️ Failed to post clarification: {comment_response.status_code}")
        
        else:
            print("✅ AI determined requirement is ready for implementation")
            
            # Add ready-for-implementation label
            label_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels'
            requests.post(label_url, headers=headers, json={'labels': ['ready-for-implementation']})
            
            # Generate and post implementation plan
            comment_body = analyzer.generate_analysis_comment(analysis, issue_title)
            
            comment_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/comments'
            requests.post(comment_url, headers=headers, json={'body': comment_body})
            
            print("✅ AI implementation plan posted")
        
        # Log Amazon Q briefing for debugging
        amazon_q_context = analysis.amazon_q_briefing
        print(f"🤖 Amazon Q Development Context:")
        print(f"  Context: {amazon_q_context.get('development_context', 'Standard development')}")
        print(f"  Requirements: {amazon_q_context.get('technical_requirements', 'OSH plugin standards')}")
        print(f"  Constraints: {amazon_q_context.get('implementation_constraints', 'Standard constraints')}")
        
        print("🎯 Stage 1 AI analysis completed successfully")
        
    except Exception as e:
        print(f"❌ AI analysis failed: {e}")
        traceback.print_exc()
        
        # Create fallback comment
        try:
            github_token = os.environ.get('GITHUB_TOKEN', '')
            repo_name = os.environ.get('REPO_NAME', '')
            issue_number = os.environ.get('ISSUE_NUMBER', '')
            
            if github_token and repo_name and issue_number:
                fallback_comment = """## 🤖 OSH AI需求分析师

感谢你创建这个Issue！我正在使用AI分析你的需求，但遇到了一些技术问题。

我们的团队会人工审查这个需求并尽快回复。

---
*🤖 由OSH需求分析系统提供 | AI分析暂时不可用*"""
                
                headers = {'Authorization': f'token {github_token}', 'Accept': 'application/vnd.github.v3+json'}
                comment_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/comments'
                requests.post(comment_url, headers=headers, json={'body': fallback_comment})
                
                print("⚠️ Posted fallback comment")
        except:
            print("❌ Failed to post fallback comment")

if __name__ == "__main__":
    main()
