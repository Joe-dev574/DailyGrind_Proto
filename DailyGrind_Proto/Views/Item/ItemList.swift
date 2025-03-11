//
//  ItemList.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData


struct ItemList: View {
    @Environment(\.modelContext) private var context
    @Query private var items: [Item]
    @State private var activeTab: Category = .today
    // Computed property to filter and sort items based on the active tab
    private var filteredItems: [Item] {
        switch activeTab {
        case .events:
            return items.filter { $0.category == "Events" }.sorted { $0.dateDue < $1.dateDue }
        case .work:
            return items.filter { $0.category == "Work" }.sorted { $0.title < $1.title }
        case .today:
            return items.filter { $0.category == "Today" }.sorted { $0.dateAdded < $1.dateAdded }
        case .family:
            return items.filter { $0.category == "Family"  }.sorted { $0.dateAdded < $1.dateDue }
        case .health:
            return items.filter { $0.category == "Health" }.sorted { $0.dateAdded < $1.dateDue }
        }
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                CustomTabBar(activeTab: $activeTab)
                LazyVStack {
                    Text(activeTab.rawValue + (activeTab == .events ? " Thou Shalt Not Forget! " : " Focus"))
                        .font(.title3)
                        .foregroundColor(.mediumGrey)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(filteredItems) { item in
                        NavigationLink{
                            ItemEditView(editItem: item)
                        } label: {
                            ItemCardView(item: item)
                                .padding(.horizontal, 12)
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    ItemList()
}


