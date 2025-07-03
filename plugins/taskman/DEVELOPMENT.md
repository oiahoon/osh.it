# Taskman Plugin - Technical Development Documentation

## Overview

Taskman is a sophisticated terminal-based task management plugin designed for both the osh shell framework and Oh-My-Zsh. This document provides comprehensive technical details about the architecture, implementation, and development process.

## Version History

### Version 2.2 (Current)
- **Modular Animation System**: Separated animation logic into `dino_animation.py` for better maintainability
- **ASCII Art Obstacles**: Multi-character ASCII art obstacles with visual stacking
  - Mountain peaks: `/^\` over `/|\`
  - Buildings: `═══` over `|||`
  - Rock formations: `^^^` over `▓▓▓`
  - Towers: `┌─┐` over `│█│`
  - Trees: ` ○ ` over `/█\`
  - Fences: `┬┬┬` over `▀▀▀`
- **Realistic Physics**: Gravity-based jumping with proper acceleration and deceleration
- **Smart Obstacle Logic**: Ground obstacles require jumping, flying obstacles pass overhead
- **Simplified Height System**: Only 1-2 height ground obstacles, 2-3 height flying obstacles
- **Enhanced Collision Detection**: Multi-character width collision detection for ASCII art
- **Input Protection**: Animation automatically hides during task input to prevent interference

### Version 2.1 (Previous)
- **Enhanced Animation System**: Multi-layer 60fps animation with toggle control
  - Three-layer display (sky, jump, ground) with varied obstacles and atmospheric elements
  - 8-frame player animation and 4-frame jumping animation for smooth motion
  - 40+ obstacle types including emoji and ASCII characters
  - Background clouds and atmospheric effects
  - Variable speeds and smart jumping mechanics
  - Animation toggle with 'x' key
- **Priority-based text coloring**: Task text colored according to priority with contextual dimming for completed tasks
- **Humanized timers**: Display task age in human-readable format (5m, 2h, 3d)
- **Visual separator**: Clear division between active and completed tasks
- **Enhanced sorting**: Multiple sort modes with keyboard shortcuts
- **Configurable storage**: Custom file path support via environment variables
- **Updated branding**: Clean "Taskman v2.0" title

### Version 1.0 (Previous)
- Basic task management with CRUD operations
- Priority system with color-coded bullets
- Interactive UI and CLI interface
- Persistent JSON storage

## Architecture

### Component Overview

```
Taskman Plugin
├── Core Components
│   ├── task_manager.py     # Main interactive UI and task management logic
│   ├── dino_animation.py   # Modular animation system with physics engine
│   ├── task_cli.py         # Command-line interface
│   └── taskman.plugin.zsh  # Shell integration and aliases
├── Data Layer
│   └── tasks.json          # Persistent storage (configurable location)
└── Integration
    ├── osh version         # Native osh plugin
    └── oh-my-zsh version   # Oh-My-Zsh compatible version
```

### Data Flow

```
User Input → Shell Plugin → Python CLI/UI → Task Manager → JSON Storage
                ↓
         Auto-completion, Aliases, Environment Setup
```

## Core Components

### 1. Task Manager (`task_manager.py`)

**Purpose**: Provides the interactive terminal UI and core task management functionality.

**Key Classes**:

#### `Task`
```python
class Task:
    def __init__(self, id: int, text: str, completed: bool = False,
                 priority: str = "normal", created_at: str = None)
```

**Attributes**:
- `id`: Unique identifier (auto-incrementing)
- `text`: Task description
- `completed`: Boolean completion status
- `priority`: "high", "normal", or "low"
- `created_at`: ISO timestamp for creation time

**Methods**:
- `to_dict()`: Serialize to JSON-compatible dictionary
- `from_dict()`: Deserialize from dictionary

#### `TaskManager`
**Purpose**: Handles task storage, sorting, and persistence.

**Key Methods**:
- `load_tasks()`: Load tasks from JSON file
- `save_tasks()`: Persist tasks to JSON file
- `add_task()`: Create new task with auto-sorting
- `toggle_task()`: Toggle completion status with re-sorting
- `delete_task()`: Remove task and update selection
- `sort_tasks()`: Apply current sort mode with completed tasks at bottom
- `set_sort_mode()`: Change sorting mode and persist
- `cycle_sort_mode()`: Rotate through available sort modes

**Sorting Logic**:
```python
def sort_tasks(self):
    if self.sort_mode == "priority":
        priority_order = {"high": 0, "normal": 1, "low": 2}
        self.tasks.sort(key=lambda t: (
            t.completed,  # Completed tasks always at bottom
            priority_order.get(t.priority, 1),
            t.id
        ))
    elif self.sort_mode == "alphabetical":
        self.tasks.sort(key=lambda t: (
            t.completed,
            t.text.lower()
        ))
    else:  # default
        self.tasks.sort(key=lambda t: (
            t.completed,
            t.id
        ))
```

#### `TaskManagerUI`
**Purpose**: Handles the interactive curses-based terminal interface.

**Key Features**:
- Non-blocking input with 100ms refresh rate
- Color-coded display with priority-based text colors
- Keyboard navigation and shortcuts
- Help panel with comprehensive documentation
- Input mode for task creation with priority cycling

**Color Scheme Implementation**:
```python
# Color pairs for different states
curses.init_pair(3, curses.COLOR_RED, curses.COLOR_BLACK)     # High priority
curses.init_pair(4, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # Normal priority
curses.init_pair(5, curses.COLOR_CYAN, curses.COLOR_BLACK)    # Low priority
curses.init_pair(9, curses.COLOR_RED, curses.COLOR_BLACK)     # Completed high (dimmed)
curses.init_pair(10, curses.COLOR_YELLOW, curses.COLOR_BLACK) # Completed normal (dimmed)
curses.init_pair(11, curses.COLOR_CYAN, curses.COLOR_BLACK)   # Completed low (dimmed)
```

**Timer Implementation**:
```python
def humanize_time_delta(created_at: str) -> str:
    created = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
    if created.tzinfo is None:
        created = created.replace(tzinfo=timezone.utc)

    now = datetime.now(timezone.utc)
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
```

### 2. Command Line Interface (`task_cli.py`)

**Purpose**: Provides command-line operations for quick task management.

**Key Features**:
- Matches UI color scheme and formatting
- Supports all task operations (add, list, complete, delete, sort)
- Displays humanized timers and visual separators
- Error handling with colored output

**Color Implementation**:
```python
# Priority-based text coloring with dimming for completed tasks
if task.completed:
    bullet_color = "\033[32m"  # Green bullet
    if task.priority == "high":
        text_color = "\033[2;31m"  # Dimmed red
    elif task.priority == "low":
        text_color = "\033[2;36m"  # Dimmed cyan
    else:
        text_color = "\033[2;33m"  # Dimmed yellow
else:
    # Active tasks - bullet and text same color
    if task.priority == "high":
        bullet_color = "\033[31m"  # Red
        text_color = "\033[31m"    # Red
    # ... etc
```

### 3. Shell Integration (`taskman.plugin.zsh`)

**Purpose**: Provides shell-level integration, aliases, and auto-completion.

**Key Features**:
- Environment variable support for custom storage paths
- Auto-completion for commands and arguments
- Convenient aliases (`tm`, `task`, `todo`)
- Startup summary (optional)
- Help system integration

**Environment Variable Handling**:
```bash
# Set the data file path (can be customized via environment variable)
export TASKMAN_DATA_FILE="${TASKMAN_DATA_FILE:-$TASKMAN_DATA_DIR/tasks.json}"
```

**Auto-completion Implementation**:
```bash
_taskman_completion() {
    local -a actions
    actions=(
        'ui:Launch interactive UI'
        'add:Add new task'
        'list:List tasks'
        'done:Mark task complete'
        'delete:Delete task'
        'sort:Set sorting mode'
        'help:Show help'
    )
    _describe 'actions' actions
}
```

## Data Storage

### JSON Schema

```json
{
  "tasks": [
    {
      "id": 1,
      "text": "Task description",
      "completed": false,
      "priority": "normal",
      "created_at": "2024-01-01T12:00:00"
    }
  ],
  "next_id": 2,
  "sort_mode": "default"
}
```

### Storage Locations

**Default**: `~/.taskman/tasks.json`
**Custom**: Set via `TASKMAN_DATA_FILE` environment variable

**Directory Creation**:
- Automatic creation of parent directories
- Graceful handling of permission issues
- Support for relative and absolute paths

## Visual Design System

### Color Philosophy

The plugin implements a sophisticated color system designed for productivity:

1. **Priority-Based Text Colors**: Task text inherits priority colors for immediate visual identification
2. **Contextual Dimming**: Completed tasks retain priority colors but are dimmed to reduce visual noise
3. **Consistent Iconography**: Clear status and priority indicators
4. **Visual Hierarchy**: Separators and spacing create clear information hierarchy

### Color Mapping

| Priority | Active Color | Completed Color | ANSI Code Active | ANSI Code Completed |
|----------|-------------|----------------|------------------|-------------------|
| High     | Red         | Dimmed Red     | `\033[31m`       | `\033[2;31m`      |
| Normal   | Yellow      | Dimmed Yellow  | `\033[33m`       | `\033[2;33m`      |
| Low      | Cyan        | Dimmed Cyan    | `\033[36m`       | `\033[2;36m`      |

### Typography

- **Bullets**: `○` (pending), `✓` (completed)
- **Priority Indicators**: `!` (high), `-` (normal), `·` (low)
- **Timers**: `[2h]`, `[5m]`, `[3d]` format
- **Separator**: `─` character repeated across width

## Enhanced Animation System

### Architecture Overview

The enhanced animation system provides a multi-layer, high-frame-rate visual experience with toggle control. The system is built around the `DinoAnimation` class with sophisticated obstacle management and visual effects.

### Core Components

#### `DinoAnimation` Class

**Purpose**: Manages the three-layer animation system with smooth 60fps rendering.

**Key Features**:
- **Frame Rate**: 60fps (60ms update intervals) vs previous 150ms
- **Multi-layer Display**: Sky, Jump, and Ground layers
- **Toggle Control**: Enable/disable animation with 'x' key
- **Varied Content**: 40+ obstacle types, clouds, and atmospheric effects

#### Animation Layers

**Sky Layer (Top)**:
- Background clouds: ☁️, ⛅, 🌤️, ☀️, 🌙, ⭐, ✨, 🌟
- Flying obstacles: 🦅, 🦆, 🐦, ✈️, 🚁, 🛸, ☁️, ⭐
- Atmospheric elements with slow movement (0.3-0.8 speed)

**Jump Layer (Middle)**:
- Jumping player sprites: ◆, ◇, ◈, ◉
- Medium obstacles: 🌵, 🪨, 🌳, 🏔️, 🗿, ⛰️, 🌲, 🌴
- Tall obstacle connectors: │, ┬
- Motion trails and effects

**Ground Layer (Bottom)**:
- Running player sprites: ●, ○, ●, ◐, ◑, ◒, ◓, ◔ (8-frame animation)
- Ground obstacles: |, ┃, ▌, █, ▐, ║, ▍, ▎, ▏
- Special effects: 💨, 💥, ⚡, 🔥, ❄️, 🌪️, 🌈, ✨
- Enhanced ground pattern: ., ·, ˙, ∘, ○, ●
- Dust effects and motion blur

## Modular Animation System (v2.2)

### Separated Architecture

The animation system has been refactored into a separate module (`dino_animation.py`) for better maintainability and modularity.

#### `DinoAnimation` Class (Modular Version)

**Purpose**: Standalone animation engine with realistic physics and ASCII art obstacles.

**Key Improvements**:
- **Realistic Physics**: Gravity-based jumping with acceleration (gravity=0.6, initial_velocity=2.8)
- **ASCII Art Obstacles**: Multi-character obstacles with visual stacking
- **Smart Collision**: Multi-character width collision detection
- **Simplified Heights**: Ground obstacles (1-2), flying obstacles (2-3)
- **Input Protection**: Animation hides during task input modes

#### ASCII Art Obstacle System

**Height 1 Obstacles** (Single character):
```python
'|', '┃', '▌', '█', '▐', '║', '▍', '▎', '▏', '▋', '▊', '▉'
```

**Height 2 Obstacles** (Stacked ASCII art):
```python
# Mountain peaks
{'base': '/|\\', 'top': '/^\\'},
# Buildings
{'base': '|||', 'top': '═══'},
# Rock formations
{'base': '▓▓▓', 'top': '^^^'},
# Towers
{'base': '│█│', 'top': '┌─┐'},
# Trees
{'base': '/█\\', 'top': ' ○ '},
# Fences
{'base': '▀▀▀', 'top': '┬┬┬'}
```

#### Physics Engine

**Jumping Mechanics**:
```python
def update_physics(self):
    if self.is_jumping:
        # Apply gravity
        self.velocity_y -= self.gravity
        self.player_y += self.velocity_y

        # Ground collision
        if self.player_y <= 0:
            self.player_y = 0
            self.is_jumping = False
            self.velocity_y = 0

def jump(self):
    if not self.is_jumping:
        self.is_jumping = True
        self.velocity_y = self.initial_velocity
```

**Smart Obstacle Logic**:
```python
def should_jump(self, obstacle):
    # Only jump for ground obstacles
    if obstacle['height'] <= 2:  # Ground obstacles
        distance = obstacle['x'] - self.player_pos
        return 3 <= distance <= 8  # Jump window
    return False  # Don't jump for flying obstacles
```

#### Collision Detection

**Multi-character Width Support**:
```python
def check_collision(self, obstacle):
    obstacle_width = len(obstacle['chars'][0]) if obstacle['chars'] else 1

    # Check collision with obstacle width
    for i in range(obstacle_width):
        if (obstacle['x'] + i == self.player_pos and
            obstacle['height'] <= 2 and  # Ground level
            not self.is_jumping):
            return True
    return False
```

#### Display System

**Multi-layer Rendering**:
```python
def render_layers(self, width):
    # Sky layer (clouds and flying objects)
    sky_line = self.render_sky_layer(width)

    # High layer (tall obstacles top parts)
    high_line = self.render_high_layer(width)

    # Mid layer (medium obstacles)
    mid_line = self.render_mid_layer(width)

    # Jump layer (player when jumping)
    jump_line = self.render_jump_layer(width)

    # Ground layer (ground obstacles and running player)
    ground_line = self.render_ground_layer(width)

    # Base layer (ground pattern)
    base_line = self.render_base_layer(width)

    return [sky_line, high_line, mid_line, jump_line, ground_line, base_line]
```

### Integration with Task Manager

**Animation Toggle**:
```python
elif key == ord('x'):
    self.animation_enabled = not self.animation_enabled
    if self.animation_enabled and not hasattr(self, 'animation'):
        from .dino_animation import DinoAnimation
        self.animation = DinoAnimation()
```

**Input Mode Protection**:
```python
# Hide animation during input to prevent interference
if self.input_mode or self.help_mode:
    animation_lines = []
else:
    animation_lines = self.animation.get_frame(width - 2) if self.animation_enabled else []
```

## User Experience Design

### Keyboard Shortcuts

**Navigation**:
- `↑`/`k`: Move up (Vim-style)
- `↓`/`j`: Move down (Vim-style)

**Task Operations**:
- `n`: New task
- `Space`: Toggle completion
- `d`: Delete task

**Sorting**:
- `s`: Cycle sort modes
- `p`: Sort by priority
- `a`: Sort alphabetically

**Interface**:
- `h`: Toggle help
- `x`: Toggle animation on/off
- `q`: Quit

### Information Hierarchy

1. **Title Bar**: Application name and sort mode
2. **Status Line**: Task counts and help hint
3. **Task List**: Main content area with timers, bullets, and text
4. **Separator**: Visual division between active and completed
5. **Input Area**: Task creation interface (when active)
6. **Status Bar**: Context-sensitive help and shortcuts

## Development Patterns

### Error Handling

```python
try:
    # Task operations
    pass
except (json.JSONDecodeError, FileNotFoundError):
    # Graceful fallback to empty state
    self.tasks = []
    self.next_id = 1
    self.sort_mode = "default"
```

### State Management

- **Persistent State**: Sort mode, task data
- **Session State**: Selected index, input mode, help visibility
- **Automatic Persistence**: Save on every modification

### Cross-Platform Compatibility

- **Path Handling**: Uses `os.path` for cross-platform compatibility
- **Terminal Detection**: Graceful fallback for limited terminal capabilities
- **Python Version**: Compatible with Python 3.6+

## Testing Strategy

### Manual Testing Scenarios

1. **Basic Operations**:
   - Add tasks with different priorities
   - Toggle completion status
   - Delete tasks
   - Sort by different modes

2. **Edge Cases**:
   - Empty task list
   - Very long task descriptions
   - Invalid JSON data
   - Missing directories

3. **Visual Testing**:
   - Color display in different terminals
   - Layout with various terminal sizes
   - Timer accuracy and formatting

4. **Integration Testing**:
   - Shell alias functionality
   - Auto-completion behavior
   - Environment variable handling

### Performance Considerations

- **File I/O**: Minimal writes, only on modifications
- **UI Refresh**: 100ms refresh rate for responsive feel
- **Memory Usage**: Efficient task storage and sorting
- **Startup Time**: Fast initialization with lazy loading

## Deployment Architecture

### Dual Distribution

The plugin supports two deployment models:

1. **osh Native**: Direct integration with osh plugin system
2. **Oh-My-Zsh**: Compatible with Oh-My-Zsh plugin architecture

### File Structure

```
plugins/taskman/
├── task_manager.py          # Core UI logic
├── task_cli.py              # CLI interface
├── taskman.plugin.zsh       # osh shell integration
├── README.md                # User documentation
├── DEVELOPMENT.md           # This technical document
└── oh-my-zsh-version/       # Oh-My-Zsh compatible version
    ├── bin/
    │   ├── task_manager.py   # Copied from parent
    │   └── task_cli.py       # Copied from parent
    ├── taskman.plugin.zsh    # Oh-My-Zsh specific integration
    ├── README.md             # Oh-My-Zsh specific documentation
    └── _taskman              # Zsh completion definitions
```

## Configuration System

### Environment Variables

- `TASKMAN_DATA_FILE`: Custom storage location
- `TASKMAN_DATA_DIR`: Default directory (fallback)

### Configuration Precedence

1. `TASKMAN_DATA_FILE` (highest priority)
2. `$HOME/.taskman/tasks.json` (default)
3. Current directory fallback (emergency)

### Runtime Configuration

- Sort mode persistence in JSON
- UI state (help visibility, input mode)
- Selection state management

## Future Development Considerations

### Extensibility Points

1. **Custom Themes**: Color scheme configuration
2. **Plugin System**: Additional task metadata
3. **Export Formats**: CSV, Markdown, etc.
4. **Sync Integration**: Cloud storage, Git repositories
5. **Notification System**: Desktop notifications for due dates

### Performance Optimizations

1. **Lazy Loading**: Load tasks on demand for large datasets
2. **Incremental Sorting**: Optimize sort operations
3. **Caching**: Cache formatted display strings
4. **Background Operations**: Async file operations

### Accessibility Improvements

1. **Screen Reader Support**: Better terminal accessibility
2. **High Contrast Mode**: Enhanced color schemes
3. **Keyboard Navigation**: Additional navigation options
4. **Font Size Adaptation**: Dynamic layout adjustment

## Development Workflow

### Code Organization

- **Separation of Concerns**: UI, CLI, and shell integration are separate
- **Shared Logic**: Common functionality in reusable modules
- **Configuration Management**: Centralized environment handling

### Version Control Strategy

- **Feature Branches**: Separate branches for major features
- **Dual Maintenance**: Keep osh and Oh-My-Zsh versions in sync
- **Documentation Updates**: Update docs with every feature change

### Release Process

1. **Development**: Feature implementation and testing
2. **Documentation**: Update README and DEVELOPMENT.md
3. **Synchronization**: Copy changes to Oh-My-Zsh version
4. **Testing**: Comprehensive testing in both environments
5. **Versioning**: Update version numbers consistently

## AI Assistant Integration

This documentation is specifically designed to enable AI assistants to understand and extend the Taskman plugin effectively. Key information for AI development:

### Code Patterns

- **Consistent Naming**: Functions use snake_case, classes use PascalCase
- **Error Handling**: Graceful degradation with user-friendly messages
- **State Management**: Clear separation between persistent and session state
- **Color Handling**: ANSI escape codes with consistent patterns

### Extension Guidelines

- **Maintain Compatibility**: Preserve existing API and file formats
- **Follow Patterns**: Use established patterns for new features
- **Update Documentation**: Keep README and DEVELOPMENT.md current
- **Test Thoroughly**: Verify both UI and CLI functionality
- **Sync Versions**: Maintain parity between osh and Oh-My-Zsh versions

### Common Development Tasks

1. **Adding New Commands**: Extend CLI parser and shell integration
2. **UI Enhancements**: Modify TaskManagerUI class methods
3. **Color Scheme Changes**: Update color pair definitions
4. **Storage Format Changes**: Modify Task class and migration logic
5. **Performance Improvements**: Optimize sorting and display logic

This technical documentation provides the foundation for understanding, maintaining, and extending the Taskman plugin effectively.

## Latest Animation System Summary (v2.2)

The current animation system represents a significant evolution from the original implementation:

### Key Achievements

1. **Modular Architecture**: Separated into `dino_animation.py` for better maintainability
2. **Realistic Physics**: Gravity-based jumping with proper acceleration/deceleration
3. **ASCII Art Obstacles**: Multi-character obstacles with visual stacking and proper collision detection
4. **Smart Logic**: Ground obstacles trigger jumps, flying obstacles pass overhead
5. **Input Protection**: Animation automatically hides during task input to prevent interference
6. **Performance Optimized**: Efficient rendering with smart redraw system

### Technical Highlights

- **Physics Engine**: Gravity (0.6), initial velocity (2.8), realistic jumping arc
- **Collision System**: Multi-character width detection for ASCII art obstacles
- **Height System**: Simplified to ground (1-2) and flying (2-3) heights
- **Visual Stacking**: Height 2 obstacles use base+top ASCII art pairs
- **Layer Rendering**: 6-layer system (sky, high, mid, jump, ground, base)

### Development Impact

The modular design enables:
- Easy maintenance and debugging
- Independent testing of animation components
- Future enhancements without affecting core task management
- Clear separation of concerns between UI and entertainment features

This represents the culmination of iterative development with continuous user feedback, resulting in a polished and engaging animation system that enhances the task management experience without interfering with productivity.