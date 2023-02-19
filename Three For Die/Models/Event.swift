import Foundation

struct Event {
    var name: String
    var numPeopleReq: Int
    var numPeopleCur: Int
    var description: String
    var host: String
    var participants: [String]
    var location: Location // need to make location struct
    var time: Date
    var activity: String
    
    init (name: String = "", numPeopleReq: Int = 0, numPeopleCur: Int = 0, description: String = "", 
            host: String = "", participants: [String] = [], location: Location = "", time: Date = Date.now, 
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
}