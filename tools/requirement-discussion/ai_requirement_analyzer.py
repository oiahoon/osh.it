#!/usr/bin/env python3
"""
AI-Powered Requirement Analyzer
Focuses on deep technical analysis for automatic development readiness
"""

import os
import sys
import json
import logging
from typing import Dict, List, Optional
from dataclasses import dataclass

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class TechnicalAnalysis:
    """Comprehensive technical analysis result"""
    requirement_understanding: Dict
    development_feasibility: Dict
    clarification_analysis: Dict
    technical_implementation: Dict
    amazon_q_briefing: Dict
    workflow_decision: Dict
    confidence_score: float
    needs_clarification: bool
    auto_dev_ready: bool

class AIRequirementAnalyzer:
    """AI-powered requirement analyzer focused on development readiness"""
    
    def __init__(self):
        self.deepseek = None
        self._initialize_ai()
    
    def _initialize_ai(self):
        """Initialize AI integration"""
        try:
            # Try to initialize DeepSeek
            sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'auto-implementation'))
            from deepseek_integration import DeepSeekCodeGenerator
            
            self.deepseek = DeepSeekCodeGenerator()
            if self.deepseek.is_available():
                logger.info("✅ DeepSeek AI initialized for requirement analysis")
            else:
                logger.warning("⚠️ DeepSeek API not available, using fallback analysis")
                self.deepseek = None
        except Exception as e:
            logger.error(f"❌ Failed to initialize AI: {e}")
            self.deepseek = None
    
    def analyze_requirement(self, issue_title: str, issue_body: str, user_comment: str = "") -> TechnicalAnalysis:
        """Perform comprehensive AI-powered requirement analysis"""
        
        if not self.deepseek or not self.deepseek.is_available():
            return self._fallback_analysis(issue_title, issue_body, user_comment)
        
        # Create comprehensive analysis prompt
        analysis_prompt = f"""你是OSH框架的专业需求分析师和技术架构师。请对以下需求进行深度技术分析，重点评估是否满足自动开发标准。

## 需求信息
**标题**: {issue_title}
**描述**: {issue_body}
**用户补充**: {user_comment}

## 核心分析任务
请进行专业的技术需求分析，严格按照JSON格式回复（不要使用markdown包装）：

{{
    "requirement_understanding": {{
        "core_functionality": "核心功能的详细理解",
        "user_scenarios": "使用场景和用户期望",
        "technical_scope": "技术实现范围",
        "implicit_requirements": "隐含的技术需求"
    }},
    "development_feasibility": {{
        "auto_dev_ready": true/false,
        "complexity_assessment": "simple/medium/complex",
        "confidence_score": 0.85,
        "blocking_factors": ["阻碍自动开发的因素"],
        "effort_estimation": "预估开发工作量"
    }},
    "clarification_analysis": {{
        "needs_clarification": true/false,
        "critical_questions": ["关键技术澄清问题"],
        "missing_details": ["缺失的重要技术细节"],
        "ambiguous_points": ["模糊不清的需求点"]
    }},
    "technical_implementation": {{
        "architecture_design": "技术架构设计方案",
        "technology_stack": ["推荐的技术栈"],
        "core_components": ["核心组件设计"],
        "osh_integration": "与OSH框架的集成方式",
        "development_approach": ["具体开发步骤"],
        "testing_strategy": "测试和验证策略",
        "performance_considerations": "性能和优化考虑"
    }},
    "amazon_q_briefing": {{
        "development_context": "给Amazon Q Developer的完整开发上下文",
        "technical_requirements": "详细的技术要求",
        "implementation_constraints": "实现约束和限制",
        "quality_standards": "代码质量和标准要求",
        "integration_guidelines": "OSH集成指导原则"
    }},
    "workflow_decision": {{
        "should_trigger_workflow": true/false,
        "next_action": "clarification/implementation/discussion",
        "reasoning": "决策理由"
    }}
}}

## 分析标准
1. **自动开发就绪标准**:
   - 需求明确，技术路径清晰
   - 无重大技术风险或依赖
   - 符合OSH插件架构
   - 可以生成完整的技术规格

2. **置信度评分**:
   - 0.9+: 完全就绪，可立即开发
   - 0.7-0.9: 基本就绪，需少量澄清
   - 0.5-0.7: 需要重要澄清
   - <0.5: 需求不明确，需大量澄清

3. **OSH框架特点**:
   - 轻量级Zsh插件系统
   - plugins/目录结构
   - .plugin.zsh主文件
   - lib/common.zsh和lib/colors.zsh工具库
   - 环境变量配置支持

请提供专业的技术分析，确保Amazon Q Developer能够基于你的分析进行高质量的自动开发。"""
        
        try:
            logger.info("🧠 Calling DeepSeek AI for comprehensive requirement analysis...")
            
            # Call DeepSeek API
            response = self.deepseek._call_deepseek_api(analysis_prompt)
            
            if response:
                logger.info("✅ DeepSeek analysis completed successfully")
                
                # Clean and parse JSON response
                cleaned_response = self._clean_json_response(response)
                json_data = json.loads(cleaned_response)
                
                return self._parse_ai_response(json_data)
            else:
                logger.warning("⚠️ DeepSeek API returned empty response")
                return self._fallback_analysis(issue_title, issue_body, user_comment)
                
        except Exception as e:
            logger.error(f"❌ AI analysis failed: {e}")
            return self._fallback_analysis(issue_title, issue_body, user_comment)
    
    def _clean_json_response(self, response: str) -> str:
        """Clean JSON response from markdown formatting"""
        # Remove markdown code blocks
        response = response.replace('```json', '').replace('```', '')
        # Remove extra whitespace
        response = response.strip()
        return response
    
    def _parse_ai_response(self, json_data: Dict) -> TechnicalAnalysis:
        """Parse AI response into structured analysis"""
        
        req_understanding = json_data.get('requirement_understanding', {})
        dev_feasibility = json_data.get('development_feasibility', {})
        clarification = json_data.get('clarification_analysis', {})
        tech_impl = json_data.get('technical_implementation', {})
        amazon_q = json_data.get('amazon_q_briefing', {})
        workflow = json_data.get('workflow_decision', {})
        
        confidence = dev_feasibility.get('confidence_score', 0.5)
        auto_ready = dev_feasibility.get('auto_dev_ready', False)
        needs_clarification = clarification.get('needs_clarification', True)
        
        return TechnicalAnalysis(
            requirement_understanding=req_understanding,
            development_feasibility=dev_feasibility,
            clarification_analysis=clarification,
            technical_implementation=tech_impl,
            amazon_q_briefing=amazon_q,
            workflow_decision=workflow,
            confidence_score=confidence,
            needs_clarification=needs_clarification,
            auto_dev_ready=auto_ready
        )
    
    def _fallback_analysis(self, issue_title: str, issue_body: str, user_comment: str) -> TechnicalAnalysis:
        """Fallback analysis when AI is not available"""
        
        # Simple rule-based analysis
        confidence = 0.6
        needs_clarification = len(issue_body) < 100 or '?' in issue_body
        auto_ready = not needs_clarification and confidence > 0.7
        
        return TechnicalAnalysis(
            requirement_understanding={
                "core_functionality": f"基于标题理解: {issue_title}",
                "user_scenarios": "标准OSH插件使用场景",
                "technical_scope": "OSH插件开发范围",
                "implicit_requirements": "符合OSH插件标准"
            },
            development_feasibility={
                "auto_dev_ready": auto_ready,
                "complexity_assessment": "medium",
                "confidence_score": confidence,
                "blocking_factors": ["需要更多技术细节"] if needs_clarification else [],
                "effort_estimation": "标准插件开发工作量"
            },
            clarification_analysis={
                "needs_clarification": needs_clarification,
                "critical_questions": [
                    "请详细描述期望的功能表现",
                    "有什么特殊的技术要求吗？",
                    "希望如何与现有OSH功能集成？"
                ] if needs_clarification else [],
                "missing_details": ["技术实现细节"] if needs_clarification else [],
                "ambiguous_points": ["功能边界"] if needs_clarification else []
            },
            technical_implementation={
                "architecture_design": "基于OSH插件系统",
                "technology_stack": ["Shell脚本", "Zsh"],
                "core_components": ["主插件文件", "配置文件"],
                "osh_integration": "标准OSH插件集成",
                "development_approach": ["创建插件结构", "实现核心功能", "添加测试"],
                "testing_strategy": "单元测试和集成测试",
                "performance_considerations": "轻量级实现"
            },
            amazon_q_briefing={
                "development_context": "OSH插件开发，基于用户需求",
                "technical_requirements": "符合OSH插件标准",
                "implementation_constraints": "轻量级，兼容Zsh",
                "quality_standards": "OSH代码质量标准",
                "integration_guidelines": "标准OSH插件集成流程"
            },
            workflow_decision={
                "should_trigger_workflow": not needs_clarification,
                "next_action": "clarification" if needs_clarification else "implementation",
                "reasoning": "基于需求清晰度评估"
            },
            confidence_score=confidence,
            needs_clarification=needs_clarification,
            auto_dev_ready=auto_ready
        )
    
    def generate_analysis_comment(self, analysis: TechnicalAnalysis, issue_title: str) -> str:
        """Generate user-facing analysis comment"""
        
        if analysis.needs_clarification:
            # Generate clarification request
            questions = analysis.clarification_analysis.get('critical_questions', [])
            questions_text = '\n'.join([f"{i+1}. {q}" for i, q in enumerate(questions)])
            
            return f"""## 🤖 OSH AI需求分析师

我已经使用AI深度分析了你的需求，为了确保自动开发的质量，需要澄清一些关键技术点：

### 📋 需求理解
**核心功能**: {analysis.requirement_understanding.get('core_functionality', '待分析')}
**使用场景**: {analysis.requirement_understanding.get('user_scenarios', '待明确')}
**技术范围**: {analysis.requirement_understanding.get('technical_scope', '待确定')}

**开发可行性**: {'✅ 满足自动开发标准' if analysis.auto_dev_ready else '⚠️ 需要澄清后评估'}
**复杂度评估**: {analysis.development_feasibility.get('complexity_assessment', 'medium')}
**置信度**: {analysis.confidence_score:.2f}/1.0

### ❓ 关键澄清问题
{questions_text}

### 🔄 下一步
请详细回复上述问题，我会基于你的澄清生成完整的技术实现方案，并为Amazon Q Developer提供精确的开发上下文。

---
*🧠 由OSH AI需求分析师提供 | AI深度分析 | 阶段: 需求澄清 (1/4)*"""
        
        else:
            # Generate implementation-ready response
            tech_impl = analysis.technical_implementation
            amazon_q = analysis.amazon_q_briefing
            
            return f"""## 🎯 OSH AI需求分析师 - AI技术分析

基于AI深度分析，你的需求已满足自动开发标准！

### 📋 需求理解
**核心功能**: {analysis.requirement_understanding.get('core_functionality', '已分析')}
**使用场景**: {analysis.requirement_understanding.get('user_scenarios', '已明确')}
**技术范围**: {analysis.requirement_understanding.get('technical_scope', '已确定')}

### 🔧 技术实现分析
**架构设计**: {tech_impl.get('architecture_design', '基于OSH插件系统')}
**技术栈**: {', '.join(tech_impl.get('technology_stack', ['Shell脚本']))}
**核心组件**: {', '.join(tech_impl.get('core_components', ['主插件文件']))}
**集成方式**: {tech_impl.get('osh_integration', 'OSH标准集成')}
**开发方法**: {', '.join(tech_impl.get('development_approach', ['标准开发流程']))}

### 🤖 Amazon Q开发准备
**开发上下文**: {amazon_q.get('development_context', '完整的技术需求已准备就绪')}
**技术要求**: {amazon_q.get('technical_requirements', '符合OSH插件标准')}
**实现约束**: {amazon_q.get('implementation_constraints', '遵循OSH插件标准')}
**质量标准**: {amazon_q.get('quality_standards', 'OSH代码质量标准')}

### ✅ 确认自动开发
如果你同意这个基于AI分析的技术方案，请回复 **"可以开发了"** 来触发Amazon Q Developer自动实现。

---
*🧠 由OSH AI需求分析师提供 | AI深度技术分析 | 置信度: {analysis.confidence_score:.2f} | 阶段: 开发就绪 (3/4)*"""

def main():
    """Test the AI requirement analyzer"""
    
    analyzer = AIRequirementAnalyzer()
    
    # Test analysis
    issue_title = "[FEATURE] 实现一个查询股市行情的插件"
    issue_body = "希望能查询股票价格，支持时间范围查询，使用免费API"
    
    analysis = analyzer.analyze_requirement(issue_title, issue_body)
    
    print("🧪 AI Requirement Analysis Test")
    print("=" * 50)
    print(f"Auto Dev Ready: {analysis.auto_dev_ready}")
    print(f"Needs Clarification: {analysis.needs_clarification}")
    print(f"Confidence: {analysis.confidence_score:.2f}")
    
    comment = analyzer.generate_analysis_comment(analysis, issue_title)
    print(f"\n💬 Generated Comment Preview:")
    print(comment[:300] + "...")

if __name__ == "__main__":
    main()
