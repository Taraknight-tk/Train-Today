// DogProfile.swift
// Train Today — Dog Profile Model
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation
import SwiftData

@Model
final class DogProfile {

    // MARK: - Properties

    var name: String
    var breed: String
    var ageYears: Int
    var ageMonths: Int
    var isProgramDog: Bool          // true = program dog, false = owner-trained
    var handlerNotes: String        // handler physical limitations or context
    var hasCompletedOnboarding: Bool
    var photoData: Data?            // stored as Data for on-device privacy

    // MARK: - Computed

    var ageDisplay: String {
        switch (ageYears, ageMonths) {
        case (0, let m) where m < 2:  return "\(m) month"
        case (0, let m):              return "\(m) months"
        case (1, 0):                  return "1 year"
        case (1, let m):              return "1 year, \(m) mo"
        case (let y, 0):              return "\(y) years"
        case (let y, let m):          return "\(y) years, \(m) mo"
        }
    }

    var trainingTypeLabel: String {
        isProgramDog ? "Program Dog" : "Owner-Trained"
    }

    // MARK: - Init

    init(
        name: String = "",
        breed: String = "",
        ageYears: Int = 0,
        ageMonths: Int = 0,
        isProgramDog: Bool = false,
        handlerNotes: String = "",
        hasCompletedOnboarding: Bool = false,
        photoData: Data? = nil
    ) {
        self.name                   = name
        self.breed                  = breed
        self.ageYears               = ageYears
        self.ageMonths              = ageMonths
        self.isProgramDog           = isProgramDog
        self.handlerNotes           = handlerNotes
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.photoData              = photoData
    }
}
