import SwiftUI

class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private var prefetching = false

    private init() {
        cache.countLimit = 50
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func store(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url.absoluteString as NSString)
    }

    /// Prefetch all meditation cover images
    func prefetchCovers() {
        guard !prefetching else { return }
        prefetching = true

        let meditations = MeditationContent.allMeditations()
        for meditation in meditations {
            guard let urlString = MeditationContent.coverURL(meditation),
                  let url = URL(string: urlString),
                  image(for: url) == nil else { continue }

            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data, let uiImage = UIImage(data: data) else { return }
                self?.store(uiImage, for: url)
            }.resume()
        }
    }
}

/// A cached image view that checks ImageCache before network
struct CachedAsyncImage: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var loading = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.clear
                    .onAppear { load() }
            }
        }
    }

    private func load() {
        guard !loading, let url else { return }
        if let cached = ImageCache.shared.image(for: url) {
            image = cached
            return
        }
        loading = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let uiImage = UIImage(data: data) else { return }
            ImageCache.shared.store(uiImage, for: url)
            DispatchQueue.main.async { image = uiImage }
        }.resume()
    }
}
