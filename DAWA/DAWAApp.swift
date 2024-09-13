import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import FirebaseMessaging

@main
struct DAWAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        checkAndRegisterForPushNotifications()
        return true
    }

    func checkAndRegisterForPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
            } else if settings.authorizationStatus == .notDetermined {
                self.requestPushNotificationPermission()
            } else {
                print("Push notifications are denied.")
            }
        }
    }

    func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted { DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() } }
            else { print("Error: \(error?.localizedDescription ?? "Permissions denied.")") }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        storeFCMToken(fcmToken)
    }

    func storeFCMToken(_ fcmToken: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown_device"
        let userRef = Firestore.firestore().collection("users").document(userId)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                return
            }
            
            var fcmTokens = (document?.data()?["fcmTokens"] as? [[String: String]]) ?? []
            
            // Remove existing entry for this device if it exists
            fcmTokens.removeAll { $0["deviceId"] == deviceId }
            
            // Add the new token
            fcmTokens.append(["deviceId": deviceId, "token": fcmToken])
            
            userRef.setData(["fcmTokens": fcmTokens], merge: true) { error in
                if let error = error {
                    print("Error updating FCM token: \(error.localizedDescription)")
                } else {
                    print("FCM token successfully added/updated for device: \(deviceId)")
                }
            }
        }
    }
}
