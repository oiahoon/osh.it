#!/usr/bin/env python3
"""
Terminal Task Manager - Modern Edition
A modern, performant, and Gemini-CLI-inspired task manager.
"""

import curses
import json
import os
import time
import textwrap
from datetime import datetime, timezone
from typing import List, Dict, Optional

def humanize_time_delta(created_at: str) -> str:
    try:
        created = datetime.fromisoformat(created_at.replace('Z', '+00:00')).astimezone()
        now = datetime.now().astimezone()
        delta = now - created
        if delta.total_seconds() < 0: return "future"
        days, rem = divmod(delta.total_seconds(), 86400)
        hours, rem = divmod(rem, 3600)
        minutes, _ = divmod(rem, 60)
        if days > 0: return f"{int(days)}d"
        if hours > 0: return f"{int(hours)}h"
        if minutes > 0: return f"{int(minutes)}m"
        return "now"
    except Exception:
        return "?"

class Task:
    def __init__(self, id: int, text: str, completed: bool = False, priority: str = "normal", created_at: str = None):
        self.id = id
        self.text = text
        self.completed = completed
        self.priority = priority
        self.created_at = created_at or datetime.now().astimezone().isoformat()

    def to_dict(self) -> Dict: return self.__dict__
    @classmethod
    def from_dict(cls, data: Dict) -> 'Task': return cls(**data)

class ModernTaskManager:
    def __init__(self, data_file: str = None):
        self.data_file = data_file or os.environ.get('TASKMAN_DATA_FILE', os.path.expanduser("~/.taskman/tasks.json"))
        self.tasks: List[Task] = []
        self.selected_index = 0
        self.next_id = 1
        self.sort_mode = "default"
        self.load_tasks()

    def load_tasks(self):
        if os.path.exists(self.data_file):
            try:
                with open(self.data_file, 'r') as f:
                    data = json.load(f)
                    self.tasks = [Task.from_dict(td) for td in data.get("tasks", [])]
                    self.next_id = data.get("next_id", len(self.tasks) + 1)
                    self.sort_mode = data.get("sort_mode", "default")
            except (json.JSONDecodeError, KeyError): pass
        self.sort_tasks()

    def save_tasks(self):
        os.makedirs(os.path.dirname(self.data_file), exist_ok=True)
        with open(self.data_file, 'w') as f:
            json.dump({"tasks": [t.to_dict() for t in self.tasks], "next_id": self.next_id, "sort_mode": self.sort_mode}, f, indent=2)

    def add_task(self, text: str, priority: str = "normal"):
        self.tasks.append(Task(self.next_id, text, priority=priority))
        self.next_id += 1
        self.sort_tasks()

    def edit_task(self, index: int, new_text: str):
        if 0 <= index < len(self.tasks): self.tasks[index].text = new_text

    def toggle_task(self, index: int):
        if 0 <= index < len(self.tasks):
            self.tasks[index].completed = not self.tasks[index].completed
            self.sort_tasks()

    def delete_task(self, index: int):
        if 0 <= index < len(self.tasks):
            del self.tasks[index]
            if self.selected_index >= len(self.tasks) and self.tasks: self.selected_index = len(self.tasks) - 1
            elif not self.tasks: self.selected_index = 0

    def sort_tasks(self):
        pending = [t for t in self.tasks if not t.completed]
        completed = [t for t in self.tasks if t.completed]
        prio = {"high": 0, "normal": 1, "low": 2}
        if self.sort_mode == "priority":
            pending.sort(key=lambda t: prio.get(t.priority, 1))
            completed.sort(key=lambda t: prio.get(t.priority, 1))
        elif self.sort_mode == "alphabetical":
            pending.sort(key=lambda t: t.text.lower())
            completed.sort(key=lambda t: t.text.lower())
        self.tasks = pending + completed

    def cycle_sort_mode(self):
        modes = ["default", "priority", "alphabetical"]
        self.sort_mode = modes[(modes.index(self.sort_mode) + 1) % len(modes)]
        self.sort_tasks()

class ModernTaskUI:
    def __init__(self, task_manager: ModernTaskManager):
        self.task_manager = task_manager
        self.mode = "normal"
        self.input_text = ""
        self.cursor_pos = 0
        self.input_priority = "normal"
        self.show_help = False
        self.ui_is_dirty = True
        self.status_message = ""
        self.status_message_time = 0
        self.last_save_time = time.time()

    def set_dirty(self): self.ui_is_dirty = True
    def set_status_message(self, msg): self.status_message, self.status_message_time = msg, time.time()

    def run(self, stdscr):
        curses.curs_set(0)
        stdscr.nodelay(1)
        stdscr.timeout(100)
        self.init_colors()
        try:
            while True:
                # Auto-save logic
                if time.time() - self.last_save_time > 30:
                    self.task_manager.save_tasks()
                    self.last_save_time = time.time()
                    self.set_status_message("Auto-saved.")
                    self.set_dirty()

                if self.status_message and time.time() - self.status_message_time > 2:
                    self.status_message = ""; self.set_dirty()
                
                h, w = stdscr.getmaxyx()
                if w < 50 or h < 10:
                    self.draw_small_terminal_message(stdscr, h, w); key = stdscr.getch()
                    if key == ord('q'): break
                    continue
                
                if self.ui_is_dirty:
                    self.draw_modern_ui(stdscr)
                    self.ui_is_dirty = False
                
                key = stdscr.getch()
                if key != -1:
                    if self.mode == "normal":
                        if self.handle_normal_mode(key, h - 3): break
                    else: self.handle_panel_mode(key)
                    self.set_dirty()
        finally:
            self.task_manager.save_tasks()

    def init_colors(self):
        curses.start_color()
        curses.use_default_colors()
        curses.init_pair(1, curses.COLOR_CYAN, -1)
        curses.init_pair(2, curses.COLOR_GREEN, -1)
        curses.init_pair(3, curses.COLOR_RED, -1)
        curses.init_pair(4, curses.COLOR_YELLOW, -1)
        curses.init_pair(5, curses.COLOR_BLUE, -1)
        curses.init_pair(7, curses.COLOR_BLACK, curses.COLOR_CYAN)
        if curses.has_colors() and curses.COLORS >= 256:
            curses.init_pair(8, 242, -1)
            curses.init_pair(9, curses.COLOR_WHITE, 235)
        else:
            curses.init_pair(8, curses.COLOR_BLACK, -1)
            curses.init_pair(9, curses.COLOR_BLACK, curses.COLOR_WHITE)
        
        # Rainbow Colors for Logo
        curses.init_pair(10, curses.COLOR_RED, -1)
        curses.init_pair(11, curses.COLOR_YELLOW, -1)
        curses.init_pair(12, curses.COLOR_GREEN, -1)
        curses.init_pair(13, curses.COLOR_CYAN, -1)
        curses.init_pair(14, curses.COLOR_BLUE, -1)
        curses.init_pair(15, curses.COLOR_MAGENTA, -1)

    def safe_addstr(self, stdscr, y, x, text, attr=0):
        h, w = stdscr.getmaxyx()
        if y >= h or x >= w: return
        max_len = w - x
        if len(text) > max_len: text = text[:max_len]
        try: stdscr.addstr(y, x, text, attr)
        except curses.error: pass

    def draw_modern_ui(self, stdscr):
        stdscr.clear()
        h, w = stdscr.getmaxyx()
        self.draw_header(stdscr, w)
        self.draw_tasks(stdscr, h, w)
        if self.mode != "normal":
            self.draw_floating_panel(stdscr, h, w)
        else:
            self.draw_status_bar(stdscr, h, w)
        if self.show_help:
            self.draw_help_panel(stdscr, h, w)
        stdscr.refresh()

    def draw_header(self, stdscr, w):
        title = "◇ TASKMAN ◇"
        x = (w - len(title)) // 2
        rainbow = [10, 11, 12, 13, 14, 15]
        for i, char in enumerate(title):
            self.safe_addstr(stdscr, 0, x + i, char, curses.color_pair(rainbow[i % len(rainbow)]) | curses.A_BOLD)

    def draw_tasks(self, stdscr, h, w):
        start_y, max_y = 2, h - 2
        completed_separator_drawn = False
        y = start_y
        for i, task in enumerate(self.task_manager.tasks):
            if y >= max_y: break
            if not completed_separator_drawn and task.completed:
                if any(not t.completed for t in self.task_manager.tasks):
                    self.safe_addstr(stdscr, y, 1, "─" * (w - 2), curses.color_pair(8))
                    y += 1
                    if y >= max_y: break
                completed_separator_drawn = True
            is_selected = (i == self.task_manager.selected_index)
            line = self.format_task_line(task, w)
            color = curses.color_pair(8)
            attr = curses.A_DIM
            if hasattr(curses, 'A_STRIKEOUT'): attr |= curses.A_STRIKEOUT
            if not task.completed:
                prio_color_map = {"high": 3, "low": 5, "normal": 4}
                color = curses.color_pair(prio_color_map.get(task.priority, 4))
                attr = curses.A_NORMAL
            if is_selected:
                bg_attr = curses.color_pair(1) | curses.A_REVERSE
                self.safe_addstr(stdscr, y, 0, " " * (w - 1), bg_attr)
                self.safe_addstr(stdscr, y, 1, line, color | bg_attr)
            else:
                self.safe_addstr(stdscr, y, 1, line, color | attr)
            y += 1

    def format_task_line(self, task, w):
        status = "[✓]" if task.completed else "[ ]"
        prio = {"high": "[H]", "normal": "[M]", "low": "[L]"}.get(task.priority, "[M]")
        time = humanize_time_delta(task.created_at).rjust(4)
        max_w = max(0, w - len(status) - len(prio) - len(time) - 5)
        text = task.text
        if len(text) > max_w: text = text[:max_w-1] + "…"
        return f"{status} {prio} {text.ljust(max_w)} {time}"

    def draw_status_bar(self, stdscr, h, w):
        y = h - 1
        self.safe_addstr(stdscr, y, 0, " " * (w - 1), curses.color_pair(7))
        if self.status_message:
            self.safe_addstr(stdscr, y, 1, self.status_message, curses.color_pair(7))
            return
        bar = " (n)ew | (e)dit | (d)elete | (s)ort | (h)elp | (q)uit "
        self.safe_addstr(stdscr, y, (w - len(bar)) // 2, bar, curses.color_pair(7))

    def draw_floating_panel(self, stdscr, h, w):
        p_h, p_w = 5, 60
        p_y, p_x = (h - p_h) // 2, (w - p_w) // 2
        
        bg_attr = curses.color_pair(9)
        for i in range(p_h): self.safe_addstr(stdscr, p_y + i, p_x, " " * p_w, bg_attr)
        
        title = ""
        if self.mode == "edit": title = "Edit Task"
        elif self.mode == "input": title = f"New Task - Priority: {self.input_priority.upper()}"
        elif self.mode == "confirm_delete": title = "Confirm Deletion"
        
        self.safe_addstr(stdscr, p_y + 1, p_x + 2, title, bg_attr | curses.A_BOLD)

        if self.mode in ["input", "edit"]:
            input_y = p_y + 3
            self.safe_addstr(stdscr, input_y, p_x + 2, "> ", bg_attr)
            self.safe_addstr(stdscr, input_y, p_x + 4, self.input_text, bg_attr | curses.A_UNDERLINE)
            curses.curs_set(1)
            stdscr.move(input_y, p_x + 4 + self.cursor_pos)
        elif self.mode == "confirm_delete":
            msg = "Are you sure you want to delete this task?"
            self.safe_addstr(stdscr, p_y + 2, p_x + (p_w - len(msg)) // 2, msg, bg_attr)
            opts = "(y)es / (n)o"
            self.safe_addstr(stdscr, p_y + 3, p_x + (p_w - len(opts)) // 2, opts, bg_attr)

    def draw_help_panel(self, stdscr, h, w):
        lines = [
            "~ TASKMAN HELP ~",
            "",
            "  n, e, d    New, Edit, Delete task",
            "  space      Toggle task completion",
            "  s          Cycle sort mode",
            "  tab        Cycle priority (in new mode)",
            "  ↑/↓, k/j   Navigate tasks",
            "  pgup/pgdn  Page up/down",
            "  home/end   Go to top/bottom",
            "",
            "  h          Close this help panel",
            "  q          Quit Taskman",
        ]
        p_h = len(lines) + 2
        p_w = 50
        p_y, p_x = (h - p_h) // 2, (w - p_w) // 2
        
        bg_attr = curses.color_pair(9)
        for i in range(p_h):
            self.safe_addstr(stdscr, p_y + i, p_x, " " * p_w, bg_attr)
        
        for i, line in enumerate(lines):
            self.safe_addstr(stdscr, p_y + 1 + i, p_x + 2, line, bg_attr)

    def handle_normal_mode(self, key, page_size):
        if key == ord('q'): return True
        elif key == ord('n'): self.mode = "input"; self.input_text = ""; self.cursor_pos = 0; self.input_priority = "normal"
        elif key == ord('e'):
            if self.task_manager.tasks: self.mode = "edit"; self.input_text = self.task_manager.tasks[self.task_manager.selected_index].text; self.cursor_pos = len(self.input_text)
        elif key == ord('d'):
            if self.task_manager.tasks: self.mode = "confirm_delete"
        elif key == ord(' '):
            if self.task_manager.tasks: self.task_manager.toggle_task(self.task_manager.selected_index)
        elif key == ord('s'):
            self.task_manager.cycle_sort_mode(); self.set_status_message(f"Sort: {self.task_manager.sort_mode}")
        elif key == ord('h'): self.show_help = not self.show_help
        elif key in [curses.KEY_UP, ord('k')]:
            if self.task_manager.tasks and self.task_manager.selected_index > 0: self.task_manager.selected_index -= 1
        elif key in [curses.KEY_DOWN, ord('j')]:
            if self.task_manager.tasks and self.task_manager.selected_index < len(self.task_manager.tasks) - 1: self.task_manager.selected_index += 1
        elif key == curses.KEY_PPAGE: self.task_manager.selected_index = max(0, self.task_manager.selected_index - page_size)
        elif key == curses.KEY_NPAGE:
            if self.task_manager.tasks: self.task_manager.selected_index = min(len(self.task_manager.tasks) - 1, self.task_manager.selected_index + page_size)
        elif key == curses.KEY_HOME: self.task_manager.selected_index = 0
        elif key == curses.KEY_END:
            if self.task_manager.tasks: self.task_manager.selected_index = len(self.task_manager.tasks) - 1
        return False

    def handle_panel_mode(self, key):
        if key == 27:
            self.mode = "normal"; curses.curs_set(0); self.set_status_message("Cancelled.")
        elif self.mode in ["input", "edit"]:
            if key in [ord('\n'), ord('\r')]:
                if self.input_text.strip():
                    if self.mode == "edit":
                        self.task_manager.edit_task(self.task_manager.selected_index, self.input_text.strip())
                        self.set_status_message("Task updated.")
                    else:
                        self.task_manager.add_task(self.input_text.strip(), self.input_priority)
                        self.set_status_message("Task added.")
                self.mode = "normal"; self.input_text = ""; curses.curs_set(0)
            elif key == ord('\t') and self.mode == "input":
                priorities = ["normal", "high", "low"]
                self.input_priority = priorities[(priorities.index(self.input_priority) + 1) % len(priorities)]
            elif key in [curses.KEY_BACKSPACE, 127]:
                if self.cursor_pos > 0:
                    self.input_text = self.input_text[:self.cursor_pos-1] + self.input_text[self.cursor_pos:]
                    self.cursor_pos -= 1
            elif key == curses.KEY_LEFT:
                if self.cursor_pos > 0: self.cursor_pos -= 1
            elif key == curses.KEY_RIGHT:
                if self.cursor_pos < len(self.input_text): self.cursor_pos += 1
            elif 32 <= key <= 126:
                self.input_text = self.input_text[:self.cursor_pos] + chr(key) + self.input_text[self.cursor_pos:]
                self.cursor_pos += 1
        elif self.mode == "confirm_delete":
            if key == ord('y'):
                self.task_manager.delete_task(self.task_manager.selected_index)
                self.set_status_message("Task deleted.")
            else:
                self.set_status_message("Deletion cancelled.")
            self.mode = "normal"

    def draw_small_terminal_message(self, stdscr, h, w):
        stdscr.clear(); msg = "Terminal too small"
        self.safe_addstr(stdscr, h // 2, (w - len(msg)) // 2, msg); stdscr.refresh()

def main():
    try: curses.wrapper(ModernTaskUI(ModernTaskManager()).run)
    except curses.error as e: print(f"Curses error: {e}")
    except KeyboardInterrupt: print("Exiting.")

if __name__ == "__main__":
    main()