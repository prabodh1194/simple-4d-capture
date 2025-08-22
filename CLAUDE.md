# Simple 4D Work Capture System

Quick capture work items into Do/Defer/Delegate/Drop categories across Apple devices.

## 🎯 What We're Building

**macOS Menu Bar App**: Text input → Choose category → Save to Reminders
**iOS Shortcuts**: Voice/text input → Save to specific category list

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

### 🎯 Success Criteria
- Launch app in <2 seconds
- Capture + save workflow in <10 seconds
- Works offline (syncs when online)
- Zero configuration after initial setup

## 🛠 Tech Stack & Requirements

### macOS App
- **Language**: Swift 5.5+
- **Framework**: SwiftUI + AppKit
- **Min Version**: macOS 12.0 (Monterey)
- **Dependencies**: EventKit (system framework)
- **Size Target**: <5MB app bundle

### iOS Shortcuts  
- **Platform**: iOS Shortcuts app (built-in)
- **Min Version**: iOS 15.0
- **Integration**: EventKit, Siri, Apple Watch
- **No additional dependencies**

### Storage
- **Primary**: Apple Reminders (EventKit)
- **Sync**: iCloud (automatic)
- **Backup**: None needed (handled by Apple)

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

## 🚀 Detailed Implementation Steps

### Step 1: Environment Setup (30 minutes)

#### 1.1 Apple Reminders Setup (10 min)
- [ ] **Launch Reminders**: Open Apple Reminders app from Dock/Launchpad
- [ ] **Create "4D - Do" list**: 
  - [ ] Click "Add List" in sidebar
  - [ ] Name: "4D - Do" (exact spelling)
  - [ ] Color: Red (click color dot → select red)
  - [ ] Click "Done"
- [ ] **Create "4D - Defer" list**:
  - [ ] Click "Add List" again  
  - [ ] Name: "4D - Defer" (exact spelling)
  - [ ] Color: Orange
  - [ ] Click "Done"
- [ ] **Create "4D - Delegate" list**:
  - [ ] Click "Add List" again
  - [ ] Name: "4D - Delegate" (exact spelling) 
  - [ ] Color: Blue
  - [ ] Click "Done"
- [ ] **Create "4D - Drop" list**:
  - [ ] Click "Add List" again
  - [ ] Name: "4D - Drop" (exact spelling)
  - [ ] Color: Gray
  - [ ] Click "Done"
- [ ] **Verify iCloud sync**: 
  - [ ] Reminders → Preferences → Accounts
  - [ ] Check iCloud account is active
  - [ ] Verify "Reminders" checkbox is checked

#### 1.2 Xcode Project Setup (20 min)
- [ ] **Launch Xcode**: Open Xcode from Applications folder  
- [ ] **Create new project**:
  - [ ] File → New → Project
  - [ ] macOS tab → App template → Next
  - [ ] Product Name: "Simple4D"
  - [ ] Bundle Identifier: "com.yourname.simple4d" (replace yourname)
  - [ ] Language: Swift
  - [ ] Interface: SwiftUI
  - [ ] Use Core Data: UNCHECKED
  - [ ] Click "Next" → Choose location → "Create"
- [ ] **Add EventKit framework**:
  - [ ] Click project name in navigator (top level)
  - [ ] Select app target under "Targets"
  - [ ] Build Phases tab
  - [ ] Expand "Link Binary With Libraries"
  - [ ] Click "+" button
  - [ ] Search "EventKit" → Select "EventKit.framework" → Add
- [ ] **Configure Info.plist**:
  - [ ] Click Info tab (same target settings)
  - [ ] Custom macOS Application Target Properties section
  - [ ] Hover over any key → Click "+" button
  - [ ] Key: "Privacy - Reminders Usage Description"
  - [ ] Value: "This app needs access to Reminders to save your 4D capture items"
- [ ] **Create folder structure**:
  - [ ] Right-click project folder in navigator
  - [ ] New Group → Name: "Models"
  - [ ] Right-click project folder again  
  - [ ] New Group → Name: "Extensions"
- [ ] **Test build**: Cmd+B to verify project compiles

### Step 2: macOS Core Implementation (2.5 hours)

#### 2.1 Basic App Structure (45 min)

##### Create Category.swift (10 min)
- [ ] **New file**: Right-click Models folder → New File → Swift File → "Category.swift"
- [ ] **Add enum definition**: 4 cases (do, defer, delegate, drop) with CaseIterable
- [ ] **Add listName property**: Maps to "4D - Do", "4D - Defer", etc.
- [ ] **Add symbolName property**: Maps to "1.square", "2.square", etc. for SF Symbols

##### Create CaptureItem.swift (5 min)
- [ ] **New file**: Right-click Models folder → New File → Swift File → "CaptureItem.swift"
- [ ] **Add struct definition**: Simple struct with text, category, and timestamp properties

##### Create Simple4DApp.swift (15 min)
- [ ] **Replace existing App file**: Open existing app file (likely named Simple4DApp.swift)
- [ ] **Import frameworks**: SwiftUI and AppKit
- [ ] **Add NSApplicationDelegateAdaptor**: For AppDelegate class
- [ ] **Create AppDelegate class**: Handle NSStatusItem creation and menu bar presence
- [ ] **Set status bar icon**: Use "square.grid.2x2" SF Symbol

##### Create MenuBarView.swift (15 min)  
- [ ] **New file**: Right-click project folder → New File → Swift File → "MenuBarView.swift"
- [ ] **Import SwiftUI**: Basic import statement
- [ ] **Create view structure**: VStack with TextField and HStack of 4 category buttons
- [ ] **Add @State inputText**: For text field binding
- [ ] **Add ForEach for buttons**: Iterate over Category.allCases
- [ ] **Test compilation**: Cmd+B to verify no errors

#### 2.2 EventKit Integration (90 min)

##### Create ReminderManager.swift file (10 min)
- [ ] **New file**: Right-click project folder → New File → Swift File → "ReminderManager.swift"
- [ ] **Import frameworks**: Foundation and EventKit
- [ ] **Create class structure**: @MainActor ObservableObject with EKEventStore property
- [ ] **Add @Published properties**: isAuthorized (Bool) and errorMessage (String?)

##### Implement requestAccess method (20 min)
- [ ] **Add requestAccess method**: Async method to handle EventKit authorization
- [ ] **Check authorization status**: Handle all EKAuthorizationStatus cases
- [ ] **Request permission**: Use eventStore.requestAccess for .notDetermined case
- [ ] **Update published properties**: Set isAuthorized and errorMessage appropriately
- [ ] **Test compilation**: Cmd+B to verify no errors

##### Implement findOrCreateLists method (25 min)
- [ ] **Add list caching property**: Dictionary to store found/created EKCalendar objects
- [ ] **Add findOrCreateLists method**: Private async throws method
- [ ] **Get existing calendars**: Use eventStore.calendars(for: .reminder)
- [ ] **Find or create each 4D list**: Loop through Category.allCases
- [ ] **Create missing lists**: Use EKCalendar initializer and eventStore.saveCalendar
- [ ] **Add error enum**: ReminderError with appropriate cases and LocalizedError conformance

##### Implement addReminder method (25 min)
- [ ] **Add addReminder method**: Public async method taking text and category
- [ ] **Check authorization**: Ensure access before proceeding
- [ ] **Initialize lists if needed**: Call findOrCreateLists if cache is empty
- [ ] **Create EKReminder**: Set title, calendar, and priority properties
- [ ] **Save reminder**: Use eventStore.save with commit
- [ ] **Add input validation method**: Check text length and non-empty after trimming
- [ ] **Handle errors**: Update errorMessage property appropriately
- [ ] **Test compilation**: Cmd+B to verify no errors

##### Add initialization method (10 min)
- [ ] **Add initialize method**: Public async method for setup
- [ ] **Request access**: Call requestAccess method
- [ ] **Initialize lists**: Call findOrCreateLists if authorized
- [ ] **Handle initialization errors**: Update errorMessage if lists can't be created
- [ ] **Test compilation**: Cmd+B to verify no errors

#### 2.3 UI Completion (30 min)

##### Wire up ReminderManager to MenuBarView (15 min)
- [ ] **Open MenuBarView.swift**
- [ ] **Import EventKit**: Add import statement at top
- [ ] **Add ReminderManager property**: @StateObject private var reminderManager
- [ ] **Add loading state**: @State private var isSubmitting for button states
- [ ] **Update button actions**: Add Task blocks to call reminderManager.addReminder
- [ ] **Add button disabled state**: Disable when submitting or input is empty
- [ ] **Clear input on success**: Reset inputText when errorMessage is nil

##### Add UI feedback states (15 min)
- [ ] **Add error display**: Conditional Text view for reminderManager.errorMessage
- [ ] **Add character count**: HStack with inputText.count/200 display
- [ ] **Add loading indicator**: ProgressView when isSubmitting is true
- [ ] **Initialize on appear**: .onAppear modifier with Task calling reminderManager.initialize
- [ ] **Test**: Cmd+R to run app, verify UI updates

#### 2.4 Global Hotkey (15 min)
- [ ] **New file**: Right-click Extensions folder → New File → Swift File → "HotKey.swift"
- [ ] **Import Carbon framework**: For system-level hotkey registration
- [ ] **Create HotKeyManager class**: Handle global hotkey registration and callbacks
- [ ] **Register Cmd+Shift+4**: Use Carbon APIs to register key combination
- [ ] **Add callback handler**: Show menu bar popup when hotkey is pressed
- [ ] **Test**: Press Cmd+Shift+4 from any app to verify popup appears

### Step 3: iOS Shortcuts Creation (1 hour)

#### 3.1 Create First Shortcut - "Add to Do" (20 min)
- [ ] Open iOS Shortcuts app
- [ ] New shortcut → Add Action → "Ask for Input"
- [ ] Configure: Input Type = Text, Prompt = "What needs to be done?"
- [ ] Add Action → "Add New Reminder"
- [ ] Configure: List = "4D - Do", Reminder = [Input Text]
- [ ] Name shortcut "Add to Do"
- [ ] Test: Run shortcut, verify reminder appears

#### 3.2 Duplicate for Other Categories (15 min)
- [ ] Duplicate "Add to Do" shortcut 3 times
- [ ] Rename: "Add to Defer", "Add to Delegate", "Add to Drop"
- [ ] Update each: Change list to corresponding 4D list
- [ ] Update prompts: "What to defer?", "What to delegate?", "What to drop?"

#### 3.3 Siri Integration (15 min)  
- [ ] For each shortcut: Settings → Add to Siri
- [ ] Record phrases: "Add to do", "Add to defer", etc.
- [ ] Test: Voice activation works on iPhone
- [ ] Test: Works on Apple Watch (if available)

#### 3.4 Export Shortcuts (10 min)
- [ ] Share each shortcut → Save to Files
- [ ] Copy .shortcut files to project repo
- [ ] Create setup-instructions.md with import steps

### Step 4: Testing & Polish (30 minutes)

#### 4.1 Cross-Platform Testing (20 min)
- [ ] Add reminder via macOS app → verify appears on iPhone
- [ ] Add reminder via iOS shortcut → verify appears on Mac
- [ ] Test offline: Add items without internet, verify sync when online
- [ ] Test edge cases: Empty input, very long text, special characters

#### 4.2 Final Polish (10 min)
- [ ] Update app icon (simple 4-square grid)
- [ ] Add "About" menu item with version info
- [ ] Create README.md with user setup instructions
- [ ] Test: Fresh install experience on clean system

## ⚡ Quick Start Commands

```bash
# Create Xcode project
cd macos-menubar
xcodebuild -project Simple4D.xcodeproj -scheme Simple4D build

# Test EventKit access
# (Run from within app - requires user permission)
```

## 🔍 Testing Checkpoints

After each major step, verify:
- **Step 1**: Lists exist in Reminders, Xcode builds
- **Step 2.1**: Menu bar icon visible, popup works  
- **Step 2.2**: Can add reminders programmatically
- **Step 2.3**: Full UI workflow successful
- **Step 3**: All 4 shortcuts work independently
- **Step 4**: Cross-device sync confirmed

**Total Time Estimate: 4-5 hours**

## 📁 Detailed Code Structure

```
simple-4d-capture/
├── macos-menubar/
│   ├── Simple4D/
│   │   ├── Simple4DApp.swift          # Main app entry point, NSStatusBar setup
│   │   ├── MenuBarView.swift          # SwiftUI popup interface
│   │   ├── ReminderManager.swift      # EventKit integration, list management
│   │   ├── Models/
│   │   │   ├── Category.swift         # 4D category enum + properties
│   │   │   └── CaptureItem.swift      # Text + category data model
│   │   ├── Extensions/
│   │   │   └── HotKey.swift           # Global keyboard shortcut handler
│   │   └── Info.plist                 # Permissions: EventKit access
│   ├── Simple4D.xcodeproj
│   └── Simple4D.entitlements          # App sandbox + EventKit entitlement
├── ios-shortcuts/
│   ├── shortcuts-source/              # JSON definitions for reproducibility
│   │   ├── add-to-do.json
│   │   ├── add-to-defer.json
│   │   ├── add-to-delegate.json
│   │   └── add-to-drop.json
│   ├── exports/                       # Shareable .shortcut files
│   │   ├── Add-to-Do.shortcut
│   │   ├── Add-to-Defer.shortcut
│   │   ├── Add-to-Delegate.shortcut
│   │   └── Add-to-Drop.shortcut
│   └── setup-instructions.md          # Step-by-step import guide
└── README.md                          # User setup instructions
```

### Key File Responsibilities

**Simple4DApp.swift** (30 lines)
- Creates NSStatusItem with custom icon
- Manages app lifecycle and menu bar presence
- Handles global hotkey registration (Cmd+Shift+4)

**MenuBarView.swift** (80 lines)  
- SwiftUI popup with TextField + 4 buttons
- Input validation (max 200 chars)
- Category selection and submission logic

**ReminderManager.swift** (120 lines)
- EventKit authorization flow
- Find/create 4D reminder lists  
- Add reminder items with proper metadata
- Error handling for permissions/network issues

**Category.swift** (25 lines)
- Enum: `.do`, `.defer`, `.delegate`, `.drop`
- List name mapping: "4D - Do", "4D - Defer", etc.
- UI colors and SF Symbol icons

**Total Time Estimate: 4-5 hours**
