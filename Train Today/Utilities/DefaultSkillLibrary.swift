// DefaultSkillLibrary.swift
// Train Today — Default Skill Library
// Handlers can customize, add, and remove skills after onboarding.
// Developed by Tara Knight | @Hopetheservicedoodle

import Foundation

struct SkillTemplate {
    let name: String
    let category: TrainingCategoryType
    let importance: SkillImportance
    let environment: SkillEnvironment
    let howToReminder: String
    let successMetric: String
}

struct DefaultSkillLibrary {

    static func skills(for category: TrainingCategoryType) -> [SkillTemplate] {
        switch category {
        case .obedience:    return obedienceSkills
        case .publicAccess: return publicAccessSkills
        case .task:         return taskSkills
        case .relationship: return relationshipSkills
        }
    }

    // MARK: - Basic Obedience

    static let obedienceSkills: [SkillTemplate] = [
        SkillTemplate(
            name: "Sit",
            category: .obedience,
            importance: .critical,
            environment: .home,
            howToReminder: "Ask once, wait 3 seconds, reward with treat or verbal 'yes!' at the hip crease on the way down.",
            successMetric: "Dog sits promptly on a single cue, 5/5 times with distractions."
        ),
        SkillTemplate(
            name: "Down",
            category: .obedience,
            importance: .critical,
            environment: .home,
            howToReminder: "Lure nose to floor with treat between paws. Mark the moment elbows touch. Keep sessions short — 3–5 reps.",
            successMetric: "Dog lies fully down within 2 seconds of cue, 5/5 times."
        ),
        SkillTemplate(
            name: "Stay",
            category: .obedience,
            importance: .critical,
            environment: .home,
            howToReminder: "Give cue, take one step back, return and reward before dog breaks. Build duration in 5-second increments.",
            successMetric: "Dog holds stay for the target duration without breaking, 4/5 times."
        ),
        SkillTemplate(
            name: "Recall (Come)",
            category: .obedience,
            importance: .critical,
            environment: .neighborhood,
            howToReminder: "Always make coming to you the best thing in the world. Say name + 'come', then back up to encourage momentum. High-value reward every time.",
            successMetric: "Dog comes reliably without repeated cuing, 5/5 times in various locations."
        ),
        SkillTemplate(
            name: "Heel / Loose-Leash Walking",
            category: .obedience,
            importance: .critical,
            environment: .neighborhood,
            howToReminder: "Mark and reward when dog's shoulder is at your hip with a loose leash. Stop when leash tightens — resume when dog returns to position.",
            successMetric: "Dog walks at heel for one full block without pulling."
        ),
        SkillTemplate(
            name: "Leave It",
            category: .obedience,
            importance: .standard,
            environment: .home,
            howToReminder: "Cover treat with hand. Wait for dog to stop trying. The moment they back off, mark and reward from other hand — never the covered treat.",
            successMetric: "Dog leaves food/object on single cue and looks to handler, 5/5 times."
        ),
        SkillTemplate(
            name: "Duration Down",
            category: .obedience,
            importance: .standard,
            environment: .home,
            howToReminder: "Ask for down, wait quietly, reward in position every 20–30 seconds. Build to 5 minutes before adding distance or duration.",
            successMetric: "Dog holds a down for the target duration without breaking or repositioning."
        ),
        SkillTemplate(
            name: "Distraction Proofing",
            category: .obedience,
            importance: .standard,
            environment: .neighborhood,
            howToReminder: "Practice known behaviors in increasingly distracting environments. Start below threshold. 'Below threshold' = dog notices but can still respond to cues.",
            successMetric: "Dog performs 3 known cues reliably in a moderately distracting environment."
        ),
        SkillTemplate(
            name: "Name Response",
            category: .obedience,
            importance: .critical,
            environment: .home,
            howToReminder: "Say dog's name once. The moment they orient toward you — mark and reward. Avoid repeating the name if no response. Reset and try again at closer range.",
            successMetric: "Dog orients immediately on name, 5/5 times with mild distraction."
        ),
    ]

    // MARK: - Public Access

    static let publicAccessSkills: [SkillTemplate] = [
        SkillTemplate(
            name: "Ignoring People",
            category: .publicAccess,
            importance: .critical,
            environment: .store,
            howToReminder: "Reward dog for choosing to look at you when people approach. Don't drill — just reinforce every offered check-in with a quiet 'yes' and treat.",
            successMetric: "Dog walks past 3 strangers without lunging, jumping, or soliciting petting."
        ),
        SkillTemplate(
            name: "Ignoring Other Dogs",
            category: .publicAccess,
            importance: .critical,
            environment: .neighborhood,
            howToReminder: "Start at a distance where dog notices but isn't reactive. Reward calm attention check-ins. Gradually decrease distance over sessions.",
            successMetric: "Dog passes another dog without barking or pulling, at 10 feet distance."
        ),
        SkillTemplate(
            name: "Restaurant Hold",
            category: .publicAccess,
            importance: .standard,
            environment: .fullPublic,
            howToReminder: "Practice duration down under tables at home first. Bring a mat or ask dog to hold under your chair. Reward quiet settled behavior every few minutes.",
            successMetric: "Dog holds a settle for 30+ minutes under a table without getting up."
        ),
        SkillTemplate(
            name: "Elevator Behavior",
            category: .publicAccess,
            importance: .standard,
            environment: .fullPublic,
            howToReminder: "Practice entering small spaces at home. Reward calm entry and exit. In real elevators, ask for sit or down and reward the whole ride.",
            successMetric: "Dog enters and exits elevator calmly without hesitation or anxiety signals."
        ),
        SkillTemplate(
            name: "Escalator Behavior",
            category: .publicAccess,
            importance: .standard,
            environment: .fullPublic,
            howToReminder: "Introduce moving surfaces (treadmill, skateboard, textured floor) at home first. Go slowly. Allow the dog to investigate. Never force.",
            successMetric: "Dog steps onto escalator without hesitation and exits calmly."
        ),
        SkillTemplate(
            name: "Crowded Space Navigation",
            category: .publicAccess,
            importance: .critical,
            environment: .fullPublic,
            howToReminder: "Start in low-traffic areas and build up gradually. Reward frequent attention checks. Practice weaving through empty chairs/objects at home.",
            successMetric: "Dog navigates a busy environment without losing focus, crowding, or shutting down."
        ),
        SkillTemplate(
            name: "Transition Practice",
            category: .publicAccess,
            importance: .standard,
            environment: .store,
            howToReminder: "Reward calm, deliberate movement from one environment to another — parking lot to store entry, store to car, etc.",
            successMetric: "Dog transitions between 3 environments in one outing without heightened reactivity."
        ),
        SkillTemplate(
            name: "Under/Beside Seat",
            category: .publicAccess,
            importance: .standard,
            environment: .fullPublic,
            howToReminder: "Teach 'under' as a behavior at home using a low table or chair. Reward dog for tucking fully under. Practice holds up to 20 minutes.",
            successMetric: "Dog tucks completely under/beside a seat and holds settle for 20+ minutes."
        ),
    ]

    // MARK: - Task Training

    static let taskSkills: [SkillTemplate] = [
        SkillTemplate(
            name: "Deep Pressure Therapy (DPT)",
            category: .task,
            importance: .critical,
            environment: .home,
            howToReminder: "Begin with dog placing chin or paw on your lap (lure and reward). Build duration before adding weight. Full DPT = dog lying across lap with sustained pressure.",
            successMetric: "Dog applies and holds pressure on cue for 2+ minutes without prompting."
        ),
        SkillTemplate(
            name: "Crowd Blocking",
            category: .task,
            importance: .critical,
            environment: .fullPublic,
            howToReminder: "Teach 'behind' (walking behind you), 'side' (pressing against your leg), and 'front' (standing in front to create distance). Use body language as cue.",
            successMetric: "Dog moves to blocking position on cue and holds for 30+ seconds in public."
        ),
        SkillTemplate(
            name: "Interrupt Repetitive Behavior",
            category: .task,
            importance: .critical,
            environment: .home,
            howToReminder: "Teach dog to nose-nudge or paw your hand. Shape the behavior using a target stick. Generalize from alert to actual interruption context.",
            successMetric: "Dog interrupts handler's behavior on cue or spontaneously, 3/5 natural occurrences."
        ),
        SkillTemplate(
            name: "Tethering / Grounding",
            category: .task,
            importance: .standard,
            environment: .home,
            howToReminder: "Dog lies across your feet or stays in body contact on cue. Reward sustained contact. Use 'anchor' or 'ground' as a verbal cue.",
            successMetric: "Dog holds grounding position for 5+ minutes on cue."
        ),
        SkillTemplate(
            name: "Wake Handler",
            category: .task,
            importance: .standard,
            environment: .home,
            howToReminder: "Start from sit: cue 'wake up' and reward dog for nudging your arm or face. Transition to waking from a lying position. Avoid full jumping.",
            successMetric: "Dog wakes handler reliably on cue without jumping or over-excitement."
        ),
        SkillTemplate(
            name: "Custom Medical Alert",
            category: .task,
            importance: .critical,
            environment: .home,
            howToReminder: "Work with your trainer on scent or behavioral alert specific to your medical condition. Document the alert behavior and cue words in your notes.",
            successMetric: "Defined by your trainer. Track repetitions and accuracy over sessions."
        ),
    ]

    // MARK: - Relationship / Play

    static let relationshipSkills: [SkillTemplate] = [
        SkillTemplate(
            name: "Free Play",
            category: .relationship,
            importance: .low,
            environment: .home,
            howToReminder: "Let the dog choose the game. Follow their lead. No cues, no expectations — just play. This builds trust and joy.",
            successMetric: "Dog is relaxed, engaged, and showing play signals. You feel better too."
        ),
        SkillTemplate(
            name: "Grooming Practice",
            category: .relationship,
            importance: .standard,
            environment: .home,
            howToReminder: "Pair brush/nail tools with high-value treats. Work slowly, stop before dog shows stress. Build tolerance in 1-minute sessions.",
            successMetric: "Dog tolerates full grooming session without stress behaviors (panting, whale eye, shaking off)."
        ),
        SkillTemplate(
            name: "Trick Enrichment",
            category: .relationship,
            importance: .low,
            environment: .home,
            howToReminder: "Pick one fun trick: spin, wave, roll over, bow. Use shaping (reward successive approximations) rather than luring. Keep it light and fun.",
            successMetric: "Dog performs new trick reliably on cue and visibly enjoys the session."
        ),
        SkillTemplate(
            name: "Calm Sniffing Walk",
            category: .relationship,
            importance: .standard,
            environment: .neighborhood,
            howToReminder: "Use a long line if possible. Let the dog choose direction and pace. This is decompression — not heel practice. Sniffing = mental enrichment.",
            successMetric: "Dog returns relaxed and calm after 15+ minutes of sniff-led walking."
        ),
        SkillTemplate(
            name: "Settle / Chill",
            category: .relationship,
            importance: .standard,
            environment: .home,
            howToReminder: "Not a 'stay' — this is voluntary relaxation. Set up comfortable space, reward dog for offering relaxation behavior like chin resting or sighing.",
            successMetric: "Dog settles independently in a designated spot for 20+ minutes with no prompting."
        ),
        SkillTemplate(
            name: "Handler Connection Check-In",
            category: .relationship,
            importance: .standard,
            environment: .home,
            howToReminder: "Daily 5-minute session: sit quietly with your dog. No phone, no training. Note how your dog is doing emotionally and physically. Journal if helpful.",
            successMetric: "You completed the check-in and noticed something new about your dog."
        ),
    ]
}
