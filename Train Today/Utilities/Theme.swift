// Theme.swift
// Train Today — Brand Colors, Typography & Style Constants
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI

// MARK: - Color Namespace
// To avoid symbol collisions across files, colors are namespaced under TTColor.
enum TTColor {
    // MARK: Brand Colors
    /// Warm cream / deep warm brown — primary app background
    static let background      = Color("ttBackground")
    /// Sage green / lighter sage — primary brand color, buttons, accents
    static let primary         = Color("ttPrimary")
    /// Lighter sage / muted sage tint — secondary fills, selected states
    static let primaryLight    = Color("ttPrimaryLight")
    /// Warm taupe / lighter warm taupe — secondary UI elements, card borders
    static let secondary       = Color("ttSecondary")
    /// Soft taupe tint / dark secondary surface — card backgrounds, dividers
    static let secondaryLight  = Color("ttSecondaryLight")
    /// Near-black / warm near-white — body text, primary labels
    static let text            = Color("ttText")
    /// Mid-gray / warm light gray — secondary labels, placeholders
    static let textSecondary   = Color("ttTextSecondary")
    /// White / elevated dark surface — surface cards, modals
    static let surface         = Color("ttSurface")
    /// Warm red / lighter warm red — error states, destructive actions
    static let error           = Color("ttError")
    /// Warm amber / lighter amber — warnings, streak nudges
    static let warning         = Color("ttWarning")
    /// Deep sage / lighter sage — confirmation, success states
    static let success         = Color("ttSuccess")

    /// Accessible dark sage — replaces ttPrimary for all interactive text, icons, and button fills.
    /// White text on this color: 5.98:1. On ttBackground cream: 5.27:1. Both pass WCAG 2.1 AA.
    static let primaryInteractive = Color(red: 56/255, green: 111/255, blue: 63/255) // #386F3F

    // MARK: Category Colors
    static let obedience       = Color("ttObedience")    // Sage green — adaptive
    static let publicAccess    = Color("ttPublicAccess") // Dusty blue — adaptive
    static let task            = Color("ttTask")         // Warm taupe — adaptive
    static let relationship    = Color("ttRelationship") // Soft lavender — adaptive

    static func forCategory(_ category: TrainingCategoryType) -> Color {
        switch category {
        case .obedience:    return TTColor.obedience
        case .publicAccess: return TTColor.publicAccess
        case .task:         return TTColor.task
        case .relationship: return TTColor.relationship
        }
    }
}


// MARK: Hex Color Helper
extension Color {
    /// Accessible dark sage — use in place of .ttPrimary for any text, icon, or button fill role.
    static var ttPrimaryInteractive: Color { TTColor.primaryInteractive }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography

struct TTFont {
    /// Large display title — onboarding headers, session plan headline
    static let display      = Font.system(size: 28, weight: .bold, design: .rounded)
    /// Screen titles
    static let title        = Font.system(size: 22, weight: .semibold, design: .rounded)
    /// Card titles, section headers
    static let headline     = Font.system(size: 17, weight: .semibold, design: .rounded)
    /// Primary body text
    static let body         = Font.system(size: 16, weight: .regular, design: .rounded)
    /// Supporting body, descriptions
    static let bodySmall    = Font.system(size: 14, weight: .regular, design: .rounded)
    /// Captions, metadata, timestamps
    static let caption      = Font.system(size: 12, weight: .regular, design: .rounded)
    /// Pill labels, tags
    static let tag          = Font.system(size: 11, weight: .medium, design: .rounded)
}

// MARK: - Spacing

struct TTSpacing {
    static let xxs:  CGFloat = 4
    static let xs:   CGFloat = 8
    static let sm:   CGFloat = 12
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 24
    static let xl:   CGFloat = 32
    static let xxl:  CGFloat = 48
}

// MARK: - Corner Radius

struct TTRadius {
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 12
    static let lg:   CGFloat = 16
    static let xl:   CGFloat = 24
    static let pill: CGFloat = 999
}

// MARK: - Shadow

extension View {
    func ttCardShadow() -> some View {
        self.shadow(color: TTColor.text.opacity(0.06), radius: 8, x: 0, y: 2)
    }
    func ttElevatedShadow() -> some View {
        self.shadow(color: TTColor.text.opacity(0.10), radius: 16, x: 0, y: 4)
    }
}

// MARK: - Reusable Card Style

struct TTCardModifier: ViewModifier {
    var padding: CGFloat = TTSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(TTColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: TTRadius.lg))
            .ttCardShadow()
    }
}

extension View {
    func ttCard(padding: CGFloat = TTSpacing.md) -> some View {
        modifier(TTCardModifier(padding: padding))
    }
}

// MARK: - Primary Button Style

struct TTPrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TTRadius.md)
                    .fill(isDestructive ? TTColor.error : TTColor.primaryInteractive)
                    .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct TTSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.headline)
            .foregroundColor(TTColor.primaryInteractive)
            .frame(maxWidth: .infinity)
            .padding(.vertical, TTSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: TTRadius.md)
                    .strokeBorder(TTColor.primaryInteractive, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

