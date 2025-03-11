//
//  TaskRowView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 3/6/25.
//



import SwiftUI
import SwiftData

// Enum for task-related events
enum TaskRowEvent {
    case toggleCompletion
}

// A refined view for displaying a task row with improved aesthetics and interaction
struct TaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let itemTask: ItemTask
    let onEvent: (TaskRowEvent) -> Void
    @State private var checked: Bool = false
    @State private var isHovered: Bool = false // For hover effect on supported platforms

    // Formats dates into human-readable strings
    private func formatItemTaskDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        if date.isToday {
            return "Today"
        } else if date.isYesterday {
            return "Yesterday"
        } else if date.isTomorrow {
            return "Tomorrow"
        } else {
            return formatter.string(from: date)
        }
    }

    // Computed property for dynamic foreground color based on completion and hover state
    private var taskForegroundStyle: Color {
        if checked {
            return .gray.opacity(0.8)
        } else if isHovered {
            return .blue.opacity(0.9)
        } else {
            return .primary
        }
    }

    var body: some View {
        ZStack {
            // Subtle background for depth
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

            HStack(alignment: .center, spacing: 12) {
                // Completion toggle button with animation
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        checked.toggle()
                        onEvent(.toggleCompletion)
                    }
                }) {
                    Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(checked ? .green : .gray.opacity(0.5))
                        .scaleEffect(checked ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: checked)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(checked ? "Mark as incomplete" : "Mark as complete")

                // Task details in a clean, readable layout
                VStack(alignment: .leading, spacing: 6) {
                    // Task name with dynamic styling
                    Text(itemTask.taskName)
                        .font(.title3)
                        .foregroundStyle(.mediumGrey)
                        .fontWeight(.semibold)
                        .strikethrough(checked, color: .gray)
                        .lineLimit(2)
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Task description if available
                    if !itemTask.taskDescription.isEmpty {
                        Text(itemTask.taskDescription)
                            .font(.subheadline)
                            .foregroundStyle(checked ? .gray.opacity(0.7) : .secondary)
                            .strikethrough(checked, color: .gray)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8)
                    }

                    // Dates in a compact, side-by-side layout
                    VStack(alignment: .leading, spacing: 5){
                        HStack{
                            // Date Created
                            Text("Created: ")
                                .font(.caption2)
                                .foregroundStyle(.mediumGrey)
                            Label(formatItemTaskDate(itemTask.dateCreated), systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }.padding(.leading, 15)
                        HStack{
                            // Due Date with dynamic color based on urgency
                            Text("Due: ")
                                .font(.caption2)
                                .foregroundStyle(.mediumGrey)
                            Label(formatItemTaskDate(itemTask.taskDueDate), systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(dueDateColor)
                                .lineLimit(1)
                        }.padding(.leading, 15)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 1)
         
        }
        .onAppear {
            checked = itemTask.isCompleted
        }
        .onChange(of: itemTask.isCompleted) { _, newValue in
            checked = newValue
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Task: \(itemTask.taskName), \(checked ? "completed" : "not completed"), Due: \(formatItemTaskDate(itemTask.taskDueDate))")
        .accessibilityHint("Double-tap the button to toggle completion status")
    }

    // Compute due date color based on urgency
    private var dueDateColor: Color {
        let today = Date()
        if checked {
            return .gray
        } else if itemTask.taskDueDate < today {
            return .red.opacity(0.8)
        } else if itemTask.taskDueDate.isToday || itemTask.taskDueDate.isTomorrow {
            return .orange.opacity(0.8)
        } else {
            return .gray
        }
    }
}

// Date extensions for convenience
extension Date {
    var isYesterday: Bool { Calendar.current.isDateInYesterday(self) }
   
}

// Preview provider for SwiftUI preview
#Preview {
    TaskRowView(itemTask: ItemTask(taskName: "Sample Task", taskDescription: "This is a sample task description.", isCompleted: false, dateCreated: Date(), taskDueDate: Date().addingTimeInterval(86400)), onEvent: { _ in })
        .padding()
        .background(Color(.systemGroupedBackground))
}
