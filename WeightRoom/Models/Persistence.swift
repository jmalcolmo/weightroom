import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        controller.seedExercises()
        controller.seedPreviewSessions()
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
            do { _ = try context.execute(deleteRequest) } catch {}
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

    /// Seeds realistic dummy workout sessions for SwiftUI previews only.
    /// Looks up named exercises that were already inserted by seedExercises().
    func seedPreviewSessions() {
        let context = container.viewContext

        func exercise(named name: String) -> Exercise? {
            let req = Exercise.fetchRequest()
            req.predicate = NSPredicate(format: "name == %@", name)
            req.fetchLimit = 1
            return try? context.fetch(req).first
        }

        func makeSession(type: WorkoutType, daysAgo: Int) -> WorkoutSession {
            let session = WorkoutSession(context: context)
            session.id = UUID()
            session.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
            session.workoutType = type.rawValue
            return session
        }

        func addSet(to session: WorkoutSession, exercise: Exercise?, weight: Double, reps: Int, secondsAgo: Int) {
            guard let exercise else { return }
            let set = LoggedSet(context: context)
            set.id = UUID()
            set.weight = weight
            set.reps = Int16(reps)
            set.timestamp = Date().addingTimeInterval(TimeInterval(-secondsAgo))
            set.exercise = exercise
            set.session = session
        }

        // ── Pull Day — 7 days ago ─────────────────────────────────────────
        let pull = makeSession(type: .pull, daysAgo: 7)
        let bench = exercise(named: "Bench Press (Flat)")
        addSet(to: pull, exercise: bench, weight: 200, reps: 4, secondsAgo: 3600)
        addSet(to: pull, exercise: bench, weight: 225, reps: 2, secondsAgo: 3300)
        addSet(to: pull, exercise: bench, weight: 185, reps: 1, secondsAgo: 3000)
        let dips = exercise(named: "Dips")
        addSet(to: pull, exercise: dips, weight: 205, reps: 12, secondsAgo: 2700)
        addSet(to: pull, exercise: dips, weight: 205, reps: 10, secondsAgo: 2400)
        addSet(to: pull, exercise: dips, weight: 205, reps: 8,  secondsAgo: 2100)

        // ── Push Day — 4 days ago ─────────────────────────────────────────
        let push = makeSession(type: .push, daysAgo: 4)
        let latPulldown = exercise(named: "Lat Pulldown")
        addSet(to: push, exercise: latPulldown, weight: 150, reps: 10, secondsAgo: 3600)
        addSet(to: push, exercise: latPulldown, weight: 160, reps: 8,  secondsAgo: 3300)
        addSet(to: push, exercise: latPulldown, weight: 160, reps: 7,  secondsAgo: 3000)
        let row = exercise(named: "Cable Row")
        addSet(to: push, exercise: row, weight: 120, reps: 12, secondsAgo: 2700)
        addSet(to: push, exercise: row, weight: 130, reps: 10, secondsAgo: 2400)

        // ── Leg Day — 2 days ago ──────────────────────────────────────────
        let legs = makeSession(type: .legs, daysAgo: 2)
        let squat = exercise(named: "Back Squat")
        addSet(to: legs, exercise: squat, weight: 225, reps: 5,  secondsAgo: 3600)
        addSet(to: legs, exercise: squat, weight: 245, reps: 3,  secondsAgo: 3300)
        addSet(to: legs, exercise: squat, weight: 265, reps: 1,  secondsAgo: 3000)
        let curl = exercise(named: "Hamstring Curl")
        addSet(to: legs, exercise: curl, weight: 90,  reps: 12, secondsAgo: 2700)
        addSet(to: legs, exercise: curl, weight: 95,  reps: 10, secondsAgo: 2400)
        addSet(to: legs, exercise: curl, weight: 95,  reps: 8,  secondsAgo: 2100)

        try? context.save()
    }
}
