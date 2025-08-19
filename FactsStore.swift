import Foundation



final class FactsStore: ObservableObject {
    @Published private(set) var all: [Fact] = [
        Fact(id: "1", text: "Miód nie psuje się — znaleziono jadalny w grobowcach faraonów."),
        Fact(id: "2", text: "Słoń jest jedynym ssakiem, który nie potrafi skakać."),
        Fact(id: "3", text: "Banany to jagody, a truskawki nie są jagodami botanicznie."),
        Fact(id: "4", text: "Ośmiornice mają trzy serca i niebieską krew.")
    ]

    // Persistowana kolejność i indeks
    private let orderKey = "facts.order"
    private let indexKey = "facts.index"

    private var order: [String] = []
    private var index: Int = 0

    init() {
        loadOrder()
        normalizeIfContentChanged()
    }

    /// Zwraca aktualny fakt wg zapisanej kolejki.
    func current() -> Fact {
        guard !order.isEmpty else {
            regenerateOrder(); saveOrder()
            return current()
        }
        let id = order[clamp(index, 0, order.count - 1)]
        return all.first(where: { $0.id == id }) ?? all.first!
    }

    /// Przechodzi do kolejnego faktu w cyklu i zwraca go.
    @discardableResult
    func next() -> Fact {
        guard !order.isEmpty else {
            regenerateOrder(); saveOrder()
            return next()
        }
        index = (index + 1) % order.count
        saveOrder()
        return current()
    }

    /// Jeśli zestaw faktów się zmienił, resetuje kolejkę.
    func normalizeIfContentChanged() {
        let ids = Set(all.map { $0.id })
        let saved = Set(order)
        if ids != saved || order.count != all.count {
            regenerateOrder()
            index = 0
            saveOrder()
        }
    }

    // MARK: - Persistence helpers

    private func loadOrder() {
        let ud = UserDefaults.standard
        if let arr = ud.array(forKey: orderKey) as? [String] {
            order = arr
        }
        index = ud.integer(forKey: indexKey)
        if order.isEmpty { regenerateOrder(); saveOrder() }
    }

    private func saveOrder() {
        let ud = UserDefaults.standard
        ud.set(order, forKey: orderKey)
        ud.set(index, forKey: indexKey)
    }

    private func regenerateOrder() {
        order = all.map { $0.id }.shuffled()
    }

    private func clamp(_ x: Int, _ lo: Int, _ hi: Int) -> Int {
        min(max(x, lo), hi)
    }
}
