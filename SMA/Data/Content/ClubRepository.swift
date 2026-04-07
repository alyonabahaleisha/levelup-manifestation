import Foundation
import FirebaseFirestore

// Mirrors Android ClubRepository — one-time getDocuments(), region == "russia" filter
actor ClubRepository {
    static let shared = ClubRepository()

    private let db = Firestore.firestore()

    func getClubs() async throws -> [Club] {
        let snapshot = try await db.collection("clubs")
            .getDocuments()

        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let country = data["country"] as? String,
                let city = data["city"] as? String,
                let region = data["region"] as? String,
                let telegramUrl = data["telegramUrl"] as? String, !telegramUrl.isEmpty,
                let latitude = data["latitude"] as? Double,
                let longitude = data["longitude"] as? Double
            else { return nil }

            return Club(
                id: doc.documentID,
                country: country,
                city: city,
                region: region,
                leaderName: data["leader"] as? String ?? "",
                telegramUrl: telegramUrl,
                latitude: latitude,
                longitude: longitude
            )
        }
    }
}
