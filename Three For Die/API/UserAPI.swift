import Foundation
import FirebaseFirestore


let db = Firestore.firestore()
class UserAPI: NSObject, ObservableObject {
    static let users = db.collection("users")
    
    /* EXAMPLE FUNCTION:
     
     
        static func fetchUsers (uid: String) async -> Void {
            do {
                let doc = try await users.document(uid).getDocument()
                // To get the document ID
                doc.documentID
                // To get the rest of doc data
                doc.data()
            } catch {
                print (error.localizedDescription)
            }
        }
     
     
    */
}
