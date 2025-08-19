import SwiftUI

struct HomeView: View {
    @EnvironmentObject var facts: FactsStore
    @EnvironmentObject var history: HistoryStore
    @EnvironmentObject var notif: NotificationManager

    @State private var displayFact: Fact? = nil
    @State private var selectedFact: Fact? = nil

    private let previewLimit = 120

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // Nagłówek
                    Text("Ciekawostka dnia")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color("wcTextPrimary"))
                        .padding(.horizontal)

                    // --- Dane do karty (proste, lokalne zmienne) ---
                    let fact: Fact = displayFact ?? facts.current()
                    let fullText: String = fact.text
                    let needsDetail: Bool = fullText.count > previewLimit
                    let previewText: String = needsDetail
                        ? String(fullText.prefix(previewLimit)) + "…"
                        : fullText

                    // --- Karta z przyciskami ---
                    FactCardRow(
                        previewText: previewText,
                        needsDetail: needsDetail,
                        onTest: {
                            let when = Date().addingTimeInterval(10)
                            notif.scheduleLocal(fact: fact, at: when)
                        },
                        onReadMore: {
                            if needsDetail { selectedFact = fact }
                        },
                        onNext: {
                            let next = facts.next()
                            displayFact = next
                        }
                    )

                    // Harmonogram notyfikacji (używa tej samej kolejki)
                    Button("Zaplanuj zgodnie z ustawieniami") {
                        let next = facts.next()
                        displayFact = next
                        notif.rescheduleRecurring { next }
                    }
                    .buttonStyle(.bordered)
                    .tint(Color("wcPrimary"))
                    .padding(.horizontal)

                    // Pozostałe linki (jak miałeś)
                    NavigationLink("Ustawienia", destination: SettingsView())
                    NavigationLink("Historia", destination: HistoryView())

                    Spacer()
                    Text("Tryb: \(AppConfig.transport.rawValue)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()

                    Button("Zarejestruj w backendzie teraz") {
                        notif.registerOrUpdateOnBackend()
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("WowCow")
            .toolbarTitleDisplayMode(.inline)
            .background(Color("wcBackground").ignoresSafeArea())
            // Nawigacja do szczegółów
            .navigationDestination(item: $selectedFact) { fact in
                DetailView(fact: fact)
            }
            // Tap w notyfikację (gdy appka żyje)
            .onReceive(NotificationCenter.default.publisher(for: .openFactFromNotification)) { note in
                if let dict = note.object as? [String:String],
                   let id = dict["id"], let text = dict["text"] {
                    selectedFact = Fact(id: id, text: text)
                }
            }
            // Cold start + inicjalizacja faktu na kartę
            .task {
                if displayFact == nil {
                    displayFact = facts.current()
                }
                if let dict = UserDefaults.standard.dictionary(forKey: "pendingFact") as? [String:String],
                   let id = dict["id"], let text = dict["text"] {
                    selectedFact = Fact(id: id, text: text)
                    UserDefaults.standard.removeObject(forKey: "pendingFact")
                }
            }
        }
    }
}

// MARK: - Mały pod-widok karty (odciąża kompilator)
private struct FactCardRow: View {
    let previewText: String
    let needsDetail: Bool
    let onTest: () -> Void
    let onReadMore: () -> Void
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(previewText)
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color("wcTextPrimary"))
                .multilineTextAlignment(.leading)

            HStack {
                // Testowa notyfikacja
                Button(action: onTest) {
                    HStack(spacing: 6) {
                        Text("Test: 10 s")
                        Image(systemName: "chevron.right")
                    }
                    .font(.body.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("wcPrimary"))

                Spacer()

                // Czytaj całość — tylko gdy potrzeba
                if needsDetail {
                    Button(action: onReadMore) {
                        Text("Czytaj całość")
                            .font(.body.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(Color("wcPrimary"))
                }

                // Następna
                Button(action: onNext) {
                    Text("Następna")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(Color("wcPrimary"))
            }
        }
        .padding(20)
        .background(Color("wcCard"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color("wcSeparator"), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 14, y: 8)
        .padding(.horizontal)
    }
}
