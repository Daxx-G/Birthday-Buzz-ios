import SwiftUI

@main
struct BirthdayBuzzApp: App {
    
    @StateObject private var storageService = StorageService()
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
                            hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                }
            }
            .environmentObject(storageService)
        }
    }
}

// TODO: Implement main tab view
struct MainTabView: View {
    var body: some View {
        TabView {
            BuzzListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Buzz List")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

// TODO: Define notification for onboarding completion
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
