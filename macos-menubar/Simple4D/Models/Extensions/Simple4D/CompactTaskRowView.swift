import EventKit
import SwiftUI

struct CompactTaskRowView: View {
    let reminder: EKReminder
    let isSelected: Bool
    let onComplete: (EKReminder) -> Void
    let onDefer: (EKReminder) -> Void
    let onDelete: (EKReminder) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 3, height: 20)
                .cornerRadius(1.5)

            // Complete button
            Button(action: { onComplete(reminder) }) {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.isCompleted ? .green : .secondary)
            }
            .buttonStyle(PlainButtonStyle())

            // Task content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(reminder.title ?? "Untitled")
                        .font(.body)
                        .strikethrough(reminder.isCompleted)
                        .foregroundColor(reminder.isCompleted ? .secondary : .primary)
                        .lineLimit(1)

                    Spacer()

                    // Due date
                    if let dueDate = reminder.dueDateComponents?.date {
                        Text(formatDueDate(dueDate))
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(dueDateColor(dueDate).opacity(0.2))
                            .foregroundColor(dueDateColor(dueDate))
                            .cornerRadius(3)
                    }
                }

                // Notes (if any)
                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            // Actions menu
            Menu {
                Button("Defer 1 week") { onDefer(reminder) }
                Button("Delete", role: .destructive) { onDelete(reminder) }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(width: 20)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(6)
    }

    private var priorityColor: Color {
        switch reminder.priority {
        case 1 ... 3: return .red
        case 4 ... 6: return .orange
        case 7 ... 9: return .yellow
        default: return .gray
        }
    }

    private func formatDueDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: now) {
            return "Today"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now)!) {
            return "Tomorrow"
        } else if date < now {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: date, relativeTo: now)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    private func dueDateColor(_ date: Date) -> Color {
        let now = Date()
        if date < now {
            return .red
        } else if Calendar.current.isDate(date, inSameDayAs: now) {
            return .orange
        } else if Calendar.current.isDate(date, inSameDayAs: Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: now
        )!) {
            return .blue
        } else {
            return .secondary
        }
    }
}

struct CompactTaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = EKEventStore()
        let reminder = EKReminder(eventStore: store)
        reminder.title = "Sample compact task"
        reminder.priority = 1
        reminder.notes = "Quick note"
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        return VStack(spacing: 4) {
            CompactTaskRowView(
                reminder: reminder,
                isSelected: false,
                onComplete: { _ in },
                onDefer: { _ in },
                onDelete: { _ in }
            )

            CompactTaskRowView(
                reminder: reminder,
                isSelected: true,
                onComplete: { _ in },
                onDefer: { _ in },
                onDelete: { _ in }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
