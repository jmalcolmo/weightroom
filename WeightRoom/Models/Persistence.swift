import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

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

    /// The current seed version. Bump this any time the exercise list changes
    /// so the app wipes and reseeds on next launch.
    private static let seedVersion = 2

    /// Inserts the predefined exercise list. If the seed version has changed
    /// since the last launch, all exercises are wiped and reseeded.
    func seedExercises() {
        let context = container.viewContext
        let defaults = UserDefaults.standard
        let lastSeedVersion = defaults.integer(forKey: "exerciseSeedVersion")

        if lastSeedVersion != Self.seedVersion {
            // Wipe existing exercises before reseeding
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: Exercise.fetchRequest())
            try? context.execute(deleteRequest)
        } else {
            // Already on the current version — nothing to do
            let request = Exercise.fetchRequest()
            request.fetchLimit = 1
            guard (try? context.count(for: request)) == 0 else { return }
        }

        let exercises: [(name: String, type: WorkoutType)] = [
            // Push
            ("Bench Press (Flat)",          .push),
            ("Bench Press (Incline)",        .push),
            ("Dips",                         .push),
            ("Shoulder Press",               .push),
            ("Tricep Extension (Machine)",   .push),
            ("Tricep Extension (Cable)",     .push),
            ("Lateral Raise (DB)",           .push),
            ("Lateral Raise (Machine)",      .push),
            ("Pec Fly",                      .push),
            // Pull
            ("Lat Pulldown",                 .pull),
            ("Pull-Ups",                     .pull),
            ("Cable Pullover",               .pull),
            ("Bicep Curl (DB)",              .pull),
            ("Bicep Curl (Machine)",         .pull),
            ("Chest Supported Row",          .pull),
            ("Cable Row",                    .pull),
            ("Rope Face Pull",               .pull),
            ("Reverse Pec Deck",             .pull),
            ("EZ Bar Curl",                  .pull),
            // Legs
            ("Back Squat",                   .legs),
            ("Hamstring Curl",               .legs),
            ("Leg Extension",                .legs),
            ("Hip Abductors",                .legs),
            ("Calf Raises",                  .legs),
            ("Bulgarians",                   .legs),
        ]

        for entry in exercises {
            let exercise = Exercise(context: context)
            exercise.id = UUID()
            exercise.name = entry.name
            exercise.workoutType = entry.type.rawValue
        }

        try? context.save()
        defaults.set(Self.seedVersion, forKey: "exerciseSeedVersion")
    }
}
