//
//  Activity.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Activity: Identifiable, Codable, Hashable {
    @DocumentID var activityId: String?
    
    let userId: String
    let groupId: String
    let title: String
    let notes: String
    let location: String
    let numRequired: Int
    let category: String
    let timestamp: Timestamp
    var numCurrent: Int
    var status: String
    var recentMessageId: String?
    
    var user: User?
    var didJoin: Bool? = false
    
    var id: String {
        return activityId ?? NSUUID().uuidString
    }
}

//extension Activity {
//    static var MOCK_ACTIVITY = Activity(id: NSUUID().uuidString, userId: "j2jCvaZ7zGQ1g7LFlYUdJR9D9m82", groupId: "j2jCvaZ7zGQ1g7LFlYUdJR9D9m82", title: "3 for die", notes: "no noobs plz", location: "Phi Psi Lawn", numRequired: 3, category: "Sports", timestamp: Timestamp(date: Date()), numCurrent: 1, status: "Open")
//}
