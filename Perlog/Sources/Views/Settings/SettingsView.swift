import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var modelContext

    @Query private var allEntries: [LogEntry]
    @Query(sort: [SortDescriptor<Person>(\.name, order: .forward)]) private var allPeople: [Person]
    @Query(sort: [SortDescriptor<Tag>(\.name, order: .forward)]) private var allTags: [Tag]

    @State private var exportURL: URL?
    @State private var isPresentingShareSheet = false
    @State private var exportError: String?
    @State private var isPresentingAddPerson = false
    @State private var newPersonName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                List {
                    Section {
                        NavigationLink {
                            ThemeStudioView()
                        } label: {
                            Label("Theme Studio", systemImage: "paintpalette.fill")
                        }
                    }
                    .listRowBackground(theme.glassMaterial)

                    Section("People") {
                        ForEach(allPeople) { person in
                            HStack {
                                Circle()
                                    .fill(Color(hex: person.colorHex))
                                    .frame(width: 10, height: 10)
                                Text(person.name)
                                    .foregroundStyle(theme.primaryText)
                            }
                        }
                        .onDelete(perform: deletePeople)
                        Button {
                            isPresentingAddPerson = true
                        } label: {
                            Label("Add person", systemImage: "person.badge.plus")
                        }
                    }
                    .listRowBackground(theme.glassMaterial)

                    Section("Tags") {
                        if allTags.isEmpty {
                            Text("No tags yet — add one from the record editor.")
                                .font(.footnote)
                                .foregroundStyle(theme.secondaryText)
                        } else {
                            ForEach(allTags) { tag in
                                HStack {
                                    Circle()
                                        .fill(Color(hex: tag.colorHex))
                                        .frame(width: 10, height: 10)
                                    Text(tag.name)
                                        .foregroundStyle(theme.primaryText)
                                }
                            }
                            .onDelete(perform: deleteTags)
                        }
                    }
                    .listRowBackground(theme.glassMaterial)

                    Section("Your data") {
                        Button {
                            exportData()
                        } label: {
                            Label("Export all data (JSON)", systemImage: "square.and.arrow.up")
                        }
                        if let exportError {
                            Text(exportError).font(.footnote).foregroundStyle(.orange)
                        }
                        Text("\(allEntries.count) records stored only on this device. Nothing is uploaded anywhere.")
                            .font(.footnote)
                            .foregroundStyle(theme.secondaryText)
                    }
                    .listRowBackground(theme.glassMaterial)

                    Section("About Perlog") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your life, logged.")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(theme.primaryText)
                            Text("Perlog is completely free — every record type, unlimited entries, and every feature, with no subscription and no account required.")
                                .font(.footnote)
                                .foregroundStyle(theme.secondaryText)
                        }
                    }
                    .listRowBackground(theme.glassMaterial)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .alert("Add person", isPresented: $isPresentingAddPerson) {
                TextField("Name", text: $newPersonName)
                Button("Add", action: addPerson)
                Button("Cancel", role: .cancel) { newPersonName = "" }
            }
            .sheet(isPresented: $isPresentingShareSheet) {
                if let exportURL {
                    ShareSheet(activityItems: [exportURL])
                }
            }
        }
    }

    private func exportData() {
        do {
            let url = try ExportManager.makeExportFile(entries: allEntries)
            exportURL = url
            isPresentingShareSheet = true
            exportError = nil
        } catch {
            exportError = "Couldn't create the export file. Please try again."
        }
    }

    private func addPerson() {
        let trimmed = newPersonName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let colors = ["FF9F0A", "30D158", "0A84FF", "BF5AF2", "FF375F", "64D2FF"]
        let person = Person(name: trimmed, colorHex: colors.randomElement() ?? "8E8E93")
        modelContext.insert(person)
        newPersonName = ""
    }

    private func deletePeople(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(allPeople[index]) }
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets { modelContext.delete(allTags[index]) }
    }
}
