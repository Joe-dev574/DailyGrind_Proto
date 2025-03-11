//
//  TagView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/27/25.
//

import SwiftUI
import SwiftData


struct TagView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var item: Item
    @Query(sort: \Tag.name) var tags: [Tag]
    @State private var newTag = false
    var body: some View {
        NavigationStack {
            Group{
                if tags.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "tag.fill")
                            .font(.largeTitle)
                    } description: {
                        Text("Create a tag for some focus and organization.")
                            .fontDesign(.serif)
                    } actions: {
                        Button("Create Tag") {
                            newTag.toggle()
                        }
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(tags) { tag in
                            HStack {
                                if let itemTag = item.tags {
                                    if itemTag.isEmpty {
                                        Button {
                                            addRemove(tag)
                                        } label: {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.primary)
                                        }
                                       
                                    } else {
                                        Button {
                                            addRemove(tag)
                                        } label: {
                                            Image(systemName: itemTag.contains(tag) ? "circle.fill" : "circle")
                                        }
                                        .foregroundStyle(tag.hexColor)
                                    }
                                }
                                Text(tag.name)
                            }
                        }
                        .onDelete(perform: { indexSet in
                            indexSet.forEach { index in
                                if let itemTags = item.tags,
                                   itemTags.contains(tags[index]),
                                   let itemTagIndex = itemTags.firstIndex(where: {$0.id == tags[index].id}) {
                                    item.tags?.remove(at: itemTagIndex)
                                }
                                context.delete(tags[index])
                            }
                        })
                        LabeledContent {
                            Button {
                                newTag.toggle()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(.white)
                            }
                            .buttonStyle(.borderedProminent)
                        } label: {
                            Text("Create new Tag")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .sheet(isPresented: $newTag) {
                NewTagView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func addRemove(_ tag: Tag) {
        if let itemTags = item.tags {
            if itemTags.isEmpty {
                item.tags?.append(tag)
            } else {
                if itemTags.contains(tag),
                   let index = itemTags.firstIndex(where: {$0.id == tag.id}) {
                    item.tags?.remove(at: index)
                } else {
                    item.tags?.append(tag)
                }
            }
        }
    }
}

#Preview {
    TagView(item: Item(category: .family, tintColor: TintColor.init(color: "Red", value: .red)))
   
}
