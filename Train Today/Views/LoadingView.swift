// LoadingView.swift
// Train Today — App Launch Screen
// Developed by Tara Knight | @Hopetheservicedoodle

import SwiftUI

struct LoadingView: View {

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pawOpacity: Double = 0
    @State private var pawScale: Double = 0.8

    var body: some View {
        ZStack {
            Color.ttBackground
                .ignoresSafeArea()

            VStack(spacing: TTSpacing.lg) {

                // Paw print icon
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 56, weight: .regular))
                    .foregroundColor(TTColor.primaryInteractive)
                    .opacity(pawOpacity)
                    .scaleEffect(pawScale)

                // App name + tagline
                VStack(spacing: TTSpacing.xs) {
                    Text("Train Today")
                        .font(TTFont.display)
                        .foregroundColor(TTColor.text)

                    Text("Open the app. Get a plan. Train.")
                        .font(TTFont.caption)
                        .foregroundColor(TTColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(pawOpacity)

                // Spinner
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: TTColor.primaryInteractive))
                    .scaleEffect(1.2)
                    .padding(.top, TTSpacing.sm)
                    .opacity(pawOpacity)
            }
        }
        .onAppear {
            guard !reduceMotion else {
                pawOpacity = 1
                pawScale = 1
                return
            }
            withAnimation(.easeOut(duration: 0.5)) {
                pawOpacity = 1
                pawScale = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
