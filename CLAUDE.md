# Simple 4D Work Capture System

Quick capture work items into Do/Defer/Delegate/Drop categories across Apple devices.

## ✅ Current Status

**macOS Menu Bar App**: ✅ COMPLETED - Fully functional with keyboard shortcuts
**iOS Shortcuts**: 🔄 PLANNED - iOS shortcuts for voice/text input

## 🔄 Evolution: Smart Reminders Wrapper

Leveraging Apple Reminders' native notification system to add timely task disposal without reinventing the wheel.

### Planned Enhancements

#### Phase 1: Smart Due Dates & Alerts
- **Do items**: Auto-set due date for today/tomorrow with morning reminder
- **Defer items**: Auto-set for next week with weekly review prompt
- **Delegate items**: Auto-set 3-day follow-up reminder
- **Drop items**: No due date (archive list)

#### Phase 2: Two-Way Sync Dashboard
- **Quick View**: Show today's Do items and overdue tasks in menu bar
- **Batch Actions**: Complete all, defer all, reschedule multiple
- **Stats Display**: "5 Do, 3 Defer, 2 Delegate" at a glance
- **Pull to Refresh**: Sync with Reminders app changes

#### Phase 3: Smart Templates
- **Preset Patterns**: "Daily standup" → Do today 9 AM
- **Recurring Tasks**: Auto-create weekly reviews
- **Context Tags**: #home, #work, #errands in notes field
- **Priority Levels**: Use Reminders priority (1-9) for urgency

#### Phase 4: Advanced Features
- **Weekly Review Mode**: See all deferred items at once
- **Delegation Tracking**: Follow-up reminders for delegated tasks
- **Location-Based**: Trigger reminders at specific locations
- **Completion Analytics**: Track productivity patterns

### Benefits of Wrapper Approach
✅ Uses Apple's robust notification system  
✅ Works across all Apple devices automatically  
✅ Free Siri integration ("Hey Siri, remind me to...")  
✅ Location-based reminders  
✅ No custom notification code needed  
✅ iCloud sync built-in

## 🎯 What We Built

**macOS Menu Bar App**: 
- Global hotkey (⌘⇧Space) opens capture popup
- Keyboard shortcuts (⌘1/2/3/4) for instant category selection  
- Saves directly to Apple Reminders lists
- Auto-clears for next capture

**Planned iOS Integration**: Voice/text input → Back tap trigger → Save to category lists

## 🚀 Usage

### macOS App
1. **Open**: Press ⌘⇧Space from anywhere
2. **Type**: Enter your capture text
3. **Save**: Press ⌘1 (Do), ⌘2 (Defer), ⌘3 (Delegate), or ⌘4 (Drop)
4. **Done**: Text clears, ready for next item

### Setup Requirements
- Create 4 Reminder lists: "4D - Do", "4D - Defer", "4D - Delegate", "4D - Drop"
- Grant Reminders permission when prompted
- Works offline, syncs via iCloud when online

## 🚧 Scope & Constraints

### ✅ IN SCOPE (Must Have)
- Simple text input (single line)
- 4 fixed categories: Do/Defer/Delegate/Drop
- Save to Apple Reminders lists
- macOS menu bar presence
- iOS shortcuts for voice/text input
- Basic error handling

### 🚀 IN SCOPE (Wrapper Enhancements)
- Due dates via Reminders API (auto-set per category)
- Priority levels via Reminders (1-9 scale)
- Alert notifications via Reminders
- Two-way sync with Reminders lists
- Dashboard view of active tasks
- Batch operations on tasks
- Template system for common tasks

### ❌ OUT OF SCOPE (Explicitly Excluded)
- Rich text editing or formatting
- Custom storage/sync (use Apple's)
- Custom notification system (use Reminders')
- Category customization beyond 4D
- File attachments
- Multi-line input

### 🎯 Performance Results
- ✅ Launch app in ~1 second (beats <2s target)
- ✅ Capture + save workflow in ~3 seconds (beats <10s target)  
- ✅ Works offline, syncs when online via iCloud
- ✅ Zero configuration after Reminders lists setup

## 🛠 Technical Implementation

### macOS App Architecture
- **Language**: Swift 5.5+, SwiftUI + AppKit
- **Global Hotkey**: Carbon framework integration (⌘⇧Space)
- **Keyboard Shortcuts**: SwiftUI onKeyPress with Command modifier detection
- **Storage**: EventKit framework → Apple Reminders lists
- **UI**: NSPopover with menu bar NSStatusItem

### File Structure
```
macos-menubar/
├── Simple4D/
│   ├── Models/
│   │   ├── Category.swift          # 4D categories with shortcuts
│   │   └── CaptureItem.swift       # Data model
│   ├── Extensions/
│   │   └── HotKeyManager.swift     # Global hotkey handling
│   ├── Simple4DApp.swift           # Main app + AppDelegate
│   ├── MenuBarView.swift           # SwiftUI capture interface
│   └── ReminderManager.swift       # EventKit integration
└── Simple4D.xcodeproj
```

## 📦 Components

### 1. macOS Menu Bar App
- Text input field
- 4 category buttons (Do/Defer/Delegate/Drop)
- Saves to corresponding Apple Reminder list
- Hotkey for quick access

### 2. iOS Shortcuts (4 shortcuts)
- "Add to Do" 
- "Add to Defer"
- "Add to Delegate" 
- "Add to Drop"

## 📦 Key Features

### macOS Menu Bar App
- **Global Hotkey**: ⌘⇧Space opens capture popup from anywhere
- **Keyboard Shortcuts**: ⌘1/2/3/4 for Do/Defer/Delegate/Drop
- **EventKit Integration**: Saves directly to Apple Reminders lists
- **Menu Bar Integration**: Discrete grid icon, NSPopover interface
- **Auto-clear**: Text field clears after successful capture

### iOS Integration (Planned)
- iOS Shortcuts for voice/text input
- Back tap trigger support
- Siri integration for hands-free capture
- Apple Watch compatibility

## 🔧 Development Notes

**Completed**: macOS app fully functional with ~250 lines of Swift code
**Time to Build**: ~4 hours from planning to completion
**Key Challenge Solved**: Reliable keyboard navigation with Cmd+Number shortcuts

**Next Phase**: Transform into smart Reminders wrapper with:
- Auto due dates per category
- Two-way sync dashboard
- Batch operations
- Template system

## 📋 Implementation Roadmap

### Phase 1: Enhanced Reminder Creation (2-3 hours)
- Modify `ReminderManager.swift` to add due dates
- Add priority levels (1-9) based on input markers (!, !!, !!!)
- Set alert times (Do=9am, Defer=Monday 9am, Delegate=3 days)
- Add notes field for context/tags

### Phase 2: Dashboard View (3-4 hours)
- Create `DashboardView.swift` with task list
- Implement fetch from Reminders lists
- Add quick complete/reschedule actions
- Show overdue items prominently
- Add pull-to-refresh

### Phase 3: Smart Templates (2 hours)
- Create `TemplateManager.swift`
- Define common patterns (daily standup, weekly review)
- Add quick template buttons to MenuBarView
- Support recurring task creation

### Phase 4: Batch Operations (2 hours)
- Add multi-select in dashboard
- Implement bulk complete/defer/drop
- Create "Review Mode" for weekly processing
- Add statistics view

### Technical Stack
- **EventKit Enhanced**: Full EKReminder properties (due date, priority, alerts)
- **SwiftUI**: Dashboard and enhanced UI
- **Combine**: Reactive updates from Reminders changes
- **UserDefaults**: Store template preferences
