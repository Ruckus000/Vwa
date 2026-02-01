import SwiftUI

// MARK: - Spacing Tokens
// Design System Section 5.1: 4px base unit with geometric progression

extension CGFloat {
    // Base spacing scale
    static let space0: CGFloat = 0
    static let space1: CGFloat = 4
    static let space2: CGFloat = 8
    static let space3: CGFloat = 12
    static let space4: CGFloat = 16
    static let space5: CGFloat = 20
    static let space6: CGFloat = 24
    static let space8: CGFloat = 32
    static let space10: CGFloat = 40

    // Shadow offsets (Section 5.4)
    static let shadowSmOffset: CGFloat = 2
    static let shadowMdOffset: CGFloat = 4
    static let shadowLgOffset: CGFloat = 8
    static let shadowPressedOffset: CGFloat = 1

    // Border widths (Section 5.3)
    static let borderSubtle: CGFloat = 1
    static let borderStandard: CGFloat = 2
    static let borderHeavy: CGFloat = 3

    // Touch target minimum (Section 9.2)
    static let touchTargetMin: CGFloat = 44
}
