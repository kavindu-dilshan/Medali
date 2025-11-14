import SwiftUI

struct AdherenceRingView: View {
    let progress: Double // 0.0 ... 1.0
    private let lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth))

            Circle()
                .trim(from: 0, to: CGFloat(max(0, min(1, progress))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8))

            Text("\(Int((max(0, min(1, progress))) * 100))%")
                .font(.headline.monospacedDigit())
        }
        .accessibilityElement()
        .accessibilityLabel("Adherence \(Int((max(0, min(1, progress))) * 100)) percent")
    }
}

struct AdherenceRingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdherenceRingView(progress: 0.72)
                .frame(width: 120, height: 120)
            AdherenceRingView(progress: 0.25)
                .frame(width: 120, height: 120)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
