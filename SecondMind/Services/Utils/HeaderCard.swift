//
//  HeaderCard.swift
//  SecondMind
//
//  Created by Jorge Cortés on 22/7/25.
//
import SwiftUI

// MARK: – Header “Tareas” + Segmented Control + Toggle Calendario
 func headerCard(title:String) -> some View {
    
   
    VStack(spacing: 10) {
        ZStack {
            Text("\(title)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.taskButtonColor)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        // Fondo semitransparente con degradado suave
        
        
        .cornerRadius(20)
    }
    .padding(.horizontal, 16)
}
