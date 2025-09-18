//
//  loginGlassContainer.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/9/25.
//
import SwiftUI

struct GlassContainerImproved: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 35, style: .continuous)

        if #available(iOS 26.0, *) {
            content
                .frame(minHeight: UIScreen.main.bounds.height * 0.80) // 👈 ocupa 75% de la pantalla

                .glassEffect(.clear, in: shape)
                .clipShape(shape)
                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 10)
                .padding(.horizontal, 20)
        } else {
            content
                .frame(minHeight: UIScreen.main.bounds.height * 0.80) // 👈 ocupa 75% de la pantalla

                .background(.ultraThinMaterial, in: shape)
                .clipShape(shape)
                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 10)
                .padding(.horizontal, 20)
        }
    }
}

struct GlassContainerProfile: ViewModifier {
    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: 35, style: .continuous)

        if #available(iOS 26.0, *) {
            content
                

                .glassEffect(.regular, in: shape)
                .clipShape(shape)
                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 10)
                .padding(.horizontal, 20)
        } else {
            content
              

                .background(.ultraThinMaterial, in: shape)
                .clipShape(shape)
                .shadow(color: .black.opacity(0.15), radius: 25, x: 0, y: 10)
                .padding(.horizontal, 20)
        }
    }
}
