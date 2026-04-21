import CoreData

@objc(WorkoutSession)
public class WorkoutSession: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var workoutType: String
    @NSManaged public var sets: NSSet?

    var workoutCategory: WorkoutType {
        WorkoutType(rawValue: workoutType) ?? .push
    }

    var setsArray: [LoggedSet] {
        (sets as? Set<LoggedSet> ?? []).sorted { $0.timestamp < $1.timestamp }
    }
}

extension WorkoutSession {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSession> {
        NSFetchRequest<WorkoutSession>(entityName: "WorkoutSession")
    }
}
