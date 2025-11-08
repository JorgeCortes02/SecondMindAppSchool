//
//  SoftButtonColor.swift
//  SecondMind
//
//  Created by Jorge Cortés on 7/11/25.
//
import SwiftUI

struct SoftButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundColor(color)
            .background(color.opacity(configuration.isPressed ? 0.15 : 0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
