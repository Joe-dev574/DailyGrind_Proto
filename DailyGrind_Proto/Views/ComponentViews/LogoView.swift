//
//  LogoView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//


import SwiftUI

/// A dynamic logo view featuring an animated gear and text, optimized for both light and dark modes.
struct LogoView: View {
    // MARK: - Animation States
    
    /// The rotation angle of the gear in degrees
    @State private var rotationAngle: Double = 0.0
    
    /// The opacity level of the gear
    @State private var gearOpacity: Double = Constants.initialGearOpacity
    
    /// The scale factor for the gear's pulse animation
    @State private var gearScale: Double = 1.0
    
    /// The vertical offset for text bounce animation
    @State private var textOffset: CGFloat = 0.0
    
    /// The intensity of the gear's glow effect
    @State private var glowIntensity: Double = 0.3
    
    // MARK: - Environment
    
    /// Detects the current color scheme (light or dark)
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Constants.spacing) {
            // Gear icon with animation and glow effects
            Image(systemName: "gearshape.2.fill")  // More detailed gear design
                .resizable()
                .frame(width: Constants.gearSize, height: Constants.gearSize)
                .foregroundStyle(
                    LinearGradient(
                        colors: gearGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(gearOpacity)  // Fades during animation
                .rotationEffect(.degrees(rotationAngle))  // Spins on appear
                .scaleEffect(gearScale)  // Pulses continuously
                .shadow(color: glowColor, radius: 5, x: 0, y: 2)  // Adds depth
                .overlay(
                    Circle()
                        .stroke(glowColor, lineWidth: 1)
                        .scaleEffect(gearScale * 1.2)
                        .opacity(glowIntensity)  // Pulsing glow ring
                )
                .onAppear(perform: startAnimation)  // Triggers animation sequence
                .accessibilityLabel("Animated gear icon")
            
            // Text group with dynamic styling
            HStack(spacing: Constants.textSpacing) {
                Text("Domain")
                    .font(.custom("Avenir-Heavy", size: 18))  // Bold, custom font
                    .foregroundStyle(textGradient)
                    .offset(y: textOffset)  // Bounces up
                
                Text("Track")
                    .font(.custom("Avenir-Black", size: 18))  // Extra bold
                    .foregroundStyle(textGradient)
                    .offset(y: -textOffset)  // Bounces down
                
                Text("1.0")
                    .font(.custom("Avenir-Medium", size: 14))  // Lighter weight for version
                    .foregroundStyle(versionColor)
                    .rotationEffect(.degrees(15))  // Slight tilt for flair
                    .offset(x: 2)  // Slight horizontal shift
            }
            .shadow(color: shadowColor, radius: 2)  // Subtle text shadow
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Domain Track version 1.0")
        }
        .padding(.vertical, 8)  // Adds vertical breathing room
        .frame(maxHeight: Constants.maxHeight)  // Constrains height
        .background(backgroundOverlay)  // Subtle backdrop
    }
    
    // MARK: - Adaptive Styling
    
    /// Gradient colors for the gear, adjusted for color scheme
    private var gearGradientColors: [Color] {
        colorScheme == .dark
            ? [.cyan.opacity(0.9), .purple.opacity(0.7)]  // Vibrant dark mode
            : [.blue.opacity(0.9), .cyan.opacity(0.7)]    // Softer light mode
    }
    
    /// Gradient for text, optimized for readability
    private var textGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [.white.opacity(0.9), .gray.opacity(0.7)]  // High contrast
                : [.black.opacity(0.9), .gray.opacity(0.8)], // Subtle in light
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Color for the version number, mode-specific
    private var versionColor: Color {
        colorScheme == .dark ? .yellow.opacity(0.9) : .orange.opacity(0.9)
    }
    
    /// Glow color that adapts to the color scheme
    private var glowColor: Color {
        colorScheme == .dark ? .cyan.opacity(glowIntensity) : .blue.opacity(glowIntensity)
    }
    
    /// Shadow color with mode-appropriate opacity
    private var shadowColor: Color {
        colorScheme == .dark ? .gray.opacity(0.4) : .gray.opacity(0.2)
    }
    
    /// Background overlay for contrast enhancement
    private var backgroundOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white.opacity(0.2))
            .shadow(color: shadowColor, radius: 3)
    }
    
    // MARK: - Constants
    
    /// Static values used throughout the view
    private enum Constants {
        static let gearSize: CGFloat = 32           // Size of the gear icon
        static let initialGearOpacity: Double = 1.0 // Starting opacity
        static let finalGearOpacity: Double = 0.85  // Ending opacity after fade
        static let spacing: CGFloat = 6             // Space between gear and text
        static let textSpacing: CGFloat = 3         // Space between text elements
        static let fastDuration: Double = 0.6       // Duration of initial spin
        static let slowDuration: Double = 0.4       // Duration of settle animation
        static let fadeDuration: Double = 0.25      // Duration of final fade
        static let pulseDuration: Double = 1.0      // Duration of continuous pulse
        static let fastRotations: Double = 3        // Number of full spins
        static let maxHeight: CGFloat = 45          // Maximum height of the logo
    }
    
    // MARK: - Animation
    
    /// Orchestrates the logo's animation sequence
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
                rotationAngle = 360 * Constants.fastRotations + 30  // Final angle
                gearScale = 0.95  // Slight shrink
                textOffset = 3    // Text bounce peak
                glowIntensity = 0.3
            }
        }
        
        // 3. Final settle with fade
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration) {
            withAnimation(.easeInOut(duration: Constants.fadeDuration)) {
                gearOpacity = Constants.finalGearOpacity
                gearScale = 1.0    // Normal size
                textOffset = 0     // Text returns to center
            }
        }
        
        // 4. Continuous subtle pulse with glow
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.fastDuration + Constants.slowDuration + Constants.fadeDuration) {
            withAnimation(.easeInOut(duration: Constants.pulseDuration).repeatForever(autoreverses: true)) {
                gearScale = 1.05    // Slight pulse
                glowIntensity = 0.4 // Glow oscillates
            }
        }
    }
}

// MARK: - Preview

/// Previews the logo in both light and dark modes
#Preview {
    VStack {
        LogoView()
            .preferredColorScheme(.light)
        LogoView()
            .preferredColorScheme(.dark)
    }
    .padding()
    .background(Color(.systemBackground))
}
