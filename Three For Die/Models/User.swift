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
