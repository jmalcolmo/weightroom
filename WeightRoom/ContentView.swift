import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 32) {
            Text("Weight Room")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Pick your workout")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
