//
//  UserActivity.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Firebase
import FirebaseFirestoreSwift

struct UserActivity: Identifiable, Codable, Hashable {
    @DocumentID var activityId: String?
    
    var recentMessageId: String?
    var recentMessage: Message?
    var activity: Activity?
    
    var id: String {
        return activityId ?? NSUUID().uuidString
    }
}
