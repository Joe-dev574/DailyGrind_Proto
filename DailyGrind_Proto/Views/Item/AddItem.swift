//
//  AddItem.swift
//  TaskFlow4.5
//
//  Created by Joseph DeWeese on 2/22/25.
//


import SwiftData
import SwiftUI

/// A view for adding or editing items with category-based color theming and distinct sections
struct AddItem: View {
    // MARK: - Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Item Property
    let item: Item?
    
    // MARK: - State Properties
    @State private var title: String
    @State private var remarks: String
    @State private var dateAdded: Date
    @State private var dateDue: Date
    @State private var dateStarted: Date
    @State private var dateCompleted: Date
    @State private var category: Category = .health
    @State private var categoryAnimationTrigger: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    /// Random Tint
    @State var tint: TintColor = tints.randomElement()!
    // MARK: - Initialization
    init(item: Item? = nil) {
        self.item = item
        if let item = item {
            _title = State(initialValue: item.title)
            _remarks = State(initialValue: item.remarks)
            _dateAdded = State(initialValue: item.dateAdded)
            _dateDue = State(initialValue: item.dateDue)
            _dateStarted = State(initialValue: item.dateStarted)
            _dateCompleted = State(initialValue: item.dateCompleted)
            _category = State(initialValue: Category(rawValue: item.category) ?? .health)
        } else {
            _title = State(initialValue: "")
            _remarks = State(initialValue: "")
            _dateAdded = State(initialValue: .now)
            _dateDue = State(initialValue: .now)
            _dateStarted = State(initialValue: .now)
            _dateCompleted = State(initialValue: .now)
            _category = State(initialValue: .today)
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            contentView
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
    
    // MARK: - Background View
    private var backgroundView: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .gray.opacity(0.02),
                .gray.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .scaleEffect(categoryAnimationTrigger ? 1.1 : 1.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: categoryAnimationTrigger)
        .onChange(of: category) { _, _ in
            withAnimation {
                categoryAnimationTrigger = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    categoryAnimationTrigger = false
                }
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    titleSection
                    remarksSection
                    categorySection
                    datesSection
                }
                .padding()
            }
            .navigationTitle(title)
            .toolbar { toolbarItems }
            .foregroundStyle(calculateContrastingColor(background: category.color))
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
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let backgroundOpacity: Double = 0.001
        static let reducedOpacity: Double = backgroundOpacity * 0.25 // 1175% reduction: 0.001 * 0.25 = 0.025
    }
    
    // MARK: - Content Sections
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .foregroundStyle(category.color) // Preserved foreground style
                .font(.title3)
            
            CustomTextEditor(remarks: $title, placeholder: "Enter title of your item...", minHeight: 35)
            .padding(8)
            .foregroundStyle(.mediumGrey)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity)) // Reduced opacity by 75%
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brief Description")
                .foregroundStyle(category.color) // Preserved foreground style
                .font(.title3)
            CustomTextEditor(remarks: $remarks, placeholder: "Enter a brief description of your item", minHeight: 85)
                .foregroundStyle(.mediumGrey) // Preserved white text
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity)) // Reduced opacity by 75%
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .foregroundStyle(category.color) // Preserved foreground style
                .font(.title3)
            
            LabeledContent {
                CategorySelector(
                    selectedCategory: $category,
                    animateColor: .constant(category.color),
                    animate: .constant(false)
                )
                .foregroundStyle(.primary)
                .accessibilityLabel("Category Selector")
                .accessibilityHint("Choose a category for your item")
            } label: {
                EmptyView()
            }
            .padding(8)
            .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity)) // Reduced opacity by 75%
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.4), lineWidth: 1)
        )
    }
    
    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dates")
                .foregroundStyle(category.color) // Preserved foreground style
                .font(.title3)
            
            VStack(spacing: 8) {
                LabeledContent("Created") {
                    Text(dateAdded.formatted(.dateTime))
                        .font(.callout)
                        .padding(.trailing, 50)
                }
                .foregroundStyle(.mediumGrey) // Preserved foreground style
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Created \(dateAdded.formatted(.dateTime))")
                
                datePickersForCategory()
            }
            .padding(8)
  //          .background(Color("LightGrey").opacity(SectionStyle.backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        }
        .padding(SectionStyle.padding)
        .background(category.color.opacity(SectionStyle.reducedOpacity)) // Reduced opacity by 75%
        .clipShape(RoundedRectangle(cornerRadius: SectionStyle.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: SectionStyle.cornerRadius)
                .stroke(category.color.opacity(0.4), lineWidth: 1)
        )
    }
    
    // MARK: - Toolbar Items
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticsManager.notification(type: .success)
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(category.color)
                }
            }
            ToolbarItem(placement: .principal) {
                LogoView()
                    .padding(.horizontal)
                    .accessibilityLabel("App Logo")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    save()
                }
                .font(.callout)
                .foregroundStyle(.white)
                .buttonStyle(.borderedProminent)
                .tint(category.color)
                .accessibilityLabel("Save Changes")
                .accessibilityHint("Tap to save your edited item.")
            }
        }
    }
    
    // MARK: - Private Methods
    private func save() {
        let newItem = Item(
            title: title,
            remarks: remarks,
            dateAdded: dateAdded,
            dateDue: dateDue,
            dateStarted: dateStarted,
            dateCompleted: dateCompleted,
            category: category,
            tintColor:  tint
        )
        context.insert(newItem)
        do {
            try context.save()
            HapticsManager.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
            print("Save error: \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    private func datePickersForCategory() -> some View {
        VStack(spacing: 12) {
            LabeledContent("Due") {
                DatePicker("", selection: $dateDue)
                    .labelsHidden()
                    .font(.caption)
            }
            .foregroundStyle(.mediumGrey) // Preserved foreground style
            .accessibilityLabel("Due Date")
            .accessibilityHint("Select the due date for your item")
            
            if category == .today || category == .work {
                LabeledContent("Start") {
                    DatePicker("", selection: $dateStarted)
                        .labelsHidden()
                        .font(.callout)
                }
                .foregroundStyle(.mediumGrey) // Preserved foreground style
                .accessibilityLabel("Start Date")
                .accessibilityHint("Select the start date for your item")
            }
        }
    }
    
    private func relativeLuminance(color: Color) -> Double {
        let uiColor = UIColor(color)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private func contrastRatio(l1: Double, l2: Double) -> Double {
        let lighter = max(l1, l2), darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }
    
    private func calculateContrastingColor(background: Color) -> Color {
        let backgroundLuminance = relativeLuminance(color: background)
        let whiteLuminance = relativeLuminance(color: .white)
        let blackLuminance = relativeLuminance(color: .black)
        let whiteContrast = contrastRatio(l1: backgroundLuminance, l2: whiteLuminance)
        let blackContrast = contrastRatio(l1: backgroundLuminance, l2: blackLuminance)
        return whiteContrast >= 7 && whiteContrast >= blackContrast ? .white : .black
    }
}

// MARK: - Preview
