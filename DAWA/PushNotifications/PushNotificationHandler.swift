//
//  PushNotificationHandler.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 9/14/24.
//

import Foundation

class PushNotificationHandler: ObservableObject {
    static let shared = PushNotificationHandler()
    
    @Published var lastNotification: [String: Any]?
    
    private init() {}

    func handleNotification(userInfo: [AnyHashable: Any]) {
        // Process the notification data
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let body = alert["body"] as? String {
            print("Received notification: \(body)")
            
            // Update the lastNotification property
            DispatchQueue.main.async {
                self.lastNotification = userInfo as? [String: Any]
            }
        }
    }
}
