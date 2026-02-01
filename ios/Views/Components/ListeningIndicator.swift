import SwiftUI

struct ListeningIndicator: View {
    let colors: AppColors
    @State private var animationPhase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: .space3) {
            HStack(spacing: .space1) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colors.primary)
                        .frame(width: .space1, height: barHeight(for: index))
                }
            }
            .frame(height: .space8)

            Text("LISTENING...")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textSecondary)
                .tracking(2)
        }
        .padding(.space5)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: .borderStandard))
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    animationPhase = 1
                }
            }
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        let base: CGFloat = 8
        let maxHeight: CGFloat = 28
        let phase = sin(animationPhase * .pi + CGFloat(index) * 0.5)
        return base + (maxHeight - base) * ((phase + 1) / 2)
    }
}
