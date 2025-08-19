import Foundation

final class HistoryStore: ObservableObject {
    @Published private(set) var items: [Fact] = []

    private let key = "history_facts"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Fact].self, from: data) {
            items = decoded
        }
    }

    func add(_ fact: Fact) {
        guard !items.contains(fact) else { return }
        items.insert(fact, at: 0)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}