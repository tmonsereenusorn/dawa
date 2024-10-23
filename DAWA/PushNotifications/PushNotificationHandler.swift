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
    @Published var tappedChatActivityId: String?
    @Published var tappedActivityId: String?
    @Published var tappedGroupId: String?
    @Published var currentChatActivityId: String? = nil
    @Published var tappedGroupInviteId: String?
    
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
        if let notificationType = userInfo["notificationType"] as? String {
            if notificationType == "message" {
                if let activityId = userInfo["activityId"] as? String {
                    DispatchQueue.main.async {
                        self.tappedChatActivityId = activityId
                    }
                }
            } else if notificationType == "newActivity" {
                if let activityId = userInfo["activityId"] as? String, let groupId = userInfo["groupId"] as? String {
                    DispatchQueue.main.async {
                        self.tappedGroupId = groupId
                        self.tappedActivityId = activityId
                    }
                }
            } else if notificationType == "groupInvite" {
                if let inviteId = userInfo["inviteId"] as? String {
                    DispatchQueue.main.async {
                        self.tappedGroupInviteId = inviteId
                    }
                }
            }
        }
    }
}
