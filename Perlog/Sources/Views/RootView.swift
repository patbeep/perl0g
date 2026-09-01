import SwiftUI

struct RootView: View {
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        TabView {
            TimelineView()
                .tabItem { Label("Timeline", systemImage: "clock.arrow.circlepath") }

            MemoriesView()
                .tabItem { Label("Memories", systemImage: "sparkles") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.xaxis") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(theme.accent)
    }
}

#Preview {
    RootView()
        .environmentObject(ThemeStore())
}
