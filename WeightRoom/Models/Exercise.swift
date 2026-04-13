import CoreData

@objc(Exercise)
public class Exercise: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var workoutType: String
    @NSManaged public var sets: NSSet?

    var workoutCategory: WorkoutType {
        WorkoutType(rawValue: workoutType) ?? .push
    }

    var setsArray: [LoggedSet] {
        (sets as? Set<LoggedSet> ?? []).sorted { $0.timestamp < $1.timestamp }
    }
}

extension Exercise {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        NSFetchRequest<Exercise>(entityName: "Exercise")
    }
}
