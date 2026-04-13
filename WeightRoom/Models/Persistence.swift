import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    // In-memory store used by SwiftUI Previews — no data written to disk.
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.seedExercises()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WeightRoom")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Seed

    /// Inserts the predefined exercise list if the database is empty.
    /// Safe to call on every launch — checks before inserting.
    func seedExercises() {
        let context = container.viewContext
        let request = Exercise.fetchRequest()
        request.fetchLimit = 1
        guard (try? context.count(for: request)) == 0 else { return }

        let exercises: [(name: String, type: WorkoutType)] = [
            // Push
            ("Bench Press",      .push),
            ("Overhead Press",   .push),
            ("Incline DB Press", .push),
            ("Tricep Pushdown",  .push),
            ("Lateral Raise",    .push),
            // Pull
            ("Pull-Ups",         .pull),
            ("Barbell Row",      .pull),
            ("Cable Row",        .pull),
            ("Barbell Curl",     .pull),
            ("Hammer Curl",      .pull),
            // Legs
            ("Squat",            .legs),
            ("Romanian Deadlift",.legs),
            ("Leg Press",        .legs),
            ("Leg Curl",         .legs),
            ("Calf Raise",       .legs),
        ]

        for entry in exercises {
            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.name = entry.name
            exercise.workoutType = entry.type.rawValue
        }

        try? context.save()
    }
}
