import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var notif: NotificationManager
    @State private var freq: Frequency = .daily
    @State private var time = Date()

    var body: some View {
        Form {
            Picker("Częstotliwość", selection: $freq) {
                ForEach(Frequency.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            DatePicker("Godzina", selection: $time, displayedComponents: .hourAndMinute)

            Button("Zapisz") {
                let comps = Calendar.current.dateComponents([.hour,.minute], from: time)
                var s = notif.settings
                s.frequency = freq
                s.hour = comps.hour ?? 9
                s.minute = comps.minute ?? 0
                notif.update(settings: s)
                notif.registerOrUpdateOnBackend()
            }
            .buttonStyle(.borderedProminent)
            .tint(.wcPrimary)
            .background(
                LinearGradient(
                    colors: [Color(UIColor.secondarySystemBackground), Color(UIColor.systemBackground)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ).ignoresSafeArea()
            )
        }
        .onAppear {
            freq = notif.settings.frequency
            var comps = DateComponents()
            comps.hour = notif.settings.hour
            comps.minute = notif.settings.minute
            time = Calendar.current.date(from: comps) ?? Date()
        }
        .navigationTitle("Ustawienia")
    }
}
