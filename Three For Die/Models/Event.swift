import Foundation

struct Event: Identifiable {
    let id = UUID()
    
    var name: String
    var numPeopleReq: Int
    var numPeopleCur: Int
    var description: String
    var host: String
    var participants: [String]
    var location: String // need to make location struct
    var time: Date
    var activity: String
    
    init (name: String = "", numPeopleReq: Int = 0, numPeopleCur: Int = 0, description: String = "",
            host: String = "", participants: [String] = [], location: String = "", time: Date = Date.now,
            activity: String = "") {
        self.name = name
        self.numPeopleReq = numPeopleReq
        self.numPeopleCur = numPeopleCur
        self.description = description
        self.host = host
        self.participants = participants
        self.location = location
        self.time = time
        self.activity = activity
    }
    
    static let preview: [Event] = Array(repeating: Event(name: "3 for die", numPeopleReq: 3, numPeopleCur: 1, description: "no noobs plz", host: "Tee", participants: [], location: "Phi Psi Lawn", time: Date.now, activity: "die"), count: 20)
}
