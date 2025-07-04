#!/usr/bin/env zsh
# Terminal Task Manager Plugin for OSH
# A powerful sidebar-style task manager that runs in your terminal

# Load common libraries (colors and vintage design system are loaded automatically)
if [[ -z "${OSH_COMMON_LOADED:-}" ]] && [[ -f "${OSH}/lib/common.zsh" ]]; then
  source "${OSH}/lib/common.zsh"
fi

# Load vintage design system
if [[ -z "${OSH_VINTAGE_LOADED:-}" ]] && [[ -f "${OSH}/lib/vintage.zsh" ]]; then
  source "${OSH}/lib/vintage.zsh"
fi

# Plugin directory
TASKMAN_PLUGIN_DIR="${0:A:h}"

# Data directory (store tasks in home directory)
# Can be customized by setting TASKMAN_DATA_FILE environment variable
TASKMAN_DATA_DIR="$HOME/.taskman"

# Check if first-time setup is needed
_taskman_check_first_time_setup() {
    local setup_complete_file="$TASKMAN_DATA_DIR/.setup_complete"
    
    if [[ ! -f "$setup_complete_file" ]]; then
        return 0  # Setup needed
    else
        return 1  # Setup already done
    fi
}

# Run first-time setup wizard
_taskman_run_setup() {
    if [[ ! -f "$TASKMAN_PLUGIN_DIR/taskman_setup.py" ]]; then
        osh_vintage_error "Setup wizard not found: $TASKMAN_PLUGIN_DIR/taskman_setup.py"
        return 1
    fi
    
    osh_vintage_info "🎨 Welcome to OSH Taskman!"
    osh_vintage_info "Running first-time setup wizard..."
    
    if python3 "$TASKMAN_PLUGIN_DIR/taskman_setup.py"; then
        osh_vintage_success "✅ Setup completed successfully!"
        return 0
    else
        osh_vintage_error "❌ Setup failed or was cancelled"
        return 1
    fi
}

# Load configuration from config file
_taskman_load_config() {
    local config_file="$TASKMAN_DATA_DIR/config.json"
    
    if [[ -f "$config_file" ]]; then
        # Try to read configuration values
        if command -v python3 >/dev/null 2>&1; then
            # Read data directory from config
            local configured_data_dir
            configured_data_dir=$(python3 -c "
import json, sys
try:
    with open('$config_file', 'r') as f:
        config = json.load(f)
    print(config.get('data_directory', '$TASKMAN_DATA_DIR'))
except:
    print('$TASKMAN_DATA_DIR')
" 2>/dev/null)
            
            if [[ -n "$configured_data_dir" && "$configured_data_dir" != "None" ]]; then
                TASKMAN_DATA_DIR="$configured_data_dir"
            fi
        fi
    fi
}

# Initialize taskman (load config and ensure directory exists)
_taskman_init() {
    # Load configuration first
    _taskman_load_config
    
    # Ensure data directory exists
    if [[ -n "${OSH_COMMON_LOADED:-}" ]]; then
        osh_file_ensure_dir "$TASKMAN_DATA_DIR"
    else
        mkdir -p "$TASKMAN_DATA_DIR"
    fi
}

# Main task manager function
tasks() {
    # Safety check: Don't auto-start if called without explicit user action
    if [[ -z "${1:-}" && -z "${TASKMAN_EXPLICIT_CALL:-}" ]]; then
        # Check if this is being called from a user terminal session
        if [[ -z "${PS1:-}" ]]; then
            # Not in interactive shell, don't auto-start
            return 0
        fi
    fi
    
    _taskman_main "$@"
}

# Main task manager function (internal)
_taskman_main() {
    local action="${1:-}"

    # CRITICAL: Prevent auto-start unless explicitly called
    if [[ -z "$action" && -z "${TASKMAN_EXPLICIT_CALL:-}" ]]; then
        # Show help instead of launching UI
        osh_vintage_info "🎯 OSH Taskman - Terminal Task Manager"
        osh_vintage_info "Usage:"
        echo "  tasks ui       # Launch interactive UI"
        echo "  tasks add      # Add a new task"
        echo "  tasks list     # List all tasks"
        echo "  tasks setup    # Run setup wizard"
        echo "  tasks config   # Show configuration"
        echo
        osh_vintage_info "💡 Use 'tasks ui' to launch the full interface"
        osh_vintage_info "💡 Use 'tm' for quick UI access"
        return 0
    fi

    # Only shift if there are arguments
    if [[ $# -gt 0 ]]; then
        shift
    fi

    # Initialize taskman
    _taskman_init

    case "$action" in
        "setup")
            # Run setup wizard
            _taskman_run_setup
            ;;
        "config")
            # Show current configuration
            _taskman_show_config
            ;;
        "" | "ui" | "show")
            # Check if first-time setup is needed
            if _taskman_check_first_time_setup; then
                osh_vintage_info "🎯 First time using Taskman?"
                osh_vintage_info "Let's set up your task management system!"
                echo
                read -p "Run setup wizard now? (Y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    osh_vintage_info "⏭️  Skipping setup. You can run 'tasks setup' anytime."
                    osh_vintage_info "Using default configuration..."
                else
                    if _taskman_run_setup; then
                        # Reload configuration after setup
                        _taskman_init
                    else
                        osh_vintage_info "Continuing with default configuration..."
                    fi
                fi
            fi
            
            # Launch the full UI
            _taskman_launch_ui
            ;;
        "add" | "new" | "create")
            # Quick add task from command line
            _taskman_add_task "$@"
            ;;
        "list" | "ls")
            # List tasks in terminal
            _taskman_list_tasks "$@"
            ;;
        "done" | "complete")
            # Mark task as complete
            _taskman_complete_task "$@"
            ;;
        "delete" | "del" | "rm")
            # Delete a task
            _taskman_delete_task "$@"
            ;;
        "sort")
            # Set sorting mode
            _taskman_set_sort "$@"
            ;;
        "help" | "-h" | "--help")
            _taskman_show_help
            ;;
        *)
            osh_color_error "Unknown action: $action"
            _taskman_show_help
            return 1
            ;;
    esac
}

# Launch the full UI
_taskman_launch_ui() {
    # Validate Python 3 is available
    if ! osh_validate_command "python3"; then
        return 1
    fi

    # Set the data file path (can be customized via environment variable)
    export TASKMAN_DATA_FILE="${TASKMAN_DATA_FILE:-$TASKMAN_DATA_DIR/tasks.json}"

    # Ensure the data directory exists
    osh_file_ensure_dir "$(dirname "$TASKMAN_DATA_FILE")"

    # --- Theme Selection ---
    # Default to 'modern' theme, allow override with TASKMAN_THEME=vintage
    local theme="${TASKMAN_THEME:-modern}"
    local ui_script

    if [[ "$theme" == "vintage" ]]; then
        ui_script="task_manager_vintage.py"
        osh_vintage_brand "✦ Launching OSH Taskman (Vintage) ✦"
    else
        ui_script="task_manager_modern.py"
        osh_color_info "Launching Taskman (Modern)..."
    fi
    
    if [[ ! -f "$TASKMAN_PLUGIN_DIR/$ui_script" ]]; then
        osh_color_error "UI script not found: $ui_script"
        return 1
    fi

    # Run the Python task manager
    if ! python3 "$TASKMAN_PLUGIN_DIR/$ui_script"; then
        osh_color_error "Failed to launch task manager UI"
        osh_color_info "Try using CLI mode: tasks add, tasks list, etc."
        return 1
    fi
}

# Quick add task from command line
_taskman_add_task() {
    if [[ $# -eq 0 ]]; then
        osh_vintage_error "Please provide task description"
        osh_vintage_info "Usage: tasks add <task description> [priority]"
        return 1
    fi

    local task_text="${1:-}"
    local priority="${2:-normal}"

    # Validate task text
    if [[ -z "$(osh_string_trim "$task_text")" ]]; then
        osh_vintage_error "Task description cannot be empty"
        return 1
    fi

    # Validate priority
    case "$priority" in
        "high"|"normal"|"low")
            ;;
        *)
            osh_vintage_warning "Invalid priority '$priority', using 'normal'"
            priority="normal"
            ;;
    esac

    # Validate Python and CLI script
    if ! osh_validate_command "python3"; then
        return 1
    fi

    if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
        osh_vintage_error "Task CLI script not found: $TASKMAN_PLUGIN_DIR/task_cli.py"
        return 1
    fi

    # Add the task
    if ! python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" add "$task_text" "$priority"; then
        osh_vintage_error "Failed to add task"
        return 1
    fi

    # Show vintage confirmation with priority-specific styling
    local priority_color=$(osh_vintage_priority_color "$priority" "active")
    local priority_icon=$(osh_vintage_priority_icon "$priority")
    
    printf "%s✓ Added task: %s%s [%s]%s %s\n" \
        "$OSH_VINTAGE_SUCCESS" \
        "$priority_color" "$priority_icon" "$priority" "$OSH_VINTAGE_RESET" \
        "$task_text"
}

# List tasks in terminal
_taskman_list_tasks() {
    local filter="${1:-all}"
    
    # Validate Python and CLI script
    if ! osh_validate_command "python3"; then
        return 1
    fi

    if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
        osh_color_error "Task CLI script not found: $TASKMAN_PLUGIN_DIR/task_cli.py"
        return 1
    fi

    # Validate filter
    case "$filter" in
        "all"|"pending"|"completed")
            ;;
        *)
            osh_color_warning "Invalid filter '$filter', using 'all'"
            filter="all"
            ;;
    esac

    if ! python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" list "$filter"; then
        osh_color_error "Failed to list tasks"
        return 1
    fi
}

# Complete a task
_taskman_complete_task() {
    if [[ $# -eq 0 ]]; then
        osh_color_error "Please provide task ID"
        osh_color_info "Usage: tasks done <task_id>"
        return 1
    fi

    local task_id="${1:-}"
    
    # Validate task ID is numeric
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        osh_color_error "Task ID must be a number"
        return 1
    fi

    # Validate Python and CLI script
    if ! osh_validate_command "python3"; then
        return 1
    fi

    if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
        osh_color_error "Task CLI script not found: $TASKMAN_PLUGIN_DIR/task_cli.py"
        return 1
    fi

    if ! python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" complete "$task_id"; then
        osh_color_error "Failed to complete task ID: $task_id"
        return 1
    fi
}

# Delete a task
_taskman_delete_task() {
    if [[ $# -eq 0 ]]; then
        osh_color_error "Please provide task ID"
        osh_color_info "Usage: tasks delete <task_id>"
        return 1
    fi

    local task_id="${1:-}"
    
    # Validate task ID is numeric
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        osh_color_error "Task ID must be a number"
        return 1
    fi

    # Validate Python and CLI script
    if ! osh_validate_command "python3"; then
        return 1
    fi

    if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
        osh_color_error "Task CLI script not found: $TASKMAN_PLUGIN_DIR/task_cli.py"
        return 1
    fi

    if ! python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" delete "$task_id"; then
        osh_color_error "Failed to delete task ID: $task_id"
        return 1
    fi
}

# Set sorting mode
_taskman_set_sort() {
    if [[ $# -eq 0 ]]; then
        osh_color_error "Please provide sort mode"
        osh_color_info "Usage: tasks sort <mode>"
        osh_color_info "Available modes: default, priority, alphabetical"
        return 1
    fi

    local sort_mode="${1:-}"
    
    # Validate sort mode
    case "$sort_mode" in
        "default"|"priority"|"alphabetical")
            ;;
        *)
            osh_color_error "Invalid sort mode: $sort_mode"
            osh_color_info "Available modes: default, priority, alphabetical"
            return 1
            ;;
    esac

    # Validate Python and CLI script
    if ! osh_validate_command "python3"; then
        return 1
    fi

    if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
        osh_color_error "Task CLI script not found: $TASKMAN_PLUGIN_DIR/task_cli.py"
        return 1
    fi

    if ! python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" sort "$sort_mode"; then
        osh_color_error "Failed to set sort mode: $sort_mode"
        return 1
    fi
}

# Show help
_taskman_show_help() {
    cat << 'EOF'
Terminal Task Manager - OSH plugin v2.2 🎨 VINTAGE BY DEFAULT

Usage:
  tasks [action] [arguments]

Actions:
  (no action)    Launch vintage interactive UI
  ui, show       Launch vintage interactive UI
  add <text> [priority]  Add new task (priority: high, normal, low)
  list [filter]  List tasks (filter: all, pending, completed)
  done <id>      Mark task as completed
  delete <id>    Delete a task
  sort <mode>    Set sorting mode (default, priority, alphabetical)
  help           Show this help

🎨 VINTAGE MODE (DEFAULT):
  Beautiful vintage OSH styling is now enabled by default!
  
  # Disable vintage mode (use classic styling)
  export TASKMAN_VINTAGE=false
  tasks ui

Examples:
  tasks                          # Launch vintage UI
  tasks add "Fix bug in login"   # Add normal priority task
  tasks add "Deploy to prod" high  # Add high priority task
  tasks list                     # List all tasks with vintage colors
  tasks list pending             # List only pending tasks
  tasks done 3                   # Mark task ID 3 as completed
  tasks delete 5                 # Delete task ID 5
  tasks sort priority            # Sort by priority

Interactive UI Keys:
  ↑/k    Move up        n      New task
  ↓/j    Move down      Space  Toggle completion
  s      Cycle sort     d      Delete task
  p      Sort priority  a      Sort alphabetical
  h      Help           q      Quit

🎨 Vintage Features (Default):
  • Beautiful vintage color scheme matching OSH theme
  • Enhanced UI with decorative borders and elements
  • Vintage priority icons: ◆ (high), ◇ (normal), ◦ (low)
  • Elegant typography and visual hierarchy
  • Responsive design for different terminal sizes
  • Retro-styled help panels and input areas

Priority Colors (Vintage Mode):
  • High Priority (◆) - Vintage red for active, dimmed for completed
  • Normal Priority (◇) - Vintage yellow for active, dimmed for completed  
  • Low Priority (◦) - Vintage teal for active, dimmed for completed

Data Storage:
  Default: ~/.taskman/tasks.json
  Custom:  Set TASKMAN_DATA_FILE environment variable

Configuration:
  # In your ~/.zshrc
  export TASKMAN_DATA_FILE="$HOME/Documents/my-tasks.json"
  export TASKMAN_VINTAGE=false  # Disable vintage styling (use classic)
EOF
}

# Aliases for convenience
alias taskman='TASKMAN_EXPLICIT_CALL=1 tasks'
alias tm='TASKMAN_EXPLICIT_CALL=1 tasks ui'  # tm always launches UI explicitly
alias task='TASKMAN_EXPLICIT_CALL=1 tasks'
alias todo='TASKMAN_EXPLICIT_CALL=1 tasks'

# Auto-completion for task actions
if [[ -n "$ZSH_VERSION" ]] && command -v compdef >/dev/null 2>&1; then
    _taskman_completion() {
        local -a actions
        actions=(
            'ui:Launch interactive UI'
            'show:Launch interactive UI'
            'add:Add new task'
            'new:Add new task'
            'create:Add new task'
            'list:List tasks'
            'ls:List tasks'
            'done:Mark task complete'
            'complete:Mark task complete'
            'delete:Delete task'
            'del:Delete task'
            'rm:Delete task'
            'sort:Set sorting mode'
            'help:Show help'
        )
        _describe 'actions' actions
    }

    compdef _taskman_completion tasks tm task todo
fi

# Quick access function for vintage taskman
tasks-vintage() {
    osh_color_info "🎨 Starting Vintage OSH Taskman..."
    osh_color_warning "✨ Beautiful vintage colors and enhanced UI enabled!"
    TASKMAN_VINTAGE=true tasks ui
}

# Quick access function for sidebar workflow
task-sidebar() {
    osh_color_info "Starting task manager in sidebar mode..."
    osh_color_warning "Tip: Use 'Cmd+D' (or equivalent) to split terminal horizontally"
    osh_color_info "New features: Sort with 's/p/a' keys, completed tasks auto-move to bottom"
    osh_color_info "🎨 Try 'tasks-vintage' for beautiful vintage styling!"
    tasks ui
}

# Show a quick summary on shell startup (optional)
# Uncomment the next line if you want to see task summary when opening terminal
# _taskman_startup_summary

# IMPORTANT: This function should NEVER be called automatically
# It's only for manual invocation or when explicitly uncommented above
_taskman_startup_summary() {
    local data_file="${TASKMAN_DATA_FILE:-$TASKMAN_DATA_DIR/tasks.json}"
    
    if [[ -f "$data_file" ]]; then
        # Validate Python and CLI script before trying to get counts
        if ! osh_validate_command "python3" >/dev/null 2>&1; then
            return 0
        fi
        if [[ ! -f "$TASKMAN_PLUGIN_DIR/task_cli.py" ]]; then
            return 0
        fi

        # Efficiently get both counts in one call
        local counts_json
        counts_json=$(python3 "$TASKMAN_PLUGIN_DIR/task_cli.py" count all_json 2>/dev/null)
        
        if [[ -n "$counts_json" ]]; then
            # Use shell built-ins to parse JSON for maximum speed
            local pending_count completed_count
            pending_count=$(echo "$counts_json" | sed -n 's/.*"pending": \([0-9]*\).*/\1/p')
            completed_count=$(echo "$counts_json" | sed -n 's/.*"completed": \([0-9]*\).*/\1/p')

            if [[ "$pending_count" -gt 0 ]]; then
                osh_color_info "📋 Task Summary: ${pending_count} pending, ${completed_count} completed"
                osh_color_warning "   Type 'tasks' to manage your tasks"
            fi
        fi
    fi
}

# Show current configuration
_taskman_show_config() {
    local config_file="$TASKMAN_DATA_DIR/config.json"
    
    osh_vintage_info "🔧 Current Taskman Configuration"
    echo
    
    if [[ -f "$config_file" ]]; then
        osh_vintage_success "Configuration file: $config_file"
        echo
        
        if command -v python3 >/dev/null 2>&1; then
            python3 -c "
import json
import os
from pathlib import Path

config_file = '$config_file'
try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    print('📋 Configuration Settings:')
    print()
    
    settings = [
        ('📁 Data Directory', config.get('data_directory', 'Not set')),
        ('🎨 Vintage Mode', '✅ Enabled' if config.get('vintage_mode', True) else '❌ Disabled'),
        ('🦕 Dino Animation', '✅ Enabled' if config.get('dino_animation', True) else '❌ Disabled'),
        ('💾 Auto-save', '✅ Enabled' if config.get('auto_save', True) else '❌ Disabled'),
        ('⭐ Default Priority', config.get('default_priority', 'normal').title()),
        ('📅 Date Format', config.get('date_format', 'relative').title()),
        ('🏷️  Setup Version', config.get('setup_version', 'Unknown')),
        ('📆 Setup Date', config.get('setup_date', 'Unknown'))
    ]
    
    for label, value in settings:
        print(f'  {label}: {value}')
    
    print()
    print('🔧 Management Commands:')
    print('  tasks setup    # Run setup wizard again')
    print('  tasks config   # Show this configuration')
    print('  tm             # Launch task manager')
    
except FileNotFoundError:
    print('❌ Configuration file not found')
    print('   Run \"tasks setup\" to create initial configuration')
except json.JSONDecodeError:
    print('❌ Configuration file is corrupted')
    print('   Run \"tasks setup\" to recreate configuration')
except Exception as e:
    print(f'❌ Error reading configuration: {e}')
"
        else
            osh_vintage_error "Python3 not available - cannot read configuration"
        fi
    else
        osh_vintage_warning "No configuration file found"
        osh_vintage_info "Using default settings:"
        echo
        echo "  📁 Data Directory: $TASKMAN_DATA_DIR"
        echo "  🎨 Vintage Mode: ✅ Enabled"
        echo "  🦕 Dino Animation: ✅ Enabled"
        echo "  💾 Auto-save: ✅ Enabled"
        echo "  ⭐ Default Priority: Normal"
        echo "  📅 Date Format: Relative"
        echo
        osh_vintage_info "💡 Run 'tasks setup' to customize these settings"
    fi
}

