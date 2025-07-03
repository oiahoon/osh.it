#!/usr/bin/env python3
"""
Taskman Setup Wizard - First-time user onboarding
Provides a friendly setup experience for new users
"""

import os
import json
import sys
from pathlib import Path
from datetime import datetime

class TaskmanSetupWizard:
    """Interactive setup wizard for first-time users"""
    
    def __init__(self):
        self.home_dir = Path.home()
        self.config_file = self.home_dir / ".taskman" / "config.json"
        self.setup_complete_file = self.home_dir / ".taskman" / ".setup_complete"
        
        # Default configuration
        self.default_config = {
            "data_directory": str(self.home_dir / ".taskman"),
            "vintage_mode": True,
            "dino_animation": True,
            "auto_save": True,
            "default_priority": "normal",
            "date_format": "relative",  # relative, absolute, iso
            "theme": "vintage",
            "setup_version": "1.0",
            "setup_date": datetime.now().isoformat()
        }
        
        # Color codes for beautiful output
        self.colors = {
            'header': '\033[1;36m',      # Cyan bold
            'question': '\033[1;33m',    # Yellow bold  
            'option': '\033[0;32m',      # Green
            'default': '\033[0;37m',     # White
            'info': '\033[0;34m',        # Blue
            'success': '\033[1;32m',     # Green bold
            'reset': '\033[0m'           # Reset
        }
    
    def print_colored(self, text, color='default'):
        """Print colored text"""
        print(f"{self.colors.get(color, '')}{text}{self.colors['reset']}")
    
    def print_header(self):
        """Print welcome header"""
        header = """
╔══════════════════════════════════════════════════════════════╗
║                    🎨 OSH TASKMAN SETUP                     ║
║                                                              ║
║           Welcome to your new task management system!       ║
╚══════════════════════════════════════════════════════════════╝
        """
        self.print_colored(header, 'header')
        
    def ask_question(self, question, default_value, options=None, info=None):
        """Ask a question with default value"""
        self.print_colored(f"\n{question}", 'question')
        
        if info:
            self.print_colored(f"ℹ️  {info}", 'info')
        
        if options:
            self.print_colored("Options:", 'default')
            for i, option in enumerate(options, 1):
                self.print_colored(f"  {i}. {option}", 'option')
        
        prompt = f"Enter your choice"
        if default_value is not None:
            prompt += f" (default: {default_value})"
        prompt += ": "
        
        try:
            response = input(prompt).strip()
            return response if response else default_value
        except (KeyboardInterrupt, EOFError):
            self.print_colored("\n\n👋 Setup cancelled. You can run 'tasks setup' anytime!", 'info')
            sys.exit(0)
    
    def ask_yes_no(self, question, default=True):
        """Ask a yes/no question"""
        default_text = "Y/n" if default else "y/N"
        response = self.ask_question(f"{question} ({default_text})", "")
        
        if not response:
            return default
        
        return response.lower().startswith('y')
    
    def setup_data_directory(self):
        """Configure data storage location"""
        self.print_colored("\n📁 DATA STORAGE CONFIGURATION", 'header')
        
        current_default = self.default_config["data_directory"]
        
        question = "Where would you like to store your tasks?"
        info = f"Tasks will be saved as JSON files in this directory.\nCurrent default: {current_default}"
        
        options = [
            f"Default location ({current_default})",
            "Custom location (you'll specify the path)",
            "Portable mode (store in plugin directory)"
        ]
        
        choice = self.ask_question(question, "1", options, info)
        
        if choice == "2":
            custom_path = self.ask_question(
                "Enter custom directory path", 
                current_default,
                info="Use absolute path (e.g., /Users/yourname/Documents/tasks)"
            )
            # Expand user path
            custom_path = os.path.expanduser(custom_path)
            self.default_config["data_directory"] = custom_path
            
        elif choice == "3":
            # Portable mode - store in plugin directory
            plugin_dir = Path(__file__).parent / "data"
            self.default_config["data_directory"] = str(plugin_dir)
            self.print_colored("📦 Portable mode selected - tasks will travel with the plugin!", 'success')
        
        # Create directory if it doesn't exist
        data_dir = Path(self.default_config["data_directory"])
        data_dir.mkdir(parents=True, exist_ok=True)
        
        self.print_colored(f"✅ Data directory: {self.default_config['data_directory']}", 'success')
    
    def setup_appearance(self):
        """Configure appearance and UI preferences"""
        self.print_colored("\n🎨 APPEARANCE & UI PREFERENCES", 'header')
        
        # Vintage mode
        vintage_enabled = self.ask_yes_no(
            "Enable Vintage OSH styling? (Recommended for beautiful retro look)",
            True
        )
        self.default_config["vintage_mode"] = vintage_enabled
        
        # Dino animation
        if vintage_enabled:
            dino_enabled = self.ask_yes_no(
                "Enable Smart Dino productivity assistant? (Fun but optional)",
                True
            )
            self.default_config["dino_animation"] = dino_enabled
            
            if dino_enabled:
                self.print_colored("🦕 Dino will help track your productivity with mood changes!", 'info')
        else:
            self.default_config["dino_animation"] = False
        
        # Date format preference
        question = "How would you like dates to be displayed?"
        options = [
            "Relative (e.g., '2 hours ago', '3 days ago') - Recommended",
            "Absolute (e.g., 'Jun 25 14:30')",
            "ISO format (e.g., '2025-06-25T14:30:00')"
        ]
        
        date_choice = self.ask_question(question, "1", options)
        date_formats = {"1": "relative", "2": "absolute", "3": "iso"}
        self.default_config["date_format"] = date_formats.get(date_choice, "relative")
    
    def setup_behavior(self):
        """Configure behavior preferences"""
        self.print_colored("\n⚙️  BEHAVIOR PREFERENCES", 'header')
        
        # Auto-save
        auto_save = self.ask_yes_no(
            "Enable auto-save? (Automatically save changes)",
            True
        )
        self.default_config["auto_save"] = auto_save
        
        # Default priority
        question = "What should be the default priority for new tasks?"
        options = ["Normal (balanced)", "High (important)", "Low (optional)"]
        
        priority_choice = self.ask_question(question, "1", options)
        priorities = {"1": "normal", "2": "high", "3": "low"}
        self.default_config["default_priority"] = priorities.get(priority_choice, "normal")
    
    def show_summary(self):
        """Show configuration summary"""
        self.print_colored("\n📋 CONFIGURATION SUMMARY", 'header')
        
        config = self.default_config
        
        summary_items = [
            ("📁 Data Directory", config["data_directory"]),
            ("🎨 Vintage Mode", "✅ Enabled" if config["vintage_mode"] else "❌ Disabled"),
            ("🦕 Dino Animation", "✅ Enabled" if config["dino_animation"] else "❌ Disabled"),
            ("💾 Auto-save", "✅ Enabled" if config["auto_save"] else "❌ Disabled"),
            ("⭐ Default Priority", config["default_priority"].title()),
            ("📅 Date Format", config["date_format"].title())
        ]
        
        for label, value in summary_items:
            self.print_colored(f"  {label}: {value}", 'default')
        
        self.print_colored("\n" + "="*60, 'default')
    
    def save_config(self):
        """Save configuration to file"""
        try:
            # Ensure config directory exists
            config_dir = Path(self.default_config["data_directory"])
            config_dir.mkdir(parents=True, exist_ok=True)
            
            # Save main config
            config_file = config_dir / "config.json"
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(self.default_config, f, indent=2, ensure_ascii=False)
            
            # Mark setup as complete
            setup_complete_file = config_dir / ".setup_complete"
            setup_complete_file.write_text(datetime.now().isoformat())
            
            self.print_colored(f"✅ Configuration saved to: {config_file}", 'success')
            return True
            
        except Exception as e:
            self.print_colored(f"❌ Error saving configuration: {e}", 'default')
            return False
    
    def show_next_steps(self):
        """Show what user can do next"""
        self.print_colored("\n🚀 YOU'RE ALL SET!", 'header')
        
        next_steps = """
🎯 Quick Start Commands:
  
  tm                    # Launch the beautiful task manager UI
  tasks add "My task"   # Add a new task from command line
  tasks list            # List all tasks
  tasks help            # Show all available commands

🔧 Advanced Usage:
  
  tasks setup           # Run this setup wizard again
  tasks config          # View current configuration
  TASKMAN_VINTAGE=false tm  # Use classic mode (if needed)

📚 Tips:
  
  • Press 'x' in the UI to toggle dino animation
  • Use priorities: tasks add "Important task" high
  • Tasks are automatically saved in your chosen directory
  
Enjoy your new task management system! 🎉
        """
        
        self.print_colored(next_steps, 'info')
    
    def run_setup(self):
        """Run the complete setup wizard"""
        self.print_header()
        
        # Check if setup was already completed
        if self.setup_complete_file.exists():
            rerun = self.ask_yes_no(
                "Setup has already been completed. Would you like to reconfigure?",
                False
            )
            if not rerun:
                self.print_colored("👍 Using existing configuration. Run 'tasks config' to view settings.", 'info')
                return True
        
        try:
            self.setup_data_directory()
            self.setup_appearance()
            self.setup_behavior()
            self.show_summary()
            
            # Confirm before saving
            confirm = self.ask_yes_no("\nSave this configuration?", True)
            
            if confirm:
                if self.save_config():
                    self.show_next_steps()
                    return True
                else:
                    self.print_colored("❌ Setup failed. Please try again.", 'default')
                    return False
            else:
                self.print_colored("⏭️  Setup cancelled. You can run 'tasks setup' anytime!", 'info')
                return False
                
        except Exception as e:
            self.print_colored(f"❌ Setup error: {e}", 'default')
            return False

def main():
    """Main entry point"""
    if len(sys.argv) > 1 and sys.argv[1] == "--check-needed":
        # Check if setup is needed
        setup_file = Path.home() / ".taskman" / ".setup_complete"
        sys.exit(0 if setup_file.exists() else 1)
    
    wizard = TaskmanSetupWizard()
    success = wizard.run_setup()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
