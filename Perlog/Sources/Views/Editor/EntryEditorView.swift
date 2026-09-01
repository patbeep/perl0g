import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct EntryEditorView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// The entry being edited, or nil when creating a new one.
    let entry: LogEntry?

    @Query(sort: [SortDescriptor<Tag>(\.name, order: .forward)])
    private var allTags: [Tag]
    @Query(sort: [SortDescriptor<Person>(\.name, order: .forward)])
    private var allPeople: [Person]

    @State private var selectedType: EntryType = .thought
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var date: Date = .now

    @State private var mood: Mood?
    @State private var placeName: String = ""
    @State private var mealCategory: String = ""
    @State private var mediaTitle: String = ""
    @State private var mediaArtist: String = ""
    @State private var measurementValueText: String = ""
    @State private var measurementUnit: String = "steps"
    @State private var isCompleted: Bool = false
    @State private var dueDate: Date = .now
    @State private var hasDueDate: Bool = false
    @State private var isMilestone: Bool = false

    @State private var selectedTags: [Tag] = []
    @State private var newTagText: String = ""
    @State private var selectedPeople: [Person] = []

    @State private var photosPickerItems: [PhotosPickerItem] = []
    @State private var photoDatas: [Data] = []

    @StateObject private var locationProvider = LocationProvider()

    private var isEditing: Bool { entry != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("New record")
                            .font(.headline)
                            .foregroundStyle(theme.secondaryText)

                        typePicker

                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField(titlePlaceholder, text: $title)
                                    .font(.headline)
                                    .foregroundStyle(theme.primaryText)

                                TextField(contentPlaceholder, text: $content, axis: .vertical)
                                    .font(.body)
                                    .foregroundStyle(theme.primaryText)
                                    .lineLimit(3...8)
                            }
                        }

                        photoSection

                        typeSpecificSection

                        tagSection

                        peopleSection

                        dateRow
                    }
                    .padding()
                    .padding(.bottom, 90)
                }

                VStack {
                    Spacer()
                    GlassPrimaryButton(title: isEditing ? "Save changes" : "Save record", isEnabled: canSave) {
                        save()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle(isEditing ? "Edit Record" : "Add Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: populateIfEditing)
            .onChange(of: photosPickerItems) { _, newItems in
                loadPhotos(from: newItems)
            }
            .onChange(of: locationProvider.placeName) { _, newValue in
                if let newValue, placeName.isEmpty {
                    placeName = newValue
                }
            }
        }
    }

    // MARK: - Sections

    private var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(EntryType.allCases) { type in
                    Button {
                        selectedType = type
                    } label: {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedType == type ? theme.tint(for: type).opacity(0.28) : Color.clear)
                                .frame(width: 46, height: 46)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(selectedType == type ? theme.tint(for: type) : theme.cardStroke, lineWidth: selectedType == type ? 2 : 1)
                                )
                                .overlay(
                                    Image(systemName: type.systemImage)
                                        .foregroundStyle(selectedType == type ? theme.tint(for: type) : theme.secondaryText)
                                )
                            Text(type.title)
                                .font(.system(size: 10))
                                .foregroundStyle(selectedType == type ? theme.primaryText : theme.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !photoDatas.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(photoDatas.enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            photoDatas.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .black.opacity(0.6))
                                        }
                                        .padding(4)
                                    }
                            }
                        }
                    }
                }
            }

            PhotosPicker(selection: $photosPickerItems, maxSelectionCount: 8, matching: .images) {
                Label(photoDatas.isEmpty ? "Add photos" : "Add more photos", systemImage: "photo.on.rectangle")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(theme.accent)
        }
    }

    @ViewBuilder
    private var typeSpecificSection: some View {
        switch selectedType {
        case .mood:
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("How are you feeling?").font(.subheadline.weight(.medium)).foregroundStyle(theme.primaryText)
                    HStack {
                        ForEach(Mood.allCases) { candidate in
                            Button {
                                mood = candidate
                            } label: {
                                VStack(spacing: 2) {
                                    Text(candidate.emoji).font(.title2)
                                    Text(candidate.label).font(.caption2)
                                }
                                .foregroundStyle(mood == candidate ? theme.accent : theme.secondaryText)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        case .place:
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Place name", text: $placeName)
                        .foregroundStyle(theme.primaryText)
                    Button {
                        locationProvider.requestCurrentLocation()
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                            Text(locationProvider.isResolving ? "Finding you…" : "Use current location")
                        }
                        .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(theme.accent)
                    .disabled(locationProvider.isResolving)
                    if let error = locationProvider.errorMessage {
                        Text(error).font(.caption2).foregroundStyle(.orange)
                    }
                }
            }
        case .meal:
            GlassCard {
                TextField("Meal type — breakfast, dinner, coffee…", text: $mealCategory)
                    .foregroundStyle(theme.primaryText)
            }
        case .music:
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Track or album title", text: $mediaTitle)
                        .foregroundStyle(theme.primaryText)
                    TextField("Artist", text: $mediaArtist)
                        .foregroundStyle(theme.primaryText)
                }
            }
        case .activity:
            GlassCard {
                HStack {
                    TextField("Amount", text: $measurementValueText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(theme.primaryText)
                    TextField("Unit (steps, miles, min)", text: $measurementUnit)
                        .foregroundStyle(theme.primaryText)
                        .multilineTextAlignment(.trailing)
                }
            }
        case .task:
            GlassCard {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Completed", isOn: $isCompleted)
                        .foregroundStyle(theme.primaryText)
                    Toggle("Set a due date", isOn: $hasDueDate)
                        .foregroundStyle(theme.primaryText)
                    if hasDueDate {
                        DatePicker("Due", selection: $dueDate, displayedComponents: [.date])
                            .foregroundStyle(theme.primaryText)
                    }
                }
            }
        case .milestone:
            GlassCard {
                Toggle("Mark as milestone", isOn: $isMilestone)
                    .foregroundStyle(theme.primaryText)
            }
        case .thought, .photo, .person:
            EmptyView()
        }
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !selectedTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(selectedTags) { tag in
                            TagChip(label: tag.name, tint: Color(hex: tag.colorHex)) {
                                selectedTags.removeAll { $0.id == tag.id }
                            }
                        }
                    }
                }
            }
            HStack {
                TextField("Add a tag", text: $newTagText)
                    .foregroundStyle(theme.primaryText)
                    .onSubmit(addTypedTag)
                Button(action: addTypedTag) {
                    Image(systemName: "plus.circle.fill")
                }
                .foregroundStyle(theme.accent)
                .disabled(newTagText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            let suggestions = allTags.filter { candidate in
                !selectedTags.contains { $0.id == candidate.id }
            }
            if !suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(suggestions.prefix(10)) { tag in
                            Button {
                                selectedTags.append(tag)
                            } label: {
                                TagChip(label: tag.name, tint: Color(hex: tag.colorHex))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("With")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.secondaryText)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(allPeople) { person in
                        let isSelected = selectedPeople.contains { $0.id == person.id }
                        Button {
                            if isSelected {
                                selectedPeople.removeAll { $0.id == person.id }
                            } else {
                                selectedPeople.append(person)
                            }
                        } label: {
                            TagChip(
                                label: person.name,
                                systemImage: "person.fill",
                                tint: isSelected ? Color(hex: person.colorHex) : theme.secondaryText
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var dateRow: some View {
        GlassCard {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(theme.accent)
                DatePicker("", selection: $date)
                    .labelsHidden()
                    .foregroundStyle(theme.primaryText)
                Spacer()
            }
        }
    }

    // MARK: - Helpers

    private var titlePlaceholder: String {
        switch selectedType {
        case .thought: return "Morning pages"
        case .task: return "What needs doing?"
        case .milestone: return "What happened?"
        default: return "Title"
        }
    }

    private var contentPlaceholder: String {
        switch selectedType {
        case .task: return "Details (optional)"
        default: return "Write what happened…"
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty || !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func addTypedTag() {
        let trimmed = newTagText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let existing = allTags.first(where: { $0.name.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }) {
            if !selectedTags.contains(where: { $0.id == existing.id }) {
                selectedTags.append(existing)
            }
        } else {
            let colors = ["FF9F0A", "30D158", "0A84FF", "BF5AF2", "FF375F", "64D2FF"]
            let newTag = Tag(name: trimmed, colorHex: colors.randomElement() ?? "8E8E93")
            modelContext.insert(newTag)
            selectedTags.append(newTag)
        }
        newTagText = ""
    }

    private func loadPhotos(from items: [PhotosPickerItem]) {
        Task {
            var newDatas: [Data] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    newDatas.append(data)
                }
            }
            await MainActor.run {
                photoDatas.append(contentsOf: newDatas)
                photosPickerItems = []
            }
        }
    }

    private func populateIfEditing() {
        guard let entry else { return }
        selectedType = entry.type
        title = entry.title
        content = entry.content
        date = entry.date
        mood = entry.mood
        placeName = entry.placeName ?? ""
        mealCategory = entry.mealCategory ?? ""
        mediaTitle = entry.mediaTitle ?? ""
        mediaArtist = entry.mediaArtist ?? ""
        if let value = entry.measurementValue {
            measurementValueText = String(value)
        }
        measurementUnit = entry.measurementUnit ?? "steps"
        isCompleted = entry.isCompleted
        if let due = entry.dueDate {
            hasDueDate = true
            dueDate = due
        }
        isMilestone = entry.isMilestone
        selectedTags = entry.tags
        selectedPeople = entry.people
        photoDatas = entry.photoData
    }

    private func save() {
        let target = entry ?? LogEntry()
        if entry == nil {
            modelContext.insert(target)
        }

        target.type = selectedType
        target.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        target.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        target.date = date
        target.mood = mood
        target.placeName = placeName.isEmpty ? nil : placeName
        target.latitude = locationProvider.latitude
        target.longitude = locationProvider.longitude
        target.mealCategory = mealCategory.isEmpty ? nil : mealCategory
        target.mediaTitle = mediaTitle.isEmpty ? nil : mediaTitle
        target.mediaArtist = mediaArtist.isEmpty ? nil : mediaArtist
        target.measurementValue = Double(measurementValueText)
        target.measurementUnit = measurementValueText.isEmpty ? nil : measurementUnit
        target.isTask = selectedType == .task
        target.isCompleted = isCompleted
        target.dueDate = hasDueDate ? dueDate : nil
        target.isMilestone = isMilestone || selectedType == .milestone
        target.tags = selectedTags
        target.people = selectedPeople
        target.photoData = photoDatas
        target.updatedAt = .now

        dismiss()
    }
}

#Preview {
    EntryEditorView(entry: nil)
        .environmentObject(ThemeStore())
        .modelContainer(for: [LogEntry.self, Tag.self, Person.self], inMemory: true)
}
