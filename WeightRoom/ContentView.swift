import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        if let type = sessionManager.activeSession?.workoutCategory {
            // Active session — land directly on the workout screen, no back button.
            NavigationStack {
                WorkoutSessionView(workoutType: type)
            }
        } else {
            // No active session — show home.
            NavigationStack {
                HomeView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SessionManager(context: PersistenceController.preview.container.viewContext))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
