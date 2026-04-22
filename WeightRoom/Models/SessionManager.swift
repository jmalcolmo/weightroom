import CoreData
import SwiftUI

class SessionManager: ObservableObject {
    @Published var activeSession: WorkoutSession?
    @Published var expandedExercise: Exercise?

    private let context: NSManagedObjectContext

    private static let activeSessionKey   = "activeSessionID"
    private static let expandedExerciseKey = "expandedExerciseID"

    init(context: NSManagedObjectContext) {
        self.context = context
        restoreState()
    }

    // MARK: - Session control

    func startSession(type: WorkoutType) {
        let session = WorkoutSession(context: context)
        session.id = UUID()
        session.date = Date()
        session.workoutType = type.rawValue
        save()
        activeSession = session
        UserDefaults.standard.set(session.id.uuidString, forKey: Self.activeSessionKey)
    }

    func finishSession() {
        activeSession = nil
        expandedExercise = nil
        UserDefaults.standard.removeObject(forKey: Self.activeSessionKey)
        UserDefaults.standard.removeObject(forKey: Self.expandedExerciseKey)
    }

    // MARK: - Exercise selection

    func selectExercise(_ exercise: Exercise) {
        if expandedExercise == exercise {
            expandedExercise = nil
            UserDefaults.standard.removeObject(forKey: Self.expandedExerciseKey)
        } else {
            expandedExercise = exercise
            UserDefaults.standard.set(exercise.id.uuidString, forKey: Self.expandedExerciseKey)
        }
    }

    // MARK: - Logging

    func addSet(exercise: Exercise, weight: Int, reps: Int) {
        guard let session = activeSession else { return }
        let set = LoggedSet(context: context)
        set.id = UUID()
        set.weight = Double(weight)
        set.reps = Int16(reps)
        set.timestamp = Date()
        set.exercise = exercise
        set.session = session
        save()
    }

    /// Returns the most recent LoggedSet ever recorded for this exercise, across all sessions.
    /// Used to pre-fill weight and reps when a row expands.
    func lastSet(for exercise: Exercise) -> LoggedSet? {
        let request = LoggedSet.fetchRequest()
        request.predicate = NSPredicate(format: "exercise == %@", exercise)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LoggedSet.timestamp, ascending: false)]
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func deleteSet(_ set: LoggedSet) {
        context.delete(set)
        save()
    }

    func updateSet(_ set: LoggedSet, weight: Int, reps: Int) {
        set.weight = Double(weight)
        set.reps = Int16(reps)
        save()
    }

    // MARK: - Private

    private func save() {
        try? context.save()
    }

    private func restoreState() {
        guard
            let idString = UserDefaults.standard.string(forKey: Self.activeSessionKey),
            let uuid = UUID(uuidString: idString)
        else { return }

        let sessionRequest = WorkoutSession.fetchRequest()
        sessionRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        sessionRequest.fetchLimit = 1
        activeSession = try? context.fetch(sessionRequest).first

        guard
            let exIDString = UserDefaults.standard.string(forKey: Self.expandedExerciseKey),
            let exUUID = UUID(uuidString: exIDString)
        else { return }

        let exerciseRequest = Exercise.fetchRequest()
        exerciseRequest.predicate = NSPredicate(format: "id == %@", exUUID as CVarArg)
        exerciseRequest.fetchLimit = 1
        expandedExercise = try? context.fetch(exerciseRequest).first
    }
}
