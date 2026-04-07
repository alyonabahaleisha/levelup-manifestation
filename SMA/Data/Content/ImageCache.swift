import SwiftUI

class ImageCache: @unchecked Sendable {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheDir: URL
    private var prefetching = false

    private init() {
        memoryCache.countLimit = 100

        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheDir = caches.appendingPathComponent("cover_images_v2", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheDir, withIntermediateDirectories: true)
        // Clean old corrupted cache
        let oldDir = caches.appendingPathComponent("cover_images", isDirectory: true)
        try? FileManager.default.removeItem(at: oldDir)
    }

    private func diskPath(for url: URL) -> URL {
        let data = Data(url.absoluteString.utf8)
        let hash = data.withUnsafeBytes { bytes -> String in
            var hash: UInt64 = 5381
            for byte in bytes {
                hash = hash &* 33 &+ UInt64(byte)
            }
            return String(hash, radix: 16)
        }
        return diskCacheDir.appendingPathComponent(hash)
    }

    func image(for url: URL) -> UIImage? {
        let key = url.absoluteString as NSString

        // Check memory
        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        // Check disk
        let path = diskPath(for: url)
        if let data = try? Data(contentsOf: path), let img = UIImage(data: data) {
            memoryCache.setObject(img, forKey: key)
            return img
        }

        return nil
    }

    func store(_ image: UIImage, for url: URL) {
        let key = url.absoluteString as NSString
        memoryCache.setObject(image, forKey: key)

        // Write to disk in background
        let path = diskPath(for: url)
        DispatchQueue.global(qos: .utility).async {
            if let data = image.jpegData(compressionQuality: 0.85) {
                try? data.write(to: path)
            }
        }
    }

    /// Prefetch all meditation cover images
    func prefetchCovers() {
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
    @State private var loadedURL: URL?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.clear
            }
        }
        .onAppear { load() }
        .onChange(of: url) { _, newURL in
            if newURL != loadedURL {
                image = nil
                loading = false
                loadedURL = nil
                load()
            }
        }
    }

    private func load() {
        guard !loading, let url else { return }
        if let cached = ImageCache.shared.image(for: url) {
            image = cached
            loadedURL = url
            return
        }
        loading = true
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let uiImage = UIImage(data: data) else { return }
            ImageCache.shared.store(uiImage, for: url)
            DispatchQueue.main.async {
                image = uiImage
                loadedURL = url
            }
        }.resume()
    }
}
