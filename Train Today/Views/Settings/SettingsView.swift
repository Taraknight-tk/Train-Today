// SettingsView.swift
// Train Today — App Settings & About
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct SettingsView: View {

    @Query private var profiles: [DogProfile]
    @State private var notificationManager = NotificationManager()
    @State private var showingDisclaimer  = false
    @State private var showingPrivacy     = false
    @State private var showingResetAlert  = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()

                List {

                    // Dog profile link
                    Section("Your Dog") {
                        NavigationLink {
                            DogProfileView()
                        } label: {
                            dogProfileRow
                        }
                    }
                    .listRowBackground(Color.ttSurface)

                    // Schedule
                    Section("Training Schedule") {
                        NavigationLink("Schedule Settings") {
                            ScheduleSettingsView()
                        }
                        .foregroundColor(.ttText)
                    }
                    .listRowBackground(Color.ttSurface)

                    // Trainer import (Phase 2 — grayed out placeholder)
                    Section("Trainer Tools") {
                        NavigationLink {
                            TrainerImportView()
                        } label: {
                            HStack {
                                Image(systemName: "link.badge.plus")
                                    .foregroundColor(.ttPrimaryInteractive)
                                Text("Import Trainer Curriculum")
                                    .foregroundColor(.ttText)
                            }
                        }
                    }
                    .listRowBackground(Color.ttSurface)

                    // Notifications
                    Section("Notifications") {
                        notificationStatusRow
                    }
                    .listRowBackground(Color.ttSurface)

                    // About
                    Section("About") {
                        Button {
                            showingDisclaimer = true
                        } label: {
                            settingsRow(icon: "exclamationmark.circle", label: "Disclaimer")
                        }

                        Button {
                            showingPrivacy = true
                        } label: {
                            settingsRow(icon: "lock.shield", label: "Privacy Policy")
                        }

                        Link(destination: URL(string: "https://instagram.com/hopetheservicedoodle")!) {
                            settingsRow(icon: "camera", label: "@Hopetheservicedoodle")
                        }

                        HStack {
                            settingsRow(icon: "apps.iphone", label: "Other Apps by Tara Knight")
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.ttSurface)

                    // App info
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 4) {
                                Text("Train Today")
                                    .font(TTFont.bodySmall)
                                    .foregroundColor(.ttTextSecondary)
                                Text("Version 1.0 · Privacy-first · No data collected")
                                    .font(TTFont.caption)
                                    .foregroundColor(.ttTextSecondary)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.ttBackground)

                    // Danger zone
                    Section("Data") {
                        Button("Reset All Data", role: .destructive) {
                            showingResetAlert = true
                        }
                    }
                    .listRowBackground(Color.ttSurface)
                }
                .scrollContentBackground(.hidden)
                .background(Color.ttBackground)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingDisclaimer) { disclaimerSheet }
            .sheet(isPresented: $showingPrivacy) { privacySheet }
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) { resetAllData() }
            } message: {
                Text("This will permanently delete your dog profile, all skills, session logs, and schedule settings. This cannot be undone.")
            }
        }
    }

    // MARK: - Dog Profile Row

    private var dogProfileRow: some View {
        HStack(spacing: TTSpacing.sm) {
            if let data = profiles.first?.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.ttSecondaryLight)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.ttText)
                    )
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(profiles.first?.name ?? "Add your dog")
                    .font(TTFont.body)
                    .foregroundColor(.ttText)
                if let p = profiles.first, !p.breed.isEmpty {
                    Text("\(p.breed) · \(p.ageDisplay)")
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                }
            }
        }
    }

    // MARK: - Notification Status Row

    private var notificationStatusRow: some View {
        HStack {
            Image(systemName: notificationManager.isAuthorized ? "bell.fill" : "bell.slash")
                .foregroundColor(notificationManager.isAuthorized ? .ttPrimaryInteractive : .ttTextSecondary)
            Text(notificationManager.isAuthorized
                 ? "Reminders enabled"
                 : "Reminders are off")
                .font(TTFont.body)
                .foregroundColor(.ttText)
            Spacer()
            if !notificationManager.isAuthorized {
                Button("Enable") {
                    notificationManager.requestAuthorization()
                }
                .font(TTFont.bodySmall)
                .foregroundColor(.ttPrimaryInteractive)
            }
        }
    }

    // MARK: - Helpers

    private func settingsRow(icon: String, label: String) -> some View {
        HStack(spacing: TTSpacing.sm) {
            Image(systemName: icon)
                .foregroundColor(.ttPrimaryInteractive)
                .frame(width: 24)
            Text(label)
                .font(TTFont.body)
                .foregroundColor(.ttText)
        }
    }

    // MARK: - Reset Data

    private func resetAllData() {
        do {
            try modelContext.delete(model: DogProfile.self)
            try modelContext.delete(model: Skill.self)
            try modelContext.delete(model: ScheduleRule.self)
            try modelContext.delete(model: TrainingSession.self)
            try modelContext.delete(model: TrainerImport.self)
            try modelContext.save()
        } catch {
            print("Reset error: \(error)")
        }
    }

    // MARK: - Sheets

    private var disclaimerSheet: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: TTSpacing.md) {
                        Text("Train Today is a planning tool for service dog handlers. It is not a replacement for working with a qualified service dog trainer. The developer is not a professional dog trainer.")
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                        Text("This app exists to support the disabled community in managing their training practice. Always consult a certified professional trainer for guidance specific to your dog and disability.")
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                    }
                    .padding(TTSpacing.md)
                }
            }
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showingDisclaimer = false }.foregroundColor(.ttPrimaryInteractive)
                }
            }
        }
    }

    private var privacySheet: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: TTSpacing.md) {
                        Text("Train Today collects no data of any kind.")
                            .font(TTFont.headline)
                            .foregroundColor(.ttText)
                        Text("All information you enter — your dog's profile, training skills, session logs, and schedule preferences — is stored only on your device. Nothing is transmitted to any server. There are no analytics, no crash reports that leave your device, and no third-party SDKs of any kind.")
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                        Text("Train Today works fully offline. Deleting the app deletes all data permanently.")
                            .font(TTFont.body)
                            .foregroundColor(.ttText)
                    }
                    .padding(TTSpacing.md)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showingPrivacy = false }.foregroundColor(.ttPrimaryInteractive)
                }
            }
        }
    }
}
