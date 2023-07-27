//
//  Group.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Groups: Identifiable, Codable {
    @DocumentID var id: String?
    
    let name: String
}

extension Groups {
    static var MOCK_GROUP = Groups(id: NSUUID().uuidString, name: "Stanford University")
}
