import Foundation

final class ImageStore {
    static let shared = ImageStore()
    private init() {}

    func save(_ data: Data) -> String? {
        let filename = "parking-sign-\(UUID().uuidString).jpg"
        guard let url = fileURL(filename: filename) else { return nil }
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            return nil
        }
    }

    func load(filename: String) -> Data? {
        guard let url = fileURL(filename: filename) else { return nil }
        return try? Data(contentsOf: url)
    }

    func delete(filename: String) {
        guard let url = fileURL(filename: filename) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private func fileURL(filename: String) -> URL? {
        guard let base = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return nil }
        let directory = base.appendingPathComponent("ParkChi", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent(filename)
    }
}
