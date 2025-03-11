//
//  CategoryButton.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftUI

struct CategoryButton: View {
    
    let category: Category
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack{
            Text(category.rawValue.uppercased())
                .font(.system(size: 14))
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(category.color.opacity(isSelected ? 0.8 : 0.25).gradient)
                )
                .padding(4)
                .foregroundStyle(isSelected ? .white : .secondary)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(.remark, lineWidth: isSelected ? 3 : 0)
                )
                .onTapGesture(perform: onTap)
        }
    }
}
