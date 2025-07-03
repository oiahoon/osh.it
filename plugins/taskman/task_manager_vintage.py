#!/usr/bin/env python3
"""
Terminal Task Manager - Vintage OSH Edition
A beautiful sidebar-style task manager with vintage colors matching OSH theme

Features:
- Vintage color scheme matching OSH sysinfo plugin
- Enhanced UI with better visual hierarchy
- Sidebar display in terminal
- Keyboard shortcuts for task operations
- Persistent task storage
- Task prioritization with vintage colors
- Configurable sorting with completed tasks at bottom
- Humanized creation timers with local timezone
- Visual separator for completed tasks
- Elegant ASCII art elements
"""

import curses
import json
import os
import random
import time
from datetime import datetime, timezone
from typing import List, Dict, Optional

# Import the separate animation module
from dino_animation import DinoAnimation

def humanize_time_delta(created_at: str) -> str:
    """Convert ISO timestamp to human-readable time delta using local timezone"""
    try:
        # Handle different timestamp formats
        if created_at.endswith('Z'):
            # UTC timestamp with Z suffix
            created = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
        elif '+' in created_at or created_at.count('-') > 2:
            # Already has timezone info
            created = datetime.fromisoformat(created_at)
        else:
            # Assume local time if no timezone info
            created = datetime.fromisoformat(created_at)
            # If no timezone info, assume it's local time
            if created.tzinfo is None:
                created = created.replace(tzinfo=datetime.now().astimezone().tzinfo)
        
        # Convert to local timezone for comparison
        if created.tzinfo is not None:
            created = created.astimezone()
        
        now = datetime.now().astimezone()
        delta = now - created

        # Handle negative deltas (future timestamps)
        if delta.total_seconds() < 0:
            return "future"

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
    except Exception as e:
        # For debugging - you can remove this in production
        return f"?({str(e)[:10]})"

class Task:
    def __init__(self, id: int, text: str, completed: bool = False, priority: str = "normal", created_at: str = None):
        self.id = id
        self.text = text
        self.completed = completed
        self.priority = priority  # "high", "normal", "low"
        # Use timezone-aware datetime to avoid timezone confusion
        self.created_at = created_at or datetime.now().astimezone().isoformat()

    def to_dict(self) -> Dict:
        return {
            "id": self.id,
            "text": self.text,
            "completed": self.completed,
            "priority": self.priority,
            "created_at": self.created_at
        }

    @classmethod
    def from_dict(cls, data: Dict) -> 'Task':
        return cls(
            id=data["id"],
            text=data["text"],
            completed=data["completed"],
            priority=data.get("priority", "normal"),
            created_at=data.get("created_at")
        )

class VintageTaskManager:
    def __init__(self, data_file: str = None):
        # Use environment variable or default path
        self.data_file = data_file or os.environ.get('TASKMAN_DATA_FILE', os.path.expanduser("~/.taskman/tasks.json"))
        self.tasks: List[Task] = []
        self.selected_index = 0
        self.next_id = 1
        self.sort_mode = "default"  # "default", "priority", "alphabetical"
        self.load_tasks()

    def load_tasks(self):
        """Load tasks from JSON file"""
        if os.path.exists(self.data_file):
            try:
                with open(self.data_file, 'r') as f:
                    data = json.load(f)
                    self.tasks = [Task.from_dict(task_data) for task_data in data.get("tasks", [])]
                    self.next_id = data.get("next_id", 1)
                    self.sort_mode = data.get("sort_mode", "default")
            except (json.JSONDecodeError, KeyError):
                self.tasks = []
                self.next_id = 1
        
        self.sort_tasks()

    def save_tasks(self):
        """Save tasks to JSON file"""
        os.makedirs(os.path.dirname(self.data_file), exist_ok=True)
        data = {
            "tasks": [task.to_dict() for task in self.tasks],
            "next_id": self.next_id,
            "sort_mode": self.sort_mode
        }
        with open(self.data_file, 'w') as f:
            json.dump(data, f, indent=2)

    def add_task(self, text: str, priority: str = "normal"):
        """Add a new task"""
        task = Task(self.next_id, text, priority=priority)
        self.tasks.append(task)
        self.next_id += 1
        self.sort_tasks()
        self.save_tasks()

    def toggle_task(self, index: int):
        """Toggle task completion status"""
        if 0 <= index < len(self.tasks):
            self.tasks[index].completed = not self.tasks[index].completed
            self.sort_tasks()
            self.save_tasks()

    def delete_task(self, index: int):
        """Delete a task"""
        if 0 <= index < len(self.tasks):
            del self.tasks[index]
            if self.selected_index >= len(self.tasks) and self.tasks:
                self.selected_index = len(self.tasks) - 1
            elif not self.tasks:
                self.selected_index = 0
            self.save_tasks()

    def sort_tasks(self):
        """Sort tasks based on current sort mode, with completed tasks always at bottom"""
        # Separate completed and pending tasks
        pending_tasks = [t for t in self.tasks if not t.completed]
        completed_tasks = [t for t in self.tasks if t.completed]
        
        # Sort pending tasks based on mode
        if self.sort_mode == "priority":
            priority_order = {"high": 0, "normal": 1, "low": 2}
            pending_tasks.sort(key=lambda t: priority_order.get(t.priority, 1))
        elif self.sort_mode == "alphabetical":
            pending_tasks.sort(key=lambda t: t.text.lower())
        # "default" keeps creation order (no additional sorting)
        
        # Sort completed tasks the same way
        if self.sort_mode == "priority":
            completed_tasks.sort(key=lambda t: priority_order.get(t.priority, 1))
        elif self.sort_mode == "alphabetical":
            completed_tasks.sort(key=lambda t: t.text.lower())
        
        # Combine: pending first, then completed
        self.tasks = pending_tasks + completed_tasks

    def cycle_sort_mode(self):
        """Cycle through sort modes"""
        modes = ["default", "priority", "alphabetical"]
        current_index = modes.index(self.sort_mode)
        self.sort_mode = modes[(current_index + 1) % len(modes)]
        self.sort_tasks()
        self.save_tasks()

class VintageTaskUI:
    def __init__(self, task_manager: VintageTaskManager):
        self.task_manager = task_manager
        self.input_mode = False
        self.input_text = ""
        self.input_priority = "normal"
        self.show_help = False
        self.dino_animation = None
        
        # 防闪烁优化
        self.last_ui_hash = None
        self.last_refresh_time = 0
        self.min_refresh_interval = 0.05  # 50ms
        self.force_refresh = False  # 强制刷新标志

    def run(self, stdscr):
        """Main application loop with vintage styling and responsive design"""
        curses.curs_set(0)  # Hide cursor
        stdscr.nodelay(1)   # Non-blocking input
        stdscr.timeout(80)  # Refresh rate

        # Check minimum terminal size
        height, width = stdscr.getmaxyx()
        if width < 60 or height < 20:
            # Show error message for too small terminal
            stdscr.clear()
            error_msg = "Terminal too small!"
            min_msg = "Minimum: 60x20"
            current_msg = f"Current: {width}x{height}"
            
            try:
                stdscr.addstr(height//2 - 1, max(0, (width - len(error_msg))//2), error_msg)
                stdscr.addstr(height//2, max(0, (width - len(min_msg))//2), min_msg)
                stdscr.addstr(height//2 + 1, max(0, (width - len(current_msg))//2), current_msg)
                stdscr.addstr(height//2 + 3, max(0, (width - 20)//2), "Resize and try again")
            except curses.error:
                pass
            stdscr.refresh()
            stdscr.getch()  # Wait for key press
            return

        # Initialize vintage color pairs
        curses.start_color()
        
        # Vintage color palette (matching OSH sysinfo)
        # Define custom colors if terminal supports it
        if curses.can_change_color():
            # Vintage colors (RGB values 0-1000)
            curses.init_color(8, 400, 200, 200)   # Dark red
            curses.init_color(9, 500, 350, 200)   # Dark orange  
            curses.init_color(10, 550, 550, 200)  # Muted yellow
            curses.init_color(11, 250, 400, 250)  # Forest green
            curses.init_color(12, 250, 400, 400)  # Dark teal
            curses.init_color(13, 300, 350, 450)  # Steel blue
            curses.init_color(14, 400, 300, 450)  # Muted purple
            curses.init_color(15, 450, 350, 400)  # Vintage magenta

        # Color pairs for vintage theme
        curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)    # Selected (inverted)
        curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)    # Completed bullet
        
        # Priority colors (vintage style)
        curses.init_pair(3, 8 if curses.can_change_color() else curses.COLOR_RED, curses.COLOR_BLACK)     # High priority (dark red)
        curses.init_pair(4, 10 if curses.can_change_color() else curses.COLOR_YELLOW, curses.COLOR_BLACK) # Normal priority (muted yellow)
        curses.init_pair(5, 12 if curses.can_change_color() else curses.COLOR_CYAN, curses.COLOR_BLACK)   # Low priority (dark teal)
        
        # UI elements
        curses.init_pair(6, curses.COLOR_WHITE, curses.COLOR_BLACK)    # Default text
        curses.init_pair(7, curses.COLOR_BLACK, curses.COLOR_WHITE)    # Input mode
        curses.init_pair(8, curses.COLOR_BLACK, curses.COLOR_BLACK)    # Hidden
        
        # Completed task colors (dimmed versions)
        curses.init_pair(9, 8 if curses.can_change_color() else curses.COLOR_RED, curses.COLOR_BLACK)     # Completed high
        curses.init_pair(10, 10 if curses.can_change_color() else curses.COLOR_YELLOW, curses.COLOR_BLACK) # Completed normal
        curses.init_pair(11, 12 if curses.can_change_color() else curses.COLOR_CYAN, curses.COLOR_BLACK)   # Completed low
        
        # Accent colors
        curses.init_pair(12, 14 if curses.can_change_color() else curses.COLOR_MAGENTA, curses.COLOR_BLACK) # Accent purple
        curses.init_pair(13, 13 if curses.can_change_color() else curses.COLOR_BLUE, curses.COLOR_BLACK)    # Accent blue
        curses.init_pair(14, 11 if curses.can_change_color() else curses.COLOR_GREEN, curses.COLOR_BLACK)   # Accent green
        
        # Help panel colors - vintage style
        curses.init_pair(15, curses.COLOR_BLACK, curses.COLOR_WHITE)    # Help background (black on white)
        curses.init_pair(16, 14 if curses.can_change_color() else curses.COLOR_MAGENTA, curses.COLOR_WHITE)  # Help headers (purple on white)
        curses.init_pair(17, 13 if curses.can_change_color() else curses.COLOR_BLUE, curses.COLOR_WHITE)     # Help accent (blue on white)

        # Initialize animation
        height, width = stdscr.getmaxyx()
        self.dino_animation = DinoAnimation(max(20, width - 4))  # Ensure minimum width

        # Main loop
        while True:
            # Check if terminal was resized
            new_height, new_width = stdscr.getmaxyx()
            if new_width < 60 or new_height < 20:
                # Handle resize to too small
                stdscr.clear()
                error_msg = "Terminal too small!"
                try:
                    stdscr.addstr(new_height//2, max(0, (new_width - len(error_msg))//2), error_msg)
                except curses.error:
                    pass
                stdscr.refresh()
                key = stdscr.getch()
                if key == ord('q'):
                    break
                continue
            
            self.draw_vintage_ui(stdscr)
            
            # Handle input
            key = stdscr.getch()
            if key == -1:  # No input
                if self.dino_animation:
                    self.dino_animation.update(self.task_manager.tasks)
                continue
                
            if self.input_mode:
                if self.handle_input_mode(key):
                    break
            else:
                if self.handle_normal_mode(key):
                    break


    def should_refresh_ui(self, tasks, width, height):
        """判断是否需要刷新UI"""
        import time
        import hashlib
        
        current_time = time.time()
        
        # 检查强制刷新标志
        if self.force_refresh:
            self.force_refresh = False
            self.last_refresh_time = current_time
            return True
        
        if current_time - self.last_refresh_time < self.min_refresh_interval:
            return False
        
        content_parts = [
            f"tasks:{len(tasks)}",
            f"completed:{sum(1 for t in tasks if t.completed)}",
            f"selected:{self.task_manager.selected_index}",
            f"size:{width}x{height}",
            f"input:{self.input_mode}",
            f"input_text:{self.input_text}",  # 添加输入文本检测
            f"input_priority:{self.input_priority}",  # 添加输入优先级检测
            f"help:{self.show_help}",
        ]
        
        # 包含任务优先级信息以检测优先级变化
        for i, task in enumerate(tasks):
            content_parts.append(f"task_{i}_priority:{task.priority}")
            content_parts.append(f"task_{i}_completed:{task.completed}")
            content_parts.append(f"task_{i}_text:{task.text[:20]}")  # 只取前20个字符避免过长
        
        if self.dino_animation and self.dino_animation.is_enabled():
            content_parts.append(f"dino:{self.dino_animation.current_mood}:{self.dino_animation.frame}")
        
        current_hash = hashlib.md5("|".join(content_parts).encode()).hexdigest()
        if current_hash == self.last_ui_hash:
            return False
        
        self.last_ui_hash = current_hash
        self.last_refresh_time = current_time
        return True

    def draw_vintage_ui(self, stdscr):
        """Draw the vintage-styled user interface"""
        height, width = stdscr.getmaxyx()
        
        if not self.should_refresh_ui(self.task_manager.tasks, width, height):
            return
        
        stdscr.clear()

        # Vintage header with decorative elements
        self.draw_vintage_header(stdscr, width)
        
        # Task statistics
        self.draw_task_stats(stdscr, width)
        
        # Check for celebration message
        if self.dino_animation and self.dino_animation.is_enabled():
            celebration = self.dino_animation.get_celebration_message(self.task_manager.tasks)
            if celebration:
                # Celebration is now integrated into the status bar
                pass
        
        # Tasks list with vintage styling
        self.draw_vintage_tasks(stdscr, height, width)
        
        # Input area
        if self.input_mode:
            self.draw_vintage_input(stdscr, height, width)
        
        # Help panel
        if self.show_help:
            self.draw_vintage_help(stdscr, height, width)
        
        # Animation is now integrated into status bar
        # (removed redundant draw_dino_animation function)
        
        # Vintage status bar with smart dino integration
        self.draw_vintage_status(stdscr, height, width)
        
        stdscr.refresh()

    def draw_vintage_header(self, stdscr, width):
        """Draw retro minimal header - clean and simple"""
        try:
            # Title on left, status on right (single line)
            title = "OSH TASKMAN"
            stdscr.addstr(0, 2, title, curses.color_pair(12) | curses.A_BOLD)
            
            # Productivity status on right side
            if width > 60 and self.dino_animation and self.dino_animation.is_enabled():
                # Get productivity status
                total_tasks = len(self.task_manager.tasks)
                completed_tasks = len([t for t in self.task_manager.tasks if t.completed])
                
                if total_tasks > 0:
                    completion_rate = completed_tasks / total_tasks
                    if completion_rate >= 0.8:
                        status = "productive"
                    elif completion_rate >= 0.5:
                        status = "focused"
                    else:
                        status = "starting"
                else:
                    status = "ready"
                
                status_text = f"🦕 {status}"
                status_x = width - len(status_text) - 2
                stdscr.addstr(0, status_x, status_text, curses.color_pair(13) | curses.A_DIM)
            
            # Simple separator line
            separator_width = width - 4
            separator = "═" * separator_width
            stdscr.addstr(1, 2, separator, curses.color_pair(13) | curses.A_DIM)
            
        except curses.error:
            pass

    def draw_task_stats(self, stdscr, width):
        """Draw minimal task statistics - clean and informative"""
        pending_count = len([t for t in self.task_manager.tasks if not t.completed])
        completed_count = len([t for t in self.task_manager.tasks if t.completed])
        
        # Responsive stats text - simple and clean
        if width >= 80:
            stats_text = f"{pending_count} active • {completed_count} complete • sorted by {self.task_manager.sort_mode}"
        elif width >= 60:
            stats_text = f"{pending_count} active • {completed_count} complete • {self.task_manager.sort_mode}"
        else:
            stats_text = f"{pending_count}A {completed_count}C {self.task_manager.sort_mode[:3]}"
        
        try:
            stdscr.addstr(3, 2, stats_text, curses.color_pair(4) | curses.A_DIM)
        except curses.error:
            pass

    def draw_vintage_tasks(self, stdscr, height, width):
        """Draw tasks with retro minimal styling - grouped and clean"""
        start_y = 5
        current_y = start_y
        max_y = height - 4  # Leave room for controls
        
        # Separate active and completed tasks
        active_tasks = [t for t in self.task_manager.tasks if not t.completed]
        completed_tasks = [t for t in self.task_manager.tasks if t.completed]
        
        # Draw ACTIVE section
        if active_tasks and current_y < max_y:
            try:
                stdscr.addstr(current_y, 2, "ACTIVE", curses.color_pair(12) | curses.A_BOLD)
                current_y += 1
            except curses.error:
                pass
            
            for i, task in enumerate(active_tasks):
                if current_y >= max_y:
                    break
                self.draw_minimal_task_line(stdscr, task, i, current_y, width, False)
                current_y += 1
        
        # Add space between sections
        if completed_tasks and current_y < max_y - 1:
            current_y += 1
            
            # Draw COMPLETED section
            try:
                stdscr.addstr(current_y, 2, "COMPLETED", curses.color_pair(12) | curses.A_BOLD)
                current_y += 1
            except curses.error:
                pass
            
            for i, task in enumerate(completed_tasks):
                if current_y >= max_y:
                    break
                task_index = len(active_tasks) + i  # Correct index for selection
                self.draw_minimal_task_line(stdscr, task, task_index, current_y, width, True)
                current_y += 1

    def draw_minimal_task_line(self, stdscr, task, index, y, width, is_completed):
        """Draw minimal task line with clean icons and layout"""
        
        # Simple priority icons
        if is_completed:
            icon = "✓"
            if task.priority == "high":
                color = curses.color_pair(3) | curses.A_DIM
            elif task.priority == "low":
                color = curses.color_pair(5) | curses.A_DIM
            else:
                color = curses.color_pair(4) | curses.A_DIM
        else:
            priority_icons = {"high": "▲", "normal": "■", "low": "▼"}
            icon = priority_icons.get(task.priority, "■")
            
            if task.priority == "high":
                color = curses.color_pair(3)  # Red
            elif task.priority == "low":
                color = curses.color_pair(5)  # Teal
            else:
                color = curses.color_pair(4)  # Yellow
        
        # Selection highlight
        if index == self.task_manager.selected_index:
            color |= curses.A_REVERSE
        
        # Time formatting
        time_ago = humanize_time_delta(task.created_at)
        if time_ago == "now":
            time_text = "now"
        elif time_ago == "future":
            time_text = "future"
        else:
            time_text = f"{time_ago} ago"
        
        # Calculate layout
        time_space = len(time_text) + 2
        icon_space = 2  # icon + space
        available_text_width = width - icon_space - time_space - 4
        
        # Truncate task text if needed
        if len(task.text) > available_text_width:
            task_text = task.text[:available_text_width-1] + "…"
        else:
            task_text = task.text
        
        try:
            # Draw icon and task text
            stdscr.addstr(y, 2, f"{icon} {task_text}", color)
            
            # Right-aligned time (if there's space)
            if width > 40:
                time_x = width - len(time_text) - 2
                stdscr.addstr(y, time_x, time_text, curses.color_pair(13) | curses.A_DIM)
                
        except curses.error:
            pass

    def draw_vintage_input(self, stdscr, height, width):
        """Draw minimal input area - clean and focused"""
        if height < 6 or width < 20:
            return
            
        input_y = height - 4
        
        try:
            # Simple input prompt
            prompt = "New Task: "
            stdscr.addstr(input_y, 2, prompt, curses.color_pair(12) | curses.A_BOLD)
            
            # Input text with cursor
            max_input_width = width - len(prompt) - 4
            display_text = self.input_text[:max_input_width] if len(self.input_text) > max_input_width else self.input_text
            stdscr.addstr(input_y, 2 + len(prompt), display_text, curses.color_pair(6))
            
            # Priority indicator on next line
            priority_icons = {"high": "▲", "normal": "■", "low": "▼"}
            priority_icon = priority_icons.get(self.input_priority, "■")
            
            if self.input_priority == "high":
                priority_color = curses.color_pair(3)
            elif self.input_priority == "low":
                priority_color = curses.color_pair(5)
            else:
                priority_color = curses.color_pair(4)
            
            priority_text = f"Priority: {priority_icon} {self.input_priority.upper()} (Tab to change)"
            if len(priority_text) <= width - 4:
                stdscr.addstr(input_y + 1, 2, "Priority: ", curses.color_pair(13) | curses.A_DIM)
                stdscr.addstr(input_y + 1, 12, priority_icon, priority_color)
                stdscr.addstr(input_y + 1, 14, f"{self.input_priority.upper()} (Tab to change)", curses.color_pair(13) | curses.A_DIM)
            else:
                # Compact version
                compact_text = f"Priority: {priority_icon} {self.input_priority.upper()}"
                stdscr.addstr(input_y + 1, 2, "Priority: ", curses.color_pair(13) | curses.A_DIM)
                stdscr.addstr(input_y + 1, 12, priority_icon, priority_color)
                stdscr.addstr(input_y + 1, 14, self.input_priority.upper(), curses.color_pair(13) | curses.A_DIM)
                
        except curses.error:
            pass
        
        curses.curs_set(1)  # Show cursor in input mode

    def draw_vintage_help(self, stdscr, height, width):
        """Draw help panel with vintage background - retro newspaper style"""
        
        # Calculate help panel dimensions
        help_width = min(72, width - 4)
        help_height = min(26, height - 4)
        help_start_x = (width - help_width) // 2
        help_start_y = (height - help_height) // 2
        
        try:
            # Draw complete background for the entire help area - fix incomplete background
            for y in range(help_start_y, help_start_y + help_height):
                if y >= 0 and y < height:
                    # Fill entire width with background color
                    bg_line = " " * help_width
                    stdscr.addstr(y, help_start_x, bg_line, curses.color_pair(15))
            
            # Vintage border - simple and elegant
            border_top = "┌" + "─" * (help_width - 2) + "┐"
            border_bottom = "└" + "─" * (help_width - 2) + "┘"
            border_side = "│"
            
            stdscr.addstr(help_start_y, help_start_x, border_top, curses.color_pair(15))
            stdscr.addstr(help_start_y + help_height - 1, help_start_x, border_bottom, curses.color_pair(15))
            
            # Side borders
            for y in range(help_start_y + 1, help_start_y + help_height - 1):
                stdscr.addstr(y, help_start_x, border_side, curses.color_pair(15))
                stdscr.addstr(y, help_start_x + help_width - 1, border_side, curses.color_pair(15))
            
            # Title with vintage styling
            title = "OSH TASKMAN HELP"
            title_x = help_start_x + (help_width - len(title)) // 2
            stdscr.addstr(help_start_y + 2, title_x, title, curses.color_pair(16) | curses.A_BOLD)
            
            # Separator
            separator = "═" * (help_width - 6)
            stdscr.addstr(help_start_y + 3, help_start_x + 3, separator, curses.color_pair(17))
            
            current_y = help_start_y + 5
            
            # Navigation section
            # Fill background for title line first
            nav_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, nav_bg_line, curses.color_pair(15))
            stdscr.addstr(current_y, help_start_x + 3, "NAVIGATION", curses.color_pair(16) | curses.A_BOLD)
            current_y += 1
            
            nav_commands = [
                "↑ / k        Move selection up",
                "↓ / j        Move selection down"
            ]
            
            for cmd in nav_commands:
                stdscr.addstr(current_y, help_start_x + 5, cmd, curses.color_pair(15))
                current_y += 1
            
            current_y += 1
            
            # Task operations section
            # Fill background for title line first
            task_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, task_bg_line, curses.color_pair(15))
            stdscr.addstr(current_y, help_start_x + 3, "TASK OPERATIONS", curses.color_pair(16) | curses.A_BOLD)
            current_y += 1
            
            task_commands = [
                "n            Create new task",
                "space        Toggle task completion", 
                "d            Delete selected task",
                "tab          Edit task priority (when selected)"
            ]
            
            for cmd in task_commands:
                stdscr.addstr(current_y, help_start_x + 5, cmd, curses.color_pair(15))
                current_y += 1
            
            current_y += 1
            
            # Sorting section
            # Fill background for title line first
            sort_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, sort_bg_line, curses.color_pair(15))
            stdscr.addstr(current_y, help_start_x + 3, "SORTING & VIEW", curses.color_pair(16) | curses.A_BOLD)
            current_y += 1
            
            sort_commands = [
                "s            Cycle through sort modes",
                "             (priority → date → alphabetical)"
            ]
            
            for cmd in sort_commands:
                stdscr.addstr(current_y, help_start_x + 5, cmd, curses.color_pair(15))
                current_y += 1
            
            current_y += 1
            
            # Priority levels section
            # Fill background for title line first
            priority_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, priority_bg_line, curses.color_pair(15))
            stdscr.addstr(current_y, help_start_x + 3, "PRIORITY LEVELS", curses.color_pair(16) | curses.A_BOLD)
            current_y += 1
            
            priority_info = [
                "▲ High       Urgent tasks",
                "■ Normal     Important tasks", 
                "▼ Low        Regular tasks",
                "✓ Done       Completed tasks"
            ]
            
            for info_text in priority_info:
                # Draw the entire line with background color first
                full_line = " " * (help_width - 6)
                stdscr.addstr(current_y, help_start_x + 3, full_line, curses.color_pair(15))
                
                # Then draw the content
                icon = info_text[0]
                text = info_text[1:]
                
                # Draw icon with emphasis
                stdscr.addstr(current_y, help_start_x + 5, icon, curses.color_pair(15) | curses.A_BOLD)
                stdscr.addstr(current_y, help_start_x + 6, text, curses.color_pair(15))
                current_y += 1
            
            current_y += 1
            
            # Other commands section - ensure background continues
            # Fill background for title line first
            title_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, title_bg_line, curses.color_pair(15))
            stdscr.addstr(current_y, help_start_x + 3, "OTHER COMMANDS", curses.color_pair(16) | curses.A_BOLD)
            current_y += 1
            
            other_commands = [
                "h            Toggle this help screen",
                "x            Toggle dino productivity assistant", 
                "q            Quit taskman"
            ]
            
            for cmd in other_commands:
                # Ensure full background coverage
                full_line = " " * (help_width - 6)
                stdscr.addstr(current_y, help_start_x + 3, full_line, curses.color_pair(15))
                stdscr.addstr(current_y, help_start_x + 5, cmd, curses.color_pair(15))
                current_y += 1
            
            # Bottom separator and tip - ensure background
            current_y += 1
            # Fill background for separator line
            sep_bg_line = " " * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, sep_bg_line, curses.color_pair(15))
            separator = "─" * (help_width - 6)
            stdscr.addstr(current_y, help_start_x + 3, separator, curses.color_pair(17))
            current_y += 1
            
            # Final tip with full background
            tip = "Press 'h' to close this help screen"
            tip_padding = (help_width - len(tip)) // 2
            full_tip_line = " " * (help_width - 2)
            stdscr.addstr(current_y, help_start_x + 1, full_tip_line, curses.color_pair(15))
            tip_x = help_start_x + tip_padding
            stdscr.addstr(current_y, tip_x, tip, curses.color_pair(17) | curses.A_DIM)
            
        except curses.error:
            pass

    def draw_vintage_status(self, stdscr, height, width):
        """Draw minimal control bar - clean and simple"""
        if height < 4:
            return
            
        control_y = height - 2
        
        # Simple separator line above controls
        try:
            separator = "─" * (width - 4)
            stdscr.addstr(control_y - 1, 2, separator, curses.color_pair(13) | curses.A_DIM)
        except curses.error:
            pass
        
        # Context-aware controls
        if self.input_mode:
            controls = "enter:save  esc:cancel  tab:priority"
        elif self.show_help:
            controls = "h:hide help  q:quit"
        else:
            # Responsive control hints
            if width >= 80:
                controls = "n:new  space:toggle  d:delete  tab:priority  s:sort  h:help  q:quit"
            elif width >= 60:
                controls = "n:new  space:toggle  d:delete  s:sort  h:help  q:quit"
            else:
                controls = "n:new  space:toggle  d:delete  q:quit"
        
        # Center the controls
        try:
            control_x = max(0, (width - len(controls)) // 2)
            stdscr.addstr(control_y, control_x, controls, curses.color_pair(13) | curses.A_DIM)
        except curses.error:
            pass

    def handle_normal_mode(self, key):
        """Handle input in normal mode"""
        if key == ord('q'):
            return True
        elif key == ord('n'):
            self.input_mode = True
            self.input_text = ""
            self.input_priority = "normal"
        elif key == ord(' '):
            if self.task_manager.tasks:
                self.task_manager.toggle_task(self.task_manager.selected_index)
        elif key == ord('d'):
            if self.task_manager.tasks:
                self.task_manager.delete_task(self.task_manager.selected_index)
        elif key == ord('s'):
            self.task_manager.cycle_sort_mode()
        elif key == ord('p'):
            self.task_manager.sort_mode = "priority"
            self.task_manager.sort_tasks()
            self.task_manager.save_tasks()
        elif key == ord('a'):
            self.task_manager.sort_mode = "alphabetical"
            self.task_manager.sort_tasks()
            self.task_manager.save_tasks()
        elif key == 9:  # TAB key
            # 循环切换选中任务的优先级
            if self.task_manager.tasks:
                selected_task = self.task_manager.tasks[self.task_manager.selected_index]
                if selected_task.priority == 'low':
                    selected_task.priority = 'normal'
                elif selected_task.priority == 'normal':
                    selected_task.priority = 'high'
                else:  # high
                    selected_task.priority = 'low'
                self.task_manager.save_tasks()
                # 强制刷新UI以立即显示优先级变化
                self.force_refresh = True
        elif key == ord('h'):
            self.show_help = not self.show_help
        elif key == ord('x'):
            if self.dino_animation:
                self.dino_animation.toggle_animation()
        elif key == curses.KEY_UP or key == ord('k'):
            if self.task_manager.tasks and self.task_manager.selected_index > 0:
                self.task_manager.selected_index -= 1
        elif key == curses.KEY_DOWN or key == ord('j'):
            if self.task_manager.tasks and self.task_manager.selected_index < len(self.task_manager.tasks) - 1:
                self.task_manager.selected_index += 1
        
        return False

    def handle_input_mode(self, key):
        """Handle input in input mode"""
        refresh_needed = False
        
        if key == 27:  # Escape
            self.input_mode = False
            curses.curs_set(0)
            refresh_needed = True
        elif key == ord('\n') or key == ord('\r'):  # Enter
            if self.input_text.strip():
                self.task_manager.add_task(self.input_text.strip(), self.input_priority)
                self.input_mode = False
                curses.curs_set(0)
                refresh_needed = True
        elif key == ord('\t'):  # Tab - cycle priority
            priorities = ["normal", "high", "low"]
            current_index = priorities.index(self.input_priority)
            self.input_priority = priorities[(current_index + 1) % len(priorities)]
            refresh_needed = True
        elif key == curses.KEY_BACKSPACE or key == 127:
            self.input_text = self.input_text[:-1]
            refresh_needed = True
        elif 32 <= key <= 126:  # Printable characters
            self.input_text += chr(key)
            refresh_needed = True
        
        # Force refresh when in input mode to show typing immediately
        if refresh_needed:
            self.last_ui_state = None  # Force UI refresh
        
        return False

def main():
    """Main entry point with minimal curses checking"""
    task_manager = VintageTaskManager()
    ui = VintageTaskUI(task_manager)
    
    try:
        curses.wrapper(ui.run)
    except KeyboardInterrupt:
        pass
    except Exception as e:
        # Only show error message if it's a curses-related issue
        if "cbreak" in str(e) or "curses" in str(e).lower():
            print("⚠️  Taskman UI requires an interactive terminal")
            print("💡 Try running in a proper terminal application")
            print("📋 Or use CLI mode: tasks add, tasks list, tasks complete, etc.")
        else:
            print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
