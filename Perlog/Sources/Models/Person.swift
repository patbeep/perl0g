import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID = UUID()
    var name: String = ""
    var relationshipLabel: String = ""
    var colorHex: String = "8E8E93"
    var createdAt: Date = Date.now

    var entries: [LogEntry] = []

    init(name: String, relationshipLabel: String = "", colorHex: String = "8E8E93") {
        self.id = UUID()
        self.name = name
        self.relationshipLabel = relationshipLabel
        self.colorHex = colorHex
        self.createdAt = .now
    }
}
