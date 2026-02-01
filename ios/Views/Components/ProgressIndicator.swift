import SwiftUI

struct ProgressIndicator: View {
    let current: Int
    let total: Int
    let colors: AppColors
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private let maxBars = 10

    var body: some View {
        VStack(alignment: .leading, spacing: .space2) {
            if total <= maxBars {
                // Individual bars for small sets
                HStack(spacing: .space1) {
                    ForEach(0..<total, id: \.self) { index in
                        Rectangle()
                            .fill(index == current ? colors.primary : colors.border)
                            .frame(height: .space1)
                            .frame(maxWidth: index == current ? .infinity : .space3)
                    }
                }
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: current)
            } else {
                // Single progress bar for large sets
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(colors.border)

                        Rectangle()
                            .fill(colors.primary)
                            .frame(width: geometry.size.width * progressFraction)
                    }
                }
                .frame(height: .space1)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: current)
            }

            Text(counterText)
                .font(.typeMonoSm)
                .foregroundColor(colors.textMuted)
                .accessibilityLabel("Phrase \(current + 1) of \(total)")
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue("Phrase \(current + 1) of \(total)")
    }

    private var progressFraction: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current + 1) / CGFloat(total)
    }

    private var counterText: String {
        "\(String(format: "%02d", current + 1))/\(String(format: "%02d", total))"
    }
}
