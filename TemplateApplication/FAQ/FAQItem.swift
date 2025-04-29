//
//  FAQItem.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-04-27.
//
import Foundation

struct FAQItem: Identifiable, Hashable,Codable{
    let id: UUID = UUID()
    let question: String
    let answer: String
}
