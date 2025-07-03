#!/usr/bin/env python3
"""
Smart Dino Animation for Taskman
Lightweight, task-integrated animation system with productivity focus
"""

import time
import random
from datetime import datetime


class DinoAnimation:
    """Smart dino animation that integrates with task management"""
    
    def __init__(self, width: int = 80):
        self.width = width
        self.enabled = False
        self.last_update = 0
        self.frame = 0
        
        # Dino moods based on productivity
        self.moods = {
            'sleeping': {
                'sprites': ['😴', '💤'],
                'description': 'No tasks yet'
            },
            'working': {
                'sprites': ['🦕', '🦖'],
                'description': 'Getting things done'
            },
            'focused': {
                'sprites': ['🎯', '🦕'],
                'description': 'In the zone'
            },
            'celebrating': {
                'sprites': ['🎉', '🦕', '✨', '🎊'],
                'description': 'All done!'
            },
            'stressed': {
                'sprites': ['😰', '🦕'],
                'description': 'Many high priority tasks'
            }
        }
        
        self.current_mood = 'sleeping'
        self.celebration_timer = 0
        self.productivity_streak = 0
        
        # Task-related state
        self.last_task_count = 0
        self.last_completed_count = 0
        
        # Celebration message state - 添加这些来稳定显示
        self.celebration_message = None
        self.celebration_message_timer = 0
        self.last_all_completed = False
        self.last_task_total = 0  # Track total task count for message updates
        
    def toggle_animation(self):
        """Toggle animation on/off"""
        self.enabled = not self.enabled
        if not self.enabled:
            self.frame = 0
            
    def is_enabled(self):
        """Check if animation is enabled"""
        return self.enabled
        
    def _analyze_tasks(self, tasks):
        """Analyze tasks to determine dino mood and behavior"""
        if not tasks:
            return 'sleeping'
            
        total_tasks = len(tasks)
        completed_tasks = sum(1 for t in tasks if t.completed)
        high_priority_pending = sum(1 for t in tasks if t.priority == 'high' and not t.completed)
        
        # All tasks completed - celebration time!
        if completed_tasks == total_tasks:
            return 'celebrating'
            
        # Too many high priority tasks - stressed
        if high_priority_pending >= 3:
            return 'stressed'
            
        # Good progress - focused
        completion_ratio = completed_tasks / total_tasks
        if completion_ratio >= 0.7:
            return 'focused'
            
        # Some progress - working
        if completed_tasks > 0:
            return 'working'
            
        # No progress yet - sleeping
        return 'sleeping'
        
    def _update_productivity_streak(self, tasks):
        """Update productivity streak based on task completion"""
        if not tasks:
            return
            
        completed_count = sum(1 for t in tasks if t.completed)
        
        # If more tasks were completed since last update
        if completed_count > self.last_completed_count:
            self.productivity_streak += (completed_count - self.last_completed_count)
        
        self.last_completed_count = completed_count
        
    def update(self, tasks=None):
        """Update animation state based on tasks"""
        if not self.enabled:
            return
            
        current_time = time.time()
        # Update every 1000ms (1 second) for even more efficient animation
        if current_time - self.last_update < 1.0:
            return
            
        self.last_update = current_time
        
        # Analyze tasks if provided
        if tasks is not None:
            new_mood = self._analyze_tasks(tasks)
            
            # Check if all tasks are completed
            all_completed = len(tasks) > 0 and all(t.completed for t in tasks)
            task_count_changed = len(tasks) != self.last_task_total
            
            # Handle celebration message state
            if all_completed and (not self.last_all_completed or (task_count_changed and all_completed)):
                # Just completed all tasks OR task count changed while all completed - generate new celebration message
                messages = [
                    f"🎉 All {len(tasks)} tasks completed! Amazing work!",
                    f"✨ Perfect! You finished all {len(tasks)} tasks!",
                    f"🎊 Task master! {len(tasks)}/{len(tasks)} done!",
                    f"🏆 Incredible! All tasks complete!"
                ]
                self.celebration_message = random.choice(messages)
                self.celebration_message_timer = 15  # Show for 15 update cycles (~12 seconds)
            elif not all_completed:
                # Tasks are no longer all completed - clear celebration immediately
                self.celebration_message = None
                self.celebration_message_timer = 0
            
            # Update last state
            self.last_all_completed = all_completed
            self.last_task_total = len(tasks)
            
            # Handle mood transitions
            if new_mood != self.current_mood:
                if new_mood == 'celebrating':
                    self.celebration_timer = 8  # Celebrate for 8 frames
                self.current_mood = new_mood
                
            self._update_productivity_streak(tasks)
        
        # Handle celebration timer
        if self.celebration_timer > 0:
            self.celebration_timer -= 1
            if self.celebration_timer == 0 and self.current_mood == 'celebrating':
                # After celebration, go to focused mode
                self.current_mood = 'focused'
        
        # Handle celebration message timer
        if self.celebration_message_timer > 0:
            self.celebration_message_timer -= 1
            if self.celebration_message_timer == 0:
                self.celebration_message = None
        
        # Update animation frame
        sprites = self.moods[self.current_mood]['sprites']
        self.frame = (self.frame + 1) % len(sprites)
        
    def get_current_sprite(self):
        """Get current dino sprite"""
        if not self.enabled:
            return ""
            
        sprites = self.moods[self.current_mood]['sprites']
        return sprites[self.frame]
        
    def get_mood_description(self):
        """Get description of current mood"""
        if not self.enabled:
            return "Animation disabled"
            
        return self.moods[self.current_mood]['description']
        
    def get_progress_bar(self, tasks, length=8):
        """Generate visual progress bar"""
        if not tasks:
            return "▱" * length
            
        completed = sum(1 for t in tasks if t.completed)
        total = len(tasks)
        
        if total == 0:
            return "▱" * length
            
        filled = int((completed / total) * length)
        return "▰" * filled + "▱" * (length - filled)
        
    def get_priority_indicator(self, tasks):
        """Get visual indicator for urgent tasks"""
        if not tasks:
            return ""
            
        high_priority_pending = sum(1 for t in tasks if t.priority == 'high' and not t.completed)
        
        if high_priority_pending >= 3:
            return "🚨"
        elif high_priority_pending >= 1:
            return "🔥"
        return ""
        
    def get_time_of_day_indicator(self):
        """Get time-based visual indicator"""
        hour = datetime.now().hour
        
        if 5 <= hour < 12:
            return "🌅"  # Morning
        elif 12 <= hour < 17:
            return "☀️"   # Afternoon  
        elif 17 <= hour < 21:
            return "🌆"  # Evening
        else:
            return "🌙"  # Night
            
    def get_productivity_indicator(self):
        """Get productivity streak indicator"""
        if self.productivity_streak >= 10:
            return "🏆"
        elif self.productivity_streak >= 5:
            return "🔥"
        elif self.productivity_streak >= 3:
            return "⭐"
        elif self.productivity_streak >= 1:
            return "✓"
        return ""
        
    def get_compact_status(self, tasks, max_width=50):
        """Get compact status line for taskman"""
        if not tasks:
            if self.enabled:
                return f"No tasks {self.get_current_sprite()}"
            return "No tasks"
            
        # Core information
        completed = sum(1 for t in tasks if t.completed)
        total = len(tasks)
        progress_bar = self.get_progress_bar(tasks, 6)
        
        # Base status
        status_parts = [f"{completed}/{total}", progress_bar]
        
        # Add dino if enabled
        if self.enabled:
            sprite = self.get_current_sprite()
            if sprite:
                status_parts.append(sprite)
        
        # Add indicators if space allows
        indicators = []
        
        # Priority indicator
        priority_ind = self.get_priority_indicator(tasks)
        if priority_ind:
            indicators.append(priority_ind)
            
        # Productivity indicator
        prod_ind = self.get_productivity_indicator()
        if prod_ind:
            indicators.append(prod_ind)
            
        # Time indicator
        time_ind = self.get_time_of_day_indicator()
        indicators.append(time_ind)
        
        # Combine everything
        base_status = " ".join(status_parts)
        if indicators:
            full_status = f"{base_status} {' '.join(indicators)}"
            if len(full_status) <= max_width:
                return full_status
                
        return base_status
        
    def get_celebration_message(self, tasks):
        """Get stable celebration message when appropriate"""
        if not self.enabled or not tasks:
            return None
            
        # Only return celebration message if all tasks are actually completed
        if len(tasks) > 0 and all(t.completed for t in tasks):
            return self.celebration_message
        else:
            return None
        
    def get_motivation_message(self, tasks):
        """Get motivational message based on current state"""
        if not tasks or not self.enabled:
            return None
            
        completed = sum(1 for t in tasks if t.completed)
        total = len(tasks)
        
        if completed == 0:
            return "🦕 Ready to tackle some tasks?"
        elif completed == total - 1:
            return "🎯 One more task to go! You've got this!"
        elif completed >= total * 0.5:
            return f"⭐ Great progress! {completed}/{total} done!"
            
        return None
        
    def get_display_lines(self):
        """Compatibility method - returns empty lines since we use compact display"""
        return ("", "", "", "", "", "")
        
    def has_display_changed(self):
        """Compatibility method"""
        return True
        
    def get_status(self):
        """Get detailed status for debugging"""
        if not self.enabled:
            return "Dino Animation: OFF (press 'x' to enable)"
            
        mood_desc = self.get_mood_description()
        sprite = self.get_current_sprite()
        
        status_parts = [f"Dino: {sprite} ({mood_desc})"]
        
        if self.productivity_streak > 0:
            status_parts.append(f"Streak: {self.productivity_streak}")
            
        if self.celebration_timer > 0:
            status_parts.append("🎉 Celebrating!")
            
        return " | ".join(status_parts)


# Compatibility class for easy migration
class SmartTaskStatus:
    """Enhanced task status manager with dino integration"""
    
    def __init__(self, width=80):
        self.dino = DinoAnimation(width)
        
    def update(self, tasks):
        """Update dino based on tasks"""
        self.dino.update(tasks)
        
    def get_status_line(self, tasks, max_width=50):
        """Get complete status line"""
        return self.dino.get_compact_status(tasks, max_width)
        
    def get_celebration_if_any(self, tasks):
        """Get celebration message if applicable"""
        return self.dino.get_celebration_message(tasks)
        
    def get_motivation_if_any(self, tasks):
        """Get motivation message if applicable"""
        return self.dino.get_motivation_message(tasks)
        
    def toggle_dino(self):
        """Toggle dino animation"""
        self.dino.toggle_animation()
        
    def is_dino_enabled(self):
        """Check if dino is enabled"""
        return self.dino.is_enabled()


if __name__ == "__main__":
    # Test the new dino animation
    print("🦕 Testing Smart Dino Animation")
    print("=" * 40)
    
    # Create test tasks
    class MockTask:
        def __init__(self, completed=False, priority='normal'):
            self.completed = completed
            self.priority = priority
    
    # Test scenarios
    scenarios = [
        ("No tasks", []),
        ("All pending", [MockTask(False), MockTask(False), MockTask(False)]),
        ("Some progress", [MockTask(True), MockTask(False), MockTask(True)]),
        ("High priority stress", [MockTask(False, 'high'), MockTask(False, 'high'), MockTask(False, 'high')]),
        ("Almost done", [MockTask(True), MockTask(True), MockTask(False)]),
        ("All completed", [MockTask(True), MockTask(True), MockTask(True)])
    ]
    
    dino = DinoAnimation()
    dino.toggle_animation()
    
    for scenario_name, tasks in scenarios:
        print(f"\n📋 {scenario_name}:")
        dino.update(tasks)
        print(f"   Status: {dino.get_compact_status(tasks)}")
        print(f"   Mood: {dino.get_mood_description()}")
        
        celebration = dino.get_celebration_message(tasks)
        if celebration:
            print(f"   🎉 {celebration}")
            
        motivation = dino.get_motivation_message(tasks)
        if motivation:
            print(f"   💪 {motivation}")
    
    print(f"\n🎮 Final status: {dino.get_status()}")
