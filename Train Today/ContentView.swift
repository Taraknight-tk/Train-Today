// ContentView.swift
// Train Today — Root Navigation Shell
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var appState = AppState()
    @Query private var profiles: [DogProfile]

    var body: some View {
        Group {
            if profiles.isEmpty || !(profiles.first?.hasCompletedOnboarding ?? false) {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .environment(appState)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppState.TabItem.home)

            SkillManagerView()
                .tabItem {
                    Label("Skills", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(AppState.TabItem.skills)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(AppState.TabItem.progress)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppState.TabItem.settings)
        }
        .tint(.ttPrimaryInteractive)
    }
}
