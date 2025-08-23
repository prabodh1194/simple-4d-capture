import EventKit
import SwiftUI

struct DashboardView: View {
    @StateObject private var reminderManager = ReminderManager()
    @State private var activeReminders: [EKReminder] = []
    @State private var isLoading = false
    @State private var selectedReminders: Set<String> = []
    @State private var showingStats = false

    var body: some View {
        VStack(spacing: 0) {
            // Title and toolbar
            HStack {
                Text("4D Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                HStack(spacing: 12) {
                    Button("Stats") {
                        showingStats.toggle()
                    }
                    .buttonStyle(.bordered)

                    Button("Refresh") {
                        refreshReminders()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()

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
        .frame(minWidth: 800, minHeight: 500)
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
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(organizedReminders.keys.sorted(), id: \.self) { category in
                    if let reminders = organizedReminders[category], !reminders.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("\(reminders.count) items")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(3)
                            }

                            // Use compact single-column layout for better space utilization
                            VStack(spacing: 4) {
                                ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                                    CompactTaskRowView(
                                        reminder: reminder,
                                        isSelected: selectedReminders.contains(reminder.calendarItemIdentifier),
                                        onComplete: { completeReminder($0) },
                                        onDefer: { deferReminder($0) },
                                        onDelete: { deleteReminder($0) }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }

    private var organizedReminders: [String: [EKReminder]] {
        let categorized = Dictionary(grouping: activeReminders) { reminder in
            // Determine category based on calendar name
            guard let calendarTitle = reminder.calendar?.title else {
                return "Other"
            }

            if calendarTitle.contains("Do") {
                return "🔥 Do Today"
            }
            if calendarTitle.contains("Defer") {
                return "📅 Deferred"
            }
            if calendarTitle.contains("Delegate") {
                return "👥 Delegated"
            }
            if calendarTitle.contains("Drop") {
                return "🗂 Dropped"
            }

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

                    if lhsOverdue, !rhsOverdue {
                        return true
                    }
                    if !lhsOverdue, rhsOverdue {
                        return false
                    }

                    return lDate < rDate
                }

                // Items with due dates come before items without
                if lhsDate != nil, rhsDate == nil {
                    return true
                }
                if lhsDate == nil, rhsDate != nil {
                    return false
                }

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
        if doCount > 0 {
            parts.append("\(doCount) Do")
        }
        if deferCount > 0 {
            parts.append("\(deferCount) Defer")
        }
        if delegateCount > 0 {
            parts.append("\(delegateCount) Delegate")
        }

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
