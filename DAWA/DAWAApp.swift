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
        // This is called when a notification is received while the app is in the foreground
        let userInfo = notification.request.content.userInfo
        
        // Handle the notification data
        PushNotificationHandler.shared.handleReceivedNotification(userInfo: userInfo)
        
        if let notificationType = userInfo["notificationType"] as? String {
            if notificationType == "message" {
                if let activityId = userInfo["activityId"] as? String {
                    if PushNotificationHandler.shared.currentChatActivityId == activityId {
                        completionHandler([])
                    }
                }
            }
        }
        
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // This is called when the user taps on a notification (app was in background)
        let userInfo = response.notification.request.content.userInfo
        
        // Handle the notification data
        PushNotificationHandler.shared.handleTappedNotification(userInfo: userInfo)
        
        completionHandler()
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
            var fcmTokens = (document?.data()?["fcmTokens"] as? [[String: String]]) ?? []
            fcmTokens.removeAll { $0["deviceId"] == deviceId }
            fcmTokens.append(["token": fcmToken, "deviceId": deviceId])

            userRef.setData(["fcmTokens": fcmTokens], merge: true) { error in
                if let error = error { print("Error: \(error.localizedDescription)") }
                else { print("FCM token successfully added.") }
            }
        }
    }
}
