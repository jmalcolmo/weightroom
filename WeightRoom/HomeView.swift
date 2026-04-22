import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingHistory = false

    var body: some View {
        VStack(spacing: 16) {
            if let session = sessionManager.activeSession {
                Button {
                    navigateTo(session.workoutCategory)
                } label: {
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                        Text("\(session.workoutCategory.displayName) Workout In Progress")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundColor(.accentColor)
                    .cornerRadius(12)
                }
            }

            ForEach(WorkoutType.allCases, id: \.self) { type in
                Button {
                    sessionManager.startSession(type: type)
                    navigateTo(type)
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
        .sheet(isPresented: $showingHistory) {
            NavigationStack {
                WorkoutHistoryView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        // TODO: Open settings
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }

                    Button {
                        // TODO: Create exercise
                    } label: {
                        Label("Create Exercise", systemImage: "dumbbell")
                    }

                    Button {
                        // TODO: Create workout
                    } label: {
                        Label("Create Workout", systemImage: "plus.circle")
                    }

                    Button {
                        showingHistory = true
                    } label: {
                        Label("View Workouts", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                }
            }
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
            HomeView(navigateTo: { _ in })
        }
        .environmentObject(SessionManager(context: PersistenceController.preview.container.viewContext))
    }
}
