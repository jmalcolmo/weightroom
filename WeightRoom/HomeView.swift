import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 16) {
            ForEach(WorkoutType.allCases, id: \.self) { type in
                Button {
                    sessionManager.startSession(type: type)
                } label: {
                    WorkoutButton(label: type.displayName, style: .primary)
                }
            }

            Divider()
                .padding(.vertical, 4)

            NavigationLink(value: ExerciseFilter.all) {
                WorkoutButton(label: "All Exercises", style: .secondary)
            }
        }
        .padding(.horizontal, 24)
        .navigationTitle("Weight Room")
        .navigationDestination(for: ExerciseFilter.self) { filter in
            ExerciseListView(filter: filter)
        }
    }
}

// MARK: - Subviews

struct WorkoutButton: View {
    enum Style { case primary, secondary }

    let label: String
    let style: Style

    var body: some View {
        Text(label)
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(style == .primary ? Color.accentColor : Color.secondary.opacity(0.15))
            .foregroundColor(style == .primary ? .white : .primary)
            .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
