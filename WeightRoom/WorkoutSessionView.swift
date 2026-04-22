import SwiftUI
import CoreData

struct WorkoutSessionView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @FetchRequest private var exercises: FetchedResults<Exercise>

    @State private var weight: Int = 0
    @State private var reps: Int = 1

    init(workoutType: WorkoutType) {
        _exercises = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
            predicate: NSPredicate(format: "workoutType == %@", workoutType.rawValue),
            animation: .default
        )
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Exercise list ──────────────────────────────────────────────
            List(exercises) { exercise in
                ExerciseRowView(
                    exercise: exercise,
                    isExpanded: sessionManager.expandedExercise == exercise,
                    weight: $weight,
                    reps: $reps,
                    onTap: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            sessionManager.selectExercise(exercise)
                        }
                    },
                    onAddSet: {
                        sessionManager.addSet(exercise: exercise, weight: weight, reps: reps)
                    }
                )
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            .listStyle(.plain)

            // ── Persistent cart ────────────────────────────────────────────
            if let session = sessionManager.activeSession {
                WorkoutCartView(session: session)
            }
        }
        .navigationTitle(sessionManager.activeSession?.workoutCategory.displayName ?? "Workout")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Finish Workout") {
                    sessionManager.finishSession()
                }
                .foregroundColor(.red)
            }
        }
        .onChange(of: sessionManager.expandedExercise) { exercise in
            resetInputs(for: exercise)
        }
        .onAppear {
            resetInputs(for: sessionManager.expandedExercise)
        }
    }

    private func resetInputs(for exercise: Exercise?) {
        guard let exercise else { return }
        if let last = sessionManager.lastSet(for: exercise) {
            weight = Int(last.weight)
            reps = Int(last.reps)
        } else {
            weight = 0
            reps = 1
        }
    }
}
