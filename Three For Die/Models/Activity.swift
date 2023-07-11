//
//  Activity.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

struct Activity: Identifiable, Codable {
    var id: String?
    
    let userId: String
    let title: String
    let notes: String
    let location: String
    let numRequired: String
    let category: String?
    var numCurrent: String
    
}

extension Activity {
    static var MOCK_ACTIVITY = Activity(id: NSUUID().uuidString, userId: "j2jCvaZ7zGQ1g7LFlYUdJR9D9m82", title: "3 for die", notes: "no noobs plz", location: "Phi Psi Lawn", numRequired: "3", category: "Sports", numCurrent: "1")
}
