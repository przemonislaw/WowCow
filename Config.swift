import Foundation

enum Transport: String {
    case local    // local notifications (no Apple Developer Program needed)
    case remote   // APNs via AWS SNS (requires Apple Developer Program)
}

struct AppConfig {
    static let transport: Transport = .local
    static let backendBaseURL: String? = "https://vlnrkp28m3.execute-api.eu-central-1.amazonaws.com/Prod"
}
