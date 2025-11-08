//
//  EventCardModifier.swift
//  SecondMind
//
//  Created by Jorge Cortés on 26/10/25.
//
import SwiftUI

struct EventCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10) // 🔹 Reduce el padding interno
            .background(Color.white)
            .cornerRadius(14) // 🔹 Menor radio de esquina
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2) // 🔹 Sombra más sutil
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.07), lineWidth: 0.8) // 🔹 Trazo más fino
            )
    }
}
