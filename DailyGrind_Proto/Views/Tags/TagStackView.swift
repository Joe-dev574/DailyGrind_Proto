//
//  TagStackView.swift
//  Flow
//
//  Created by Joseph DeWeese on 2/3/25.
//

import SwiftUI

struct TagsStackView: View {
    var tags: [Tag]
    var body: some View {
        HStack {
            ForEach(tags.sorted(using: KeyPathComparator(\Tag.name))) { tag in
                Image(systemName: "tag.fill")
                    .foregroundStyle(tag.hexColor)
                    .offset(x: 7)
                Text(tag.name)
                    .fontDesign(.serif)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }.padding(5)
    }
}
#Preview {
    TagsStackView(tags: [])
}
