//
//  EventCardModifier.swift
//  SecondMind
//
//  Created by Jorge Cortés on 26/10/25.
//
import SwiftUI
struct EventCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding()
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
    }
}
