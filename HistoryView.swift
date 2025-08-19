import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var history: HistoryStore

    var body: some View {
        List(history.items) { fact in
            Text(fact.text)
        }
        .navigationTitle("Historia")
    }
}