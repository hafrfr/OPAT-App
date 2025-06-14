// This source file is part of the Stanford Spezi Template Application open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziNotifications
import SpeziOnboarding
import SpeziScheduler
import SwiftUI


class TemplateApplicationDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: TemplateApplicationStandard()) {
            if !FeatureFlags.disableFirebase {
                AccountConfiguration(
                    service: FirebaseAccountService(providers: [.emailAndPassword, .signInWithApple], emulatorSettings: accountEmulator),
                    storageProvider: FirestoreAccountStorage(storeIn: FirebaseConfiguration.userCollection),
                    configuration: [
                    ]
                )
                firestore
                if FeatureFlags.useFirebaseEmulator {
                    FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
                } else {
                    FirebaseStorageConfiguration()
                }
            }

            healthKit
            TemplateApplicationScheduler()
            Scheduler()
            OnboardingDataSource()
            TreatmentModel()
            TreatmentScheduler()
            Notifications()

            FAQModule()
            GuideModule()
            TreatmentModule()
        }
    }

    private var accountEmulator: (host: String, port: Int)? {
        if FeatureFlags.useFirebaseEmulator {
            (host: "localhost", port: 9099)
        } else {
            nil
        }
    }

    
    private var firestore: Firestore {
        let settings = FirestoreSettings()
        if FeatureFlags.useFirebaseEmulator {
            settings.host = "localhost:8080"
            settings.cacheSettings = MemoryCacheSettings()
            settings.isSSLEnabled = false
        }
        
        return Firestore(
            settings: settings
        )
    }
    private var healthKit: HealthKit {
            HealthKit {                                                                                                                    
                CollectSample(.stepCount)
                CollectSample(.heartRate, continueInBackground: true)
                CollectSample(.bodyTemperature)
                RequestReadAccess(quantity: [.bloodOxygen])
                CollectSample(.bloodPressureSystolic)
                CollectSample(.bloodPressureDiastolic)
            }
        }
}
