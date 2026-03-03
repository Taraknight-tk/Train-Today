// SessionLogView.swift
// Train Today — Post-Session Log Entry
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData

struct SessionLogView: View {

    let plan: SessionPlan
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var selectedRating: SessionRating = .great
    @State private var notes: String = ""
    @State private var isSaving: Bool = false
    @State private var showConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ttBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: TTSpacing.lg) {

                        // Header
                        header

                        // Skill recap
                        skillRecap

                        // Rating picker
                        ratingSection

                        // Notes
                        notesSection

                        // Save button
                        saveButton

                        Spacer(minLength: TTSpacing.xxl)
                    }
                    .padding(.horizontal, TTSpacing.md)
                    .padding(.top, TTSpacing.md)
                }
            }
            .navigationTitle("Log Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.ttTextSecondary)
                }
            }
            .overlay {
                if showConfirmation {
                    confirmationOverlay
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: TTSpacing.xs) {
            Text("How did it go?")
                .font(TTFont.display)
                .foregroundColor(.ttText)
            Text("Every session counts, even the tough ones. 💙")
                .font(TTFont.bodySmall)
                .foregroundColor(.ttTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Skill Recap

    private var skillRecap: some View {
        HStack {
            VStack(alignment: .leading, spacing: TTSpacing.xxs) {
                Text(plan.primarySkill.skill.name)
                    .font(TTFont.headline)
                    .foregroundColor(.ttText)
                HStack(spacing: TTSpacing.xxs) {
                    CategoryTag(category: plan.primarySkill.skill.category)
                    Text("·")
                        .foregroundColor(.ttTextSecondary)
                    Text("~\(plan.primarySkill.suggestedMinutes) min")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.ttTextSecondary)
                }
            }
            Spacer()
        }
        .ttCard()
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("How did it go?")
                .font(TTFont.headline)
                .foregroundColor(.ttText)

            HStack(spacing: TTSpacing.sm) {
                ForEach(SessionRating.allCases) { rating in
                    ratingButton(rating)
                }
            }
        }
        .ttCard()
    }

    private func ratingButton(_ rating: SessionRating) -> some View {
        Button {
            selectedRating = rating
        } label: {
            VStack(spacing: TTSpacing.xxs) {
                Text(rating.emoji)
                    .font(.title2)
                Text(rating.rawValue)
                    .font(TTFont.caption)
                    .foregroundColor(selectedRating == rating ? .white : .ttText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(selectedRating == rating ? Color.ttPrimary : Color.ttSecondaryLight)
            .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.xs) {
            Text("Notes (optional)")
                .font(TTFont.headline)
                .foregroundColor(.ttText)
            Text("What did you notice? Anything to remember for next time?")
                .font(TTFont.bodySmall)
                .foregroundColor(.ttTextSecondary)

            TextEditor(text: $notes)
                .font(TTFont.body)
                .frame(minHeight: 100)
                .padding(TTSpacing.xs)
                .background(Color.ttSecondaryLight)
                .clipShape(RoundedRectangle(cornerRadius: TTRadius.sm))
                .scrollContentBackground(.hidden)
        }
        .ttCard()
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            saveSession()
        } label: {
            if isSaving {
                HStack {
                    ProgressView().tint(.white)
                    Text("Saving…")
                }
            } else {
                Text("Save Session")
            }
        }
        .buttonStyle(TTPrimaryButtonStyle())
        .disabled(isSaving)
    }

    // MARK: - Confirmation Overlay

    private var confirmationOverlay: some View {
        VStack(spacing: TTSpacing.sm) {
            Text("🌟")
                .font(.system(size: 56))
            Text("Session logged!")
                .font(TTFont.title)
                .foregroundColor(.ttText)
            Text("Great work with \(plan.primarySkill.skill.name).")
                .font(TTFont.body)
                .foregroundColor(.ttTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ttBackground.opacity(0.95))
    }

    // MARK: - Save Logic

    private func saveSession() {
        isSaving = true

        // Update skill's lastPracticed date
        plan.primarySkill.skill.lastPracticed = Date()
        plan.secondarySkill?.skill.lastPracticed = Date()

        // Create log record
        let session = TrainingSession(
            durationMinutes: plan.totalMinutes,
            skillName: plan.primarySkill.skill.name,
            skillCategory: plan.primarySkill.skill.category,
            rating: selectedRating,
            notes: notes,
            isQuickWin: plan.isQuickWin
        )
        modelContext.insert(session)

        do {
            try modelContext.save()
        } catch {
            print("Error saving session: \(error)")
        }

        // Show confirmation then dismiss
        withAnimation {
            showConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            appState.clearPlan()
            dismiss()
        }
    }
}
