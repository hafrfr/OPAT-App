import SpeziScheduler
import SwiftUI

struct TreatmentProgressBar: View {
    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]

    private var barHeight: CGFloat = 20
    @State private var animatedProgress: CGFloat = 0
    @State private var shimmerPhase: CGFloat = -1.0
    @State private var didPlayCompletionSound = false
    @State private var showProgressText = false
    @State private var shimmerVisible = false

    private static var todayRange: Range<Date> {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start)!
        return start..<end
    }

    private var completedCount: Int {
        todaysEvents.filter { $0.isCompleted }.count
    }

    private var totalCount: Int {
        todaysEvents.count
    }

    private var progressFraction: CGFloat {
        guard totalCount > 0 else { return 0 }
        return min(max(CGFloat(completedCount) / CGFloat(totalCount), 0), 1)
    }

    private var progressPercent: Int {
        Int((progressFraction * 100).rounded())
    }

    init(barHeight: CGFloat = 20) {
        self.barHeight = barHeight
    }

    var body: some View {
        if totalCount > 0 {
            GeometryReader { geo in
                progressBarContent(geometry: geo, currentAnimatedProgress: animatedProgress)
            }
            .frame(height: barHeight)
            .onAppear {
                animatedProgress = 0
                showProgressText = false
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedProgress = progressFraction
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showProgressText = true
                }

                if progressFraction == 1.0 {
                    triggerShimmerAndSound()
                }
            }
            .onChange(of: progressFraction) { newProgress in
                showProgressText = false
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedProgress = newProgress
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showProgressText = true
                }

                if newProgress == 1.0 {
                    triggerShimmerAndSound()
                } else {
                    shimmerPhase = -1.0
                    shimmerVisible = false
                    didPlayCompletionSound = false
                }

                print("TreatmentProgressBar: progressFraction changed. New: \(newProgress)")
            }
        } else {
            EmptyView()
        }
    }

    // MARK: - Shimmer + Sound
    private func triggerShimmerAndSound() {
        if !didPlayCompletionSound {
            SoundManager.shared.playSound(.tasksCompleted)
            didPlayCompletionSound = true
        }

        shimmerVisible = true
        shimmerPhase = -1.0
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            shimmerPhase = 2.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.6)) {
                shimmerVisible = false
            }
            shimmerPhase = -1.0
        }
    }

    // MARK: - Visuals
    @ViewBuilder
    private func progressBarContent(geometry geo: GeometryProxy, currentAnimatedProgress: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.green.opacity(0.35))

            if shimmerVisible {
                Capsule()
                    .fill(shimmerGradient)
                    .frame(width: geo.size.width)
                    .mask(Capsule())
                    .opacity(shimmerVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.6), value: shimmerVisible)
            } else {
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * currentAnimatedProgress)
                    .animation(.easeOut(duration: 0.8), value: currentAnimatedProgress)
            }

            progressBarText(geometry: geo, currentAnimatedProgress: currentAnimatedProgress)
        }
        .frame(height: barHeight)
    }

    private var shimmerGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.green.opacity(0.7),
                Color.white.opacity(0.9),
                Color.green.opacity(0.7)
            ]),
            startPoint: UnitPoint(x: shimmerPhase - 1, y: 0.5),
            endPoint: UnitPoint(x: shimmerPhase, y: 0.5)
        )
    }

    @ViewBuilder
    private func progressBarText(geometry geo: GeometryProxy, currentAnimatedProgress: CGFloat) -> some View {
        HStack {
            if currentAnimatedProgress > 0.05 || progressPercent > 0 {
                Spacer()
                Text("\(progressPercent)%")
                    .font(.caption).bold()
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .frame(width: geo.size.width * currentAnimatedProgress)
        .clipped()
    }
}

struct TreatmentProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Progress Bar (will query actual events in app):")
            TreatmentProgressBar()
                .padding(.horizontal)
        }
        .previewLayout(.sizeThatFits)
    }
}
