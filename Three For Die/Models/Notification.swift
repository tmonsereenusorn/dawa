//
//  Notification.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/13/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

enum NotificationType: String, Codable {
    case activityJoin = "activity_join"
    case activityLeave = "activity_leave"
}

protocol NotificationBase: Codable {
    var id: String? { get }
    var type: NotificationType { get }
    var timestamp: Timestamp { get }
    var message: String { get }
    var hasRead: Bool { get set }
}

struct ActivityJoinNotification: NotificationBase {
    @DocumentID var id: String?
    var type: NotificationType
    var timestamp: Timestamp
    var activityId: String
    var joinedByUserId: String
    var hasRead: Bool = false
    var user: User?

    // Computed property to generate the message based on available data
    var message: String {
        if let username = user?.username {
            return "\(username) has joined your activity."
        } else {
            return "User \(joinedByUserId) has joined your activity."
        }
    }

    // Initializer
    init(activityId: String, joinedByUserId: String) {
        self.type = .activityJoin
        self.timestamp = Timestamp()
        self.activityId = activityId
        self.joinedByUserId = joinedByUserId
    }
}

// ActivityLeaveNotification struct
struct ActivityLeaveNotification: NotificationBase {
    @DocumentID var id: String?
    var type: NotificationType
    var timestamp: Timestamp
    var activityId: String
    var leftByUserId: String
    var hasRead: Bool = false
    var user: User?

    // Computed property to generate the message based on available data
    var message: String {
        if let username = user?.username {
            return "\(username) has left your activity."
        } else {
            return "User \(leftByUserId) has left your activity."
        }
    }

    // Initializer
    init(activityId: String, leftByUserId: String) {
        self.type = .activityLeave
        self.timestamp = Timestamp()
        self.activityId = activityId
        self.leftByUserId = leftByUserId
    }
}
