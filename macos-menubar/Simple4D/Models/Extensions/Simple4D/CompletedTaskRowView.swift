import EventKit
import SwiftUI

struct CompletedTaskRowView: View {
    let reminder: EKReminder
    let onUncomplete: (EKReminder) -> Void
    let onDelete: (EKReminder) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            Rectangle()
                .fill(priorityColor)
                .frame(width: 3, height: 20)
                .cornerRadius(1.5)

            // Uncomplete button
            Button(action: { onUncomplete(reminder) }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())

            // Task content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(reminder.title ?? "Untitled")
                        .font(.body)
                        .strikethrough(true)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Spacer()

                    // Completion date
                    if let completionDate = reminder.completionDate {
                        Text(formatCompletionDate(completionDate))
                            .font(.caption)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
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
                Button("Mark Incomplete") { onUncomplete(reminder) }
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

    private func formatCompletionDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current

        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Today \(formatter.string(from: date))"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now)!) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Yesterday \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
}

struct CompletedTaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = EKEventStore()
        let reminder = EKReminder(eventStore: store)
        reminder.title = "Sample completed task"
        reminder.priority = 1
        reminder.notes = "Quick note"
        reminder.isCompleted = true
        reminder.completionDate = Date()

        return VStack(spacing: 4) {
            CompletedTaskRowView(
                reminder: reminder,
                onUncomplete: { _ in },
                onDelete: { _ in }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
