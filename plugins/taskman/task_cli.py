#!/usr/bin/env python3
"""
Terminal Task Manager CLI - Command-line interface with vintage OSH styling

This module provides command-line access to the task management system
with beautiful vintage colors matching the OSH theme.
"""

import argparse
import json
import os
import sys
from datetime import datetime, timezone
from typing import List, Dict, Optional

# Vintage color codes matching OSH theme
class VintageColors:
    # Vintage gradient colors (256-color palette)
    VINTAGE_RED = "\033[38;5;124m"      # Dark red
    VINTAGE_ORANGE = "\033[38;5;130m"   # Dark orange
    VINTAGE_YELLOW = "\033[38;5;136m"   # Muted yellow-orange
    VINTAGE_OLIVE = "\033[38;5;142m"    # Olive yellow
    VINTAGE_GREEN = "\033[38;5;64m"     # Forest green
    VINTAGE_TEAL = "\033[38;5;66m"      # Dark teal
    VINTAGE_BLUE = "\033[38;5;68m"      # Muted blue
    VINTAGE_PURPLE = "\033[38;5;97m"    # Muted purple
    VINTAGE_MAGENTA = "\033[38;5;95m"   # Dark magenta
    
    # UI colors
    ACCENT = "\033[1;36m"               # Bright cyan for accents
    SUCCESS = "\033[1;32m"              # Bright green for success
    WARNING = "\033[1;33m"              # Bright yellow for warnings
    ERROR = "\033[1;31m"                # Bright red for errors
    DIM = "\033[2m"                     # Dimmed text
    BOLD = "\033[1m"                    # Bold text
    RESET = "\033[0m"                   # Reset colors

def humanize_time_delta(created_at: str) -> str:
    """Convert ISO timestamp to human-readable time delta using local timezone"""
    try:
        created = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
        if created.tzinfo is None:
            created = created.replace(tzinfo=timezone.utc).astimezone()
        else:
            created = created.astimezone()

        now = datetime.now().astimezone()
        delta = now - created

        days = delta.days
        hours = delta.seconds // 3600
        minutes = (delta.seconds % 3600) // 60

        if days > 0:
            return f"{days}d"
        elif hours > 0:
            return f"{hours}h"
        elif minutes > 0:
            return f"{minutes}m"
        else:
            return "now"
    except:
        return "?"

# Import the Task and TaskManager classes from task_manager.py
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from task_manager import Task, TaskManager

class TaskCLI:
    def __init__(self):
        # Load configuration and determine data directory
        self.config = self._load_config()
        data_dir = self.config.get('data_directory', os.path.expanduser('~/.taskman'))
        
        # Initialize task manager with configured data directory
        self.task_manager = TaskManager(data_file=os.path.join(data_dir, 'tasks.json'))
    
    def _load_config(self):
        """Load configuration from config file"""
        config_file = os.path.expanduser('~/.taskman/config.json')
        
        if os.path.exists(config_file):
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass
        
        # Return default configuration
        return {
            'data_directory': os.path.expanduser('~/.taskman'),
            'vintage_mode': True,
            'dino_animation': True,
            'auto_save': True,
            'default_priority': 'normal',
            'date_format': 'relative'
        }

    def add_task(self, text: str, priority: str = "normal"):
        """Add a new task via CLI"""
        task = self.task_manager.add_task(text, priority)
        return task

    def list_tasks(self, filter_type: str = "all"):
        """List tasks with vintage OSH colors and styling"""
        tasks = self.task_manager.tasks

        if filter_type == "pending":
            tasks = [t for t in tasks if not t.completed]
        elif filter_type == "completed":
            tasks = [t for t in tasks if t.completed]

        if not tasks:
            if filter_type == "all":
                print(f"{VintageColors.WARNING}No tasks found. Add your first task with: tasks add 'task description'{VintageColors.RESET}")
            else:
                print(f"{VintageColors.WARNING}No {filter_type} tasks found.{VintageColors.RESET}")
            return

        # Vintage header
        print(f"{VintageColors.BOLD}{filter_type.title()} Tasks (Sort: {self.task_manager.sort_mode}):{VintageColors.RESET}")
        print()

        # Track if we need to show separator
        completed_separator_shown = False

        for task in tasks:
            # Show vintage separator before first completed task
            if not completed_separator_shown and task.completed and any(not t.completed for t in tasks):
                separator = "─" * 60
                print(f"{VintageColors.DIM}{separator}{VintageColors.RESET}")
                completed_separator_shown = True

            # Get humanized time
            time_str = humanize_time_delta(task.created_at)

            # Vintage status and priority icons
            status_icon = "✓" if task.completed else "◯"
            priority_icons = {"high": "◆", "normal": "◇", "low": "◦"}
            priority_icon = priority_icons.get(task.priority, "◇")

            # Vintage color scheme based on priority
            if task.completed:
                bullet_color = VintageColors.SUCCESS  # Green for completed bullet
                if task.priority == "high":
                    text_color = VintageColors.VINTAGE_RED + VintageColors.DIM
                elif task.priority == "low":
                    text_color = VintageColors.VINTAGE_TEAL + VintageColors.DIM
                else:
                    text_color = VintageColors.VINTAGE_YELLOW + VintageColors.DIM
            else:
                # Active tasks with vintage colors
                if task.priority == "high":
                    bullet_color = VintageColors.VINTAGE_RED
                    text_color = VintageColors.VINTAGE_RED
                elif task.priority == "low":
                    bullet_color = VintageColors.VINTAGE_TEAL
                    text_color = VintageColors.VINTAGE_TEAL
                else:
                    bullet_color = VintageColors.VINTAGE_YELLOW
                    text_color = VintageColors.VINTAGE_YELLOW

            # Format task line with vintage styling
            timer_part = f"{VintageColors.DIM}[{time_str:>3}]{VintageColors.RESET}"
            bullet_part = f"{bullet_color} {status_icon} [{priority_icon}]{VintageColors.RESET}"
            text_part = f"{text_color} (ID: {task.id}) {task.text}{VintageColors.RESET}"
            task_line = timer_part + bullet_part + text_part
            print(task_line)

        print()
        pending_count = len([t for t in self.task_manager.tasks if not t.completed])
        completed_count = len([t for t in self.task_manager.tasks if t.completed])
        stats_text = f"Total: {len(tasks)} tasks | Pending: {pending_count}, Completed: {completed_count}"
        print(f"{VintageColors.DIM}{stats_text}{VintageColors.RESET}")

    def complete_task(self, task_id: str):
        """Mark a task as completed"""
        try:
            task_id_int = int(task_id)
        except ValueError:
            print(f"\033[31mError: Invalid task ID '{task_id}'. Must be a number.\033[0m")
            return False

        task = next((t for t in self.task_manager.tasks if t.id == task_id_int), None)
        if not task:
            print(f"\033[31mError: Task with ID {task_id_int} not found.\033[0m")
            return False

        if task.completed:
            print(f"\033[33mTask '{task.text}' is already completed.\033[0m")
            return True

        self.task_manager.toggle_task(task_id_int)
        print(f"\033[32m✓ Completed task: {task.text}\033[0m")
        return True

    def delete_task(self, task_id: str):
        """Delete a task"""
        try:
            task_id_int = int(task_id)
        except ValueError:
            print(f"\033[31mError: Invalid task ID '{task_id}'. Must be a number.\033[0m")
            return False

        task = next((t for t in self.task_manager.tasks if t.id == task_id_int), None)
        if not task:
            print(f"\033[31mError: Task with ID {task_id_int} not found.\033[0m")
            return False

        task_text = task.text
        self.task_manager.delete_task(task_id_int)
        print(f"\033[31m× Deleted task: {task_text}\033[0m")
        return True

    def set_sort_mode(self, mode: str):
        """Set sorting mode"""
        if mode in ["default", "priority", "alphabetical"]:
            self.task_manager.set_sort_mode(mode)
            print(f"\033[32m✓ Sort mode set to: {mode}\033[0m")
            return True
        else:
            print(f"\033[31mError: Invalid sort mode '{mode}'. Use: default, priority, alphabetical\033[0m")
            return False

    def count_tasks(self, filter_type: str = "all"):
        """Count tasks by type. If filter_type is 'all_json', print a JSON object with all counts."""
        tasks = self.task_manager.tasks

        if filter_type == "all_json":
            pending_count = len([t for t in tasks if not t.completed])
            completed_count = len([t for t in tasks if t.completed])
            print(json.dumps({"pending": pending_count, "completed": completed_count}))
            return

        if filter_type == "pending":
            count = len([t for t in tasks if not t.completed])
        elif filter_type == "completed":
            count = len([t for t in tasks if t.completed])
        else:
            count = len(tasks)

        print(count)
        return count

def main():
    """Main CLI entry point"""
    if len(sys.argv) < 2:
        print("Usage: task_cli.py <command> [args...]")
        sys.exit(1)

    cli = TaskCLI()
    command = sys.argv[1].lower()

    try:
        if command == "add":
            if len(sys.argv) < 3:
                print("\033[31mError: Please provide task description\033[0m")
                sys.exit(1)

            text = sys.argv[2]
            priority = sys.argv[3] if len(sys.argv) > 3 else "normal"

            # Validate priority
            if priority not in ["high", "normal", "low"]:
                print(f"\033[33mWarning: Invalid priority '{priority}', using 'normal'\033[0m")
                priority = "normal"

            cli.add_task(text, priority)

        elif command == "list":
            filter_type = sys.argv[2] if len(sys.argv) > 2 else "all"
            if filter_type not in ["all", "pending", "completed"]:
                print(f"\033[33mWarning: Invalid filter '{filter_type}', using 'all'\033[0m")
                filter_type = "all"
            cli.list_tasks(filter_type)

        elif command == "complete":
            if len(sys.argv) < 3:
                print("\033[31mError: Please provide task ID\033[0m")
                sys.exit(1)
            cli.complete_task(sys.argv[2])

        elif command == "delete":
            if len(sys.argv) < 3:
                print("\033[31mError: Please provide task ID\033[0m")
                sys.exit(1)
            cli.delete_task(sys.argv[2])

        elif command == "sort":
            if len(sys.argv) < 3:
                print("\033[31mError: Please provide sort mode (default, priority, alphabetical)\033[0m")
                sys.exit(1)
            cli.set_sort_mode(sys.argv[2])

        elif command == "count":
            filter_type = sys.argv[2] if len(sys.argv) > 2 else "all"
            cli.count_tasks(filter_type)

        else:
            print(f"\033[31mError: Unknown command '{command}'\033[0m")
            print("Available commands: add, list, complete, delete, sort, count")
            sys.exit(1)

    except Exception as e:
        print(f"\033[31mError: {e}\033[0m")
        sys.exit(1)

if __name__ == "__main__":
    main()

