import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var navPath: [WorkoutType] = []

    var body: some View {
        NavigationStack(path: $navPath) {
            HomeView(navigateTo: { type in
                navPath = [type]
            })
            .navigationDestination(for: WorkoutType.self) { type in
                WorkoutSessionView(workoutType: type)
            }
        }
        .onAppear {
            if let session = sessionManager.activeSession {
                navPath = [session.workoutCategory]
            }
        }
        .onChange(of: sessionManager.activeSession) { session in
            if session == nil {
                navPath = []
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
