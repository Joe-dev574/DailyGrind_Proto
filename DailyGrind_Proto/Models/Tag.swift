//
//  Tag.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/2/25.
//

import SwiftUI
import SwiftData

@Model
class Tag {
    var name: String = ""
    var tagColor: String = "FF0000"
    var items: [Item]?
    
    init(name: String, tagColor: String) {
        self.name = name
        self.tagColor = tagColor
    }
    
    var hexColor: Color {
        Color(hex: self.tagColor) ?? .orange
    }
}
