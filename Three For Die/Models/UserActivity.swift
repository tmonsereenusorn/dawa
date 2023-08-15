//
//  UserActivity.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Firebase
import FirebaseFirestoreSwift

struct UserActivity: Identifiable, Codable {
    @DocumentID var activityId: String?
    
    var recentMessageId: String?
    
    var id: String {
        return activityId ?? NSUUID().uuidString
    }
}
