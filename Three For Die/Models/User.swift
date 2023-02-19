import Foundation

struct User {
    var uid: String
    var username: String
    var flakeScore: Int
    var numAttended: Int
    var numFlakes: Int
    var bio: String
    
    init (uid: String = "", username: String = "", flakeScore: Int = 0, numAttended: Int = 0, numFlakes: Int = 0, bio: String = "") {
        self.uid = uid
        self.username = username
        self.flakeScore = flakeScore
        self.numAttended = numAttended
        self.numFlakes = numFlakes
        self.bio = bio
    }
}

struct Location {
    var latitude: Double
    var longitude: Double

    init (latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

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