import Foundation

/// Codable mirror of the SwiftData models used purely for JSON export.
/// Photos are base64-encoded inline so the whole export is a single
/// portable file the person fully owns.
private struct ExportEntry: Codable {
    let id: UUID
    let date: Date
    let type: String
    let title: String
    let content: String
    let mood: String?
    let placeName: String?
    let latitude: Double?
    let longitude: Double?
    let mealCategory: String?
    let mediaTitle: String?
    let mediaArtist: String?
    let measurementValue: Double?
    let measurementUnit: String?
    let isTask: Bool
    let isCompleted: Bool
    let dueDate: Date?
    let isMilestone: Bool
    let tags: [String]
    let people: [String]
    let photosBase64: [String]
}

enum ExportManager {
    /// Builds a single JSON file containing every entry. Returns the
    /// file URL in a temporary directory, ready to hand to a share sheet.
    static func makeExportFile(entries: [LogEntry]) throws -> URL {
        let exportable = entries.map { entry in
            ExportEntry(
                id: entry.id,
                date: entry.date,
                type: entry.type.rawValue,
                title: entry.title,
                content: entry.content,
                mood: entry.mood?.rawValue,
                placeName: entry.placeName,
                latitude: entry.latitude,
                longitude: entry.longitude,
                mealCategory: entry.mealCategory,
                mediaTitle: entry.mediaTitle,
                mediaArtist: entry.mediaArtist,
                measurementValue: entry.measurementValue,
                measurementUnit: entry.measurementUnit,
                isTask: entry.isTask,
                isCompleted: entry.isCompleted,
                dueDate: entry.dueDate,
                isMilestone: entry.isMilestone,
                tags: entry.tags.map { $0.name },
                people: entry.people.map { $0.name },
                photosBase64: entry.photoData.map { $0.base64EncodedString() }
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportable)

        let fileName = "Perlog-Export-\(Int(Date.now.timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }
}
