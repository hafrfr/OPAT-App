//
//  OpatContact.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-28.
//
import Foundation

struct OpatContact: Identifiable {
    let id = UUID()
    let name: String
    let phoneNumber: String
    let hospitalName: String
    let address: String // Simple string for address
    let availability: String // Used for grouping (e.g., "24/7", "Weekdays 9 AM - 5 PM")
    // Can make it a range later on
    
    
}
