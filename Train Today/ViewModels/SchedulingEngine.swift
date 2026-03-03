// SchedulingEngine.swift
// Train Today — Core Session Recommendation Engine
// Developed by Tara Knight | @Hopetheservicedoodle
//
// This engine runs entirely on-device using deterministic, rule-based logic.
// No machine learning, no cloud processing, no data leaves the device.
//
// Decision Hierarchy (from PRD §5):
//  1. Apply schedule rules  — respect day-of-week overrides
//  2. Filter by location    — remove skills requiring unavailable environments
//  3. Filter by energy      — Low energy excludes new skill introductions
//  4. Sort by importance    — Critical > Standard > Low
//  5. Sort by recency       — least-recently-practiced rises to top within tier
//  6. Weight by status      — Developing > Maintaining when recency is equal
//  7. Apply time constraint — truncate to fit within available time
//  8. Output plan           — primary skill + optional secondary if time permits

import Foundation

// MARK: - Session Plan Output

struct SessionPlan {
    let primarySkill: SessionSkillItem
    let secondarySkill: SessionSkillItem?
    let totalMinutes: Int
    let generatedAt: Date
    let isQuickWin: Bool
    let warningMessage: String?     // e.g., "No Critical skills available in this location"
}

struct SessionSkillItem {
    let skill: Skill
    let suggestedMinutes: Int
    let adjustedForLowEnergy: Bool  // true = low energy version of a Critical skill
}

// MARK: - Scheduling Engine

struct SchedulingEngine {

    // MARK: - Public API

    /// Generates a session plan based on the three daily inputs.
    /// - Parameters:
    ///   - skills:       All active skills for this handler
    ///   - sessions:     All past training sessions (for recency calculation)
    ///   - scheduleRule: Today's schedule rule (may be nil if none configured)
    ///   - duration:     Handler-selected session duration
    ///   - energy:       Handler-selected energy level
    ///   - location:     Handler-selected available environment
    static func generatePlan(
        skills: [Skill],
        sessions: [TrainingSession],
        scheduleRule: ScheduleRule?,
        duration: SessionDuration,
        energy: EnergyLevel,
        location: SkillEnvironment
    ) -> SessionPlan {

        // --- Step 1: Apply schedule rules ---
        var effectiveDuration = duration
        if let rule = scheduleRule, rule.isEnabled, rule.maxMinutes > 0 {
            let ruleDurationValue = min(rule.maxMinutes, duration.rawValue)
            effectiveDuration = closestDuration(to: ruleDurationValue)
        }

        // Determine category priority from schedule rule
        let priorityCategory = scheduleRule?.priorityCategory

        // --- Step 2 & 3: Filter by location and energy ---
        let available = skills.filter { skill in
            guard skill.isActive else { return false }
            guard skill.requiredEnvironment.isAvailableIn(location) else { return false }
            // Low energy: exclude Beginner skills (new introductions) unless Critical
            if energy == .low && skill.status == .beginner && skill.importance != .critical {
                return false
            }
            return true
        }

        if available.isEmpty {
            // Fallback: suggest a Quick Win even with no matching skills
            let fallback = skills.filter { $0.isActive }.first
            if let f = fallback {
                let item = SessionSkillItem(skill: f, suggestedMinutes: 5, adjustedForLowEnergy: true)
                return SessionPlan(
                    primarySkill: item,
                    secondarySkill: nil,
                    totalMinutes: 5,
                    generatedAt: .now,
                    isQuickWin: true,
                    warningMessage: "No skills matched your current location and energy. Showing a fallback option."
                )
            }
        }

        // --- Steps 4–6: Sort ---
        let sorted = available.sorted { a, b in
            // Priority category first (if set by schedule rule)
            if let pc = priorityCategory {
                if a.category == pc && b.category != pc { return true }
                if b.category == pc && a.category != pc { return false }
            }
            // 4. Sort by importance
            if a.importance.sortPriority != b.importance.sortPriority {
                return a.importance.sortPriority < b.importance.sortPriority
            }
            // 5. Sort by recency (least recently practiced = higher priority)
            let aRecency = a.lastPracticed?.timeIntervalSinceNow ?? -.infinity
            let bRecency = b.lastPracticed?.timeIntervalSinceNow ?? -.infinity
            if abs(aRecency - bRecency) > 60 * 60 * 12 {   // >12h difference = meaningful
                return aRecency < bRecency  // more negative = longer ago = higher priority
            }
            // 6. Weight by status (Developing > Maintaining)
            return a.status.sortPriority < b.status.sortPriority
        }

        // --- Step 7: Apply time constraint ---
        let maxSkills = effectiveDuration.maxSkills
        let minPerSkill = effectiveDuration.minutesPerSkill
        let candidates = Array(sorted.prefix(maxSkills))

        // Low-energy adjustment: for Critical skills on low-energy days,
        // suggest a lighter version (3 calm reps) instead of a full session
        let primarySkill = candidates.first!
        let isAdjusted = energy == .low && primarySkill.importance == .critical

        let primaryItem = SessionSkillItem(
            skill: primarySkill,
            suggestedMinutes: isAdjusted ? min(5, minPerSkill) : minPerSkill,
            adjustedForLowEnergy: isAdjusted
        )

        var secondaryItem: SessionSkillItem? = nil
        if candidates.count > 1 {
            let secondary = candidates[1]
            let secAdjusted = energy == .low && secondary.importance == .critical
            secondaryItem = SessionSkillItem(
                skill: secondary,
                suggestedMinutes: secAdjusted ? min(5, minPerSkill) : minPerSkill,
                adjustedForLowEnergy: secAdjusted
            )
        }

        let totalMinutes = (primaryItem.suggestedMinutes) + (secondaryItem?.suggestedMinutes ?? 0)

        // Warning: any overdue Critical skills that didn't make it into the plan
        let overdueCritical = skills.filter { $0.isCriticalOverdue }
            .filter { s in !candidates.contains(where: { $0.name == s.name }) }
        let warning: String? = overdueCritical.isEmpty ? nil :
            "⚠️ \(overdueCritical.first!.name) is overdue and wasn't included (location unavailable or energy too low)."

        return SessionPlan(
            primarySkill: primaryItem,
            secondarySkill: secondaryItem,
            totalMinutes: totalMinutes,
            generatedAt: .now,
            isQuickWin: false,
            warningMessage: warning
        )
    }

    // MARK: - Quick Win Mode

    /// Selects the single easiest, most recently-succeeded skill for a confidence-boost session.
    static func generateQuickWin(skills: [Skill], sessions: [TrainingSession]) -> SessionPlan? {
        // Quick Win: pick the Maintaining skill with the most recent Great rating
        let candidates = skills.filter { $0.isActive && $0.status == .maintaining }

        // Score each candidate by most recent "Great" session
        let scored = candidates.compactMap { skill -> (Skill, Date)? in
            let great = sessions
                .filter { $0.skillName == skill.name && $0.rating == .great }
                .sorted { $0.date > $1.date }
                .first
            guard let date = great?.date else { return nil }
            return (skill, date)
        }.sorted { $0.1 > $1.1 }

        let best = scored.first?.0 ?? candidates.first ?? skills.filter { $0.isActive }.first

        guard let winner = best else { return nil }

        let item = SessionSkillItem(skill: winner, suggestedMinutes: 5, adjustedForLowEnergy: false)
        return SessionPlan(
            primarySkill: item,
            secondarySkill: nil,
            totalMinutes: 5,
            generatedAt: .now,
            isQuickWin: true,
            warningMessage: nil
        )
    }

    // MARK: - Helpers

    private static func closestDuration(to minutes: Int) -> SessionDuration {
        SessionDuration.allCases
            .filter { $0.rawValue <= minutes }
            .max(by: { $0.rawValue < $1.rawValue })
            ?? .fiveMin
    }

    // MARK: - Streak Calculation

    /// Returns the current consecutive training day streak.
    static func currentStreak(sessions: [TrainingSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        let calendar = Calendar.current
        let sorted = sessions.sorted { $0.date > $1.date }
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        for session in sorted {
            let sessionDay = calendar.startOfDay(for: session.date)
            if sessionDay == checkDate {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if sessionDay < checkDate {
                break
            }
        }
        return streak
    }

    /// Returns days since last session (nil if never trained)
    static func daysSinceLastSession(sessions: [TrainingSession]) -> Int? {
        guard let last = sessions.max(by: { $0.date < $1.date }) else { return nil }
        return Calendar.current.dateComponents([.day], from: last.date, to: Date()).day
    }
}
