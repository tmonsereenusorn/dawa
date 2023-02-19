import Foundation
import FirebaseFirestore


let db = Firestore.firestore()
class UserAPI: NSObject, ObservableObject {
    static let users = db.collection("users")
    static let events = db.collection("events")
    
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
    static func fetchParticipants (eid: String) async -> [String] {
        do {
            let doc = try await events.document(eid).getDocument()
            let data = doc.data()
            let event = createEvent(data: data)
            return event.participants
        } catch {
            print (error.localizedDescription)
        }
    }

    static func createEvent (data: [String: Any]) async -> Event {
        do {
            let name = data["name"] as? String ?? ""
            let numPeopleReq = data["numPeopleReq"] as? Int ?? 0
            let numPeopleCur = data["numPoepleCur"] as? Int ?? 0
            let description = data["description"] as? String ?? ""
            let host = data["host"] as? String ?? ""
            let participants = data["participants"] as? [String] ?? []
            let location = data["location"] as? Location ?? Location()
            let time = data["time"] as? Date ?? Date.now()
            let activity = data["activity"] as? String ?? ""
            return Event(name: name, numPeopleReq: numPeopleReq, numPeopleCur: numPeopleCur, description: description, 
                        host: host, participants: participants, location: location, time: time, activity: activity)
        } catch {
            print (error.localizedDescription)
        }
    }

    static func addEvent(event: Event) async -> Void {
        do {
            let data = [
                "name": event.names,
                "numPeopleReq": event.numPeopleReq,
                "description": event.description,
                "host": event.host,
                "participants": event.participants,
                "location": event.location,
                "time": event.time,
                "activity": event.activity
            ]
            db.collection("events").addDocument(data: data)
        } catch {
            print (error.localizedDescription)
        }
    }
}
