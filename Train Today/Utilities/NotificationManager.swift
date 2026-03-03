// NotificationManager.swift
// Train Today — Local Notification Manager
// Uses @Observable macro (iOS 17+) — replaces ObservableObject/Published
// All notifications are iOS local (UNUserNotificationCenter). No data leaves the device.
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import UserNotifications
import SwiftUI

@MainActor
@Observable
final class NotificationManager {

    var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()

    // MARK: - Notification Identifiers

    private enum NotificationID {
        static func dailyReminder(for weekday: Weekday) -> String {
            "tt_daily_\(weekday.rawValue)"
        }
        static func streakNudge() -> String { "tt_streak_nudge" }
        static func criticalSkillAlert(skillName: String) -> String {
            "tt_critical_\(skillName.lowercased().replacingOccurrences(of: " ", with: "_"))"
        }
    }

    // MARK: - Authorization

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
    }

    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Daily Training Reminder

    /// Schedules a weekly repeating reminder for the given schedule rule.
    /// Fires at the rule's configured hour/minute on the rule's weekday.
    func scheduleReminder(for rule: ScheduleRule) {
        guard rule.reminderEnabled else {
            cancelReminder(for: rule.weekday)
            return
        }

        let id = NotificationID.dailyReminder(for: rule.weekday)
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Time to train! 🐾"
        content.body  = "Tap to see today's plan."
        content.sound = .default

        var components        = DateComponents()
        components.weekday    = rule.weekday.rawValue
        components.hour       = rule.reminderHour
        components.minute     = rule.reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelReminder(for weekday: Weekday) {
        center.removePendingNotificationRequests(
            withIdentifiers: [NotificationID.dailyReminder(for: weekday)]
        )
    }

    // MARK: - Streak Nudge

    /// Fires once if no session has been logged in 3+ days.
    func scheduleStreakNudge(daysSinceLastSession: Int) {
        let id = NotificationID.streakNudge()
        center.removePendingNotificationRequests(withIdentifiers: [id])

        guard daysSinceLastSession >= 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "It's been a few days 💙"
        content.body  = "Even 5 minutes counts. Tap to start a Quick Win session."
        content.sound = .default

        // Fire after a short delay (next morning at 9am)
        var comps    = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour   = 9
        comps.minute = 0
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var triggerComps = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        triggerComps.hour   = 9
        triggerComps.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Critical Skill Alert

    /// Fires a one-time notification when a Critical skill hasn't been practiced in 7+ days.
    func scheduleCriticalSkillAlert(skillName: String) {
        let id = NotificationID.criticalSkillAlert(skillName: skillName)

        // Only add if not already scheduled
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let alreadyScheduled = requests.contains { $0.identifier == id }
            guard !alreadyScheduled else { return }

            let content = UNMutableNotificationContent()
            content.title = "Heads up 🐾"
            content.body  = "\(skillName) hasn't been practiced in a week."
            content.sound = .default

            // Fire tomorrow at 10am
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            var comps    = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
            comps.hour   = 10
            comps.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            self.center.add(request)
        }
    }

    func cancelCriticalSkillAlert(skillName: String) {
        center.removePendingNotificationRequests(
            withIdentifiers: [NotificationID.criticalSkillAlert(skillName: skillName)]
        )
    }

    // MARK: - Cancel All

    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
}
