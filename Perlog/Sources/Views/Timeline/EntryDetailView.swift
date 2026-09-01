import SwiftUI
import UIKit

struct EntryDetailView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var entry: LogEntry
    @State private var isPresentingEditor = false
    @State private var isPresentingDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !entry.photoData.isEmpty {
                            TabView {
                                ForEach(Array(entry.photoData.enumerated()), id: \.offset) { _, data in
                                    if let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                            }
                            .tabViewStyle(.page)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        }

                        HStack(spacing: 10) {
                            TypeBadge(type: entry.type, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.title.isEmpty ? entry.type.title : entry.title)
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(theme.primaryText)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(theme.secondaryText)
                            }
                            Spacer()
                        }

                        if !entry.content.isEmpty {
                            GlassCard {
                                Text(entry.content)
                                    .font(.body)
                                    .foregroundStyle(theme.primaryText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        metadataSection

                        if !entry.tags.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(entry.tags) { tag in
                                    TagChip(label: tag.name, systemImage: "tag", tint: Color(hex: tag.colorHex))
                                }
                            }
                        }

                        if !entry.people.isEmpty {
                            HStack(spacing: 6) {
                                ForEach(entry.people) { person in
                                    TagChip(label: person.name, systemImage: "person.fill", tint: Color(hex: person.colorHex))
                                }
                            }
                        }
                    }
                    .padding()
                }

                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Button {
                            isPresentingEditor = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .foregroundStyle(theme.primaryText)
                        .background(theme.glassMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Button(role: .destructive) {
                            isPresentingDeleteConfirm = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .foregroundStyle(.white)
                        .background(Color.red.opacity(0.85), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                EntryEditorView(entry: entry)
            }
            .confirmationDialog("Delete this record?", isPresented: $isPresentingDeleteConfirm, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(entry)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let placeName = entry.placeName {
                metadataRow(icon: "mappin.and.ellipse", text: placeName)
            }
            if let mood = entry.mood {
                metadataRow(icon: "face.smiling", text: "\(mood.emoji) \(mood.label)")
            }
            if entry.type == .meal, let mealCategory = entry.mealCategory {
                metadataRow(icon: "fork.knife", text: mealCategory)
            }
            if entry.type == .music, let mediaTitle = entry.mediaTitle {
                metadataRow(icon: "music.note", text: [mediaTitle, entry.mediaArtist].compactMap { $0 }.joined(separator: " — "))
            }
            if entry.type == .activity, let value = entry.measurementValue {
                let unit = entry.measurementUnit ?? ""
                metadataRow(icon: "figure.walk", text: "\(value.formatted()) \(unit)")
            }
            if entry.type == .task {
                metadataRow(
                    icon: entry.isCompleted ? "checkmark.circle.fill" : "circle",
                    text: entry.isCompleted ? "Completed" : "Not completed"
                )
                if let dueDate = entry.dueDate {
                    metadataRow(icon: "calendar", text: "Due \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            if entry.isMilestone {
                metadataRow(icon: "star.fill", text: "Milestone")
            }
        }
    }

    private func metadataRow(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(theme.accent)
            Text(text)
                .foregroundStyle(theme.primaryText)
        }
        .font(.subheadline)
    }
}
