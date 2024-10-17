//
//  Constants.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Firebase

struct FirestoreConstants {
    
    static let UserCollection = Firestore.firestore().collection("users")
    static let ActivitiesCollection = Firestore.firestore().collection("activities")
    static let GroupsCollection = Firestore.firestore().collection("groups")
    
}

struct ProfileConstants {
    static let maxUsernameLength = 15
    static let maxBioLength = 150
}
