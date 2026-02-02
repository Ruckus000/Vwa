import SwiftUI

// MARK: - Shadow Modifiers
// Design System Section 5.4: Hard Shadows (no blur)

struct BrutalShadow: ViewModifier {
    let colors: AppColors
    let offset: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(
                color: colors.shadow,
                radius: 0,
                x: offset,
                y: offset
            )
    }
}

extension View {
    /// Apply small brutal shadow (2px offset)
    func brutalShadowSm(_ colors: AppColors) -> some View {
        modifier(BrutalShadow(colors: colors, offset: .shadowSmOffset))
    }

    /// Apply medium brutal shadow (4px offset)
    func brutalShadowMd(_ colors: AppColors) -> some View {
        modifier(BrutalShadow(colors: colors, offset: .shadowMdOffset))
    }

    /// Apply large brutal shadow (8px offset)
    func brutalShadowLg(_ colors: AppColors) -> some View {
        modifier(BrutalShadow(colors: colors, offset: .shadowLgOffset))
    }

    /// Apply pressed state shadow (1px offset)
    func brutalShadowPressed(_ colors: AppColors) -> some View {
        modifier(BrutalShadow(colors: colors, offset: .shadowPressedOffset))
    }
}

// MARK: - Card Modifier

struct BrutalCard: ViewModifier {
    let colors: AppColors
    let borderWidth: CGFloat
    let shadowOffset: CGFloat

    init(colors: AppColors, heavy: Bool = false) {
        self.colors = colors
        self.borderWidth = heavy ? .borderHeavy : .borderStandard
        self.shadowOffset = heavy ? .shadowMdOffset : .shadowSmOffset
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
