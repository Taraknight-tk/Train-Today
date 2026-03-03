// TrainTodayApp.swift
// Train Today — Service Dog Training Planner
// Developed by Tara Knight | @Hopetheservicedoodle
// Version 1.0 | Phase 1 MVP

import SwiftUI
import SwiftData

@main
struct TrainTodayApp: App {

    let modelContainer: ModelContainer
    @State private var appState = AppState()
    @State private var notificationManager = NotificationManager()

    init() {
        do {
            #if DEBUG
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            #else
            let configuration = ModelConfiguration()
            #endif

            modelContainer = try ModelContainer(
                for: DogProfile.self,
                     Skill.self,
                     ScheduleRule.self,
                     TrainingSession.self,
                     TrainerImport.self,
                configurations: configuration
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(notificationManager)
                .modelContainer(modelContainer)
        }
    }
}

