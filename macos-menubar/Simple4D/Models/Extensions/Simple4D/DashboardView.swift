import EventKit
import SwiftUI

struct DashboardView: View {
    @StateObject private var reminderManager = ReminderManager()
    @State private var activeReminders: [EKReminder] = []
    @State private var isLoading = false
    @State private var selectedReminders: Set<String> = []
    @State private var showingStats = false
    @State private var showingCompletionConfirmation = false
    @State private var reminderToComplete: EKReminder?

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
                mainContentView
            }
        }
        .frame(minWidth: 800, minHeight: 500)
        .onAppear {
            initializeAndRefresh()
        }
        .alert("Complete Task", isPresented: $showingCompletionConfirmation) {
            Button("Cancel", role: .cancel) {
                reminderToComplete = nil
            }
            Button("Complete") {
                if let reminder = reminderToComplete {
                    completeReminder(reminder)
                }
                reminderToComplete = nil
            }
        } message: {
            if let reminder = reminderToComplete {
                Text("Complete '\(reminder.title ?? "Untitled")'?")
            }
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

    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Tasks Section
                VStack(spacing: 12) {
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

                                VStack(spacing: 4) {
                                    ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                                        CompactTaskRowView(
                                            reminder: reminder,
                                            isSelected: selectedReminders.contains(reminder.calendarItemIdentifier),
                                            onComplete: { requestCompletion($0) },
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

                // Stats Section
                if showingStats, !activeReminders.isEmpty {
                    Divider()
                        .padding(.horizontal, 16)

                    VStack(spacing: 20) {
                        // Section title
                        HStack {
                            Text("Statistics")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        .padding(.horizontal, 16)

                        // Overview Cards
                        overviewSection

                        // Category Breakdown
                        categorySection

                        // Priority Distribution
                        prioritySection

                        // Due Date Analysis
                        dueDateSection
                    }
                    .padding(.horizontal, 16)
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

    // MARK: - Stats Computed Properties

    private var doCount: Int {
        activeReminders.filter { $0.calendar?.title.contains("Do") == true }.count
    }

    private var deferCount: Int {
        activeReminders.filter { $0.calendar?.title.contains("Defer") == true }.count
    }

    private var delegateCount: Int {
        activeReminders.filter { $0.calendar?.title.contains("Delegate") == true }.count
    }

    private var dropCount: Int {
        activeReminders.filter { $0.calendar?.title.contains("Drop") == true }.count
    }

    private var highPriorityCount: Int {
        activeReminders.filter { (1 ... 3).contains($0.priority) }.count
    }

    private var mediumPriorityCount: Int {
        activeReminders.filter { (4 ... 6).contains($0.priority) }.count
    }

    private var lowPriorityCount: Int {
        activeReminders.filter { (7 ... 9).contains($0.priority) }.count
    }

    private var noPriorityCount: Int {
        activeReminders.filter { $0.priority == 0 }.count
    }

    private var overdueCount: Int {
        let now = Date()
        return activeReminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else {
                return false
            }
            return dueDate < now && !reminder.isCompleted
        }.count
    }

    private var dueTodayCount: Int {
        let now = Date()
        return activeReminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else {
                return false
            }
            return Calendar.current.isDate(dueDate, inSameDayAs: now) && !reminder.isCompleted
        }.count
    }

    private var dueThisWeekCount: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)!

        return activeReminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else {
                return false
            }
            return dueDate > now && dueDate <= weekFromNow && !reminder.isCompleted
        }.count
    }

    private var dueLaterCount: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)!

        return activeReminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else {
                return false
            }
            return dueDate > weekFromNow && !reminder.isCompleted
        }.count
    }

    private var noDueDateCount: Int {
        activeReminders.filter { $0.dueDateComponents?.date == nil && !$0.isCompleted }.count
    }

    // MARK: - Stats View Components

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                StatCard(
                    title: "Total Tasks",
                    value: "\(activeReminders.count)",
                    color: .blue,
                    icon: "list.bullet"
                )

                StatCard(
                    title: "Overdue",
                    value: "\(overdueCount)",
                    color: .red,
                    icon: "exclamationmark.triangle"
                )

                StatCard(
                    title: "Due Today",
                    value: "\(dueTodayCount)",
                    color: .orange,
                    icon: "calendar.badge.clock"
                )

                StatCard(
                    title: "High Priority",
                    value: "\(highPriorityCount)",
                    color: .red,
                    icon: "flame"
                )
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                CategoryBar(label: "🔥 Do", count: doCount, total: activeReminders.count, color: .red)
                CategoryBar(label: "📅 Defer", count: deferCount, total: activeReminders.count, color: .orange)
                CategoryBar(label: "👥 Delegate", count: delegateCount, total: activeReminders.count, color: .blue)
                CategoryBar(label: "🗂 Drop", count: dropCount, total: activeReminders.count, color: .gray)
            }
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Priority")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                CategoryBar(
                    label: "High (!!! 1-3)",
                    count: highPriorityCount,
                    total: activeReminders.count,
                    color: .red
                )
                CategoryBar(
                    label: "Medium (!! 4-6)",
                    count: mediumPriorityCount,
                    total: activeReminders.count,
                    color: .orange
                )
                CategoryBar(label: "Low (! 7-9)", count: lowPriorityCount, total: activeReminders.count, color: .yellow)
                CategoryBar(label: "None", count: noPriorityCount, total: activeReminders.count, color: .gray)
            }
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Due Date")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                CategoryBar(label: "Overdue", count: overdueCount, total: activeReminders.count, color: .red)
                CategoryBar(label: "Due Today", count: dueTodayCount, total: activeReminders.count, color: .orange)
                CategoryBar(label: "Due This Week", count: dueThisWeekCount, total: activeReminders.count, color: .blue)
                CategoryBar(label: "Due Later", count: dueLaterCount, total: activeReminders.count, color: .green)
                CategoryBar(label: "No Due Date", count: noDueDateCount, total: activeReminders.count, color: .gray)
            }
        }
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

    private func requestCompletion(_ reminder: EKReminder) {
        reminderToComplete = reminder
        showingCompletionConfirmation = true
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
