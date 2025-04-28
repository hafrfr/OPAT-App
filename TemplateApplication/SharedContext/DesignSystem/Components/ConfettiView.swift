//
//  ConfettiView.swift
//  OPATApp
//
//  Created by harre on 2025-04-28.
//


// ConfettiView.swift
// Part of the OPAT @ Home application
//
// A simple animated confetti effect using SwiftUI shapes.
// Created by OPAT @ Home team, Chalmers University of Technology, 2025.

import SwiftUI

struct ConfettiView: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { index in
                Circle()
                    .fill(randomColor())
                    .frame(width: 8, height: 8)
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: animate ? geo.size.height + 20 : -20
                    )
                    .animation(
                        .easeIn(duration: Double.random(in: 2.0...3.5)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }

    private func randomColor() -> Color {
        let colors: [Color] = [
            .red, .blue, .yellow, .green, .purple, .orange, .pink
        ]
        return colors.randomElement() ?? .blue
    }
}
