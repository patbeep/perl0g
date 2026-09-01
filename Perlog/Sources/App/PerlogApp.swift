import SwiftUI
import SwiftData

@main
struct PerlogApp: App {
    @StateObject private var themeStore = ThemeStore()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LogEntry.self,
            Tag.self,
            Person.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create Perlog's local ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(themeStore)
                .preferredColorScheme(themeStore.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
