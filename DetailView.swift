import SwiftUI

struct DetailView: View {
    let fact: Fact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ciekawostka")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color("wcPrimary"))
                
                Text(fact.text)
                    .font(.body)
                    .foregroundColor(Color("wcTextPrimary"))
                    .padding(.top, 4)
            }
            .padding()
        }
        .background(Color("wcBackground").ignoresSafeArea())
        .navigationTitle("Szczegóły")
        .navigationBarTitleDisplayMode(.inline)
    }
}
