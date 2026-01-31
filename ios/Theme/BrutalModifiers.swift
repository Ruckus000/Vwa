import SwiftUI

struct BrutalCard: ViewModifier {
    let colors: AppColors
    let borderWidth: CGFloat
    let shadowOffset: CGFloat

    init(colors: AppColors, heavy: Bool = false) {
        self.colors = colors
        self.borderWidth = heavy ? 3 : 2
        self.shadowOffset = heavy ? 4 : 2
    }

    func body(content: Content) -> some View {
        content
            .background(colors.surface)
            .overlay(
                Rectangle()
                    .stroke(colors.borderStrong, lineWidth: borderWidth)
            )
            .shadow(
                color: colors.shadow,
                radius: 0,
                x: shadowOffset,
                y: shadowOffset
            )
    }
}

extension View {
    func brutalistCard(_ colors: AppColors, heavy: Bool = false) -> some View {
        modifier(BrutalCard(colors: colors, heavy: heavy))
    }
}
