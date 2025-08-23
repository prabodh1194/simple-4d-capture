//
//  ReminderManager.swift
//  Simple4D
//
//  Created by Prabodh Agarwal on 22/08/25.
//



  import Foundation
  import EventKit

  @MainActor
  class ReminderManager: ObservableObject {
      private let eventStore = EKEventStore()
      private var cachedLists: [String: EKCalendar] = [:]

      @Published var isAuthorized = false
      @Published var errorMessage: String?

      func initialize() async {
          await requestAccess()
          if isAuthorized {
              do {
                  try await findOrCreateLists()
              } catch {
                  errorMessage = "Failed to initialize lists: \(error.localizedDescription)"
              }
          }
      }

      func requestAccess() async {
          let status = EKEventStore.authorizationStatus(for: .reminder)

          switch status {
          case .notDetermined:
              do {
                  if #available(macOS 14.0, *) {
                      let granted = try await eventStore.requestFullAccessToReminders()
                      isAuthorized = granted
                      if !granted {
                          errorMessage = "Reminders access denied"
                      }
                  } else {
                      let granted = try await eventStore.requestAccess(to: .reminder)
                      isAuthorized = granted
                      if !granted {
                          errorMessage = "Reminders access denied"
                      }
                  }
              } catch {
                  errorMessage = "Failed to request access: \(error.localizedDescription)"
              }
          case .authorized:
              isAuthorized = true
          case .fullAccess:
              isAuthorized = true
          case .writeOnly:
              isAuthorized = true
          case .denied, .restricted:
              isAuthorized = false
              errorMessage = "Reminders access denied. Please enable in System Preferences."
          @unknown default:
              errorMessage = "Unknown authorization status"
          }
      }

      private func findOrCreateLists() async throws {
          guard isAuthorized else { throw ReminderError.notAuthorized }

          let calendars = eventStore.calendars(for: .reminder)

          for category in Category.allCases {
              let listName = category.listName

              if let existingList = calendars.first(where: { $0.title == listName }) {
                  cachedLists[listName] = existingList
              } else {
                  // Create new list
                  let newList = EKCalendar(for: .reminder, eventStore: eventStore)
                  newList.title = listName
                  newList.source = eventStore.defaultCalendarForNewReminders()?.source

                  try eventStore.saveCalendar(newList, commit: true)
                  cachedLists[listName] = newList
              }
          }
      }

      func addReminder(text: String, category: Category) async {
          do {
              if !isAuthorized {
                  await requestAccess()
                  guard isAuthorized else { return }
              }
              // Ensure lists exist
              if cachedLists.isEmpty {
                  try await findOrCreateLists()
              }

              let listName = category.listName
              guard let calendar = cachedLists[listName] else {
                  throw ReminderError.listNotFound(listName)
              }

              let reminder = EKReminder(eventStore: eventStore)
              
              // Parse priority markers and clean text
              let (cleanText, priority) = parsePriorityFromText(text)
              reminder.title = cleanText
              reminder.calendar = calendar
              reminder.priority = priority
              
              // Set due date based on category
              setDueDateForCategory(reminder: reminder, category: category)
              
              // Set alerts based on category
              setAlertsForCategory(reminder: reminder, category: category)
              
              // Add notes for context/tags
              if let notes = extractNotesFromText(cleanText) {
                  reminder.notes = notes
              }

              try eventStore.save(reminder, commit: true)
              errorMessage = nil // Clear any previous errors

          } catch {
              errorMessage = error.localizedDescription
          }
      }
      
      private func parsePriorityFromText(_ text: String) -> (String, Int) {
          let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
          
          // Count exclamation marks at the beginning
          let exclamationCount = trimmed.prefix(while: { $0 == "!" }).count
          
          let priority: Int
          switch exclamationCount {
          case 3...: priority = 1 // High priority
          case 2: priority = 5     // Medium priority
          case 1: priority = 9     // Low priority
          default: priority = 0    // No priority
          }
          
          // Remove exclamation marks from text
          let cleanText = String(trimmed.dropFirst(exclamationCount)).trimmingCharacters(in: .whitespacesAndNewlines)
          
          return (cleanText, priority)
      }
      
      private func setDueDateForCategory(reminder: EKReminder, category: Category) {
          let calendar = Calendar.current
          let now = Date()
          
          switch category {
          case .doIt:
              // Due today at 11:59 PM or tomorrow if after 6 PM
              let hour = calendar.component(.hour, from: now)
              if hour >= 18 {
                  reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: 1, to: now)!)
              } else {
                  reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: now)
              }
              
          case .deferIt:
              // Due next Monday at 9 AM
              let nextMonday = calendar.nextDate(after: now, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime)!
              var components = calendar.dateComponents([.year, .month, .day], from: nextMonday)
              components.hour = 9
              components.minute = 0
              reminder.dueDateComponents = components
              
          case .delegate:
              // Due in 3 days for follow-up
              let followUpDate = calendar.date(byAdding: .day, value: 3, to: now)!
              var components = calendar.dateComponents([.year, .month, .day], from: followUpDate)
              components.hour = 10
              components.minute = 0
              reminder.dueDateComponents = components
              
          case .drop:
              // No due date for dropped items
              break
          }
      }
      
      private func setAlertsForCategory(reminder: EKReminder, category: Category) {
          let calendar = Calendar.current
          
          switch category {
          case .doIt:
              // Alert at 9 AM today or tomorrow
              let now = Date()
              let hour = calendar.component(.hour, from: now)
              let alertDate: Date
              
              if hour >= 9 {
                  // If past 9 AM, alert tomorrow at 9 AM
                  alertDate = calendar.date(byAdding: .day, value: 1, to: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!)!
              } else {
                  // Alert today at 9 AM
                  alertDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
              }
              
              let alarm = EKAlarm(absoluteDate: alertDate)
              reminder.addAlarm(alarm)
              
          case .deferIt:
              // Alert on Monday at 9 AM (when due)
              if let dueDate = reminder.dueDateComponents {
                  let alarm = EKAlarm(absoluteDate: calendar.date(from: dueDate)!)
                  reminder.addAlarm(alarm)
              }
              
          case .delegate:
              // Alert in 3 days at 10 AM for follow-up
              if let dueDate = reminder.dueDateComponents {
                  let alarm = EKAlarm(absoluteDate: calendar.date(from: dueDate)!)
                  reminder.addAlarm(alarm)
              }
              
          case .drop:
              // No alerts for dropped items
              break
          }
      }
      
      private func extractNotesFromText(_ text: String) -> String? {
          // Look for hashtags or @mentions for context
          let words = text.components(separatedBy: .whitespacesAndNewlines)
          let tags = words.filter { $0.hasPrefix("#") || $0.hasPrefix("@") }
          
          return tags.isEmpty ? nil : "Context: \(tags.joined(separator: " "))"
      }

      func isValidInput(_ text: String) -> Bool {
          let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
          return !trimmed.isEmpty && trimmed.count <= 200
      }
      
      // MARK: - Dashboard Support Methods
      
      func fetchActiveReminders() async -> [EKReminder] {
          guard isAuthorized else { return [] }
          
          var allReminders: [EKReminder] = []
          
          // Fetch from all 4D lists
          for category in Category.allCases {
              let listName = category.listName
              guard let calendar = cachedLists[listName] else { continue }
              
              // Create predicate for incomplete reminders in this calendar
              let predicate = eventStore.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: [calendar])
              
              // Use completion handler pattern for reminders
              await withCheckedContinuation { continuation in
                  eventStore.fetchReminders(matching: predicate) { reminders in
                      if let reminders = reminders {
                          allReminders.append(contentsOf: reminders)
                      } else {
                          print("Error fetching reminders from \(listName)")
                      }
                      continuation.resume()
                  }
              }
          }
          
          // Sort by due date, with overdue items first
          return allReminders.sorted { lhs, rhs in
              guard let lhsDate = lhs.dueDateComponents?.date,
                    let rhsDate = rhs.dueDateComponents?.date else {
                  // Items without due dates go to the end
                  return lhs.dueDateComponents?.date != nil
              }
              
              let now = Date()
              let lhsOverdue = lhsDate < now
              let rhsOverdue = rhsDate < now
              
              if lhsOverdue && !rhsOverdue {
                  return true // Overdue items come first
              } else if !lhsOverdue && rhsOverdue {
                  return false
              } else {
                  return lhsDate < rhsDate // Then sort by date
              }
          }
      }
      
      func completeReminder(_ reminder: EKReminder) async {
          do {
              reminder.isCompleted = true
              reminder.completionDate = Date()
              try eventStore.save(reminder, commit: true)
          } catch {
              errorMessage = "Failed to complete reminder: \(error.localizedDescription)"
          }
      }
      
      func rescheduleReminder(_ reminder: EKReminder, to category: Category) async {
          do {
              // Move to new category list
              let listName = category.listName
              guard let newCalendar = cachedLists[listName] else {
                  throw ReminderError.listNotFound(listName)
              }
              
              reminder.calendar = newCalendar
              
              // Update due date based on new category
              setDueDateForCategory(reminder: reminder, category: category)
              
              // Update alerts
              reminder.alarms?.forEach { reminder.removeAlarm($0) }
              setAlertsForCategory(reminder: reminder, category: category)
              
              try eventStore.save(reminder, commit: true)
          } catch {
              errorMessage = "Failed to reschedule reminder: \(error.localizedDescription)"
          }
      }
      
      func getReminderCounts() async -> (doCount: Int, deferCount: Int, delegateCount: Int, dropCount: Int) {
          let reminders = await fetchActiveReminders()
          
          let doCount = reminders.filter { $0.calendar?.title == "4D - Do" }.count
          let deferCount = reminders.filter { $0.calendar?.title == "4D - Defer" }.count
          let delegateCount = reminders.filter { $0.calendar?.title == "4D - Delegate" }.count
          let dropCount = reminders.filter { $0.calendar?.title == "4D - Drop" }.count
          
          return (doCount, deferCount, delegateCount, dropCount)
      }
      
      // MARK: - Dashboard Support Methods
      
      func markReminderComplete(_ reminder: EKReminder) async {
          do {
              reminder.isCompleted = true
              reminder.completionDate = Date()
              try eventStore.save(reminder, commit: true)
          } catch {
              errorMessage = "Failed to complete reminder: \(error.localizedDescription)"
          }
      }
      
      func deferReminder(_ reminder: EKReminder, days: Int) async {
          do {
              let calendar = Calendar.current
              let newDueDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
              reminder.dueDateComponents = calendar.dateComponents([.year, .month, .day], from: newDueDate)
              
              // Update alert to match new due date
              reminder.alarms?.forEach { reminder.removeAlarm($0) }
              let alert = EKAlarm(absoluteDate: newDueDate)
              reminder.addAlarm(alert)
              
              try eventStore.save(reminder, commit: true)
          } catch {
              errorMessage = "Failed to defer reminder: \(error.localizedDescription)"
          }
      }
      
      func deleteReminder(_ reminder: EKReminder) async {
          do {
              try eventStore.remove(reminder, commit: true)
          } catch {
              errorMessage = "Failed to delete reminder: \(error.localizedDescription)"
          }
      }
  }

  enum ReminderError: LocalizedError {
      case notAuthorized
      case listNotFound(String)
      case saveFailed(Error)

      var errorDescription: String? {
          switch self {
          case .notAuthorized: return "Not authorized to access Reminders"
          case .listNotFound(let name): return "List '\(name)' not found"
          case .saveFailed(let error): return "Failed to save: \(error.localizedDescription)"
          }
      }
  }
