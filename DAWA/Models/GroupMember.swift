import Foundation
import FirebaseFirestoreSwift

struct GroupMember: Identifiable, Codable, Hashable {
    @DocumentID var uid: String?
    var permissions: String
    
    var notificationsEnabled: Bool? = false
    
    var user: User?
    
    var isAdmin: Bool {
        return permissions == "Admin" || permissions == "Owner"
    }
    
    var id: String {
        return uid ?? NSUUID().uuidString
    }
}
