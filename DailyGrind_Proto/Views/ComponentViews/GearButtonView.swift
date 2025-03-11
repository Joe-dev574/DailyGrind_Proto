//
//  ItemScreenLogoView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/28/25.
//

import SwiftUI

/// A standalone animated gear icon that becomes a settings button after animation.
struct GearButtonView: View {
    // MARK: - Animation States
    
    /// The rotation angle of the gear in degrees
    @State private var rotationAngle: Double = 0.0
    
    /// The opacity level of the gear
    @State private var gearOpacity: Double = Constants.initialGearOpacity
    
    /// The scale factor for the gear's pulse animation
    @State private var gearScale: Double = 1.0
    
    /// The intensity of the gear's glow effect
    @State private var glowIntensity: Double = 0.3
    
    /// Tracks whether the initial animation has completed
    @State private var isAnimationComplete: Bool = false
    
    // MARK: - Environment
    
    /// Detects the current color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Properties
    
    /// Action to perform when the button is tapped
   @State private var showSettings: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            if isAnimationComplete {
                HapticsManager.notification(type: .success)
                showSettings = true
            }
        }) {
            Image(systemName: "gearshape.2.fill")
                .resizable()
                .frame(width: Constants.gearSize, height: Constants.gearSize)
                .foregroundStyle(
                    LinearGradient(
                        colors: gearGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(gearOpacity)
                .rotationEffect(.degrees(rotationAngle))
                .scaleEffect(gearScale)
                .shadow(color: glowColor, radius: 5, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(glowColor, lineWidth: 1)
                        .scaleEffect(gearScale * 1.2)
                        .opacity(glowIntensity)
                        .shadow(color: .black, radius: 3, x: 2, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())  // Removes default button styling
        .frame(maxHeight: Constants.maxHeight)
        .background(backgroundOverlay)
        .onAppear(perform: startAnimation)
        .accessibilityLabel("Settings gear button")
        .disabled(!isAnimationComplete)  // Button is inactive during animation
        .sheet(isPresented: $showSettings) {
            SettingsView( )
        }
    }
    
    // MARK: - Adaptive Styling
    
    /// Gradient colors for the gear, adjusted for color scheme
    private var gearGradientColors: [Color] {
        colorScheme == .dark
            ? [.cyan.opacity(0.9), .purple.opacity(0.7)]
            : [.blue.opacity(0.9), .cyan.opacity(0.7)]
    }
    
    /// Glow color that adapts to the color scheme
    private var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(glowIntensity) : .blue.opacity(glowIntensity)
    }
    
    /// Shadow color with mode-appropriate opacity
    private var shadowColor: Color {
        colorScheme == .dark ? .gray.opacity(0.5) : .gray.opacity(0.2)
    }
    
    /// Background overlay for contrast enhancement
    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
            .shadow(color: shadowColor, radius: 4)
    }
    
    // MARK: - Constants
    
    /// Static values used throughout the view
    private enum Constants {
        static let gearSize: CGFloat = 30           // Size of the gear icon
        static let initialGearOpacity: Double = 1.0 // Starting opacity
        static let finalGearOpacity: Double = 0.85  // Ending opacity after fade
        static let fastDuration: Double = 0.6       // Duration of initial spin
        static let slowDuration: Double = 0.4       // Duration of settle animation
        static let fadeDuration: Double = 0.25      // Duration of final fade
        static let pulseDuration: Double = 1.0      // Duration of continuous pulse
        static let fastRotations: Double = 3        // Number of full spins
        static let maxHeight: CGFloat = 40          // Maximum height of the button
    }
    
    // MARK: - Animation
    
    /// Orchestrates the gear's animation sequence and enables the button
    private func startAnimation() {
        // 1. Initial fast spin and scale up with glow
        withAnimation(.easeInOut(duration: Constants.fastDuration)) {
            rotationAngle = 360 * Constants.fastRotations
            gearScale = 1.15
            glowIntensity = 0.5
        }
        
        // 2. Bounce and settle with spring effect
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration) {
            withAnimation(.spring(response: Constants.slowDuration, dampingFraction: 0.7)) {
                rotationAngle = 360 * Constants.fastRotations + 30
                gearScale = 0.95
                glowIntensity = 0.3
            }
        }
        
        // 3. Final settle with fade
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeInOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity
                gearScale = 1.0
            }
        }
        
        // 4. Continuous subtle pulse with glow, enable button
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            isAnimationComplete = true  // Button becomes active
            withAnimation(.easeInOut(duration: Constants.pulseDuration).repeatForever(autoreverses: true)) {
                gearScale = 1.05
                glowIntensity = 0.4
            }
        }
    }
}

// MARK: - Preview

/// Previews the gear button in both light and dark modes
#Preview {
    VStack {
        GearButtonView()
        .preferredColorScheme(.light)
        
        GearButtonView()
        .preferredColorScheme(.dark)
   
}
}
