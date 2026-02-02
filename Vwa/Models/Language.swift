import Foundation

enum Language: String, CaseIterable, Codable {
    case ES
    case FR

    /// Display name for UI
    var displayName: String {
        switch self {
        case .ES: return "ESPANOL"
        case .FR: return "FRANCAIS"
        }
    }

    /// Short code for toggle buttons
    var code: String { rawValue }
}
