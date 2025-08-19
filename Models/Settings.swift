import Foundation

enum Frequency: String, CaseIterable, Codable, Identifiable {
    case daily = "Codziennie"
    case weekly = "Co tydzień"
    var id: String { rawValue }
}

struct Settings: Codable {
    var frequency: Frequency = .daily
    var hour: Int = 9
    var minute: Int = 0
}