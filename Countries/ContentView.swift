//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CountryListView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Countries")
                }
            QuizView()
                .tabItem {
                    Image(systemName: "checkmark.circle.badge.questionmark")
                    Text("Flag quiz")
                }
        }
    }
}

#Preview {
    ContentView()
} 
