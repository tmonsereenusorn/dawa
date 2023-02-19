import Foundation

struct Location {
    var latitude: Double
    var longitude: Double

    init (latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
    }
}