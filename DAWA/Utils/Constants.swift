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
    static let minUsernameLength = 3
    static let maxBioLength = 150
    static let maxPasswordLength = 128
    static let minPasswordLength = 8
}

struct GroupConstants {
    static let maxHandleLength = 15
    static let minHandleLength = 3
    static let maxNameLength = 30
    static let minNameLength = 3
}

struct ActivityConstants {
    static let maxTitleLength = 30
    static let minTitleLength = 1
    static let maxLocationLength = 30
    static let minLocationLength = 1
    static let maxParticipants = 50
    static let minParticipants = 1
    static let maxActivityDetails = 50
}
