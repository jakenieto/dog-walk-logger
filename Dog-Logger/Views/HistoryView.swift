//
//  HistoryView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var walkLogService: WalkLogService
    @State private var selectedFilter: WalkQuality? = nil
    
    var filteredLogs: [WalkLog] {
        if let filter = selectedFilter {
            return walkLogService.logs.filter { $0.walkQuality == filter }
        }
        return walkLogService.logs
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: 8) {
                    Text("🐾 Walk History")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !walkLogService.logs.isEmpty {
                        let stats = walkLogService.getStats()
                        Text("\(stats.total) walks • \(stats.good) great • \(stats.okay) okay • \(stats.bad) poor")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 20)
                
                // Filter buttons
                if !walkLogService.logs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                emoji: "🐾",
                                label: "All",
                                isSelected: selectedFilter == nil,
                                action: {
                                    selectedFilter = nil
                                    walkLogService.fetchLogs()
                                }
                            )
                            
                            ForEach(WalkQuality.allCases, id: \.self) { quality in
                                FilterButton(
                                    emoji: quality.emoji,
                                    label: quality.label.components(separatedBy: " ").first ?? "",
                                    isSelected: selectedFilter == quality,
                                    action: {
                                        selectedFilter = quality
                                        walkLogService.fetchLogs()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 20)
                }
                
                // Content
                if filteredLogs.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Text("🐕")
                            .font(.system(size: 64))
                        Text(walkLogService.logs.isEmpty ? "No walks logged yet" : "No walks match your filter")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(walkLogService.logs.isEmpty ? "Start logging your pup's adventures!" : "Try a different filter to see more walks")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredLogs) { log in
                                WalkLogCardView(log: log) {
                                    walkLogService.deleteLog(log)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private func refreshData() async {
        // Add a small delay to show the refresh animation
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Fetch fresh data from the database
        await MainActor.run {
            walkLogService.fetchLogs()
        }
    }
}

struct FilterButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 14, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.orange : Color(.systemBackground))
            )
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.orange : Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
