enum ExerciseFilter: Hashable {
    case all
    case byType(WorkoutType)

    var displayName: String {
        switch self {
        case .all:            return "All Exercises"
        case .byType(let t):  return t.displayName
        }
    }
}
