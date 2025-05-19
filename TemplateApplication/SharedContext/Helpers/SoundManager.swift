//
//  SoundManager.swift
//  OPATApp
//  Handles sound effects for the app, such as sound when tapping next, etc.
//  Created by harre on 2025-04-27.
//


import AVFoundation
import SwiftUI

enum SoundType: String, CaseIterable {
    case nextTap = "next-tap"
    case progressTap = "progress-tap"
    case notificationSound = "notification-sound"
    case celebration = "celebration"
    case tasksCompleted = "tasks-completed"
    // Add new sounds here as needed :D
}

@MainActor
class SoundManager {
    static let shared = SoundManager()

    private var players: [SoundType: AVAudioPlayer] = [:]

    private init() {
        preloadSounds()
    }

    private func preloadSounds() {
        for sound in SoundType.allCases {
            if let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    players[sound] = player
                } catch {
                    print("Error preloading sound \(sound.rawValue): \(error.localizedDescription)")
                }
            }
        }
    }

    func playSound(_ sound: SoundType) {
        players[sound]?.play()
    }
}
