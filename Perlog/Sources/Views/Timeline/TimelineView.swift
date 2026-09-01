import SwiftUI
import SwiftData

/// One calendar day's worth of entries, plus the small derived summary
/// line shown under the date header (mood, steps, photo count) like in
/// the reference design.
private struct DayGroup: Identifiable {
    let day: Date
    let entries: [LogEntry]
    var id: Date { day }

    var moodSummary: Mood? {
        entries.first(where: { $0.mood != nil })?.mood
    }

    var stepCount: Int? {
        let steps = entries
            .filter { $0.type == .activity && $0.measurementUnit?.lowercased() == "steps" }
            .compactMap { $0.measurementValue }
        guard !steps.isEmpty else { return nil }
        return Int(steps.reduce(0, +))
    }

    var photoCount: Int {
        entries.filter { $0.type == .photo || !$0.photoData.isEmpty }.count
    }
}

struct TimelineView: View {
    @EnvironmentObject private var theme: ThemeStore
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [SortDescriptor<LogEntry>(\.date, order: .reverse)])
    private var entries: [LogEntry]

    @State private var searchText: String = ""
    @State private var activeFilters: Set<EntryType> = []
    @State private var isPresentingEditor: Bool = false
    @State private var selectedEntry: LogEntry?

    private var filteredEntries: [LogEntry] {
        entries.filter { entry in
            let matchesFilter = activeFilters.isEmpty || activeFilters.contains(entry.type)
            let matchesSearch = searchText.isEmpty
                || entry.title.localizedCaseInsensitiveContains(searchText)
                || entry.content.localizedCaseInsensitiveContains(searchText)
                || entry.tags.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            return matchesFilter && matchesSearch
        }
    }

    private var dayGroups: [DayGroup] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEntries) { calendar.startOfDay(for: $0.date) }
        return grouped
            .map { DayGroup(day: $0.key, entries: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                theme.background.ignoresSafeArea()

                if entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(dayGroups) { group in
                            Section {
                                ForEach(group.entries) { entry in
                                    EntryRowView(entry: entry)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .contentShape(Rectangle())
                                        .onTapGesture { selectedEntry = entry }
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                delete(entry)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            } header: {
                                dayHeader(for: group)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Button {
                    isPresentingEditor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 58, height: 58)
                        .background(theme.accent, in: Circle())
                        .shadow(color: theme.accent.opacity(0.5), radius: 12, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 18)
            }
            .navigationTitle("Perlog")
            .searchable(text: $searchText, prompt: "Search your log")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .sheet(isPresented: $isPresentingEditor) {
                EntryEditorView(entry: nil)
            }
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            ForEach(EntryType.allCases) { type in
                Button {
                    toggle(type)
                } label: {
                    Label(type.title, systemImage: activeFilters.contains(type) ? "checkmark.circle.fill" : type.systemImage)
                }
            }
            if !activeFilters.isEmpty {
                Divider()
                Button("Clear filters", role: .destructive) { activeFilters.removeAll() }
            }
        } label: {
            Image(systemName: activeFilters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        }
    }

    private func toggle(_ type: EntryType) {
        if activeFilters.contains(type) {
            activeFilters.remove(type)
        } else {
            activeFilters.insert(type)
        }
    }

    private func dayHeader(for group: DayGroup) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(group.day.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.primaryText)
            HStack(spacing: 6) {
                if let mood = group.moodSummary {
                    Text("\(mood.emoji) \(mood.label)")
                }
                if let steps = group.stepCount {
                    Text("· \(steps.formatted()) steps")
                }
                if group.photoCount > 0 {
                    Text("· \(group.photoCount) photo\(group.photoCount == 1 ? "" : "s")")
                }
            }
            .font(.caption)
            .foregroundStyle(theme.secondaryText)
        }
        .padding(.vertical, 6)
        .textCase(nil)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 44))
                .foregroundStyle(theme.accent)
            Text("Your log is empty")
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.primaryText)
            Text("Tap + to record your first moment.")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
        }
        .padding()
    }

    private func delete(_ entry: LogEntry) {
        withAnimation {
            modelContext.delete(entry)
        }
    }
}

#Preview {
    TimelineView()
        .environmentObject(ThemeStore())
        .modelContainer(for: [LogEntry.self, Tag.self, Person.self], inMemory: true)
}
