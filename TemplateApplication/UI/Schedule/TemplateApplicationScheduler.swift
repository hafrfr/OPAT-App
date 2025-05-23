//
// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse


@Observable
final class TemplateApplicationScheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored private var scheduler

    @MainActor var viewState: ViewState = .idle

    init() {}

    /// Add or update the current list of task upon app startup.
    func configure() {
        do {
            /*
            // Old template task – you can re-enable this if needed
            try scheduler.createOrUpdateTask(
                id: "social-support-questionnaire",
                title: "Social Support Questionnaire",
                instructions: "Please fill out the Social Support Questionnaire every day.",
                category: .questionnaire,
                schedule: .daily(hour: 8, minute: 0, startingAt: .today)
            ) { context in
                context.questionnaire = Bundle.main.questionnaire(withName: "SocialSupportQuestionnaire")
            }
            */

            // OPAT questionnaire – added here!
            try scheduler.createOrUpdateTask(
                id: "opatfollowup",
                title: "Daily OPAT Check-in",
                instructions: "Take a moment to check in and let us know how you're doing today.",
                category: .questionnaire,
                schedule: .daily(hour: 9, minute: 0, startingAt: .today)
            ) { context in
                context.questionnaire = Bundle.main.questionnaire(withName: "OPATFollowUp")
            }

            // You can add more scheduled tasks here later (e.g., weekly follow-ups, injection helper prompts, etc.)
        } catch {
            viewState = .error(AnyLocalizedError(
                error: error,
                defaultErrorDescription: "Failed to create or update scheduled tasks."
            ))
        }
    }
}


// This extension is required so `context.questionnaire` works!
extension Task.Context {
    @Property(coding: .json) var questionnaire: Questionnaire?
}


// Optional but good: Allows us to store the user's response
extension Outcome {
    @Property(coding: .json) var questionnaireResponse: QuestionnaireResponse?
}
