// TemplateApplication/UI/Schedule/EventView.swift
// Handles displaying and completing events, including questionnaires.
// Modified to store HealthKitSnapshot separately and update EventLog.
// Logger has been removed from this version.

import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI


struct EventView: View {
    private let event: Event
    private let healthKitSnapshotFromPreamble: HealthKitSnapshot?

    @Environment(TemplateApplicationStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    // Removed: @Application (\.logger) private var logger
     
    var body: some View {
        if let questionnaire = event.task.questionnaire {
            QuestionnaireView(questionnaire: questionnaire) { result in
                dismiss() // Dismiss the questionnaire view first

                guard case let .completed(questionnaireResponse) = result else {
                    // logger.debug("Questionnaire \(questionnaire.id ?? "Unknown") dismissed or not completed.")
                    print("Questionnaire \(questionnaire.id ?? "Unknown") dismissed or not completed.") // Replaced logger with print
                    return
                }
                
                 do {
                    // 1. Store the QuestionnaireResponse itself
                    await standard.add(response: questionnaireResponse)
                    // logger.info("QuestionnaireResponse for event \(event.id) with ID \(questionnaireResponse.id.uuidString) added to standard.")
                    print("QuestionnaireResponse for event \(event.id) with ID \(questionnaireResponse.identifier) added to standard.") // Replaced logger
                    
                    if let snapshot = healthKitSnapshotFromPreamble {
                        let responseIdString: String? = questionnaireResponse.identifier as? String
                        await standard.storeHealthKitSnapshot(snapshot, forResponseId: responseIdString ?? "")
                        // logger.info("HealthKitSnapshot for event \(event.id) stored separately, linked to QR ID \(questionnaireResponse.id.uuidString).")
                        print("HealthKitSnapshot for event \(event.id) stored separately, linked to QR ID \(questionnaireResponse.id).") // Replaced logger
                    }
                    

                    do {
                        try event.complete()
                        // logger.info("Event \(event.id) marked as complete.")
                        print("Event \(event.id) marked as complete.") // Replaced logger
                    } catch {
                        // logger.error("Failed to mark event \(event.id) as complete: \(error.localizedDescription)")
                        print("ERROR: Failed to mark event \(event.id) as complete: \(error.localizedDescription)") // Replaced logger
                        // Decide if you should proceed with logging if event completion fails
                    }
                        
                    // 4. Create and log the EventLog, now linking to the QuestionnaireResponse ID
                    let eventLogEntry = EventLog(
                        from: event,
                        completionTime: Date(), // Or questionnaireResponse.completionDate if available
                    )
                                           
                    await standard.logCompletedEvent(eventLogEntry)
                    // logger.info("EventView: Logged completion for SpeziScheduler event \(event.id). Linked QR ID: \(questionnaireResponse.id.uuidString)")
                    print("EventView: Logged completion for SpeziScheduler event \(event.id). Linked QR ID: \(questionnaireResponse.id)") // Replaced logger
                }
            }
        } else {
            // Fallback for non-questionnaire events (unchanged)
            NavigationStack {
                ContentUnavailableView(
                    "Unsupported Event",
                    systemImage: "list.bullet.clipboard",
                    description: Text("This type of event is currently unsupported. Please contact the developer of this app.")
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // Modified initializer
    init(_ event: Event, healthKitSnapshotFromPreamble: HealthKitSnapshot? = nil) {
        self.event = event
        self.healthKitSnapshotFromPreamble = healthKitSnapshotFromPreamble
    }
}

