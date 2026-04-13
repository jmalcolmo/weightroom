import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ForEach(WorkoutType.allCases, id: \.self) { type in
                    NavigationLink(value: type) {
                        Text(type.displayName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)
            .navigationTitle("Weight Room")
            .navigationDestination(for: WorkoutType.self) { type in
                // Exercise list — coming next
                Text("\(type.displayName) exercises coming soon")
                    .navigationTitle(type.displayName)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
