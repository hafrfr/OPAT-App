import SwiftUI

struct TreatmentProgressBar: View {
    let completedCount: Int
    let totalCount: Int
    let barHeight: CGFloat = 20

    @State private var animatedProgress: CGFloat = 0

    private var progressFraction: CGFloat {
        guard totalCount > 0 else { return 0 }
        return min(max(CGFloat(completedCount) / CGFloat(totalCount), 0), 1)
    }

    private var progressPercent: Int {
        Int(progressFraction * 100)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.green.opacity(0.2))
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * animatedProgress)
                    .overlay(
                        Text("\(progressPercent)%")
                            .font(.caption).bold()
                            .foregroundColor(.white)
                            .offset(x: (geo.size.width * animatedProgress) / 2 - 20)
                            .animation(.easeOut(duration: 0.8), value: animatedProgress)
                    )
                    .animation(.easeOut(duration: 0.8), value: animatedProgress)
            }
            .frame(height: barHeight)
            .onAppear {
                // Animate fill
                animatedProgress = 0
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedProgress = progressFraction
                }
            }
        }
        .frame(height: barHeight)
    }
}

struct TreatmentProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TreatmentProgressBar(completedCount: 3, totalCount: 10)
                .padding(.horizontal)
            TreatmentProgressBar(completedCount: 10, totalCount: 10)
                .padding(.horizontal)
        }
        .previewLayout(.sizeThatFits)
    }
}
