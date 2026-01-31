import SwiftUI

struct AppColors {
    let bg: Color
    let surface: Color
    let surfaceRaised: Color
    let border: Color
    let borderStrong: Color
    let text: Color
    let textSecondary: Color
    let textMuted: Color
    let primary: Color
    let accent: Color
    let shadow: Color

    static let dark = AppColors(
        bg: Color(hex: "0D0D0D"),
        surface: Color(hex: "1A1A1A"),
        surfaceRaised: Color(hex: "242424"),
        border: Color(hex: "333333"),
        borderStrong: .white,
        text: .white,
        textSecondary: Color(hex: "A3A3A3"),
        textMuted: Color(hex: "666666"),
        primary: Color(hex: "FF6B00"),
        accent: Color(hex: "FFE600"),
        shadow: .black
    )

    static let light = AppColors(
        bg: Color(hex: "F5F5F0"),
        surface: .white,
        surfaceRaised: .white,
        border: Color(hex: "E0E0E0"),
        borderStrong: Color(hex: "0D0D0D"),
        text: Color(hex: "0D0D0D"),
        textSecondary: Color(hex: "525252"),
        textMuted: Color(hex: "858585"),
        primary: Color(hex: "FF5500"),
        accent: Color(hex: "FFD600"),
        shadow: Color(hex: "0D0D0D")
    )

    static func forTheme(_ theme: Theme) -> AppColors {
        theme == .dark ? .dark : .light
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
