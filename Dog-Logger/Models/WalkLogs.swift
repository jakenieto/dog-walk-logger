//
//  WalkLogs.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import Foundation
import SwiftUICore

struct WalkLog: Identifiable, Codable {
    let id: UUID?
    let date: Date
    let walkQuality: WalkQuality
    let bathroom: BathroomActivity
    let userName: String
    let notes: String?
    
    init(walkQuality: WalkQuality, bathroom: BathroomActivity, notes: String? = nil, userName: String = "Jake") {
        self.id = UUID()
        self.date = Date()
        self.walkQuality = walkQuality
        self.bathroom = bathroom
        self.notes = notes?.isEmpty == true ? nil : notes
        self.userName = userName
    }
}

enum WalkQuality: String, CaseIterable, Codable {
    case good = "good"
    case okay = "okay"
    case bad = "bad"
    
    var emoji: String {
        switch self {
        case .good: return "🐕🥇"
        case .okay: return "🐕"
        case .bad: return "🐕🫣"
        }
    }
    
    var label: String {
        switch self {
        case .good: return "Great Walk"
        case .okay: return "Okay Walk"
        case .bad: return "Poor Walk"
        }
    }
    
    var color: Color {
        switch self {
        case .good: return .green
        case .okay: return .orange
        case .bad: return .red
        }
    }
}

enum BathroomActivity: String, CaseIterable, Codable {
    case none = "none"
    case pee = "pee"
    case poop = "poop"
    case both = "both"
    
    var emoji: String {
        switch self {
        case .none: return "🚫"
        case .pee: return "💧"
        case .poop: return "💩"
        case .both: return "💩💧"
        }
    }
    
    var label: String {
        switch self {
        case .none: return "Nothing"
        case .pee: return "Pee"
        case .poop: return "Poop"
        case .both: return "Both"
        }
    }
}
