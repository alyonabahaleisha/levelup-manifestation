import SwiftUI
import MapKit

// UIViewRepresentable wrapping MKMapView.
// SwiftUI's Map does not support annotation clustering; MKMapView does via
// clusteringIdentifier. This mirrors the Android Clustering composable.

struct ClubMapView: UIViewRepresentable {
    let clubs: [Club]
    @Binding var selectedClub: Club?

    private static let pinReuseID     = "ClubPin"
    private static let clusterReuseID = "ClubCluster"

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.overrideUserInterfaceStyle = .dark
        mapView.mapType = .standard
        mapView.showsUserLocation = false
        mapView.showsCompass = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.showsScale = false

        // Register reuse identifiers up-front
        mapView.register(
            ClubPinView.self,
            forAnnotationViewWithReuseIdentifier: Self.pinReuseID
        )
        mapView.register(
            ClubClusterView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Rebuild annotations only when the club list changes
        let current = Set(mapView.annotations.compactMap { ($0 as? ClubAnnotation)?.club.id })
        let incoming = Set(clubs.map(\.id))

        guard current != incoming else { return }

        mapView.removeAnnotations(mapView.annotations)
        let annotations = clubs
            .filter { $0.latitude != 0 || $0.longitude != 0 }
            .map { ClubAnnotation(club: $0) }
        mapView.addAnnotations(annotations)

        // Fit all pins with padding, fall back to Russia center
        if annotations.count >= 2 {
            let coords = annotations.map(\.coordinate)
            var minLat = coords[0].latitude,  maxLat = coords[0].latitude
            var minLon = coords[0].longitude, maxLon = coords[0].longitude
            for c in coords {
                minLat = min(minLat, c.latitude);  maxLat = max(maxLat, c.latitude)
                minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
            }
            let center = CLLocationCoordinate2D(
                latitude:  (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )
            let span = MKCoordinateSpan(
                latitudeDelta:  (maxLat - minLat) * 1.15,
                longitudeDelta: (maxLon - minLon) * 1.15
            )
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)
        } else {
            mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 62, longitude: 90),
                    span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 130)
                ),
                animated: false
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedClub: $selectedClub)
    }

    // MARK: - Coordinator (MKMapViewDelegate)

    final class Coordinator: NSObject, MKMapViewDelegate {
        var selectedClub: Binding<Club?>

        init(selectedClub: Binding<Club?>) {
            self.selectedClub = selectedClub
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let club = annotation as? ClubAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: ClubMapView.pinReuseID,
                    for: club
                ) as? ClubPinView ?? ClubPinView(annotation: club, reuseIdentifier: ClubMapView.pinReuseID)
                view.annotation = club
                view.clusteringIdentifier = ClubAnnotation.clusterID
                view.canShowCallout = false
                return view
            }

            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: cluster
                ) as? ClubClusterView ?? ClubClusterView(annotation: cluster, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
                view.annotation = cluster
                view.canShowCallout = false
                return view
            }

            return nil
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: false)

            if let pin = view.annotation as? ClubAnnotation {
                selectedClub.wrappedValue = pin.club
                return
            }

            // Tap on cluster → zoom to fit its members
            if let cluster = view.annotation as? MKClusterAnnotation {
                let members = cluster.memberAnnotations.compactMap { $0 as? ClubAnnotation }
                guard members.count >= 2 else { return }
                let coords = members.map(\.coordinate)
                var minLat = coords[0].latitude,  maxLat = coords[0].latitude
                var minLon = coords[0].longitude, maxLon = coords[0].longitude
                for c in coords {
                    minLat = min(minLat, c.latitude);  maxLat = max(maxLat, c.latitude)
                    minLon = min(minLon, c.longitude); maxLon = max(maxLon, c.longitude)
                }
                let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
                let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3, longitudeDelta: (maxLon - minLon) * 1.3)
                mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
            }
        }
    }
}

// MARK: - Custom pin view — teal circle with glow ──────────────────────────────

final class ClubPinView: MKAnnotationView {
    private static let size: CGFloat = 32
    private static let innerSize: CGFloat = 20
    private static let teal = UIColor(red: 91/255, green: 184/255, blue: 212/255, alpha: 1)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: Self.size, height: Self.size)
        centerOffset = .zero
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Outer glow — radial gradient
        let glowRadius = Self.size / 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let glowColors = [Self.teal.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor] as CFArray
        let glowLocations: [CGFloat] = [0, 1]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocations) {
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: glowRadius, options: [])
        }

        // Inner filled circle
        let innerRect = CGRect(
            x: center.x - Self.innerSize / 2,
            y: center.y - Self.innerSize / 2,
            width: Self.innerSize,
            height: Self.innerSize
        )
        ctx.setFillColor(Self.teal.cgColor)
        ctx.fillEllipse(in: innerRect)
    }

    // Accessibility
    override var accessibilityLabel: String? {
        get {
            guard let club = (annotation as? ClubAnnotation)?.club else { return nil }
            return "\(club.city). Руководитель: \(club.leaderName). Нажмите, чтобы открыть подробности."
        }
        set { }
    }
}

// MARK: - Custom cluster view — teal circle with count ─────────────────────────

final class ClubClusterView: MKAnnotationView {
    private static let teal = UIColor(red: 91/255, green: 184/255, blue: 212/255, alpha: 1)

    private let label: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        isOpaque = false
        addSubview(label)
    }

    required init?(coder: NSCoder) { fatalError() }

    override var annotation: MKAnnotation? {
        didSet { update() }
    }

    private func update() {
        guard let cluster = annotation as? MKClusterAnnotation else { return }
        let count = cluster.memberAnnotations.count
        let size: CGFloat = count <= 5 ? 32 : count <= 15 ? 40 : 48
        let glowSize = size * 1.6
        frame = CGRect(x: 0, y: 0, width: glowSize, height: glowSize)
        centerOffset = .zero
        label.text = "\(count)"
        label.frame = CGRect(x: (glowSize - size) / 2, y: (glowSize - size) / 2, width: size, height: size)
        setNeedsDisplay()

        // Accessibility
        accessibilityLabel = "Группа клубов: \(count) городов. Нажмите, чтобы приблизить."
    }

    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let count = (annotation as? MKClusterAnnotation)?.memberAnnotations.count ?? 0
        let size: CGFloat = count <= 5 ? 32 : count <= 15 ? 40 : 48
        let glowSize = size * 1.6
        let center = CGPoint(x: rect.midX, y: rect.midY)

        // Outer glow
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let glowColors = [Self.teal.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor] as CFArray
        let glowLocations: [CGFloat] = [0, 1]
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: glowColors, locations: glowLocations) {
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: glowSize / 2, options: [])
        }

        // Filled cluster circle
        let circleRect = CGRect(
            x: center.x - size / 2,
            y: center.y - size / 2,
            width: size,
            height: size
        )
        ctx.setFillColor(Self.teal.cgColor)
        ctx.fillEllipse(in: circleRect)
    }
}
