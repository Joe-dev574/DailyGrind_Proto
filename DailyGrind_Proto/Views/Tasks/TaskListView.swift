//
//  TaskList.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/7/25.
//
import SwiftUI
import SwiftData




struct TaskListView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Binding var itemTasks: [ItemTask] // Binding to the item's tasks
    @State private var showingAddTask = false
    @State private var taskToEdit: ItemTask?
    @State private var itemCategory: Category
    @State private var taskListHeight: CGFloat = 0

    // MARK: - Section Styling Configuration
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 10  // Corner radius for sections
        static let padding: CGFloat = 16  // Padding for sections
        static let backgroundOpacity: Double = 0.01  // Base background opacity
        static let reducedOpacity: Double = backgroundOpacity * 0.30  // Reduced opacity for layering
    }
   
    // MARK: - Initialization
    init(itemTasks: Binding<[ItemTask]>, itemCategory: Category) {
        self._itemTasks = itemTasks
        self._itemCategory = State(initialValue: itemCategory)
    }
    // MARK: - Preference Key for Height Measurement
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with "Tasks" title and Add Task button
            HStack {
                Text("Tasks")
                    .foregroundStyle(itemCategory.color)
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    taskToEdit = nil
                    showingAddTask = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(itemCategory.color)
                        .padding()
                        .background(itemCategory.color.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Add Task")
                .accessibilityHint("Tap to add a new task to this item")
            }

            // Content based on whether there are tasks
            if itemTasks.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("Task bin is empty", systemImage: "list.bullet.rectangle")
                            .foregroundStyle(.gray)
                    },
                    description: {
                        Text("Add a new task by tapping the plus (+) button above.")
                            .foregroundStyle(.gray)
                    }
                    )
            } else {
                List {
                    ForEach(itemTasks.indices, id: \.self) { index in
                        TaskRowView(itemTask: itemTasks[index]) { event in
                            handleTaskRowEvent(event, for: itemTasks[index])
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(.clear))
                        .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14))
                        .swipeActions(edge: .leading) {
                            Button {
                                taskToEdit = itemTasks[index]
                                showingAddTask = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteTask(itemTasks[index])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }.padding(4)
                .listStyle(.plain)
                .frame(minHeight: 450, maxHeight: 1000) // Ensure the list has enough space to render
            }
        }
        .sheet(isPresented: $showingAddTask) {
            TaskFormView(taskToEdit: $taskToEdit, itemCategory: $itemCategory, onSave: { newTask in
                if let taskToEdit = taskToEdit, let index = itemTasks.firstIndex(where: { $0 === taskToEdit }) {
                    // Update existing task
                    itemTasks[index] = newTask
                } else {
                    // Add new task
                    itemTasks.append(newTask)
                }
            })
            .presentationDetents([.medium])
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometry.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { height in
            taskListHeight = height
        }
    }

    // MARK: - Methods
    private func handleTaskRowEvent(_ event: TaskRowEvent, for task: ItemTask) {
        switch event {
        case .toggleCompletion:
            task.toggleCompletion()
            saveContext()
        }
    }

    private func deleteTask(_ task: ItemTask) {
        if let index = itemTasks.firstIndex(where: { $0 === task }) {
            itemTasks.remove(at: index)
        }
        modelContext.delete(task)
        saveContext()
    }

    private func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
                print("TaskListView: Context saved successfully")
            } else {
                print("TaskListView: No changes to save in context")
            }
        } catch {
            print("TaskListView: Failed to save context: \(error.localizedDescription)")
        }
    }
}
