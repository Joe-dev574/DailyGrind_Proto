//
//  ItemTask.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/21/25.
//

import SwiftUI
import SwiftData

/// A model class representing a task item, managed by SwiftData.
/// This class supports persistence, Codable conformance, and provides formatted date properties.
@Model
final class ItemTask: Codable {
    // MARK: - Properties
    
    /// The name of the task, guaranteed to be non-empty after initialization.
    @Attribute(.unique)
    var taskName: String = ""
    
    /// A detailed description of the task, can be empty.
    var taskDescription: String = ""
    
    /// Indicates whether the task is completed.
    var isCompleted: Bool
    
    /// The date when the task was created, set automatically on initialization.
    @Attribute(.unique)
    var dateCreated = Date.now
    
    var taskDueDate = Date.now
    /// Optional reference to a related Item object (parent entity).
    @Relationship(deleteRule: .nullify, inverse: \Item.itemTasks)
    var item: Item?
    
    // MARK: - Computed Properties
    
    /// Formatted date string for display purposes (e.g., "Sep 15, 2023 at 2:30 PM").
    var formattedDateCreated: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateCreated)
    }
    
    /// Relative date string for user-friendly display (e.g., "Today", "Yesterday").
    var relativeDateCreated: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: dateCreated, relativeTo: Date())
    }
    
    /// A short summary of the task for display purposes, combining name and completion status.
    var summary: String {
        let status = isCompleted ? "✅" : "⬜"
        return "\(status) \(taskName)"
    }
    
    // MARK: - Initialization
    
    /// Initializes a new task item with the specified properties.
    /// - Parameters:
    ///   - taskName: The name of the task (if empty after trimming, defaults to "Untitled Task").
    ///   - taskDescription: A detailed description of the task (default: empty string).
    ///   - isCompleted: Completion status of the task (default: false).
    ///   - dateCreated: Date when the task was created (default: current date).
    ///   - item: Optional parent Item object (default: nil).
    init(
        taskName: String = "",
        taskDescription: String = "",
        isCompleted: Bool = false,
        dateCreated: Date = Date.now,
        taskDueDate: Date = Date.now,
        item: Item? = nil
    ) {
        let trimmedName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : taskName
        self.taskDescription = taskDescription
        self.isCompleted = isCompleted
        self.dateCreated = dateCreated
        self.taskDueDate = taskDueDate
        self.item = item
    }
    
    // MARK: - Methods
    
    /// Toggles the completion status of the task between completed and not completed.
    func toggleCompletion() {
        isCompleted.toggle()
    }
    
    /// Updates the task name with validation to ensure it isn't empty.
    /// - Parameter newName: The new name to set.
    func updateTaskName(_ newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : newName
    }
    
    // MARK: - Codable Conformance
    
    /// Coding keys for encoding and decoding the ItemTask properties.
    enum CodingKeys: String, CodingKey {
        case taskName
        case taskDescription
        case isCompleted
        case dateCreated
        case taskDueDate
    }
    
    /// Encodes the ItemTask instance into the provided encoder.
    /// - Parameter encoder: The encoder to encode the data into.
    /// - Throws: An error if encoding fails.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(taskName, forKey: .taskName)
        try container.encode(taskDescription, forKey: .taskDescription)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(taskDueDate, forKey: .taskDueDate)
    }
    
    
    /// Initializes an ItemTask instance from a decoder.
    /// - Parameter decoder: The decoder to decode the data from.
    /// - Throws: An error if decoding fails or if required properties are missing.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedTaskName = try container.decode(String.self, forKey: .taskName)
        let trimmedName = decodedTaskName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.taskName = trimmedName.isEmpty ? "Untitled Task" : decodedTaskName
        self.taskDescription = try container.decode(String.self, forKey: .taskDescription)
        self.isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.taskDueDate = try container.decode(Date.self, forKey: .taskDueDate)
        self.item = nil // Relationships are not decoded; must be set separately
    }
}

// MARK: - Preview Extension

extension ItemTask {
    /// A collection of sample tasks for SwiftUI previews.
    static var previewTasks: [ItemTask] {
        [
            ItemTask(
                taskName: "Buy Groceries",
                taskDescription: "Milk, eggs, bread, and butter",
                isCompleted: false,
                dateCreated: Date().addingTimeInterval(-86400) // Yesterday
            ),
            ItemTask(
                taskName: "Finish Project",
                taskDescription: "Complete the SwiftUI implementation",
                isCompleted: true,
                dateCreated: Date().addingTimeInterval(-172800) // 2 days ago
            ),
            ItemTask(
                taskName: "Call Mom",
                taskDescription: "Check in and see how she's doing",
                isCompleted: false,
                dateCreated: Date() // Today
            )
        ]
    }
    
    /// A single completed task for preview purposes.
    static var previewCompletedTask: ItemTask {
        ItemTask(
            taskName: "Write Report",
            taskDescription: "Submit the annual report to the team",
            isCompleted: true,
            dateCreated: Date().addingTimeInterval(-3600) // 1 hour ago
        )
    }
    
    /// A single incomplete task for preview purposes.
    static var previewIncompleteTask: ItemTask {
        ItemTask(
            taskName: "Schedule Meeting",
            taskDescription: "Set up a team sync for next week",
            isCompleted: false,
            dateCreated: Date()
        )
    }
}

// MARK: - SwiftUI Preview Provider (Example Usage)

/// A preview provider demonstrating the ItemTask model in a SwiftUI view.
struct ItemTask_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section(header: Text("Sample Tasks")) {
                    ForEach(ItemTask.previewTasks) { task in
                        VStack(alignment: .leading) {
                            Text(task.summary)
                                .font(.headline)
                            Text(task.taskDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Created: \(task.relativeDateCreated)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Task Preview")
        }
    }
}
