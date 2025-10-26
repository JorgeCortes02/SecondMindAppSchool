//
//  TaskCardModifier.swift
//  SecondMind
//
//  Created by Jorge Cortés on 26/10/25.
//
import SwiftUI

// MARK: - Modificador reutilizable para tarjetas de tarea
struct TaskCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
    }
}
