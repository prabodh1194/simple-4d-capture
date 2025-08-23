import EventKit
import SwiftUI

struct TaskRowView: View {
    let reminder: EKReminder
    let isSelected: Bool
    let onComplete: (EKReminder) -> Void
    let onDefer: (EKReminder) -> Void
    let onDelete: (EKReminder) -> Void

    @State private var showingActions = false

    var body: some View {
        HStack(spacing: 12) {
            // Priority indicator
            priorityIndicator

            VStack(alignment: .leading, spacing: 4) {
                // Title
                HStack {
                    Text(reminder.title ?? "Untitled")
                        .font(.body)
                        .strikethrough(reminder.isCompleted)
                        .foregroundColor(reminder.isCompleted ? .secondary : .primary)

                    Spacer()

                    // Due date badge
                    dueDateBadge
                }

                // Notes/Context
                if let notes = reminder.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Creation date
                if let creationDate = reminder.creationDate {
                    Text(creationDate, style: .relative)
                        .font(.caption2)
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                }
            }

            Spacer()

            // Quick actions
            HStack(spacing: 8) {
                Button(action: { onComplete(reminder) }) {
                    Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(reminder.isCompleted ? .green : .secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Mark complete")

                Menu {
                    Button("Defer 1 week") { onDefer(reminder) }
                    Button("Delete", role: .destructive) { onDelete(reminder) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .help("More actions")
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .onHover { hovering in
            showingActions = hovering
        }
    }

    private var priorityIndicator: some View {
        Rectangle()
            .fill(priorityColor)
            .frame(width: 4)
            .cornerRadius(2)
    }

    private var priorityColor: Color {
        switch reminder.priority {
        case 1 ... 3: return .red // High priority
        case 4 ... 6: return .orange // Medium priority
        case 7 ... 9: return .yellow // Low priority
        default: return .gray // No priority
        }
    }

    @ViewBuilder
    private var dueDateBadge: some View {
        if let dueDate = reminder.dueDateComponents?.date {
            let now = Date()
            let isOverdue = dueDate < now
            let isToday = Calendar.current.isDate(dueDate, inSameDayAs: now)
            let isTomorrow = Calendar.current.isDate(
                dueDate,
                inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: now)!
            )

            let (text, color): (String, Color) = {
                if isOverdue {
                    let formatter = RelativeDateTimeFormatter()
                    formatter.unitsStyle = .abbreviated
                    return (formatter.localizedString(for: dueDate, relativeTo: now), .red)
                } else if isToday {
                    return ("Today", .orange)
                } else if isTomorrow {
                    return ("Tomorrow", .blue)
                } else {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    return (formatter.string(from: dueDate), .secondary)
                }
            }()

            Text(text)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .foregroundColor(color)
                .cornerRadius(4)
        }
    }
}

struct TaskRowView_Previews: PreviewProvider {
    static var previews: some View {
        let store = EKEventStore()
        let reminder = EKReminder(eventStore: store)
        reminder.title = "Sample task with priority"
        reminder.priority = 1
        reminder.notes = "Context: #work @john"
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())

        return Group {
            TaskRowView(
                reminder: reminder,
                isSelected: false,
                onComplete: { _ in },
                onDefer: { _ in },
                onDelete: { _ in }
            )
            .padding()

            TaskRowView(
                reminder: reminder,
                isSelected: true,
                onComplete: { _ in },
                onDefer: { _ in },
                onDelete: { _ in }
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
