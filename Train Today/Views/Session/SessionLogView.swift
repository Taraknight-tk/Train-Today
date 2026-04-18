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
    @State private var didCompletePrimary: Bool   = true   // optimistic — both on by default
    @State private var didCompleteSecondary: Bool = true   // at least one must stay checked

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background.ignoresSafeArea()

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
                        .foregroundColor(.textSecondary)
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
                .foregroundColor(.textPrimary)
            Text("Every session counts, even the tough ones. 💙")
                .font(TTFont.bodySmall)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Skill Recap

    private var skillRecap: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {

            if plan.secondarySkill != nil {
                Text("Which skills did you practice?")
                    .font(TTFont.caption)
                    .foregroundColor(.textSecondary)
                    .textCase(.uppercase)
            }

            // Primary skill — toggleable, but locked on if secondary is off
            skillRecapRow(
                item: plan.primarySkill,
                label: didCompletePrimary ? "Practiced" : "Skipped",
                isCompleted: didCompletePrimary,
                // Can only deselect primary if secondary is still checked
                isToggleable: didCompleteSecondary,
                onToggle: { didCompletePrimary.toggle() }
            )

            // Secondary skill — toggleable, but locked on if primary is off
            if let secondary = plan.secondarySkill {
                Divider()
                skillRecapRow(
                    item: secondary,
                    label: didCompleteSecondary ? "Also practiced" : "Skipped",
                    isCompleted: didCompleteSecondary,
                    // Can only deselect secondary if primary is still checked
                    isToggleable: didCompletePrimary,
                    onToggle: { didCompleteSecondary.toggle() }
                )
            }
        }
        .ttCard()
    }

    private func skillRecapRow(
        item: SessionSkillItem,
        label: String,
        isCompleted: Bool,
        isToggleable: Bool,
        onToggle: @escaping () -> Void
    ) -> some View {
        HStack(spacing: TTSpacing.sm) {
            // Checkmark / toggle indicator
            Button(action: isToggleable ? onToggle : {}) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .accentInteractive : .fillSecondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .disabled(!isToggleable)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.skill.name)
                    .font(TTFont.headline)
                    .foregroundColor(isCompleted ? .textPrimary : .textSecondary)
                HStack(spacing: TTSpacing.xxs) {
                    CategoryTag(category: item.skill.category)
                    Text("·")
                        .foregroundColor(.textSecondary)
                    Text("~\(item.suggestedMinutes) min")
                        .font(TTFont.bodySmall)
                        .foregroundColor(.textSecondary)
                    Text("· \(label)")
                        .font(TTFont.bodySmall)
                        .foregroundColor(isCompleted ? .accentInteractive : .textSecondary)
                }
            }
            Spacer()
        }
    }

    // MARK: - Rating Section

    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.sm) {
            Text("How did it go?")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)

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
                    .foregroundColor(selectedRating == rating ? .white : .textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(selectedRating == rating ? Color.accentInteractive : Color.fillSecondary)
            .clipShape(RoundedRectangle(cornerRadius: TTRadius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: TTSpacing.xs) {
            Text("Notes (optional)")
                .font(TTFont.headline)
                .foregroundColor(.textPrimary)
            Text("What did you notice? Anything to remember for next time?")
                .font(TTFont.bodySmall)
                .foregroundColor(.textSecondary)

            TextEditor(text: $notes)
                .font(TTFont.body)
                .frame(minHeight: 100)
                .padding(TTSpacing.xs)
                .background(Color.fillSecondary)
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
        var practicedNames: [String] = []
        if didCompletePrimary   { practicedNames.append(plan.primarySkill.skill.name) }
        if didCompleteSecondary, let secondary = plan.secondarySkill { practicedNames.append(secondary.skill.name) }
        let confirmationText = practicedNames.count == 2
            ? "Great work on \(practicedNames[0]) and \(practicedNames[1])."
            : "Great work with \(practicedNames.first ?? "your session")."

        return VStack(spacing: TTSpacing.sm) {
            Text("🌟")
                .font(.system(size: 56))
            Text("Session logged!")
                .font(TTFont.title)
                .foregroundColor(.textPrimary)
            Text(confirmationText)
                .font(TTFont.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background.opacity(0.95))
    }

    // MARK: - Save Logic

    private func saveSession() {
        isSaving = true

        // Build list of skills actually completed this session
        var completedItems: [SessionSkillItem] = []
        if didCompletePrimary   { completedItems.append(plan.primarySkill) }
        if didCompleteSecondary, let secondary = plan.secondarySkill { completedItems.append(secondary) }

        // Create one TrainingSession log entry per completed skill
        let perSkillMinutes = max(1, plan.totalMinutes / completedItems.count)
        for item in completedItems {
            item.skill.lastPracticed = Date()
            let session = TrainingSession(
                durationMinutes: perSkillMinutes,
                skillName: item.skill.name,
                skillCategory: item.skill.category,
                rating: selectedRating,
                notes: notes,
                isQuickWin: plan.isQuickWin
            )
            modelContext.insert(session)
        }

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
