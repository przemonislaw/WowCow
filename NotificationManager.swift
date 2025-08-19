import Foundation
import UIKit
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published var settings = loadSettings()

    static func loadSettings() -> Settings {
        if let data = UserDefaults.standard.data(forKey: "settings"),
           let s = try? JSONDecoder().decode(Settings.self, from: data) {
            return s
        }
        return Settings()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: "settings")
        }
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // LOCAL notification (works without Developer Program)
    func scheduleLocal(fact: Fact, at date: Date) {
        let content = UNMutableNotificationContent()
        
        let maxLength = 120
        let fullText = fact.text
        let bodyText = fullText.count > maxLength
            ? String(fullText.prefix(maxLength)) + "… (otwórz aby przeczytać całość)"
            : fullText
        
        content.title = "Ciekawostka"
        content.body = bodyText //fact.text
        content.sound = .default
        
        // przekazujemy komplet danych do późniejszego otwarcia detailu
        content.userInfo = [
            "factId": fact.id,
            "fullText": fullText
        ]
        
        
        if let url = Bundle.main.url(forResource: "AppIcon_WowCow_1024", withExtension: "png"),
           let attachment = try? UNNotificationAttachment(identifier: "wowcow", url: url) {
            content.attachments = [attachment]
        }

        let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { error in
            if let error = error {
                print("❌ Scheduling local notification failed: \(error.localizedDescription)")
            } else {
                print("✅ Local notification scheduled at \(date)")
            }
        }
    }

    func rescheduleRecurring(nextFactProvider: () -> Fact?) {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.hour = settings.hour
        comps.minute = settings.minute

        var next = cal.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTimePreservingSmallerComponents) ?? Date().addingTimeInterval(60)
        if settings.frequency == .weekly && next < Date() { next = next.addingTimeInterval(7*24*3600) }

        if let fact = nextFactProvider() {
            switch AppConfig.transport {
            case .local:
                scheduleLocal(fact: fact, at: next)
            case .remote:
                // In remote mode, backend handles time-based push; we just register/update settings.
                registerOrUpdateOnBackend()
            }
        }
    }

    func update(settings newSettings: Settings) {
        self.settings = newSettings
        persist()
        if AppConfig.transport == .remote {
            registerOrUpdateOnBackend()
        }
    }

    // Placeholder for backend call (use once you have API URL and APNs token)
    func registerOrUpdateOnBackend() {
        print("🔧 registerOrUpdateOnBackend() start")
        print("🔧 backendBaseURL:", AppConfig.backendBaseURL ?? "nil")

        guard let base = AppConfig.backendBaseURL,
              let url = URL(string: base + "/registerDevice") else {
            print("⚠️ Backend URL not set or invalid.")
            return
        }

        let tz = TimeZone.current.identifier
        let payload: [String: Any] = [
            "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            "deviceToken": "TOKEN_PLACEHOLDER",
            "frequency": settings.frequency == .daily ? "daily" : "weekly",
            "hour": settings.hour,
            "minute": settings.minute,
            "timezone": tz
        ]
        print("➡️ Sending to \(url.absoluteString), payload:", payload)

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { print("❌ registerDevice error:", err.localizedDescription); return }
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            print("✅ registerDevice status:", status)
            if let data = data, let body = String(data: data, encoding: .utf8) {
                print("📦 registerDevice body:", body)
            }
        }.resume()
    }

}
