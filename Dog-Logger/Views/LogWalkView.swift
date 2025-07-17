//
//  LogWalkView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import SwiftUI

struct LogWalkView: View {
    @ObservedObject var walkLogService: WalkLogService
    @State private var selectedWalkQuality: WalkQuality?
    @State private var selectedBathroom: BathroomActivity = .none
    @State private var notes: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🐕 How was the walk?")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Log your pup's adventure")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Main Content Card
                    VStack(spacing: 32) {
                        // Walk Quality Section
                        SectionCard(title: "Walk Quality", icon: "figure.walk") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                                ForEach(WalkQuality.allCases, id: \.self) { quality in
                                    QualityButton(
                                        quality: quality,
                                        isSelected: selectedWalkQuality == quality,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedWalkQuality = quality
                                            }
                                            // Dismiss keyboard when selecting quality
                                            isNotesFocused = false
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Bathroom Section
                        SectionCard(title: "Bathroom Breaks", icon: "drop.fill") {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(BathroomActivity.allCases, id: \.self) { activity in
                                    BathroomButton(
                                        activity: activity,
                                        isSelected: selectedBathroom == activity,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedBathroom = activity
                                            }
                                            // Dismiss keyboard when selecting bathroom activity
                                            isNotesFocused = false
                                        }
                                    )
                                }
                            }
                        }
                        
                        // Notes Section
                        SectionCard(title: "Notes", icon: "note.text", isOptional: true) {
                            TextField("Any special moments or observations...", text: $notes, axis: .vertical)
                                .textFieldStyle(NotesTextFieldStyle())
                                .lineLimit(3...6)
                                .focused($isNotesFocused)
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        Button("Done") {
                                            isNotesFocused = false
                                        }
                                        .foregroundColor(.orange)
                                        .fontWeight(.semibold)
                                    }
                                }
                        }
                        
                        // Save Button
                        Button(action: saveWalkLog) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                }
                                Text(isLoading ? "Saving..." : "Save Walk Log")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(buttonBackgroundColor)
                            )
                            .scaleEffect(selectedWalkQuality != nil ? 1.0 : 0.95)
                            .shadow(color: buttonShadowColor, radius: 12, x: 0, y: 6)
                        }
                        .disabled(selectedWalkQuality == nil || isLoading)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedWalkQuality)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                isNotesFocused = false
            }
        }
        .alert("Walk Logged!", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var buttonBackgroundColor: Color {
        if isLoading {
            return Color.orange.opacity(0.8)
        } else if selectedWalkQuality != nil {
            return Color.orange
        } else {
            return Color.gray
        }
    }
    
    private var buttonShadowColor: Color {
        if selectedWalkQuality != nil && !isLoading {
            return Color.orange.opacity(0.4)
        } else {
            return Color.clear
        }
    }
    
    private func saveWalkLog() {
        guard let walkQuality = selectedWalkQuality else {
            alertMessage = "Please select how the walk went!"
            showingAlert = true
            return
        }
        
        // Dismiss keyboard before saving
        isNotesFocused = false
        
        isLoading = true
        
        // Simulate loading for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let log = WalkLog(
                walkQuality: walkQuality,
                bathroom: selectedBathroom,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                userName: walkLogService.getUserName()
            )
            
            walkLogService.addLog(log)
            
            // Reset form with animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                selectedWalkQuality = nil
                selectedBathroom = .none
                notes = ""
                isLoading = false
            }
            
            alertMessage = "🐾 Walk logged successfully!"
            showingAlert = true
        }
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let isOptional: Bool
    let content: Content
    
    init(title: String, icon: String, isOptional: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.isOptional = isOptional
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                if isOptional {
                    Text("(Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            content
        }
    }
}

struct QualityButton: View {
    let quality: WalkQuality
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(quality.emoji)
                    .font(.system(size: 32))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                
                Text(quality.label)
                    .font(.system(size: 12, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.green : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.green : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? Color.green.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BathroomButton: View {
    let activity: BathroomActivity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(activity.emoji)
                    .font(.system(size: 28))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                
                Text(activity.label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NotesTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}
