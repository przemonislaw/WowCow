import SwiftUI
import UserNotifications

@main
struct WowCowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var factsStore = FactsStore()
    @StateObject private var history = HistoryStore()
    @StateObject private var notif = NotificationManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(.light)
                .environmentObject(factsStore)
                .environmentObject(history)
                .environmentObject(notif)
                .onAppear {
                    notif.requestAuthorization()
                    notif.registerOrUpdateOnBackend() // auto-register
                }
        }
    }
}
