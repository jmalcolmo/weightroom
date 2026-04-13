enum WorkoutType: String, CaseIterable {
    case push = "push"
    case pull = "pull"
    case legs = "legs"

    var displayName: String {
        switch self {
        case .push: return "Push"
        case .pull: return "Pull"
        case .legs: return "Legs"
        }
    }
}
