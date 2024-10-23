//
//  PushNotificationHandler.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 9/14/24.
//

import Foundation
import SwiftUI

class PushNotificationHandler: ObservableObject {
    static let shared = PushNotificationHandler()
    
    @Published var lastNotification: [String: Any]?
    @Published var tappedActivityId: String?
    @Published var currentChatActivityId: String? = nil
    
    private init() {}

    func handleReceivedNotification(userInfo: [AnyHashable: Any]) {
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

    func handleTappedNotification(userInfo: [AnyHashable: Any]) {
        if let notificationType = userInfo["notificationType"] as? String, notificationType == "message" {
            if let activityId = userInfo["activityId"] as? String {
                DispatchQueue.main.async {
                    self.tappedActivityId = activityId
                }
            }
        }
    }
}
