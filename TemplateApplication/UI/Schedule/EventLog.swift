// In a new file, e.g., EventLog.swift
import Foundation
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import SpeziScheduler // Import to reference Event, Task, etc.
import SwiftUI

/// Represents the log entry for a completed SpeziScheduler Event instance.
struct EventLog: Codable, Identifiable, Sendable {
    /// Firestore document ID (auto-populated when read from Firestore).
    @DocumentID var firestoreID: String?
    /// Unique ID for this log entry, generated locally when the object is created.
    let id: UUID = UUID()
    /// ID of the user this event belongs to (filled by the Standard before saving).
    var userID: String?

    // --- Information derived from SpeziScheduler.Event ---

    /// String representation of the unique ID of the specific `Event` instance that was completed.
    let eventID: String // Derived from event.id
    /// The stable identifier (`String`) of the parent `Task` definition.
    let taskID: String // Derived from event.task.id
    /// The localization key for the user-visible title of the parent `Task`.
    let taskTitleKey: String // Derived from event.task.title.key
    /// String representation of the task's category identifier (or "uncategorized").
    let taskCategoryDescription: String // Derived from event.task.category
    /// The **start** date and time of this specific event instance.
    let scheduledTimestamp: Date // Derived from event.start
    /// The optional **end** date and time of this specific event instance.
    let eventEndTime: Date? // Derived from event.end
    /// An optional description associated with the event.
    let eventDescription: String? // Derived from event.description

    // --- Logging Information ---

    /// Timestamp when the event was marked complete in the app and this log entry was created.
    let completionTimestamp: Date

    /// Initializer that takes a completed SpeziScheduler.Event.
    /// Assumes `event.complete()` was already successfully called before creating this log.
    ///
    /// - Parameters:
    ///   - event: The `SpeziScheduler.Event` that was completed.
    ///   - completionTime: The timestamp when the completion occurred. Defaults to the time of initialization.
    init(from event: Event, completionTime: Date = Date()) { // No longer throws
        self.userID = nil // Standard fills this later

        self.eventID = String(describing: event.id)
        self.taskID = event.task.id
        self.taskTitleKey = event.task.title.key

        if let category = event.task.category {
            self.taskCategoryDescription = String(describing: category)
        } else {
            self.taskCategoryDescription = "uncategorized"
        }

        // Use the confirmed properties from SpeziScheduler.Event
        self.scheduledTimestamp = event.occurrence.start// Use the start time
        self.eventEndTime = event.occurrence.end      // Use the optional end time
        
        self.eventDescription = event.description

        // Set the completion timestamp
        self.completionTimestamp = completionTime
    }
}
