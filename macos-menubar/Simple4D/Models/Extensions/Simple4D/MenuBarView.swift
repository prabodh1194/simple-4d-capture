import SwiftUI
import EventKit

struct MenuBarView: View {
    @State private var inputText = ""
    @State private var isSubmitting = false
    @StateObject private var reminderManager = ReminderManager()

    var body: some View {
        VStack(spacing: 12) {
            TextField("What needs to be captured?", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)

            // Character count
            HStack {
                Spacer()
                Text("\(inputText.count)/200")
                    .font(.caption)
                    .foregroundColor(inputText.count > 200 ? .red : .secondary)
            }
            .frame(width: 300)

            HStack(spacing: 8) {
                ForEach(Category.allCases, id: \.self) { category in
                    Button(category.displayName) {
                        guard reminderManager.isValidInput(inputText) else { return }

                        isSubmitting = true
                        Task {
                            await reminderManager.addReminder(text: inputText, category: category)
                            if reminderManager.errorMessage == nil {
                                inputText = "" // Clear on success
                            }
                            isSubmitting = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSubmitting || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            // Loading indicator
            if isSubmitting {
                ProgressView()
                    .scaleEffect(0.5)
            }

            // Error display
            if let error = reminderManager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(width: 300)
            }
        }
        .padding()
        .frame(width: 340)
        .onAppear {
            Task {
                await reminderManager.initialize()
            }
        }
    }
}

#Preview {
    MenuBarView()
}

