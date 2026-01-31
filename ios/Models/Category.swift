import Foundation

enum Category: String, Codable, CaseIterable {
    case agreement = "AGREEMENT"
    case criticism = "CRITICISM"
    case degree = "DEGREE"
    case emotion = "EMOTION"
    case praise = "PRAISE"
    case quality = "QUALITY"
    case truth = "TRUTH"
    case other = "OTHER"
}
