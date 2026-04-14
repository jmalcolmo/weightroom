import SwiftUI

@main
struct WeightRoomApp: App {

    let persistence = PersistenceController.shared
    let sessionManager: SessionManager

    init() {
        persistence.seedExercises()
        sessionManager = SessionManager(context: persistence.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(sessionManager)
        }
    }
}
