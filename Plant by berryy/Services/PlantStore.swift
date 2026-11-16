import Foundation

// Reads and writes the list of plants as a JSON file on disk.
// It knows nothing about SwiftUI, so the view model can use it without caring how data is stored.
struct PlantStore {
    let fileURL: URL

    // Application Support is the right home for data the user doesn't manage directly
    static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "plants.json")
    }

    init(fileURL: URL = PlantStore.defaultFileURL) {
        self.fileURL = fileURL
    }

    // No file yet means first launch, so there are simply no plants
    func load() throws -> [Plant] {
        // percentEncoded: false, otherwise "Application Support" becomes "Application%20Support"
        // and fileExists wrongly reports that the file is missing
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Plant].self, from: data)
    }

    func save(_ plants: [Plant]) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try JSONEncoder().encode(plants)
        // .atomic writes to a temp file first, so a crash mid-write can't leave a half-written file
        try data.write(to: fileURL, options: .atomic)
    }
}
