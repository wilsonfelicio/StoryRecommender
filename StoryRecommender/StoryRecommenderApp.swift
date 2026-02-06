import SwiftUI

@main
struct StoryRecommenderApp: App {
    @State private var favoritesVM = FavoritesViewModel()
    @State private var historyVM = HistoryViewModel()
    @State private var darkModeOverride = StorageService.shared.darkModeOverride
    @AppStorage("dark_mode_manual") private var manualDarkMode = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favoritesVM)
                .environment(historyVM)
                .preferredColorScheme(resolvedColorScheme)
        }
    }

    private var resolvedColorScheme: ColorScheme? {
        if let override = darkModeOverride {
            return override ? .dark : .light
        }
        // Auto dark after 7 PM
        return TimeUtilities.isNightTime() ? .dark : nil
    }
}

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "book.fill")
            }
            .tag(0)

            NavigationStack {
                GenerateView()
            }
            .tabItem {
                Label("Generate", systemImage: "sparkles")
            }
            .tag(1)

            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            .tag(2)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.fill")
            }
            .tag(3)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .tint(.indigo)
    }
}
