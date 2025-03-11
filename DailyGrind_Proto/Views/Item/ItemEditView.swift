//
//  ItemEditView.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/23/25.
//

import SwiftData
import SwiftUI

/// A view for editing items with category-based color theming and distinct sections
struct ItemEditView: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context  // SwiftData context for persistence
  
    @Environment(\.dismiss) private var dismiss  // Environment value to dismiss the view
    
    let item: Item  // The original item being edited (immutable reference)
   
    // MARK: - State Properties
    private let editItem: Item  // Working copy of the item for editing
    @State var taskToEdit: ItemTask?
    @State var showingAddTask = false
    @State private var taskName: String  // Item taskName
    @State private var taskDescription: String  // Item description
    @State private var dateAdded: Date  // Creation date
    @State private var dateDue: Date  // Due date
    @State private var dateStarted: Date  // Start date
    @State private var dateCompleted: Date  // Completion date
    @State private var itemCategory: Category  // Item category
    @State private var itemStatus: Item.Status  // Item status
    @State private var categoryAnimationTrigger: Bool = false  // Trigger for category change animation
    @State private var showErrorAlert: Bool = false  // Controls error alert visibility
    @State private var showTaskSheet: Bool = false  // Task list for Item
    @State private var errorMessage: String = ""  // Error message text
    @State private var showTags = false  // Controls tags sheet visibility
    @State private var itemTasks: [ItemTask] = []
    @State private var taskListHeight: CGFloat = 0 // Track the height of TaskListView content
    // MARK: - Initial Values for Comparison
    private let initialTaskName: String
        private let initialTaskDescription: String
        private let initialDateAdded: Date
        private let initialDateDue: Date
        private let initialDateStarted: Date
        private let initialDateCompleted: Date
        private let initialCategory: Category
        private let initialStatus: Item.Status
        private let initialTags: [Tag]?
        private let initialItemTasks: [ItemTask]?
    // MARK: - Initialization
    init(editItem: Item) {
            self.item = editItem
            self.editItem = editItem
            _taskName = State(initialValue: editItem.title)
            _taskDescription = State(initialValue: editItem.remarks)
            _dateAdded = State(initialValue: editItem.dateAdded)
            _dateDue = State(initialValue: editItem.dateDue)
            _dateStarted = State(initialValue: editItem.dateStarted)
            _dateCompleted = State(initialValue: editItem.dateCompleted)
            _itemCategory = State(initialValue: Category(rawValue: editItem.category) ?? .today)
            _itemStatus = State(initialValue: Item.Status(rawValue: editItem.status)!)
            _itemTasks = State(initialValue: editItem.itemTasks ?? [])
            initialTaskName = editItem.title
            initialTaskDescription = editItem.remarks
            initialDateAdded = editItem.dateAdded
            initialDateDue = editItem.dateDue
            initialDateStarted = editItem.dateStarted
            initialDateCompleted = editItem.dateCompleted
            initialCategory = Category(rawValue: editItem.category) ?? .today
            initialStatus = Item.Status(rawValue: editItem.status)!
            initialTags = editItem.tags
            initialItemTasks = editItem.itemTasks
        }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView  // Background gradient layer
            contentView  // Main content layer
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .presentationDetents([.fraction(0.5), .fraction(0.8), .large]) // Allow multiple height options
                .presentationDragIndicator(.visible)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .gray.opacity(0.02),  // Light gray top
                .gray.opacity(0.1),  // Darker gray bottom
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)  // Scale animation for category change
        .animation(
            .spring(response: 0.5, dampingFraction: 0.9),
            value: categoryAnimationTrigger
        )
        .onChange(of: itemCategory) { _, _ in
            withAnimation {
                categoryAnimationTrigger = true  // Trigger scale animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false  // Reset after 0.5 seconds
                }
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                //MARK:  **CONTENT MENU**
                VStack(spacing: 24) {  // Main content stack with sections
                    titleSection
                    remarksSection
                    categorySection
                    tagsSection
                    statusSection
                    datesSection
                    taskSection
                    
                }
                .padding()
            }
            .navigationTitle(item.title)  // Dynamic navigation taskName
            .toolbar { toolbarItems }  // Custom toolbar with save button
            .foregroundStyle(
                calculateContrastingColor(background: itemCategory.color)
            )
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { showErrorAlert = false }
            } message: {
                Text(errorMessage)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
    
    // MARK: - Section Styling Configuration
    private struct SectionStyle {
        static let cornerRadius: CGFloat = 10  // Corner radius for sections
        static let padding: CGFloat = 16  // Padding for sections
        static let backgroundOpacity: Double = 0.01  // Base background opacity
        static let reducedOpacity: Double = backgroundOpacity * 0.30  // Reduced opacity for layering
    }
    
    // MARK: Item Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(itemCategory.color)  // Section taskName in medium grey
                .font(.title2)
                .fontWeight(.semibold)
            LabeledContent {
                CustomTextEditor(
                    remarks: $taskName, placeholder: "Enter taskName of your item",
                    minHeight: 45
                )
                .foregroundStyle(.mediumGrey)
                .accessibilityLabel("Item Title")
                .accessibilityHint("Enter the title of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(
                Color("LightGrey").opacity(SectionStyle.backgroundOpacity)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Item Description Text Editor
    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(itemCategory.color)  // Section title in medium grey
                .font(.title2)
                .fontWeight(.semibold)
            CustomTextEditor(
                remarks: $taskDescription,
                placeholder: "Enter a brief description of your item",
                minHeight: 85
            )
            .foregroundStyle(.mediumGrey)  // Preserved white text
            .padding(8)
            .background(
                Color("LightGrey").opacity(SectionStyle.backgroundOpacity)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
            )
            .accessibilityLabel("Item Description")
            .accessibilityHint("Enter brief description of your item")
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(itemCategory.color)  // Section title in medium grey
                .font(.title2)
                .fontWeight(.semibold)
            LabeledContent {
                CategorySelector(
                    selectedCategory: $itemCategory,
                    animateColor: .constant(itemCategory.color),
                    animate: .constant(false)
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Category Selector")
                .accessibilityHint("Choose a category for your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(
                Color("LightGrey").opacity(SectionStyle.backgroundOpacity)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Tag Section
    private var tagsSection: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Tags")
                    .foregroundStyle(itemCategory.color)  // Section title in medium grey(off black : off white)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                //      MARK:  Button to show tags management sheet
                Button {
                    HapticsManager.notification(type: .success)
                    showTags.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(itemCategory.color)
                        .padding()
                        .background(itemCategory.color.opacity(0.1))
                        .clipShape(Circle())
                }
                .sheet(isPresented: $showTags) {
                    TagView(item: item)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }.padding(.bottom, 8)
            }
            VStack(alignment: .leading) {
                // Display existing tags in a horizontal scroll view
                if let tags = editItem.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagItemView(
                                    ///actual tag view
                                    tag: tag,
                                    onDelete: {
                                        // Remove tag from the editable item's tags array
                                        if let index = editItem.tags?
                                            .firstIndex(of: tag)
                                        {
                                            editItem.tags?.remove(at: index)
                                        }
                                    }
                                ).padding(.horizontal, 4)
                                
                            }.padding(.top, 7)
                        }
                    }
                    .frame(height: 50)
                } else {
                    Text("No tags added")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
            }
        }
        
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: Status Section
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .foregroundStyle(itemCategory.color)  // Section title in medium grey
                .font(.title2)
                .fontWeight(.semibold)
            
            LabeledContent {
                Picker("Status", selection: $itemStatus) {
                    ForEach(Item.Status.allCases, id: \.self) { status in
                        Text(status.descr)
                            .tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Status Picker")
                .accessibilityHint("Select the status of your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(
                Color("LightGrey").opacity(SectionStyle.backgroundOpacity)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    // MARK: Dates Section
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(itemCategory.color)  // Section title in medium grey
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                LabeledContent("Created") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7)
                            .foregroundStyle(.gray.opacity(0.2))
                        Text(dateAdded.formatted(.dateTime))
                            .font(.system(size: 16))
                            .foregroundStyle(.mediumGrey)
                    }
                    .frame(width: 195, height: 35)
                    .foregroundStyle(itemCategory.color)
                    .padding(.trailing, 3)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "Created \(dateAdded.formatted(.dateTime))")
                }.foregroundStyle(.mediumGrey)
                datePickersForCategory()
            }
            .padding(8)
            .background(
                Color("LightGrey").opacity(SectionStyle.backgroundOpacity)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    // MARK: - Preference Key for Height Measurement
    struct HeightPreferenceKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }
    // MARK: - Private Computed Properties
        private var hasFormChanged: Bool {
            taskName != initialTaskName || taskDescription != initialTaskDescription
            || dateAdded != initialDateAdded || dateDue != initialDateDue
            || dateStarted != initialDateStarted
            || dateCompleted != initialDateCompleted
            || itemCategory != initialCategory || editItem.tags != initialTags
            || itemTasks != initialItemTasks
        }
  
    // MARK: **Task Section**
    private var taskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TaskListView(itemTasks: $itemTasks, itemCategory: itemCategory)
                .padding(SectionStyle.padding)
                .background(itemCategory.color.opacity(SectionStyle.reducedOpacity))
                .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
               
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        print("List size: \(geometry.size)")
                    }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(itemCategory.color.opacity(0.3), lineWidth: 2)
        )
    }
    // MARK: - Toolbar Items
    private var toolbarItems: some ToolbarContent {
        
        Group {
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveEditedItem()
                }
                .font(.callout)
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(itemCategory.color)
                .disabled(!hasFormChanged)  // Disable if no changes made
                .accessibilityLabel("Save Changes")
                .accessibilityHint(
                    "Tap to save your edited item. Disabled until changes are made."
                )
            }
        }
    }
    
    
    // MARK: - Private Methods
    private func saveEditedItem() {
        // Update working copy with current values
        editItem.title = taskName
        editItem.remarks = taskDescription
        editItem.dateAdded = dateAdded
        editItem.dateDue = dateDue
        editItem.dateStarted = dateStarted
        editItem.dateCompleted = dateCompleted
        editItem.category = itemCategory.rawValue
        // Note: Tags are updated via the tagsSection
        
        do {
            try context.save()  // Save changes to SwiftData
            HapticsManager.notification(type: .success)  // Success feedback
            dismiss()  // Close the view
        } catch {
            errorMessage =
            "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    //MARK:  DATE PICKERS FOR CATEGORY
    @ViewBuilder
        private func datePickersForCategory() -> some View {
            VStack(spacing: 12) {
                LabeledContent("Due") {
                    DatePicker("", selection: $dateDue)
                        .labelsHidden()
                        .foregroundStyle(itemCategory.color)
                        .font(.caption)
                }
                .foregroundStyle(.mediumGrey)
                .accessibilityLabel("Due Date")
                .accessibilityHint("Select the due date for your item")
                
                if itemCategory == .today || itemCategory == .work {
                    LabeledContent("Start") {
                        DatePicker("", selection: $dateStarted)
                            .labelsHidden()
                            .font(.caption)
                    }
                    .foregroundStyle(.mediumGrey)
                    .accessibilityLabel("Start Date")
                    .accessibilityHint("Select the start date for your item")
                }
                
                if itemCategory == .today {
                    LabeledContent("Finish") {
                        DatePicker("", selection: $dateCompleted)
                            .labelsHidden()
                            .foregroundStyle(.mediumGrey)
                            .font(.caption)
                    }
                    .foregroundStyle(.mediumGrey)
                    .accessibilityLabel("Completion Date")
                    .accessibilityHint("Select the completion date for your item")
                }
            }
        }
    //MARK:  FUNCTIONS
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g =
        green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b =
        blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func calculateContrastingColor(background: Color) -> Color {
        // Calculate contrasting color for readability
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(
            l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(
            l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast
        ? .white : .black
    }
}
    //MARK:  TAGITEM VIEW
    /// Displays a tag with its name overlaid on a tag icon, with a delete button.
struct TagItemView: View {
       let tag: Tag  // The tag to display
       let onDelete: () -> Void  // Closure to handle tag deletion

       @State var showTags = false

       // MARK: - Body
       var body: some View {
           VStack {
               HStack(spacing: 4) {
                   // Tag icon with text overlay
                   HStack(spacing: 0) {
                       Image(systemName: "tag.fill")  // Using filled tag icon
                           .resizable()
                           .frame(width: 30, height: 30)  // Large enough for text overlay
                           .foregroundStyle(tag.hexColor)  // Fill with tag's color

                       Text(tag.name)
                           .foregroundStyle(.mediumGrey)  // Medium Grey text for contrast
                           .font(.system(size: 12, weight: .medium))
                       // Padding to fit within tag shape
                       // Delete button
                       Button(action: onDelete) {
                           Image(systemName: "minus.circle")
                               .foregroundStyle(.lightGrey)  // Consistent delete icon color
                               .frame(width: 15, height: 15)
                               .padding(.horizontal, 1)
                       }
                       .buttonStyle(.plain)
                   }.padding(.horizontal, 2)
                       .accessibilityElement(children: .combine)
                       .accessibilityLabel("Tag: \(tag.name)")
                       .accessibilityAddTraits(.isButton)
               }
           }
       }
   }
    
        // MARK: - Color Extension
        extension Color {
            /// Returns a darker version of the color by reducing RGB values
            func darker() -> Color {
                let uiColor = UIColor(self)
                var red: CGFloat = 0
                var green: CGFloat = 0
                var blue: CGFloat = 0
                var alpha: CGFloat = 0
                uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return Color(
                    red: max(red - 0.2, 0), green: max(green - 0.2, 0),
                    blue: max(blue - 0.2, 0), opacity: alpha)
            }
        }
    
        // MARK: - Tag Extension
        extension Tag {
            /// Converts the tag's color string to a SwiftUI Color
            var swiftUIColor: Color {
                switch tagColor.lowercased() {
                case "red": return .red
                case "blue": return .blue
                case "green": return .green
                case "yellow": return .yellow
                case "purple": return .purple
                case "orange": return .orange
                case "gray": return .gray
                case "black": return .black
                case "white": return .white
                default:
                    // Handle hex codes (e.g., "#FF0000") or fallback to gray
                    if tagColor.hasPrefix("#"), tagColor.count == 7 {
                        let hex = String(tagColor.dropFirst())
                        if let intValue = UInt32(hex, radix: 16) {
                            let r = Double((intValue >> 16) & 0xFF) / 255.0
                            let g = Double((intValue >> 8) & 0xFF) / 255.0
                            let b = Double(intValue & 0xFF) / 255.0
                            return Color(red: r, green: g, blue: b)
                        }
                    }
                    return .gray  // Fallback color if unrecognized
                }
            }
        }
    

