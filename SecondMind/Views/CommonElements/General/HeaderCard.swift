//
//  HeaderCard.swift
//  SecondMind
//
//  Created by Jorge Cortés on 22/7/25.
//
import SwiftUI

// MARK: – Cabecera visual con ícono y título
 func headerCard(title: String, accentColor: Color, sizeClass: UserInterfaceSizeClass?) -> some View {
     
    ZStack {
        // Título a la izquierda
        HStack {
            Image(systemName: "folder.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(accentColor)
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(accentColor)
            Spacer()
        }
        
        // Header centrado absolutamente
        if sizeClass == .regular {
            Header()
                .frame(height: 40)
        }
    }
    .padding(.horizontal, 20)
    .padding(.top, sizeClass == .regular ? 10 : 0)
    .padding(.bottom, sizeClass == .regular ? 5 : 0)
}
