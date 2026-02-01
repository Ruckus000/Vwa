import SwiftUI

struct BrutalButton<Content: View>: View {
    let action: () -> Void
    let colors: AppColors
    let small: Bool
    let content: Content

    init(
        colors: AppColors,
        small: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.colors = colors
        self.small = small
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(BrutalButtonStyle(colors: colors, small: small))
    }
}

struct BrutalButtonStyle: ButtonStyle {
    let colors: AppColors
    let small: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let offset: CGFloat = configuration.isPressed ? .shadowPressedOffset : 0
        let shadowOffset: CGFloat = configuration.isPressed ? .shadowPressedOffset : (small ? .shadowSmOffset : .shadowMdOffset)

        configuration.label
            .offset(x: offset, y: offset)
            .shadow(
                color: colors.shadow,
                radius: 0,
                x: shadowOffset,
                y: shadowOffset
            )
            .animation(reduceMotion ? nil : .easeOut(duration: 0.075), value: configuration.isPressed)
    }
}
