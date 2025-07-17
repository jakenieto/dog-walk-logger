//
//  AnimatedIconView.swift
//  Dog-Logger
//
//  Created by Jake Nieto on 7/12/25.
//

import SwiftUI

struct AnimatedIconView: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void
    
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 48))
                    .scaleEffect(scale)
                
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? selectedColor : .secondary)
            }
            .frame(minWidth: 2)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? selectedColor.opacity(0.2) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? selectedColor : Color(.systemGray4), lineWidth: 2)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isSelected ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
