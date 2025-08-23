# Simple 4D Work Capture System

Quick capture work items into Do/Defer/Delegate/Drop categories across Apple devices.

## ✅ Current Status

**macOS Menu Bar App**: ✅ COMPLETED - Fully functional with keyboard shortcuts
**iOS Shortcuts**: 🔄 PLANNED - iOS shortcuts for voice/text input

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

### ❌ OUT OF SCOPE (Explicitly Excluded)
- Rich text editing or formatting
- Custom storage/sync (use Apple's)
- Advanced UI/UX (keep minimal)
- Priority levels or due dates
- Category customization
- Analytics or metrics
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

**Next**: iOS shortcuts implementation for mobile capture workflow
