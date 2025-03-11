//
//  CustomTextEditor.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftUI

// A custom text editor component with placeholder support and styling
struct CustomTextEditor: View {
    // MARK: - Properties
    @Binding var remarks: String    // Two-way binding to the text content
    let placeholder: String         // Text to show when editor is empty
    let minHeight: CGFloat          // Minimum height of the text editor
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {    // Stack for overlaying placeholder and editor
            // Placeholder text shown when taskDescription is empty
            if remarks.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)    // Muted color for placeholder
                    .padding(.top, 8)              // Align with TextEditor padding
                    .padding(.leading, 4)          // Slight left padding
            }
            
            // Main text editor component
            TextEditor(text: $remarks)
                .scrollContentBackground(.hidden)    // Removes default background
 //               .background(.background.opacity(0.4)) // Custom subtle background
                .font(.system(size: 16))             // Set font size
                .fontDesign(.serif)                  // Use serif font style
                .frame(minHeight: minHeight)         // Enforce minimum height
                .foregroundStyle(.primary)         // Text color
                .padding(.horizontal, 4)
                .padding(.horizontal,8)
                .overlay(                            // Border overlay
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.lightGrey, lineWidth: 2)
                       
                )
        }
    }
}

// MARK: - Preview
#Preview {
    // Preview with sample data
    CustomTextEditor(
        remarks: .constant(""),    // Binding to empty string
        placeholder: "Enter your text here...",
        minHeight: 100
    )
}
