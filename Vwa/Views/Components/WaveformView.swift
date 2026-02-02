import SwiftUI

/// Waveform visualization for voice input states
/// Uses TimelineView for leak-free animation (no Timer)
struct WaveformView: View {
    let colors: AppColors
    let isActive: Bool
    
    private let barCount = 24
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        Group {
            if isActive && !reduceMotion {
                // Active: TimelineView with ~12fps updates (80ms interval)
                TimelineView(.periodic(from: .now, by: 0.08)) { context in
                    barsView(seed: context.date.timeIntervalSince1970)
                }
            } else {
                // Dormant or reduced motion: static sine wave pattern
                barsView(seed: nil)
            }
        }
        .frame(height: isActive ? 40 : 32)
        .opacity(isActive ? 1.0 : 0.3)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isActive ? "Voice input active" : "Voice input indicator")
        .accessibilityAddTraits(isActive ? .updatesFrequently : [])
    }
    
    private func barsView(seed: Double?) -> some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(isActive ? colors.primary : colors.textMuted)
                    .frame(width: 2.5, height: barHeight(index: index, seed: seed))
            }
        }
    }
    
    private func barHeight(index: Int, seed: Double?) -> CGFloat {
        if let seed = seed {
            // Animated: pseudo-random based on time + index
            let phase = seed * 13.7 + Double(index) * 2.3
            let normalized = (sin(phase) + 1) / 2  // 0...1
            return 3 + CGFloat(normalized) * 22
        } else {
            // Static: gentle sine wave for dormant state
            return 3 + sin(CGFloat(index) * 0.5) * 2
        }
    }
}

// MARK: - Previews

#Preview("Waveform - Active") {
    WaveformView(colors: .dark, isActive: true)
        .padding()
        .background(Color(hex: "0D0D0D"))
}

#Preview("Waveform - Dormant") {
    WaveformView(colors: .dark, isActive: false)
        .padding()
        .background(Color(hex: "0D0D0D"))
}

#Preview("Waveform - Light Mode") {
    WaveformView(colors: .light, isActive: true)
        .padding()
        .background(Color(hex: "F5F5F0"))
}
