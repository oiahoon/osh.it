#!/usr/bin/env python3
"""
Code Quality Checker for OSH Pull Requests
Performs comprehensive code quality checks on merged PRs
"""

import os
import sys
import subprocess
import json
import requests
import traceback
from typing import Dict, List, Optional

def get_environment_variables():
    """Get required environment variables"""
    return {
        'github_token': os.environ.get('GITHUB_TOKEN', ''),
        'pr_number': os.environ.get('PR_NUMBER', ''),
        'repo_name': os.environ.get('REPO_NAME', ''),
    }

def run_shell_script_linting() -> Dict:
    """Run shell script linting checks"""
    
    print("🔍 Running shell script linting...")
    
    results = {
        'passed': True,
        'issues': [],
        'files_checked': 0
    }
    
    try:
        # Find all shell script files
        find_cmd = ['find', '.', '-name', '*.sh', '-o', '-name', '*.zsh', '-o', '-name', '*.plugin.zsh']
        result = subprocess.run(find_cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            shell_files = [f.strip() for f in result.stdout.split('\n') if f.strip()]
            results['files_checked'] = len(shell_files)
            
            print(f"  Found {len(shell_files)} shell script files")
            
            # Check if shellcheck is available
            shellcheck_available = subprocess.run(['which', 'shellcheck'], 
                                                capture_output=True).returncode == 0
            
            if shellcheck_available:
                print("  Using shellcheck for linting")
                for file_path in shell_files[:5]:  # Limit to first 5 files to avoid timeout
                    try:
                        shellcheck_result = subprocess.run(
                            ['shellcheck', '-f', 'json', file_path],
                            capture_output=True, text=True, timeout=30
                        )
                        
                        if shellcheck_result.returncode != 0 and shellcheck_result.stdout:
                            try:
                                issues = json.loads(shellcheck_result.stdout)
                                for issue in issues:
                                    results['issues'].append({
                                        'file': file_path,
                                        'line': issue.get('line', 0),
                                        'level': issue.get('level', 'info'),
                                        'message': issue.get('message', 'Unknown issue')
                                    })
                            except json.JSONDecodeError:
                                results['issues'].append({
                                    'file': file_path,
                                    'line': 0,
                                    'level': 'warning',
                                    'message': 'Shellcheck parsing error'
                                })
                    except subprocess.TimeoutExpired:
                        results['issues'].append({
                            'file': file_path,
                            'line': 0,
                            'level': 'warning',
                            'message': 'Shellcheck timeout'
                        })
            else:
                print("  Shellcheck not available, performing basic checks")
                # Basic shell script checks
                for file_path in shell_files[:10]:  # Check first 10 files
                    try:
                        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                            content = f.read()
                            
                        # Basic syntax checks
                        if not content.startswith('#!'):
                            results['issues'].append({
                                'file': file_path,
                                'line': 1,
                                'level': 'warning',
                                'message': 'Missing shebang line'
                            })
                        
                        # Check for common issues
                        lines = content.split('\n')
                        for i, line in enumerate(lines, 1):
                            if 'rm -rf /' in line:
                                results['issues'].append({
                                    'file': file_path,
                                    'line': i,
                                    'level': 'error',
                                    'message': 'Dangerous rm command detected'
                                })
                    except Exception as e:
                        results['issues'].append({
                            'file': file_path,
                            'line': 0,
                            'level': 'warning',
                            'message': f'File read error: {str(e)}'
                        })
        
        # Determine if checks passed
        error_count = len([issue for issue in results['issues'] if issue['level'] == 'error'])
        results['passed'] = error_count == 0
        
        print(f"  Shell linting completed: {len(results['issues'])} issues found")
        
    except Exception as e:
        print(f"  Shell linting failed: {e}")
        results['passed'] = False
        results['issues'].append({
            'file': 'system',
            'line': 0,
            'level': 'error',
            'message': f'Linting system error: {str(e)}'
        })
    
    return results

def run_osh_plugin_validation() -> Dict:
    """Validate OSH plugin structure and standards"""
    
    print("🔍 Running OSH plugin validation...")
    
    results = {
        'passed': True,
        'issues': [],
        'plugins_checked': 0
    }
    
    try:
        # Find plugin files
        plugin_files = []
        if os.path.exists('plugins'):
            for root, dirs, files in os.walk('plugins'):
                for file in files:
                    if file.endswith('.plugin.zsh'):
                        plugin_files.append(os.path.join(root, file))
        
        results['plugins_checked'] = len(plugin_files)
        print(f"  Found {len(plugin_files)} OSH plugin files")
        
        for plugin_file in plugin_files:
            try:
                with open(plugin_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Check plugin structure
                if not content.strip():
                    results['issues'].append({
                        'file': plugin_file,
                        'line': 1,
                        'level': 'error',
                        'message': 'Empty plugin file'
                    })
                    continue
                
                # Check for required shebang
                if not content.startswith('#!/bin/zsh') and not content.startswith('#!/usr/bin/env zsh'):
                    results['issues'].append({
                        'file': plugin_file,
                        'line': 1,
                        'level': 'warning',
                        'message': 'Plugin should start with zsh shebang'
                    })
                
                # Check for plugin documentation
                if '# Plugin:' not in content and '## ' not in content:
                    results['issues'].append({
                        'file': plugin_file,
                        'line': 1,
                        'level': 'info',
                        'message': 'Plugin lacks documentation comments'
                    })
                
                # Check for function definitions
                if 'function ' not in content and '() {' not in content:
                    results['issues'].append({
                        'file': plugin_file,
                        'line': 1,
                        'level': 'warning',
                        'message': 'Plugin contains no function definitions'
                    })
                
            except Exception as e:
                results['issues'].append({
                    'file': plugin_file,
                    'line': 0,
                    'level': 'error',
                    'message': f'Plugin validation error: {str(e)}'
                })
        
        # Determine if validation passed
        error_count = len([issue for issue in results['issues'] if issue['level'] == 'error'])
        results['passed'] = error_count == 0
        
        print(f"  OSH plugin validation completed: {len(results['issues'])} issues found")
        
    except Exception as e:
        print(f"  OSH plugin validation failed: {e}")
        results['passed'] = False
        results['issues'].append({
            'file': 'system',
            'line': 0,
            'level': 'error',
            'message': f'Plugin validation system error: {str(e)}'
        })
    
    return results

def run_general_code_quality_checks() -> Dict:
    """Run general code quality checks"""
    
    print("🔍 Running general code quality checks...")
    
    results = {
        'passed': True,
        'issues': [],
        'files_checked': 0
    }
    
    try:
        # Check for common code quality issues
        code_files = []
        
        # Find various code files
        for ext in ['*.py', '*.sh', '*.zsh', '*.js', '*.md']:
            find_cmd = ['find', '.', '-name', ext, '-not', '-path', './.git/*']
            result = subprocess.run(find_cmd, capture_output=True, text=True)
            if result.returncode == 0:
                code_files.extend([f.strip() for f in result.stdout.split('\n') if f.strip()])
        
        results['files_checked'] = len(code_files)
        print(f"  Checking {len(code_files)} code files")
        
        # Basic quality checks
        for file_path in code_files[:20]:  # Limit to first 20 files
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                
                # Check file size (warn if > 1MB)
                if len(content) > 1024 * 1024:
                    results['issues'].append({
                        'file': file_path,
                        'line': 0,
                        'level': 'warning',
                        'message': 'Large file size (>1MB)'
                    })
                
                # Check for TODO/FIXME comments
                lines = content.split('\n')
                for i, line in enumerate(lines, 1):
                    line_lower = line.lower()
                    if 'todo' in line_lower or 'fixme' in line_lower:
                        results['issues'].append({
                            'file': file_path,
                            'line': i,
                            'level': 'info',
                            'message': f'TODO/FIXME comment: {line.strip()[:50]}...'
                        })
                
                # Check for potential security issues
                for i, line in enumerate(lines, 1):
                    if 'password' in line.lower() and '=' in line:
                        results['issues'].append({
                            'file': file_path,
                            'line': i,
                            'level': 'warning',
                            'message': 'Potential hardcoded password'
                        })
                    
                    if 'api_key' in line.lower() and '=' in line and 'export' not in line.lower():
                        results['issues'].append({
                            'file': file_path,
                            'line': i,
                            'level': 'warning',
                            'message': 'Potential hardcoded API key'
                        })
                
            except Exception as e:
                results['issues'].append({
                    'file': file_path,
                    'line': 0,
                    'level': 'warning',
                    'message': f'File check error: {str(e)}'
                })
        
        print(f"  General quality checks completed: {len(results['issues'])} issues found")
        
    except Exception as e:
        print(f"  General quality checks failed: {e}")
        results['passed'] = False
        results['issues'].append({
            'file': 'system',
            'line': 0,
            'level': 'error',
            'message': f'Quality check system error: {str(e)}'
        })
    
    return results

def generate_quality_report(shell_results: Dict, plugin_results: Dict, general_results: Dict) -> str:
    """Generate comprehensive quality report"""
    
    total_issues = len(shell_results['issues']) + len(plugin_results['issues']) + len(general_results['issues'])
    overall_passed = shell_results['passed'] and plugin_results['passed'] and general_results['passed']
    
    # Count issues by severity
    error_count = 0
    warning_count = 0
    info_count = 0
    
    for results in [shell_results, plugin_results, general_results]:
        for issue in results['issues']:
            if issue['level'] == 'error':
                error_count += 1
            elif issue['level'] == 'warning':
                warning_count += 1
            else:
                info_count += 1
    
    report = f"""## 🔍 OSH代码质量检查报告

### 📊 检查总结
- **总体状态**: {'✅ 通过' if overall_passed else '❌ 需要关注'}
- **检查文件**: {shell_results['files_checked'] + plugin_results['plugins_checked'] + general_results['files_checked']} 个
- **发现问题**: {total_issues} 个
  - 🔴 错误: {error_count} 个
  - 🟡 警告: {warning_count} 个
  - 🔵 信息: {info_count} 个

### 🐚 Shell脚本检查
- **文件数量**: {shell_results['files_checked']} 个
- **问题数量**: {len(shell_results['issues'])} 个
- **状态**: {'✅ 通过' if shell_results['passed'] else '❌ 有问题'}

### 🔌 OSH插件验证
- **插件数量**: {plugin_results['plugins_checked']} 个
- **问题数量**: {len(plugin_results['issues'])} 个
- **状态**: {'✅ 通过' if plugin_results['passed'] else '❌ 有问题'}

### 📝 通用代码质量
- **文件数量**: {general_results['files_checked']} 个
- **问题数量**: {len(general_results['issues'])} 个
- **状态**: {'✅ 通过' if general_results['passed'] else '❌ 有问题'}
"""
    
    # Add detailed issues if any
    if total_issues > 0:
        report += "\n### 📋 详细问题列表\n"
        
        all_issues = []
        for results in [shell_results, plugin_results, general_results]:
            all_issues.extend(results['issues'])
        
        # Sort by severity
        severity_order = {'error': 0, 'warning': 1, 'info': 2}
        all_issues.sort(key=lambda x: (severity_order.get(x['level'], 3), x['file'], x['line']))
        
        for issue in all_issues[:20]:  # Show first 20 issues
            level_emoji = {'error': '🔴', 'warning': '🟡', 'info': '🔵'}.get(issue['level'], '⚪')
            report += f"- {level_emoji} **{issue['file']}:{issue['line']}** - {issue['message']}\n"
        
        if len(all_issues) > 20:
            report += f"\n*... 还有 {len(all_issues) - 20} 个问题未显示*\n"
    
    report += f"""
### 🎯 建议
{'🎉 代码质量良好！继续保持。' if overall_passed else '请关注上述问题，特别是错误级别的问题。'}

---
*🤖 由OSH代码质量检查器自动生成*"""
    
    return report

def post_quality_report(repo_name: str, pr_number: str, report: str, github_token: str) -> bool:
    """Post quality report as PR comment"""
    
    try:
        url = f'https://api.github.com/repos/{repo_name}/issues/{pr_number}/comments'
        headers = {
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json'
        }
        
        data = {'body': report}
        
        response = requests.post(url, headers=headers, json=data)
        
        if response.status_code == 201:
            print("✅ Quality report posted successfully")
            return True
        else:
            print(f"⚠️ Failed to post quality report: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error posting quality report: {e}")
        return False

def main():
    """Main code quality checking function"""
    
    try:
        print("🔍 Starting OSH code quality checks")
        
        # Get environment variables
        env_vars = get_environment_variables()
        
        if not all([env_vars['github_token'], env_vars['pr_number'], env_vars['repo_name']]):
            print("❌ Missing required environment variables")
            return
        
        print(f"📊 Checking PR #{env_vars['pr_number']} in {env_vars['repo_name']}")
        
        # Run all quality checks
        shell_results = run_shell_script_linting()
        plugin_results = run_osh_plugin_validation()
        general_results = run_general_code_quality_checks()
        
        # Generate comprehensive report
        report = generate_quality_report(shell_results, plugin_results, general_results)
        
        print("\n" + "="*60)
        print("📋 QUALITY REPORT PREVIEW:")
        print("="*60)
        print(report[:500] + "..." if len(report) > 500 else report)
        print("="*60)
        
        # Post report to PR
        success = post_quality_report(
            env_vars['repo_name'],
            env_vars['pr_number'],
            report,
            env_vars['github_token']
        )
        
        # Determine exit code based on results
        has_errors = any([
            any(issue['level'] == 'error' for issue in shell_results['issues']),
            any(issue['level'] == 'error' for issue in plugin_results['issues']),
            any(issue['level'] == 'error' for issue in general_results['issues'])
        ])
        
        if success:
            print("🎯 Code quality checks completed successfully")
            if has_errors:
                print("⚠️ Some errors were found, but report was posted")
                sys.exit(1)  # Exit with error code if there are errors
            else:
                print("✅ No critical issues found")
        else:
            print("⚠️ Code quality checks completed with warnings")
            sys.exit(1)
        
    except Exception as e:
        print(f"❌ Code quality checking failed: {e}")
        traceback.print_exc()
        
        # Try to post a fallback comment
        try:
            env_vars = get_environment_variables()
            if env_vars['github_token'] and env_vars['repo_name'] and env_vars['pr_number']:
                fallback_report = """## 🔍 OSH代码质量检查报告

代码质量检查遇到了技术问题，无法完成自动检查。

请手动审查代码质量，确保：
- Shell脚本语法正确
- OSH插件结构符合标准
- 无明显的代码质量问题

---
*🤖 由OSH代码质量检查器提供*"""
                
                post_quality_report(
                    env_vars['repo_name'],
                    env_vars['pr_number'],
                    fallback_report,
                    env_vars['github_token']
                )
                print("⚠️ Posted fallback quality report")
        except:
            print("❌ Failed to post fallback quality report")
        
        sys.exit(1)

if __name__ == "__main__":
    main()
