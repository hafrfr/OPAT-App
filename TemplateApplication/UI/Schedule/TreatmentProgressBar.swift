// OPAT-App/TemplateApplication/UI/Schedule/TreatmentProgressBar.swift
import SwiftUI
import SpeziScheduler // Required for @EventQuery and Event

struct TreatmentProgressBar: View {
    // Query events for today directly in this view
    @EventQuery(in: Self.todayRange) private var todaysEvents: [Event]

    private var barHeight: CGFloat = 20
    @State private var animatedProgress: CGFloat = 0

    // Helper to define today's range for the @EventQuery
    private static var todayRange: Range<Date> {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            // Fallback to an empty range if endOfDay can't be calculated (should not happen)
            return startOfDay..<startOfDay
        }
        return startOfDay..<endOfDay
    }

    // Calculate completedCount from the queried events
    private var completedCount: Int {
        todaysEvents.filter { $0.isCompleted }.count
    }

    // Calculate totalCount from the queried events
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

    // Initializer no longer needs completedCount and totalCount
    init(barHeight: CGFloat = 20) {
        self.barHeight = barHeight
    }

    var body: some View {
           if totalCount > 0 {
               GeometryReader { geo in // This closure is now much shorter
                   progressBarContent(geometry: geo, currentAnimatedProgress: animatedProgress)
               }
               .frame(height: barHeight)
               .onAppear {
                   animatedProgress = 0
                   withAnimation(.easeOut(duration: 0.8)) {
                       animatedProgress = progressFraction
                   }
               }
               .onChange(of: progressFraction) { newProgressFractionValue in
                   withAnimation(.easeOut(duration: 0.8)) {
                       animatedProgress = newProgressFractionValue
                   }
                   print("TreatmentProgressBar: progressFraction changed. New: \(newProgressFractionValue)")
               }
           } else {
               EmptyView()
           }
       }

       // --- Private Helper Method for the progress bar's visual content ---
       @ViewBuilder
       private func progressBarContent(geometry geo: GeometryProxy, currentAnimatedProgress: CGFloat) -> some View {
           ZStack(alignment: .leading) {
               Capsule()
                   .fill(Color.green.opacity(0.2)) // Consider ColorTheme
               Capsule()
                   .fill(
                       LinearGradient(
                           gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]), // Consider ColorTheme
                           startPoint: .leading,
                           endPoint: .trailing
                       )
                   )
                   .frame(width: geo.size.width * currentAnimatedProgress) // Use parameter
                   .overlay(
                       progressBarText(geometry: geo, currentAnimatedProgress: currentAnimatedProgress) // Extracted text
                   )
                   // Animation for capsule width moved to the main body's onChange or onAppear if tied to state changes
                   // However, since this view is rebuilt when currentAnimatedProgress changes, direct animation here is also fine.
                   .animation(.easeOut(duration: 0.8), value: currentAnimatedProgress)
           }
           .frame(height: barHeight) // Height can be applied here or on the ZStack
       }

       // --- Further extraction for the text overlay ---
       @ViewBuilder
       private func progressBarText(geometry geo: GeometryProxy, currentAnimatedProgress: CGFloat) -> some View {
           HStack {
               // Show percentage only if there's some progress
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
           // Animation for text appearance can be tied to currentAnimatedProgress
           .animation(.easeOut(duration: 0.8), value: currentAnimatedProgress)
       }
   }

   // Preview remains the same
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
