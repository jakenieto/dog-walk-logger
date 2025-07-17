//
//  WalkLogCardView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import SwiftUI

struct WalkLogCardView: View {
    let log: WalkLog
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Text(log.walkQuality.emoji)
                        .font(.title2)
                    Text(log.bathroom.emoji)
                        .font(.title3)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                }
            }
            
            HStack {
                Text(log.userName + " - ")
                    .font(.system(size: 14, weight: .thin))
                    .foregroundColor(.secondary)
                
                Text(log.walkQuality.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(log.walkQuality.color)
            }
            
            Text(log.date.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        
            
            if let notes = log.notes {
                Text(notes)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .italic()
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            Rectangle()
                .fill(Color.orange)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
    }
}
