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
                  let granted = try await eventStore.requestAccess(to: .reminder)
                  isAuthorized = granted
                  if !granted {
                      errorMessage = "Reminders access denied"
                  }
              } catch {
                  errorMessage = "Failed to request access: \(error.localizedDescription)"
              }
          case .authorized:
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
              reminder.title = text
              reminder.calendar = calendar
              reminder.priority = 0

              try eventStore.save(reminder, commit: true)
              errorMessage = nil // Clear any previous errors

          } catch {
              errorMessage = error.localizedDescription
          }
      }

      func isValidInput(_ text: String) -> Bool {
          let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
          return !trimmed.isEmpty && trimmed.count <= 200
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
