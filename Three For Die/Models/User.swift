import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Codable, Hashable {
    @DocumentID var uid: String?
    let fullname: String
    let email: String
    var username: String
    let bio: String
    var profileImageUrl: String?
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == id }
    
    var groupPermissions: String?
    
//    var initials: String {
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: fullname) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//
//        return ""
//    }
}

extension User {
    static var MOCK_USER = User(fullname: "Kobe Bryant", email: "test@gmail.com", username: "username", bio: "Sample bio")
}
