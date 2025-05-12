//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziQuestionnaire
import SpeziScheduler
import SwiftUI


struct EventView: View {
    private let event: Event

    @Environment(TemplateApplicationStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let questionnaire = event.task.questionnaire {
            QuestionnaireView(questionnaire: questionnaire) { result in
                dismiss()

                guard case let .completed(response) = result else {
                    return
                }
                do {
                    try event.complete()
                    // Optional: Add any logic here that should only execute if complete() succeeds
                } catch {
                    // Handle the error appropriately
                    print("Failed to complete event \(event.id): \(error)")
                    // You might want to show an alert to the user or log this more formally.
                }
                await standard.add(response: response)
                
            }
        } else {
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

    init(_ event: Event) {
        self.event = event
    }
}
