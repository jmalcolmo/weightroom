import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var navPath: [WorkoutType] = []

    var body: some View {
        if let type = sessionManager.activeSession?.workoutCategory {
            NavigationStack {
                WorkoutSessionView(workoutType: type)
            }
        } else {
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
