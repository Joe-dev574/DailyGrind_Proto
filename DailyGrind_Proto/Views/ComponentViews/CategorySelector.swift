//
//  CustomCatagorySelector.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftUI

/// A view that displays a grid of category selection buttons
struct CategorySelector: View {
    // MARK: - Properties
    
    /// The currently selected category, bound to parent view
    @Binding var selectedCategory: Category
    
    /// The color used for animation, bound to parent view
    @Binding var animateColor: Color
    
    /// Controls the animation state, bound to parent view
    @Binding var animate: Bool
    
    // MARK: - Body
    
    var body: some View {
        // Creates a vertical grid with 3 flexible columns
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3),
            spacing: 15
        ) {
            // Iterate through all possible Category cases
            ForEach(Category.allCases, id: \.rawValue) { category in
                CategoryButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    onTap: {
                        // Prevent interaction during animation
                        guard !animate else { return }
                        
                        // Set the animation color to the category's color
                        animateColor = category.color
                        
                        // Start animation with spring effect
                        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 1)) {
                            animate = true
                        }
                        
                        // Reset animation and update selection after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animate = false
                            selectedCategory = category
                        }
                    }
                )
            }
        }
    }
}
// MARK: - Preview

/// Preview provider for CategorySelector
struct CategorySelector_Previews: PreviewProvider {
    @State static var selectedCategory = Category.today
    @State static var animateColor = Color.red
    @State static var animate = false
    
    static var previews: some View {
        CategorySelector(
            selectedCategory: $selectedCategory,
            animateColor: $animateColor,
            animate: $animate
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
