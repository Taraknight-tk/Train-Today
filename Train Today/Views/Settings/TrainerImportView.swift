// TrainerImportView.swift
// Train Today — Trainer Curriculum Import (Phase 2 Ready)
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct TrainerImportView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var linkText: String = ""
    @State private var parsedPayload: TrainerLinkPayload? = nil
    @State private var parseError: String? = nil
    @State private var isImporting: Bool = false
    @State private var importSuccess: Bool = false

    var body: some View {
        ZStack {
            Color.ttBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: TTSpacing.lg) {

                    // Header
                    VStack(alignment: .leading, spacing: TTSpacing.xs) {
                        Text("🔗")
                            .font(.system(size: 40))
                        Text("Trainer Curriculum")
                            .font(TTFont.display)
                            .foregroundColor(.ttText)
                        Text("If your trainer gave you a Train Today import link, paste it below. This will add skills to your inventory while keeping all data on your device.")
                            .font(TTFont.body)
                            .foregroundColor(.ttTextSecondary)
                    }

                    // Input
                    VStack(alignment: .leading, spacing: TTSpacing.xs) {
                        Text("Trainer link")
                            .font(TTFont.bodySmall)
                            .foregroundColor(.ttTextSecondary)
                        TextEditor(text: $linkText)
                            .font(TTFont.bodySmall)
                            .frame(minHeight: 80)
                            .padding(TTSpacing.sm)
                            .background(Color.ttSurface)
                            .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
                            .overlay(RoundedRectangle(cornerRadius: TTRadius.md)
                                .strokeBorder(Color.ttSecondaryLight, lineWidth: 1))
                            .scrollContentBackground(.hidden)
                    }

                    // Parse error
                    if let error = parseError {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.ttError)
                            Text(error)
                                .font(TTFont.bodySmall)
                                .foregroundColor(.ttError)
                        }
                    }

                    // Preview
                    if let payload = parsedPayload {
                        importPreview(payload)
                    }

                    // Buttons
                    if parsedPayload == nil {
                        Button("Parse Link") {
                            parseLink()
                        }
                        .buttonStyle(TTPrimaryButtonStyle())
                        .disabled(linkText.trimmingCharacters(in: .whitespaces).isEmpty)
                    } else {
                        Button("Import \(parsedPayload!.skills.count) Skills") {
                            importSkills()
                        }
                        .buttonStyle(TTPrimaryButtonStyle())
                        .disabled(isImporting || importSuccess)

                        Button("Cancel") {
                            parsedPayload = nil
                            linkText = ""
                        }
                        .buttonStyle(TTSecondaryButtonStyle())
                    }

                    if importSuccess {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.ttSuccess)
                            Text("Skills imported successfully!")
                                .font(TTFont.body)
                                .foregroundColor(.ttSuccess)
                        }
                    }

                    Spacer(minLength: TTSpacing.xxl)
                }
                .padding(.horizontal, TTSpacing.md)
                .padding(.top, TTSpacing.md)
            }
        }
        .navigationTitle("Trainer Import")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Import Preview

    private func importPreview(_ payload: TrainerLinkPayload) -> some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("Preview")
                .font(TTFont.headline)
                .foregroundColor(.ttText)

            if !payload.trainerName.isEmpty {
                Text("From: \(payload.trainerName)")
                    .font(TTFont.bodySmall)
                    .foregroundColor(.ttTextSecondary)
            }

            ForEach(payload.skills, id: \.name) { entry in
                HStack {
                    Text(entry.name)
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttText)
                    Spacer()
                    Text(entry.category)
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                }
                .padding(.horizontal, TTSpacing.sm)
                .padding(.vertical, 4)
                .background(Color.ttSurface)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
            }
        }
        .ttCard()
    }

    // MARK: - Parse Link

    private func parseLink() {
        parseError = nil
        let text = linkText.trimmingCharacters(in: .whitespaces)

        // Extract base64 payload from traintoday://import?data=<base64>
        guard
            let urlComponents = URLComponents(string: text),
            let dataParam = urlComponents.queryItems?.first(where: { $0.name == "data" })?.value,
            let payload = TrainerLinkPayload.decode(from: dataParam)
        else {
            parseError = "Couldn't read this link. Make sure you pasted the full trainer link."
            return
        }
        parsedPayload = payload
    }

    // MARK: - Import Skills

    private func importSkills() {
        guard let payload = parsedPayload else { return }
        isImporting = true

        var order = 1000    // start high to avoid collision with existing skills
        for entry in payload.skills {
            let category    = TrainingCategoryType(rawValue: entry.category) ?? .obedience
            let status      = SkillStatus(rawValue: entry.status) ?? .developing
            let importance  = SkillImportance(rawValue: entry.importance) ?? .standard
            let environment = SkillEnvironment(rawValue: entry.environment) ?? .home

            let skill = Skill(
                name: entry.name,
                category: category,
                status: status,
                importance: importance,
                requiredEnvironment: environment,
                howToReminder: entry.howToReminder,
                successMetric: entry.successMetric,
                isCustom: false,
                sortOrder: order
            )
            modelContext.insert(skill)
            order += 1
        }

        // Log the import
        let importRecord = TrainerImport(
            sourceLink: linkText,
            trainerName: payload.trainerName,
            skillsImported: payload.skills.count,
            rawPayload: linkText
        )
        modelContext.insert(importRecord)

        try? modelContext.save()
        isImporting = false
        importSuccess = true
    }
}
