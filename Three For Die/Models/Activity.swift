//
//  Activity.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Activity: Identifiable, Codable {
    @DocumentID var id: String?
    
    let userId: String
    let title: String
    let notes: String
    let location: String
    let numRequired: Int
    let category: String
    let timestamp: Timestamp
    var numCurrent: Int
    
    var user: User?
}

extension Activity {
    static var MOCK_ACTIVITY = Activity(id: NSUUID().uuidString, userId: "j2jCvaZ7zGQ1g7LFlYUdJR9D9m82", title: "3 for die", notes: "no noobs plz", location: "Phi Psi Lawn", numRequired: 3, category: "Sports", timestamp: Timestamp(date: Date()), numCurrent: 1)
}
