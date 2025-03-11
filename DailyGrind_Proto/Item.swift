//
//  Item.swift
//  DailyGrind_Proto
//
//  Created by Joseph DeWeese on 3/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
