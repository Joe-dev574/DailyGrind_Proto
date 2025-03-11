//
//  TaskFormView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/11/25.
//

import SwiftUI
import SwiftData


struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var taskToEdit: ItemTask?
    @Binding var itemCategory: Category
    var onSave: (ItemTask) -> Void

    @State private var taskName: String = ""
    @State private var taskDescription: String = ""

    private var isEditing: Bool {
        taskToEdit != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $taskName)
                        .accessibilityLabel("Task name")
                    TextField("Description", text: $taskDescription, axis: .vertical)
                        .lineLimit(1...3)
                        .accessibilityLabel("Task description")
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveOrUpdateTask()
                        dismiss()
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let task = taskToEdit {
                    taskName = task.taskName
                    taskDescription = task.taskDescription
                }
            }
        }
    }

    private func saveOrUpdateTask() {
        let task: ItemTask
        if let existingTask = taskToEdit {
            // Update existing task
            existingTask.updateTaskName(taskName)
            existingTask.taskDescription = taskDescription
            task = existingTask
        } else {
            // Create new task
            task = ItemTask(taskName: taskName, taskDescription: taskDescription)
            modelContext.insert(task)
        }
        saveContext()
        onSave(task)
    }

    private func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
                print("TaskFormView: Context saved successfully")
            } else {
                print("TaskFormView: No changes to save in context")
            }
        } catch {
            print("TaskFormView: Failed to save context: \(error.localizedDescription)")
        }
    }
}

