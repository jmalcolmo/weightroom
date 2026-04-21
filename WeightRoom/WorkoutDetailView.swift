import SwiftUI

struct WorkoutDetailView: View {
    let session: WorkoutSession

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    /// Sets grouped by exercise in the order they were first logged.
    private var exerciseGroups: [(name: String, sets: [LoggedSet])] {
        var groups: [(name: String, sets: [LoggedSet])] = []
        var indexMap: [String: Int] = [:]
        for set in session.setsArray {
            let name = set.exercise?.name ?? "Unknown"
            if let idx = indexMap[name] {
                groups[idx].sets.append(set)
            } else {
                indexMap[name] = groups.count
                groups.append((name: name, sets: [set]))
            }
        }
        return groups
    }

    var body: some View {
        List {
            ForEach(exerciseGroups, id: \.name) { group in
                Section(group.name) {
                    ForEach(Array(group.sets.enumerated()), id: \.offset) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(set.weight)) lbs × \(set.reps) reps")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(session.workoutCategory.displayName + " Day")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(Self.dateFormatter.string(from: session.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let request = WorkoutSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WorkoutSession.date, ascending: false)]
        request.fetchLimit = 1
        let session = (try? context.fetch(request))?.first

        return Group {
            if let session {
                NavigationStack {
                    WorkoutDetailView(session: session)
                }
                .environment(\.managedObjectContext, context)
            } else {
                Text("No preview session found")
            }
        }
    }
}
