//
//  DateComponents+add_subb.swift
//  TemplateApplication
//
//  Created by Jacob Justad on 2025-04-23.
//

import Foundation

extension DateComponents {
    /// Returns a new DateComponents with the time shifted by `minutes`.
    /// Uses Jan 1, 2000 as a reference date so only hour/minute matter for repeats.
    func adding(minutes: Int, calendar: Calendar = .current) -> DateComponents? {
        guard let reference = calendar.date(from: self) else {
            return nil
        }
        let shifted = reference.addingTimeInterval(TimeInterval(minutes * 60))
        // Extract just hour & minute back
        return calendar.dateComponents([.hour, .minute], from: shifted)
    }
    
    /// Shortcut for subtracting minutes.
    func subtracting(minutes: Int, calendar: Calendar = .current) -> DateComponents? {
        adding(minutes: -minutes, calendar: calendar)
    }
}
