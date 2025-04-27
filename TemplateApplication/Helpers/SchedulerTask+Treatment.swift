//
//  Untitled.swift
//  TemplateApplication
//
//  Created by Jacob Justad on 2025-04-21.
//
import Foundation
import SpeziScheduler

// Extend the Task Context to store our custom Treatment ID
extension Task.Context {
    @Property var treatmentId: UUID?
}
