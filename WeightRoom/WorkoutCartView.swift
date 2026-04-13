import SwiftUI
import CoreData

struct WorkoutCartView: View {
    @FetchRequest private var sets: FetchedResults<LoggedSet>

    init(session: WorkoutSession) {
        _sets = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \LoggedSet.timestamp, ascending: true)],
            predicate: NSPredicate(format: "session == %@", session),
            animation: .default
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                Text("Today's Sets")
                    .font(.headline)
                Spacer()
                Text("\(sets.count) \(sets.count == 1 ? "set" : "sets")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if sets.isEmpty {
                Text("No sets logged yet — add your first one above.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(sets) { set in
                            HStack {
                                Text(set.exercise?.name ?? "")
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(set.weight)) lbs × \(set.reps) reps")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 16)
                }
                .frame(maxHeight: 180)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}
