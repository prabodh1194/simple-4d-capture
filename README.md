# Simple4D Capture

A macOS menu bar application for capturing and organizing tasks using the 4D (Do, Defer, Delegate, Drop) method integrated with your system's Reminders database.

## Features

### Quick Capture
- **Global Hotkey**: Use `Cmd+Shift+Space` to quickly capture tasks from anywhere
- **Menu Bar Interface**: Access the capture interface directly from your menu bar
- **Text Input**: Type your task or idea directly into the capture field
- **Character Counter**: Track input length (up to 200 characters)

### 4D Classification System
- **Do (1)**: Tasks to complete today - added to "4D - Do" list with due date set to today or tomorrow based on time of day
- **Defer (2)**: Tasks to postpone - added to "4D - Defer" list with due date set to next Monday
- **Delegate (3)**: Tasks to assign to others - added to "4D - Delegate" list with a 3-day follow-up
- **Drop (4)**: Tasks to discard - added to "4D - Drop" list (can be deleted later)

### Priority System
- **High Priority**: Add `!!!` at the beginning of your task text for high priority
- **Medium Priority**: Add `!!` at the beginning for medium priority  
- **Low Priority**: Add `!` at the beginning for low priority

### Advanced Features
- **Reminders Integration**: All tasks are stored in macOS Reminders using custom lists
- **Automatic Due Dates**: Tasks are assigned due dates based on category
- **Smart Alerts**: Appropriate alerts are set based on task category and urgency
- **Dashboard View**: Full-featured dashboard to manage, complete, defer, and analyze your tasks
- **Statistics**: Detailed analytics on task completion, categories, priorities, and due dates
- **Batch Operations**: Select and complete multiple tasks at once
- **Recently Completed Section**: View completed tasks within configurable time ranges (24h, 3d, 1w, 2w)
- **Context Tags**: Use `#hashtags` and `@mentions` to add context notes to tasks

### Keyboard Shortcuts
- `Cmd+D`: Open dashboard from menu bar
- `Cmd+Shift+Space`: Open quick capture from anywhere
- `Cmd+1`: Submit task as "Do"
- `Cmd+2`: Submit task as "Defer"
- `Cmd+3`: Submit task as "Delegate"
- `Cmd+4`: Submit task as "Drop"

### Dashboard Functionality
- **Active Tasks**: View all tasks organized by category
- **Task Management**: Complete, defer, or delete individual tasks
- **Statistics Dashboard**: Visual analytics of your task patterns
- **Completed Tasks**: Track recently completed items
- **Category Breakdown**: See how tasks are distributed across the 4D categories
- **Priority Distribution**: Understand your priority-setting patterns
- **Due Date Analysis**: Track overdue and upcoming tasks

## Requirements
- macOS 12.0 or later
- Access to Reminders app

## Installation
1. Clone this repository
2. Build the project with Xcode or use the Makefile:
   ```bash
   make deploy
   ```
   This will build the app and copy it to your Desktop

## Privacy
- All data is stored locally in your macOS Reminders database
- No external data collection or cloud storage
- The app only accesses Reminders after explicit permission is granted

## Usage Tips
- Use the priority prefixes (`!`, `!!`, `!!!`) to set task importance
- Include `#hashtags` or `@mentions` in your tasks to add context
- Use the dashboard regularly to move completed tasks and manage your workload
- The global hotkey works system-wide for quick capture