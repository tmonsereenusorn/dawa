//
//  Group.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Groups: Identifiable, Codable, Hashable {
    @DocumentID var uid: String?
    
    let name: String
    var handle: String
    var groupImageUrl: String?
    var numMembers: Int
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
    
    var memberList: [User]?
}

extension Groups {
    static var MOCK_GROUP = Groups(name: "Stanford University", handle: "stanforduniversity", numMembers: 44)
}
