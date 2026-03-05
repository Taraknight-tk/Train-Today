// AppState.swift
// Train Today — Global Observable App State
// Developed by Tara Knight | @Hopetheservicedoodle
// Uses @Observable macro (iOS 17+) — replaces ObservableObject/Published

import SwiftUI
import SwiftData

@MainActor
@Observable
final class AppState {

    // MARK: - Navigation State

    var selectedTab: TabItem = .home
    var showingOnboarding: Bool = false
    var activeSheet: ActiveSheet? = nil

    // MARK: - Daily Session Inputs (preserved across view transitions)

    var selectedDuration: SessionDuration   = .twentyMin
    var selectedEnergy: EnergyLevel         = .medium
    var selectedLocation: SkillEnvironment  = .home

    // MARK: - Active Session Plan

    var currentPlan: SessionPlan?           = nil
    var isGeneratingPlan: Bool              = false

    // MARK: - Tab Enum

    enum TabItem: String, Identifiable, CaseIterable {
        case home     = "Home"
        case skills   = "Skills"
        case progress = "Progress"
        case settings = "Settings"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .home:     return "house.fill"
            case .skills:   return "list.bullet.clipboard.fill"
            case .progress: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    // MARK: - Active Sheet Enum

    enum ActiveSheet: Identifiable {
        case sessionLog(plan: SessionPlan)
        case quickWin
        case quickLog
        case trainerImport
        case addSkill(category: TrainingCategoryType)
        case editSkill(skill: Skill)

        var id: String {
            switch self {
            case .sessionLog:             return "sessionLog"
            case .quickWin:               return "quickWin"
            case .quickLog:               return "quickLog"
            case .trainerImport:          return "trainerImport"
            case .addSkill(let c):        return "addSkill_\(c.rawValue)"
            case .editSkill(let s):       return "editSkill_\(s.name)"
            }
        }
    }

    // MARK: - Actions

    func generatePlan(
        skills: [Skill],
        sessions: [TrainingSession],
        scheduleRule: ScheduleRule?
    ) {
        isGeneratingPlan = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.currentPlan = SchedulingEngine.generatePlan(
                skills: skills,
                sessions: sessions,
                scheduleRule: scheduleRule,
                duration: self.selectedDuration,
                energy: self.selectedEnergy,
                location: self.selectedLocation
            )
            self.isGeneratingPlan = false
            self.selectedTab = .home
        }
    }

    func generateQuickWin(skills: [Skill], sessions: [TrainingSession]) {
        currentPlan = SchedulingEngine.generateQuickWin(skills: skills, sessions: sessions)
        activeSheet = .quickWin
    }

    func clearPlan() {
        currentPlan = nil
    }
}
