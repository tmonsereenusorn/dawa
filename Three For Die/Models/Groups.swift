//
//  Group.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Groups: Identifiable, Codable {
    @DocumentID var uid: String?
    
    let name: String
    var groupImageUrl: String?
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
}

extension Groups {
    static var MOCK_GROUP = Groups(name: "Stanford University")
}
