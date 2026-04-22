import SwiftUI
import CoreData

struct ExerciseListView: View {
    let filter: ExerciseFilter

    @FetchRequest private var exercises: FetchedResults<Exercise>

    init(filter: ExerciseFilter) {
        self.filter = filter

        let predicate: NSPredicate? = {
            switch filter {
            case .all:
                return nil
            case .byType(let type):
                return NSPredicate(format: "workoutType == %@", type.rawValue)
            }
        }()

        _exercises = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        Group {
            if exercises.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No exercises found.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(exercises) { exercise in
                    NavigationLink(value: exercise) {
                        Text(exercise.name)
                            .font(.body)
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(filter.displayName)
    }
}

struct ExerciseListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExerciseListView(filter: .byType(.push))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
