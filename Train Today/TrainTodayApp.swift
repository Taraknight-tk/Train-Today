// TrainTodayApp.swift
// Train Today — Service Dog Training Planner
// Developed by Tara Knight | @Hopetheservicedoodle
// Version 1.0 | Phase 1 MVP

import SwiftUI
import SwiftData

@main
struct TrainTodayApp: App {

    let modelContainer: ModelContainer = {
        let schema = Schema([
            DogProfile.self,
            Skill.self,
            ScheduleRule.self,
            TrainingSession.self,
            TrainerImport.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema migration failed — wipe the local store and start fresh.
            // This preserves app launch in development when models change.
            // A production release would use a versioned SchemaMigrationPlan instead.
            print("⚠️ ModelContainer failed to load (\(error)). Deleting store and rebuilding.")
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            // SQLite writes .store-shm and .store-wal sidecar files — clean those too
            let base = storeURL.deletingLastPathComponent()
            let name = storeURL.deletingPathExtension().lastPathComponent
            try? FileManager.default.removeItem(at: base.appendingPathComponent("\(name).store-shm"))
            try? FileManager.default.removeItem(at: base.appendingPathComponent("\(name).store-wal"))
            return try! ModelContainer(for: schema, configurations: [modelConfiguration])
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

