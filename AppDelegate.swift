import UIKit
import UserNotifications

extension Notification.Name {
    static let openFactFromNotification = Notification.Name("OpenFactFromNotification")
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Foreground presentation
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([ .banner, .sound ])
    }

    // Handle tap
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let info = response.notification.request.content.userInfo
        if let fullText = info["fullText"] as? String,
             let id = info["factId"] as? String {
            // 1) zapisz pending fakt na zimny start / późniejszy odczyt
             let payload: [String:String] = ["id": id, "text": fullText]
             UserDefaults.standard.set(payload, forKey: "pendingFact")
             
            // 2) wyślij event dla działającej już aplikacji
              NotificationCenter.default.post(name: .openFactFromNotification, object: payload)
        
        //    let fact = Fact(id: id, text: fullText)
          //   NotificationCenter.default.post(name: Notification.Name("OpenFact"), object: fact)
         }
        
        completionHandler()
    }

    // Remote push placeholders (will work after APNs is enabled)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs token: \(token)")
        // TODO: send to backend in remote mode
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed APNs registration: \(error.localizedDescription)")
    }
}
