// TrainerImport.swift
// Train Today — Trainer Curriculum Import Record (Phase 2 ready)
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import SwiftData

@Model
final class TrainerImport {

    // MARK: - Properties

    var importDate: Date
    var sourceLink: String          // original traintoday://import?data=... URL
    var trainerName: String         // extracted from payload if present
    var skillsImported: Int         // count of skills in the import
    var rawPayload: String           // base64-encoded JSON, kept for audit

    // MARK: - Computed

    var importDateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: importDate)
    }

    var summary: String {
        "\(skillsImported) skill\(skillsImported == 1 ? "" : "s") imported"
        + (trainerName.isEmpty ? "" : " from \(trainerName)")
    }

    // MARK: - Init

    init(
        importDate: Date = .now,
        sourceLink: String,
        trainerName: String = "",
        skillsImported: Int,
        rawPayload: String = ""
    ) {
        self.importDate      = importDate
        self.sourceLink      = sourceLink
        self.trainerName     = trainerName
        self.skillsImported  = skillsImported
        self.rawPayload      = rawPayload
    }
}

// MARK: - Trainer Link Payload (Phase 2)

/// JSON payload structure for trainer curriculum links.
/// URL scheme: traintoday://import?data=<base64-encoded-JSON>
struct TrainerLinkPayload: Codable {
    let trainerName: String
    let generatedDate: String
    let skills: [TrainerSkillEntry]

    struct TrainerSkillEntry: Codable {
        let name: String
        let category: String        // TrainingCategoryType rawValue
        let status: String          // SkillStatus rawValue
        let importance: String      // SkillImportance rawValue
        let environment: String     // SkillEnvironment rawValue
        let howToReminder: String
        let successMetric: String
    }

    static func decode(from base64: String) -> TrainerLinkPayload? {
        guard
            let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        else { return nil }
        return try? JSONDecoder().decode(TrainerLinkPayload.self, from: data)
    }
}
