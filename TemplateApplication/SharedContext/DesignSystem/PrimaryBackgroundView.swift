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
    let useWhiteContainer: Bool
    let content: () -> Content

    @State private var showSettingsButton = false
    @State private var showHeader = false

    // MARK: - Init
    init(
        title: String,
        subtitle: String? = nil,
        showsSettingsButton: Bool = false,
        useWhiteContainer: Bool = false, // Default = NO box
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showsSettingsButton = showsSettingsButton
        self.useWhiteContainer = useWhiteContainer
        self.content = content
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            gradientBackground

            VStack(spacing: Layout.Spacing.medium) {
                header
                Spacer(minLength: 0)

                if useWhiteContainer {
                    contentContainer
                } else {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            content()
                                .padding(.horizontal, Layout.Spacing.large)
                            Spacer()
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .bottom)
            .padding(.bottom)
        }
        .overlay(alignment: .topTrailing) {
            if showsSettingsButton {
                SettingsButton(color: ColorTheme.title) {
                    print("Settings tapped")
                }
                .padding()
                .opacity(showSettingsButton ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showSettingsButton)
            }
        }
        .onAppear {
            showSettingsButton = true
            showHeader = true
        }
    }
    
    // MARK: - Full Gradient Background
    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .white, location: 0.0), // Bottom
                .init(color: ColorTheme.headerGradientStart.opacity(0.9), location: 0.2),
                .init(color: ColorTheme.headerGradientStart, location: 0.68),
                .init(color: ColorTheme.headerGradientEnd.opacity(0.95), location: 0.99),
                .init(color: ColorTheme.headerGradientEnd, location: 1.0) // Top
            ]),
            startPoint: .bottom,
            endPoint: .top
        )
        .blur(radius: 0.6) // just enough to smooth transitions
        .ignoresSafeArea()
    }
    // MARK: - Header (Title + Subtitle)
    private var header: some View {
        VStack(spacing: Layout.Spacing.small) {
            Text(title)
                .font(FontTheme.title)
                .foregroundColor(ColorTheme.title)
                .multilineTextAlignment(.center)
                .opacity(showHeader ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: showHeader)
                .shadowStyle(ShadowTheme.card)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(FontTheme.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(showHeader ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: showHeader)
            }
        }
        .padding(.top, Layout.Spacing.small)
        .padding(.horizontal, Layout.Spacing.large)
    }

    // MARK: - White Container
    private var contentContainer: some View {
        VStack {
            content()
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
    VStack(spacing: 30) {
        PrimaryBackgroundView(title: "Standard (No Box)") {
            Text("This content is outside the white container.")
        }

        //PrimaryBackgroundView(title: "With White Box", //useWhiteContainer: true) {
            //Text("This content is in a rounded white container.")
        //}
    }
}
#endif
