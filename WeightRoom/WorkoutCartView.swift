import SwiftUI
import CoreData

struct WorkoutCartView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @FetchRequest private var sets: FetchedResults<LoggedSet>

    @State private var expandedSetID: NSManagedObjectID?
    @State private var editingSetID: NSManagedObjectID?
    @State private var editWeight: Int = 0
    @State private var editReps: Int = 1

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
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(sets) { set in
                            VStack(alignment: .leading, spacing: 0) {
                                // Main row
                                HStack {
                                    Text(set.exercise?.name ?? "")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(Int(set.weight)) lbs × \(set.reps) reps")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Image(systemName: expandedSetID == set.objectID ? "chevron.up" : "chevron.down")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .padding(.leading, 6)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        if expandedSetID == set.objectID {
                                            expandedSetID = nil
                                            editingSetID = nil
                                        } else {
                                            expandedSetID = set.objectID
                                            editingSetID = nil
                                        }
                                    }
                                }

                                if expandedSetID == set.objectID {
                                    if editingSetID == set.objectID {
                                        // Edit panel — matches ExerciseRowView style
                                        HStack(spacing: 0) {
                                            Spacer()
                                            VStack(spacing: 2) {
                                                Text("Weight (lbs)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                SwipeableNumber(value: $editWeight, step: 5, minimum: 0)
                                            }
                                            Spacer()
                                            VStack(spacing: 2) {
                                                Text("Reps")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                SwipeableNumber(value: $editReps, step: 1, minimum: 1)
                                            }
                                            Spacer()
                                            Button("Save") {
                                                sessionManager.updateSet(set, weight: editWeight, reps: editReps)
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    editingSetID = nil
                                                    expandedSetID = nil
                                                }
                                            }
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color.accentColor)
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                            .buttonStyle(.plain)
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    } else {
                                        // Edit / Delete action row
                                        HStack(spacing: 12) {
                                            Spacer()
                                            Button("Edit") {
                                                editWeight = Int(set.weight)
                                                editReps = Int(set.reps)
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    editingSetID = set.objectID
                                                }
                                            }
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(Color.accentColor.opacity(0.12))
                                            .foregroundColor(.accentColor)
                                            .cornerRadius(8)
                                            .buttonStyle(.plain)

                                            Button("Delete") {
                                                sessionManager.deleteSet(set)
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    expandedSetID = nil
                                                }
                                            }
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 8)
                                            .background(Color.red.opacity(0.12))
                                            .foregroundColor(.red)
                                            .cornerRadius(8)
                                            .buttonStyle(.plain)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }

                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 16)
                }
                .frame(maxHeight: 240)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}