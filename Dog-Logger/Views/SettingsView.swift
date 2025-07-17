//
//  SettingsView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/13/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var walkLogService: WalkLogService
    @State private var name: String = ""
    @State private var showSaveSuccess = false
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("⚙️ Settings")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Customize your walk logging experience")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Settings Card
                    VStack(alignment: .leading, spacing: 20) {
                        // Name Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 20))
                                Text("Your Name")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            TextField("Enter your name...", text: $name, axis: .vertical)
                                .textFieldStyle(CustomTextFieldStyle())
                                .focused($isNotesFocused)
                                .lineLimit(1...3)
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
                        Button(action: {
                            walkLogService.saveSettings(name)
                            showSaveSuccess = true
                            
                            // Hide success message after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showSaveSuccess = false
                            }
                            // Dismiss keyboard before saving
                            isNotesFocused = false
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showSaveSuccess ? "checkmark.circle.fill" : "square.and.arrow.down")
                                Text(showSaveSuccess ? "Saved!" : "Save Settings")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(buttonBackgroundColor)
                            )
                            .scaleEffect(showSaveSuccess ? 1.05 : 1.0)
                            .shadow(color: buttonShadowColor, radius: 8, x: 0, y: 4)
                        }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: name)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSaveSuccess)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            // Load saved name when view appears
            name = walkLogService.getUserName() ?? ""
        }
    }
    
    private var buttonBackgroundColor: Color {
        if showSaveSuccess {
            return Color.green
        } else if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Color.gray
        } else {
            return Color.orange
        }
    }
    
    private var buttonShadowColor: Color {
        if showSaveSuccess {
            return Color.green.opacity(0.3)
        } else if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Color.clear
        } else {
            return Color.orange.opacity(0.3)
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
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
