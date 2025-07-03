#!/usr/bin/env python3
"""
Workflow Stage 2: AI-Powered Multi-turn Clarification
Processes user responses and determines if ready for implementation
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
    """Main clarification processing function using AI"""
    
    try:
        # Get environment variables
        issue_title = os.environ.get('ISSUE_TITLE', '')
        issue_body = os.environ.get('ISSUE_BODY', '')
        comment_body = os.environ.get('COMMENT_BODY', '')
        issue_number = os.environ.get('ISSUE_NUMBER', '')
        repo_name = os.environ.get('REPO_NAME', '')
        github_token = os.environ.get('GITHUB_TOKEN', '')
        
        print('💬 Processing user clarification response with AI')
        print(f'📊 Issue #{issue_number}: {issue_title}')
        print(f'📝 User clarification length: {len(comment_body)} characters')
        
        # Initialize AI analyzer
        analyzer = AIRequirementAnalyzer()
        
        # Analyze the clarified requirement (original + user clarification)
        full_context = f"{issue_body}\n\n用户澄清: {comment_body}"
        analysis = analyzer.analyze_requirement(issue_title, full_context, comment_body)
        
        print(f'🔍 AI Analysis Results:')
        print(f'  Auto Dev Ready: {analysis.auto_dev_ready}')
        print(f'  Needs More Clarification: {analysis.needs_clarification}')
        print(f'  Confidence Score: {analysis.confidence_score:.2f}')
        print(f'  Complexity: {analysis.development_feasibility.get("complexity_assessment", "unknown")}')
        
        # Create GitHub API headers
        headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
        
        if analysis.auto_dev_ready and analysis.confidence_score >= 0.8:
            print('✅ AI determined requirement is ready for implementation')
            
            # Remove discussing-requirements label
            try:
                label_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels/discussing-requirements'
                requests.delete(label_url, headers=headers)
                print("✅ Removed discussing-requirements label")
            except:
                print("⚠️ Could not remove discussing-requirements label")
            
            # Add ready-for-implementation label
            label_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/labels'
            label_response = requests.post(label_url, headers=headers, json={'labels': ['ready-for-implementation']})
            
            if label_response.status_code == 200:
                print("✅ Added ready-for-implementation label")
            else:
                print(f"⚠️ Failed to add label: {label_response.status_code}")
            
            # Generate implementation-ready comment
            comment_body = generate_implementation_ready_comment(analysis, issue_title, comment_body)
            
        elif analysis.needs_clarification:
            print('🔄 AI determined more clarification is needed')
            
            # Generate follow-up clarification comment
            comment_body = generate_followup_clarification_comment(analysis, issue_title, comment_body)
            
        else:
            print('⚠️ Unclear analysis result, generating general response')
            
            # Generate general response
            comment_body = generate_general_response_comment(analysis, issue_title, comment_body)
        
        # Post the comment
        comment_url = f'https://api.github.com/repos/{repo_name}/issues/{issue_number}/comments'
        response = requests.post(comment_url, headers=headers, json={'body': comment_body})
        
        if response.status_code == 201:
            print('✅ AI analysis response posted')
        else:
            print(f'⚠️ Failed to post response: {response.status_code}')
        
        # Log Amazon Q briefing for debugging
        if analysis.auto_dev_ready:
            amazon_q_context = analysis.amazon_q_briefing
            print(f"🤖 Amazon Q Development Context:")
            print(f"  Context: {amazon_q_context.get('development_context', 'Standard development')}")
            print(f"  Requirements: {amazon_q_context.get('technical_requirements', 'OSH plugin standards')}")
        
        print("🎯 Stage 2 AI clarification processing completed successfully")
        
    except Exception as e:
        print(f"❌ AI clarification processing failed: {e}")
        traceback.print_exc()

def generate_implementation_ready_comment(analysis, issue_title: str, user_clarification: str) -> str:
    """Generate implementation-ready comment based on AI analysis"""
    
    req_understanding = analysis.requirement_understanding
    tech_impl = analysis.technical_implementation
    amazon_q = analysis.amazon_q_briefing
    
    return f"""## 🎯 OSH AI需求分析师 - 实现方案确认

感谢你的详细澄清！基于AI深度分析，你的需求现在已经满足自动开发标准。

### 📋 最终需求理解
**核心功能**: {req_understanding.get('core_functionality', '已明确')}
**使用场景**: {req_understanding.get('user_scenarios', '已理解')}
**技术范围**: {req_understanding.get('technical_scope', '已确定')}

**用户澄清**: {user_clarification[:200]}{'...' if len(user_clarification) > 200 else ''}

### 🔧 技术实现方案
**架构设计**: {tech_impl.get('architecture_design', '基于OSH插件系统')}
**技术栈**: {', '.join(tech_impl.get('technology_stack', ['Shell脚本', 'Zsh']))}
**核心组件**: {', '.join(tech_impl.get('core_components', ['主插件文件']))}
**OSH集成**: {tech_impl.get('osh_integration', 'OSH标准插件集成')}

### 🤖 Amazon Q开发准备
**开发上下文**: {amazon_q.get('development_context', '完整的技术需求已准备就绪')}
**技术要求**: {amazon_q.get('technical_requirements', '符合OSH插件标准')}
**质量标准**: {amazon_q.get('quality_standards', 'OSH代码质量标准')}

### ✅ 确认自动开发
如果你同意这个基于AI分析的完整技术方案，请回复 **"可以开发了"** 来触发Amazon Q Developer自动实现。

---
*🧠 由OSH AI需求分析师提供 | AI深度技术分析 | 置信度: {analysis.confidence_score:.2f} | 阶段: 开发就绪 (3/4)*"""

def generate_followup_clarification_comment(analysis, issue_title: str, user_response: str) -> str:
    """Generate follow-up clarification comment"""
    
    questions = analysis.clarification_analysis.get('critical_questions', [])
    questions_text = '\n'.join([f"{i+1}. {q}" for i, q in enumerate(questions)])
    
    return f"""## 🤖 OSH AI需求分析师 - 继续澄清

感谢你的回复！我已经理解了你提供的信息。

**你已经澄清的内容**: {user_response[:200]}{'...' if len(user_response) > 200 else ''}

基于AI分析，我还需要澄清一些关键技术点来确保高质量的自动开发：

### ❓ 进一步澄清问题
{questions_text}

### 🔄 下一步
请回复上述问题，我会基于完整的信息生成最终的技术实现方案。

---
*🧠 由OSH AI需求分析师提供 | AI智能分析 | 阶段: 深度澄清 (2/4)*"""

def generate_general_response_comment(analysis, issue_title: str, user_response: str) -> str:
    """Generate general response when analysis is unclear"""
    
    return f"""## 🤖 OSH AI需求分析师 - 分析中

感谢你的回复！我正在使用AI深度分析你的澄清信息。

**你的回复**: {user_response[:200]}{'...' if len(user_response) > 200 else ''}

**当前分析状态**:
- 置信度: {analysis.confidence_score:.2f}/1.0
- 复杂度: {analysis.development_feasibility.get('complexity_assessment', 'medium')}

我会继续分析并很快提供详细的技术实现方案。

---
*🧠 由OSH AI需求分析师提供 | AI分析处理中*"""

if __name__ == "__main__":
    main()
