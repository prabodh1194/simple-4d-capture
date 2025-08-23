import SwiftUI
import EventKit

struct DashboardView: View {
    @StateObject private var reminderManager = ReminderManager()
    @State private var activeReminders: [EKReminder] = []
    @State private var isLoading = false
    @State private var selectedReminders: Set<String> = []
    @State private var showingStats = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats and actions
                headerView
                
                Divider()
                
                // Main content
                if isLoading {
                    ProgressView("Loading reminders...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if activeReminders.isEmpty {
                    emptyStateView
                } else {
                    remindersList
                }
            }
            .navigationTitle("4D Dashboard")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Refresh") {
                        refreshReminders()
                    }
                    
                    Button("Stats") {
                        showingStats.toggle()
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .onAppear {
            initializeAndRefresh()
        }
        .sheet(isPresented: $showingStats) {
            StatsView(reminders: activeReminders)
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Active Tasks")
                    .font(.headline)
                Text(statsText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if !selectedReminders.isEmpty {
                batchActionsView
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
    
    private var batchActionsView: some View {
        HStack {
            Text("\(selectedReminders.count) selected")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Complete All") {
                markSelectedComplete()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Defer All") {
                deferSelected()
            }
            .buttonStyle(.bordered)
            
            Button("Clear Selection") {
                selectedReminders.removeAll()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("All caught up!")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("No active reminders. Use ⌘⇧Space to capture new items.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var remindersList: some View {
        List(selection: $selectedReminders) {
            ForEach(organizedReminders.keys.sorted(), id: \.self) { category in
                if let reminders = organizedReminders[category], !reminders.isEmpty {
                    Section(header: Text(category).font(.headline)) {
                        ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                            TaskRowView(
                                reminder: reminder,
                                isSelected: selectedReminders.contains(reminder.calendarItemIdentifier),
                                onComplete: { completeReminder($0) },
                                onDefer: { deferReminder($0) },
                                onDelete: { deleteReminder($0) }
                            )
                        }
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
    }
    
    private var organizedReminders: [String: [EKReminder]] {
        let categorized = Dictionary(grouping: activeReminders) { reminder in
            // Determine category based on calendar name
            guard let calendarTitle = reminder.calendar?.title else { return "Other" }
            
            if calendarTitle.contains("Do") { return "🔥 Do Today" }
            if calendarTitle.contains("Defer") { return "📅 Deferred" }
            if calendarTitle.contains("Delegate") { return "👥 Delegated" }
            if calendarTitle.contains("Drop") { return "🗂 Dropped" }
            
            return "Other"
        }
        
        // Sort reminders within each category by due date
        return categorized.mapValues { reminders in
            reminders.sorted { lhs, rhs in
                // Overdue items first
                let now = Date()
                let lhsDate = lhs.dueDateComponents?.date
                let rhsDate = rhs.dueDateComponents?.date
                
                if let lDate = lhsDate, let rDate = rhsDate {
                    let lhsOverdue = lDate < now
                    let rhsOverdue = rDate < now
                    
                    if lhsOverdue && !rhsOverdue { return true }
                    if !lhsOverdue && rhsOverdue { return false }
                    
                    return lDate < rDate
                }
                
                // Items with due dates come before items without
                if lhsDate != nil && rhsDate == nil { return true }
                if lhsDate == nil && rhsDate != nil { return false }
                
                // Both have no due date, sort by creation date
                return lhs.creationDate ?? Date.distantPast < rhs.creationDate ?? Date.distantPast
            }
        }
    }
    
    private var statsText: String {
        let counts = organizedReminders.mapValues { $0.count }
        let doCount = counts["🔥 Do Today"] ?? 0
        let deferCount = counts["📅 Deferred"] ?? 0
        let delegateCount = counts["👥 Delegated"] ?? 0
        
        var parts: [String] = []
        if doCount > 0 { parts.append("\(doCount) Do") }
        if deferCount > 0 { parts.append("\(deferCount) Defer") }
        if delegateCount > 0 { parts.append("\(delegateCount) Delegate") }
        
        return parts.isEmpty ? "No active tasks" : parts.joined(separator: ", ")
    }
    
    private func initializeAndRefresh() {
        Task {
            await reminderManager.initialize()
            await refreshReminders()
        }
    }
    
    @MainActor
    private func refreshReminders() {
        isLoading = true
        Task {
            let reminders = await reminderManager.fetchActiveReminders()
            activeReminders = reminders
            isLoading = false
        }
    }
    
    private func completeReminder(_ reminder: EKReminder) {
        Task {
            await reminderManager.markReminderComplete(reminder)
            await refreshReminders()
        }
    }
    
    private func deferReminder(_ reminder: EKReminder) {
        Task {
            await reminderManager.deferReminder(reminder, days: 7)
            await refreshReminders()
        }
    }
    
    private func deleteReminder(_ reminder: EKReminder) {
        Task {
            await reminderManager.deleteReminder(reminder)
            await refreshReminders()
        }
    }
    
    private func markSelectedComplete() {
        Task {
            for identifier in selectedReminders {
                if let reminder = activeReminders.first(where: { $0.calendarItemIdentifier == identifier }) {
                    await reminderManager.markReminderComplete(reminder)
                }
            }
            selectedReminders.removeAll()
            await refreshReminders()
        }
    }
    
    private func deferSelected() {
        Task {
            for identifier in selectedReminders {
                if let reminder = activeReminders.first(where: { $0.calendarItemIdentifier == identifier }) {
                    await reminderManager.deferReminder(reminder, days: 7)
                }
            }
            selectedReminders.removeAll()
            await refreshReminders()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}