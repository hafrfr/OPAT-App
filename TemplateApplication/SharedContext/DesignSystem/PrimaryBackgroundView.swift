//
// PrimaryBackgroundView.swift
// Part of the OPAT @ Home application
//
// Standard reusable background layout with gradient header and rounded white content container.
// Created by the OPAT @ Home team, Chalmers University of Technology, 2025.
//

import SwiftUI

struct PrimaryBackgroundView<Content: View>: View {
    let title: String
    let subtitle: String?
    let showsSettingsButton: Bool
    let content: () -> Content

    // MARK: - Animation states (header + button doesnt show up instantly)
    @State private var showSettingsButton = false
    @State private var showHeader = false

    // MARK: - Init
    init(title: String, subtitle: String? = nil, showsSettingsButton: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.showsSettingsButton = showsSettingsButton
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            gradientBackground // The colorful gradient background

            VStack(spacing: 0) {
                header // Title + subtitle
                contentContainer // Main white rounded container
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .topTrailing) {
            // Optional Settings button in top-right corner
            if showsSettingsButton {
                SettingsButton(color: ColorTheme.title) {
                    print("Settings tapped") // Replace later if needed
                }
                .padding()
                .opacity(showSettingsButton ? 1 : 0) // Fade in
                .animation(.easeOut(duration: 0.4), value: showSettingsButton)
            }
        }
        .onAppear {
            showSettingsButton = true // Triggers fade-in animation
            showHeader = true // Triggers title/subtitle fade-in
        }
    }

    // MARK: - Background
    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: ColorTheme.headerGradientStart, location: 0.0),
                .init(color: ColorTheme.headerGradientEnd, location: 0.4) // Faster gradient fade
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header (Title + Subtitle)
    private var header: some View {
        VStack(spacing: Layout.Spacing.small) {
            Text(title)
                .font(FontTheme.title)
                .foregroundColor(ColorTheme.title)
                .multilineTextAlignment(.center)
                .opacity(showHeader ? 1 : 0) // Fade in
                .animation(.easeOut(duration: 0.5), value: showHeader)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(FontTheme.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showHeader ? 1 : 0) // Fade in
                    .animation(.easeOut(duration: 0.6), value: showHeader)
            }
        }
        .padding(.top, Layout.Spacing.xLarge)
        .padding(.horizontal, Layout.Spacing.large)
    }

    // MARK: - Main Content Area
    private var contentContainer: some View {
        VStack {
            content() // The custom content passed in
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Layout.Spacing.large)
        .background(ColorTheme.contentContainerBackground)
        .cornerRadius(120, corners: [.topLeft, .topRight])
        .shadowStyle(ShadowTheme.card)
    }
}

#if DEBUG
#Preview {
    PrimaryBackgroundView(title: "Title", subtitle: "Optional subtitle here.", showsSettingsButton: true) {
        Text("Content goes here")
    }
}
#endif

