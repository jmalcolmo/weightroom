import SwiftUI

@main
struct WeightRoomApp: App {

    let persistence = PersistenceController.shared

    init() {
        persistence.seedExercises()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
