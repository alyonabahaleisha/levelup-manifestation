import Foundation
import Combine

enum DownloadStatus {
    case notDownloaded, downloading, downloaded
}

struct DownloadState {
    var status: DownloadStatus = .notDownloaded
    var progress: Double = 0 // 0...1
}

class AudioDownloadManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioDownloadManager()

    private let cacheDir: URL
    @Published var downloads: [String: DownloadState] = [:]
    private var activeTasks: [String: URLSessionDownloadTask] = [:]
    private var observations: [String: NSKeyValueObservation] = [:]

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDir = caches.appendingPathComponent("audio_cache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
    }

    func cacheFile(for id: String) -> URL {
        cacheDir.appendingPathComponent("\(id).mp3")
    }

    func isDownloaded(_ id: String) -> Bool {
        FileManager.default.fileExists(atPath: cacheFile(for: id).path)
    }

    func localURL(for id: String) -> URL? {
        let file = cacheFile(for: id)
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    func downloadState(for id: String) -> DownloadState {
        if isDownloaded(id) { return DownloadState(status: .downloaded, progress: 1) }
        return downloads[id] ?? DownloadState()
    }

    func download(id: String, url: String) {
        guard !isDownloaded(id) else { return }
        guard activeTasks[id] == nil else { return }
        guard let audioURL = URL(string: url) else { return }

        downloads[id] = DownloadState(status: .downloading, progress: 0)

        let task = URLSession.shared.downloadTask(with: audioURL) { [weak self] tempURL, _, error in
            guard let self else { return }

            if let tempURL, error == nil {
                let dest = self.cacheFile(for: id)
                try? FileManager.default.removeItem(at: dest)
                try? FileManager.default.moveItem(at: tempURL, to: dest)
                DispatchQueue.main.async {
                    self.downloads[id] = DownloadState(status: .downloaded, progress: 1)
                    self.activeTasks.removeValue(forKey: id)
                    self.observations.removeValue(forKey: id)
                }
            } else {
                DispatchQueue.main.async {
                    self.downloads[id] = DownloadState(status: .notDownloaded, progress: 0)
                    self.activeTasks.removeValue(forKey: id)
                    self.observations.removeValue(forKey: id)
                }
            }
        }

        // Observe progress
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloads[id] = DownloadState(status: .downloading, progress: progress.fractionCompleted)
            }
        }

        activeTasks[id] = task
        observations[id] = observation
        task.resume()
    }
}
