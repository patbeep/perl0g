import SwiftUI
import UIKit

struct EntryRowView: View {
    @EnvironmentObject private var theme: ThemeStore
    let entry: LogEntry

    var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                TypeBadge(type: entry.type)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.title.isEmpty ? entry.type.title : entry.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(theme.secondaryText)
                    }

                    if entry.type == .task {
                        HStack(spacing: 6) {
                            Image(systemName: entry.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(entry.isCompleted ? theme.accent : theme.secondaryText)
                            Text(entry.content)
                                .font(.footnote)
                                .foregroundStyle(theme.secondaryText)
                                .strikethrough(entry.isCompleted)
                                .lineLimit(2)
                        }
                    } else if !entry.content.isEmpty {
                        Text(entry.content)
                            .font(.footnote)
                            .foregroundStyle(theme.secondaryText)
                            .lineLimit(2)
                    }

                    if let firstPhoto = entry.photoData.first, let uiImage = UIImage(data: firstPhoto) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 120)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    if entry.placeName != nil || !entry.tags.isEmpty || entry.mood != nil {
                        HStack(spacing: 6) {
                            if let mood = entry.mood {
                                TagChip(label: mood.label, systemImage: nil)
                            }
                            if let placeName = entry.placeName {
                                TagChip(label: placeName, systemImage: "mappin")
                            }
                            ForEach(entry.tags.prefix(3)) { tag in
                                TagChip(label: tag.name, tint: Color(hex: tag.colorHex))
                            }
                        }
                    }
                }
            }
        }
    }
}
