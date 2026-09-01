import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "8E8E93"
    var createdAt: Date = Date.now

    var entries: [LogEntry] = []

    init(name: String, colorHex: String = "8E8E93") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = .now
    }
}
