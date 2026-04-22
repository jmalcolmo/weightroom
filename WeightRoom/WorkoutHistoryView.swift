import SwiftUI
import CoreData

struct WorkoutHistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)],
        animation: .default
    ) private var sessions: FetchedResults<WorkoutSession>

    var body: some View {
        Group {
            if sessions.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Text("No workouts logged yet.")
                        .font(.headline)
                    Text("Finish a workout to see it here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(sessions) { session in
                    NavigationLink(destination: WorkoutDetailView(session: session)) {
                        WorkoutHistoryRow(session: session)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Workout History")
    }
}

// MARK: - Row

private struct WorkoutHistoryRow: View {
    let session: WorkoutSession

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    var setCount: Int {
        session.setsArray.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.workoutCategory.displayName + " Day")
                .font(.headline)
            HStack(spacing: 8) {
                Text(Self.dateFormatter.string(from: session.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("·")
                    .foregroundColor(.secondary)
                Text("\(setCount) \(setCount == 1 ? "set" : "sets")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

struct WorkoutHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WorkoutHistoryView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
