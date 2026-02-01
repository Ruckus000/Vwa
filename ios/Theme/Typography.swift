import SwiftUI

// MARK: - Typography Tokens
// Design System Section 4: Type Scale

extension Font {
    // Display fonts (SF Pro Display, weight 800-900)
    static var typeDisplayLg: Font {
        .system(size: 42, weight: .black, design: .default)
    }

    static var typeDisplayMd: Font {
        .system(size: 36, weight: .black, design: .default)
    }

    static var typeDisplaySm: Font {
        .system(size: 28, weight: .heavy, design: .default)
    }

    static var typeHeading: Font {
        .system(size: 20, weight: .black, design: .default)
    }

    // Body fonts (SF Pro Text, weight 400)
    static var typeBodyLg: Font {
        .system(size: 16, weight: .regular, design: .default)
    }

    static var typeBody: Font {
        .system(size: 14, weight: .regular, design: .default)
    }

    static var typeBodySm: Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    // Labels (SF Pro Text, weight 800, uppercase with 1px tracking)
    static var typeLabel: Font {
        .system(size: 10, weight: .heavy, design: .default)
    }

    // Mono (SF Mono, weight 400)
    static var typeMono: Font {
        .system(size: 13, weight: .regular, design: .monospaced)
    }

    static var typeMonoSm: Font {
        .system(size: 11, weight: .regular, design: .monospaced)
    }
}

// MARK: - Letter Spacing Tokens
extension CGFloat {
    static let trackingTight: CGFloat = -2  // Display Large/Medium
    static let trackingNormal: CGFloat = -1  // Display Small, Heading
    static let trackingLoose: CGFloat = 1    // Labels (uppercase)
}
