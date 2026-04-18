// DogProfileView.swift
// Train Today — Dog Profile Edit Screen
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI
import SwiftData
import PhotosUI

struct DogProfileView: View {

    @Query private var profiles: [DogProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var ageYears: Int = 0
    @State private var ageMonths: Int = 0
    @State private var isProgramDog: Bool = false
    @State private var handlerNotes: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var isSaved: Bool = false

    private var profile: DogProfile? { profiles.first }

    var body: some View {
        ZStack {
            Color.ttBackground.ignoresSafeArea()

            Form {
                // Profile photo
                Section {
                    photoSection
                }
                .listRowBackground(Color.ttSurface)

                // Dog info
                Section("Dog Information") {
                    TextField("Dog's name", text: $name)
                    TextField("Breed", text: $breed)

                    HStack {
                        Text("Age")
                            .foregroundColor(.ttText)
                        Spacer()
                        Stepper("\(ageYears) yr", value: $ageYears, in: 0...20)
                            .labelsHidden()
                        Text("\(ageYears) yr")
                            .font(TTFont.bodySmall)
                            .foregroundColor(.ttTextSecondary)
                            .frame(width: 40, alignment: .center)
                        Stepper("\(ageMonths) mo", value: $ageMonths, in: 0...11)
                            .labelsHidden()
                        Text("\(ageMonths) mo")
                            .font(TTFont.bodySmall)
                            .foregroundColor(.ttTextSecondary)
                            .frame(width: 40, alignment: .center)
                    }

                    Toggle("Program Dog", isOn: $isProgramDog)
                        .tint(.ttPrimaryInteractive)
                }
                .listRowBackground(Color.ttSurface)

                // Handler notes
                Section("Handler Notes") {
                    Text("Physical limitations, sensitivities, or context the app should respect.")
                        .font(TTFont.caption)
                        .foregroundColor(.ttTextSecondary)
                    TextEditor(text: $handlerNotes)
                        .font(TTFont.body)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                }
                .listRowBackground(Color.ttSurface)

                // Save
                Section {
                    Button {
                        saveProfile()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isSaved ? "✓ Saved" : "Save Changes")
                                .font(TTFont.headline)
                                .foregroundColor(isSaved ? .ttSuccess : .ttPrimaryInteractive)
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.ttSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttBackground)
        }
        .navigationTitle("Dog Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { populateFields() }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        HStack {
            Spacer()
            VStack(spacing: TTSpacing.xs) {
                Group {
                    if let data = photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.ttTextSecondary)
                    }
                }
                .frame(width: 100, height: 100)
                .background(Color.ttSecondaryLight)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.ttPrimary.opacity(0.3), lineWidth: 2))

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Text("Change Photo")
                        .font(TTFont.caption)
                        .foregroundColor(.ttPrimaryInteractive)
                }
            }
            Spacer()
        }
    }

    // MARK: - Helpers

    private func populateFields() {
        guard let p = profile else { return }
        name          = p.name
        breed         = p.breed
        ageYears      = p.ageYears
        ageMonths     = p.ageMonths
        isProgramDog  = p.isProgramDog
        handlerNotes  = p.handlerNotes
        photoData     = p.photoData
    }

    private func saveProfile() {
        if let p = profile {
            p.name         = name
            p.breed        = breed
            p.ageYears     = ageYears
            p.ageMonths    = ageMonths
            p.isProgramDog = isProgramDog
            p.handlerNotes = handlerNotes
            p.photoData    = photoData
        } else {
            let newProfile = DogProfile(
                name: name,
                breed: breed,
                ageYears: ageYears,
                ageMonths: ageMonths,
                isProgramDog: isProgramDog,
                handlerNotes: handlerNotes,
                hasCompletedOnboarding: true,
                photoData: photoData
            )
            modelContext.insert(newProfile)
        }
        try? modelContext.save()
        withAnimation { isSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isSaved = false
        }
    }
}
