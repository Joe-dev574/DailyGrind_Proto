//
//  CustomTabBar.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftUI
import SwiftData

/// A custom tab bar view that displays category tabs with dynamic styling
struct CustomTabBar: View {
    // MARK: - Properties
    
    /// The currently selected tab, bound to parent view's state
    @Binding var activeTab: Category
    
    /// Environment variable to detect current color scheme (light/dark mode)
    @Environment(\.colorScheme) private var scheme
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate available width for tab offset animation
            let size = geometry.size
            let allOffset = size.width - (8 * CGFloat(Category.allCases.count - 1))
            
            HStack(spacing: 5) {
                // Container for regular tabs (excluding events)
                HStack(spacing: activeTab == .events ? -15 : 8) {
                    ForEach(Category.allCases.filter { $0 != .events }, id: \.rawValue) { tab in
                        ResizableTabButton(tab: tab)
                    }
                }
                
                // Display scheduled tab only when it's active
                if activeTab == .events {
                    ResizableTabButton(tab: .events)
                        .transition(.offset(x: allOffset)) // Animate events tab appearance
                }
            }
            .padding(.horizontal, 10) // Horizontal padding for the entire tab bar
        }
        .frame(height: 40) // Fixed height for the tab bar
    }
    
    // MARK: - Helper Views
    
    /// Creates a resizable tab button with dynamic appearance based on selection state
    @ViewBuilder
    private func ResizableTabButton(tab: Category) -> some View {
        HStack(spacing: 5) {
            // Tab icon with filled/unfilled states based on selection
            Image(systemName: tab.symbolImage)
                .opacity(activeTab != tab ? 1 : 0)
                .overlay {
                    Image(systemName: tab.symbolImage)
                        .symbolVariant(.fill)
                        .opacity(activeTab == tab ? 1 : 0)
                }
            
            // Show tab taskName only when tab is active
            if activeTab == tab {
                Text(tab.rawValue)
                    .font(.callout)
                    .fontDesign(.serif)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(tab == .events ? schemeColor : activeTab == tab ? .white : .gray)
        .frame(maxHeight: .infinity) // Fill available height
        .frame(maxWidth: activeTab == tab ? .infinity : nil) // Expand width when active
        .padding(.horizontal, activeTab == tab ? 10 : 15) // Dynamic padding based on state
        .background {
            // Background color changes based on selection
            Rectangle()
                .fill(activeTab == tab ? tab.color : .inActiveTab)
        }
        .clipShape(.rect(cornerRadius: 10, style: .circular)) // Rounded corners
        .background {
            // Border effect with dynamic padding
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.background)
                .padding(activeTab == .events && tab != .events ? -3 : 3)
        }
        .contentShape(.rect) // Ensure entire area is tappable
        .onTapGesture {
            // Handle tab selection with animation
            // Double tap on active tab switches to events tab
            guard tab != .events else { return }
            withAnimation(.bouncy) {
                activeTab = activeTab == tab ? .events : tab
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Returns appropriate color based on current color scheme
    private var schemeColor: Color {
        scheme == .dark ? .black : .white
    }
}

// MARK: - Preview (Optional)
#if DEBUG
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(activeTab: .constant(.events))
    }
}
#endif
