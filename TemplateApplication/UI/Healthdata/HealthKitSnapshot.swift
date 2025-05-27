//
//  HealthKitSnapshot.swift
//  OPATApp
//
//  Created by Jacob Justad on 2025-05-17.
//

import Foundation
import HealthKit
struct HealthKitSnapshot: Codable, Sendable {
    let collectionDate: Date

    struct ValueWithUnit: Codable, Sendable {
        let value: Double // The numerical value of the measurement.
        let unit: String  // The unit of measurement (e.g., "bpm", "%", "steps", "°C").
        let date: Date    // The exact date and time this specific measurement was recorded by HealthKit.
    }

    var latestHeartRate: ValueWithUnit?
    var latestBloodOxygen: ValueWithUnit?
    var latestBodyTemperature: ValueWithUnit?
    var latestBloodPressureSystolic: ValueWithUnit?
    var latestBloodPressureDiastolic: ValueWithUnit?
    

    // Initializer for creating a HealthKitSnapshot instance.
    // All parameters have default nil values, allowing for flexible creation.
    init(
        collectionDate: Date = Date(), // Defaults to the current date and time.
        latestHeartRate: ValueWithUnit? = nil,
        latestBloodOxygen: ValueWithUnit? = nil,
        latestBodyTemperature: ValueWithUnit? = nil,
        latestBloodPressureSystolic: ValueWithUnit? = nil,
        lastestBloodPressureDiastolic: ValueWithUnit? = nil
    ) {
        self.collectionDate = collectionDate
        self.latestHeartRate = latestHeartRate
        self.latestBloodOxygen = latestBloodOxygen
        self.latestBodyTemperature = latestBodyTemperature
        self.latestBloodPressureSystolic = latestBloodPressureSystolic
        self.latestBloodPressureDiastolic = lastestBloodPressureDiastolic
    }
}
