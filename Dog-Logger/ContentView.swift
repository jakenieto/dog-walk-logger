//
//  ContentView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var walkLogService = WalkLogService()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LogWalkView(walkLogService: walkLogService)
                .tabItem {
                    Image(systemName: "plus")
                    Text("Log Walk")
                }
                .tag(0)
            
            HistoryView(walkLogService: walkLogService)
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(1)
                .onAppear {
                    if selectedTab == 1 {
                        walkLogService.fetchLogs()
                    }
                }
            
            SettingsView(walkLogService: walkLogService)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.orange)
        .onChange(of: selectedTab) { newValue in
            if newValue == 1 {
                walkLogService.fetchLogs()
            }
        }
    }
}

