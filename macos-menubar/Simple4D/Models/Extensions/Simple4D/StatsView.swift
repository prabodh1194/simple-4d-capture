import SwiftUI
import EventKit

struct StatsView: View {
    let reminders: [EKReminder]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overview Cards
                    overviewSection
                    
                    // Category Breakdown
                    categorySection
                    
                    // Priority Distribution
                    prioritySection
                    
                    // Due Date Analysis
                    dueDateSection
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .frame(minWidth: 500, minHeight: 400)
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                StatCard(
                    title: "Total Tasks",
                    value: "\(reminders.count)",
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
                CategoryBar(label: "🔥 Do", count: doCount, total: reminders.count, color: .red)
                CategoryBar(label: "📅 Defer", count: deferCount, total: reminders.count, color: .orange)
                CategoryBar(label: "👥 Delegate", count: delegateCount, total: reminders.count, color: .blue)
                CategoryBar(label: "🗂 Drop", count: dropCount, total: reminders.count, color: .gray)
            }
        }
    }
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Priority")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                CategoryBar(label: "High (!!! 1-3)", count: highPriorityCount, total: reminders.count, color: .red)
                CategoryBar(label: "Medium (!! 4-6)", count: mediumPriorityCount, total: reminders.count, color: .orange)
                CategoryBar(label: "Low (! 7-9)", count: lowPriorityCount, total: reminders.count, color: .yellow)
                CategoryBar(label: "None", count: noPriorityCount, total: reminders.count, color: .gray)
            }
        }
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Due Date")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                CategoryBar(label: "Overdue", count: overdueCount, total: reminders.count, color: .red)
                CategoryBar(label: "Due Today", count: dueTodayCount, total: reminders.count, color: .orange)
                CategoryBar(label: "Due This Week", count: dueThisWeekCount, total: reminders.count, color: .blue)
                CategoryBar(label: "Due Later", count: dueLaterCount, total: reminders.count, color: .green)
                CategoryBar(label: "No Due Date", count: noDueDateCount, total: reminders.count, color: .gray)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var doCount: Int {
        reminders.filter { $0.calendar?.title.contains("Do") == true }.count
    }
    
    private var deferCount: Int {
        reminders.filter { $0.calendar?.title.contains("Defer") == true }.count
    }
    
    private var delegateCount: Int {
        reminders.filter { $0.calendar?.title.contains("Delegate") == true }.count
    }
    
    private var dropCount: Int {
        reminders.filter { $0.calendar?.title.contains("Drop") == true }.count
    }
    
    private var highPriorityCount: Int {
        reminders.filter { (1...3).contains($0.priority) }.count
    }
    
    private var mediumPriorityCount: Int {
        reminders.filter { (4...6).contains($0.priority) }.count
    }
    
    private var lowPriorityCount: Int {
        reminders.filter { (7...9).contains($0.priority) }.count
    }
    
    private var noPriorityCount: Int {
        reminders.filter { $0.priority == 0 }.count
    }
    
    private var overdueCount: Int {
        let now = Date()
        return reminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else { return false }
            return dueDate < now && !reminder.isCompleted
        }.count
    }
    
    private var dueTodayCount: Int {
        let now = Date()
        return reminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else { return false }
            return Calendar.current.isDate(dueDate, inSameDayAs: now) && !reminder.isCompleted
        }.count
    }
    
    private var dueThisWeekCount: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)!
        
        return reminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else { return false }
            return dueDate > now && dueDate <= weekFromNow && !reminder.isCompleted
        }.count
    }
    
    private var dueLaterCount: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)!
        
        return reminders.filter { reminder in
            guard let dueDate = reminder.dueDateComponents?.date else { return false }
            return dueDate > weekFromNow && !reminder.isCompleted
        }.count
    }
    
    private var noDueDateCount: Int {
        reminders.filter { $0.dueDateComponents?.date == nil && !$0.isCompleted }.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CategoryBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.body)
                Spacer()
                Text("\(count)")
                    .font(.body)
                    .fontWeight(.medium)
                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.controlBackgroundColor))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.3), value: percentage)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 2)
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        let store = EKEventStore()
        let sampleReminders = (0..<10).map { i in
            let reminder = EKReminder(eventStore: store)
            reminder.title = "Sample reminder \(i)"
            reminder.priority = [0, 1, 5, 9].randomElement()!
            if i % 3 == 0 {
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            }
            return reminder
        }
        
        StatsView(reminders: sampleReminders)
    }
}