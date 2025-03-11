//
//  TaskCategory.swift
//  TaskPlanner
//
//  Created by Balaji on 04/01/23.
//
import SwiftData
import SwiftUI

/// Represents different life domains and priority categories with associated styling
enum Category: String, CaseIterable {
    // MARK: - Life Domain Cases
    
    /// Represents tasks or focus for the current day
    case today = "Today"
    
    /// Represents family-related tasks and priorities
    case family = "Family"
    
    /// Represents health, both mental and physical, as well as wellness activities
    case health = "Health"
    
    /// Represents work-related tasks and obligations
    case work = "Work"
    
    // MARK: - Priority/Time-based Cases
    
    /// Represents scheduled or recurring tasks
    case events = "Events"
    
    // MARK: - Computed Properties
    
    /// Returns a color associated with each category for visual distinction
    var color: Color {
        switch self {
        case .family:
            return .green // Green for family-related items
        case .events:
            return .orange // Orange for events tasks
        case .work:
            return .blue // Blue for work items
        case .today:
            return .oliveDrab // System gray color for current day
        case .health:
            return .red // Red for health-related items
        }
    }
    
    /// Returns a system symbol image for each category
    var symbolImage: String {
        switch self {
        // Time-Based Symbols
        case .today:
            return "alarm" // Clock symbol for daily tasks
                    
        case .work:
            return "calendar.and.person" // Calendar with person for work
            
        // Status-Based Symbols
        case .events:
            return "repeat" // Repeat symbol for events tasks
            
        case .family:
            return "figure.2.and.child.holdinghands" // Family symbol
            
        case .health:
            return "heart.rectangle" // Heart in rectangle for health
        }
    }
}
