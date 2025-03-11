//
//  HapticManager.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/1/25.
//

import Foundation
import SwiftUI


class HapticsManager {
    
    static private let hapticFeedbackGenerator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        hapticFeedbackGenerator.notificationOccurred(type)
    
    }
}
