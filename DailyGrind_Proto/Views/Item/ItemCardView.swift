//
//  ItemCardView.swift
//  Flow
//
//  Created by Joseph DeWeese on 1/31/25.
//

import SwiftUI
import SwiftData


/// A view that displays a card representation of an Item with its details
struct ItemCardView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var context
    let item: Item                 // The item to display
    
    // Computed property to map the item's category string to a Category enum
    private var category: Category {
        Category(rawValue: item.category) ?? .today
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            SwipeAction(cornerRadius: 10, direction: .trailing) {
                ZStack {
                    // Background with material effect
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Main content stack
                    VStack(alignment: .leading, spacing: 10) {
                        
                        // Category header
                        HStack(spacing: 12) {
                            Spacer()
                            Text(item.category)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .background(category.color.opacity(0.8))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        }
                        
                        // Title section with category image
                        HStack(spacing: 10) {
                            Image(systemName: category.symbolImage)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(category.color.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                                .padding(.trailing, 2)
                            
                            Text(item.title)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(category.color)
                                .lineLimit(1)
                        }
                        
                        // Dates section (optional rendering)
                        VStack(alignment: .leading, spacing: 4) {
                            if item.dateAdded != .distantPast {
                                HStack(spacing: 4) {
                                    Text("Added:")
                                        .foregroundStyle(.gray)
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.gray)
                                    Text(item.dateAdded, format: .dateTime.day().month().year())
                                        .foregroundStyle(.gray)
                                }
                            }
                            if item.dateDue != .distantPast {
                                HStack(spacing: 4) {
                                    Text("Due:")
                                        .foregroundStyle(.gray)
                                    Image(systemName: "clock")
                                        .foregroundStyle(.gray)
                                    Text(item.dateDue, format: .dateTime.day().month().year())
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 4)
                        
                        // Remarks section (shown only if not empty)
                        if !item.remarks.isEmpty {
                            Text(item.remarks)
                                .font(.system(size: 14, weight: .regular, design: .serif)) // Standardized to serif
                                .foregroundStyle(.primary) // Matches dates section
                                .padding(.horizontal, 4)
                                .lineLimit(3)
                                .padding(.bottom, 4)
                        }
                        if let tags = item.tags {
                            ViewThatFits {
                                TagsStackView(tags: tags)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    TagsStackView(tags: tags)
                                }
                            }
                        }
                    }
                }.padding(7)
                // Card border overlay
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            .linearGradient(
                                colors: [.gray.opacity(0.8), category.color.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            }actions: {
                Action(tint: .red, icon: "trash", action: {
                    context.delete(item)
                    //WidgetCentrer.shared.reloadAllTimneLines
                })
            }
        }
    }
}
