import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
struct Three_For_DieApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var groupsViewModel = GroupsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(groupsViewModel)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
