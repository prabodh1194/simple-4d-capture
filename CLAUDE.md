# Simple 4D Work Capture System

Quick capture work items into Do/Defer/Delegate/Drop categories across Apple devices.

## 🎯 What We're Building

**macOS Menu Bar App**: Text input → Choose category → Save to Reminders
**iOS Shortcuts**: Voice/text input → Save to specific category list

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

Each shortcut: Voice/text input → Save to that category's Reminder list

## 🚀 Implementation Steps

### Step 1: Setup (30 minutes)
- [ ] Create 4 Reminder lists in Apple Reminders app:
  - "4D - Do"
  - "4D - Defer" 
  - "4D - Delegate"
  - "4D - Drop"
- [ ] Create GitHub repo with basic structure

### Step 2: macOS Menu Bar App (2-3 hours)
- [ ] Create Swift project
- [ ] Build menu bar interface with text field + 4 buttons
- [ ] Integrate EventKit to save to Reminder lists
- [ ] Add global hotkey (e.g., Cmd+Shift+4)
- [ ] Test across all 4 categories

### Step 3: iOS Shortcuts (1 hour)
- [ ] Create 4 shortcuts in iOS Shortcuts app
- [ ] Each prompts for text/voice input
- [ ] Each saves to corresponding Reminder list
- [ ] Add to Siri for voice activation
- [ ] Test on iPhone and Apple Watch

### Step 4: Polish (30 minutes)
- [ ] Test sync across all devices
- [ ] Write simple README with setup instructions
- [ ] Done!

## 🛠 Tech Stack
- **macOS**: Swift, EventKit, NSStatusBar
- **iOS**: Shortcuts app, Siri integration
- **Storage**: Apple Reminders (free iCloud sync)

## 📁 Repo Structure
```
simple-4d-capture/
├── macos-menubar/
│   ├── Simple4D/
│   │   ├── ContentView.swift
│   │   ├── ReminderManager.swift
│   │   └── App.swift
│   └── Simple4D.xcodeproj
├── ios-shortcuts/
│   ├── Add-to-Do.shortcut
│   ├── Add-to-Defer.shortcut
│   ├── Add-to-Delegate.shortcut
│   └── Add-to-Drop.shortcut
└── README.md
```

**Total Time Estimate: 4-5 hours**
