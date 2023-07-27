import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    let username: String
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == id }
    
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

//extension User {
//    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Kobe Bryant", email: "test@gmail.com", username: "username", currSelectedGroup: "j2jCvaZ7zGQ1g7LFlYUdJR9D9m82")
//}
