// SpeziTemplateApplication/TemplateApplication/Instructions/InstructionGuideDataSource.swift
// (Corrected Line Length)

import Foundation // Or SwiftUI

struct InstructionGuideDataSource {
    private static let opatChecklist: [ChecklistItem] = [
            ChecklistItem(name: "Alcohol wipes", iconName: "icon_alcohol_wipes"), // Ensure icons exist
            ChecklistItem(name: "IV tubing", iconName: "icon_iv_tubing"),
            ChecklistItem(name: "Syringe", iconName: "icon_syringe"),
            ChecklistItem(name: "Gloves", iconName: "icon_gloves"),
            ChecklistItem(name: "Sharps container", iconName: "icon_sharps")
        ]

    private static let opatSteps: [InstructionStep] = [
        InstructionStep(
            title: "Step 1: Preparation",
            substeps: [
                SubStep(title: "PREPPING",
                        description: "• TEST"
                        , imageName: "Opat_1"),
            ]
        ),
        InstructionStep(
            title: "Step 2: Disinfecting",
            substeps: [
                SubStep(title: "Clean Tray", description: "• Clean & dry tray.", imageName: "Opat_1"),
                SubStep(
                    title: "Wash Your Hands",
                    // Corrected long line:
                    description: """
                    • Wash hands (2 min) & use alcohol rub.
                    """,
                    imageName: "Opat_1"
                ),
                SubStep(
                    title: "Place Items",
                    description: """
                    • Place pump & syringe in tray.
                    • Open wipe/towel.
                    """, // Split description
                    imageName: "disinfecting_image"
                 )
            ]
        ),
        // ... Other steps ...
         InstructionStep(
             title: "Complete",
             substeps: [
                 SubStep(
                     title: "Wait & Prep",
                     description: """
                     • Wait for balloon deflation.
                     • Wash hands (2 min) & alcohol rub.
                     • Clean tray (detergent & disinfectant).
                     • Prep tray: 2 wipes, dressing towel,
                       new saline syringe.
                     """, // Split line
                     imageName: nil
                 ),
             ]
         ),
    ]
    // --- Function to Load All Guides ---
    static func loadGuides() -> [InstructionGuideInfo] {
            var guides: [InstructionGuideInfo] = []

            // Add OPAT Guide - Ensure ALL arguments are provided
            guides.append(
                InstructionGuideInfo( // This call needs all 4 parameters
                    title: "OPAT Self-Administration Guide",
                    iconName: "Opat_icon",
                    checklistItems: opatChecklist, // Uses the defined checklist constant
                    steps: opatSteps // Uses the defined steps constant
                )
            )
        
        
            // ADD ANOTHER GUIDE IF NEEDED
        
        return guides
    }
}
