import MapKit

// MKAnnotation subclass carrying the full Club value.
// NSObject subclass required by the MKAnnotation protocol.
final class ClubAnnotation: NSObject, MKAnnotation {
    let club: Club
    var coordinate: CLLocationCoordinate2D
    var title: String? { club.city }
    var subtitle: String? { club.leaderName }

    // All pins share one clusteringIdentifier so MapKit clusters them natively
    static let clusterID = "clubs"

    init(club: Club) {
        self.club = club
        self.coordinate = CLLocationCoordinate2D(
            latitude: club.latitude,
            longitude: club.longitude
        )
        super.init()
    }
}
