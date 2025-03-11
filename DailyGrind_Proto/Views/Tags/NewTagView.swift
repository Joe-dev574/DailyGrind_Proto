//
//  NewTagView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/27/25.
//

import SwiftData
import SwiftUI

struct NewTagView: View {
    @State private var name = ""
    @State private var tagColor = Color.red
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("name", text: $name)
                ColorPicker("Set the tag color", selection: $tagColor, supportsOpacity: false)
                Button("Create") {
                    let newTag = Tag(name: name, tagColor: tagColor.toHexString()!)
                    context.insert(newTag)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .disabled(name.isEmpty)
            }
            .padding()
            .navigationTitle("New Genre")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NewTagView()
}
