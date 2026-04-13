import CoreData

@objc(LoggedSet)
public class LoggedSet: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var weight: Double
    @NSManaged public var reps: Int16
    @NSManaged public var timestamp: Date
    @NSManaged public var exercise: Exercise?
    @NSManaged public var session: WorkoutSession?
}

extension LoggedSet {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoggedSet> {
        NSFetchRequest<LoggedSet>(entityName: "LoggedSet")
    }
}
