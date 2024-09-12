//
//  MemberRequest.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 1/22/24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct MemberRequest: Identifiable, Codable, Hashable {
    @DocumentID var requestId: String?
    
    let fromUserId: String
    let toGroupId: String
    let timestamp: Timestamp
    
    var user: User?
    
    var id: String {
        return requestId ?? NSUUID().uuidString
    }
}
