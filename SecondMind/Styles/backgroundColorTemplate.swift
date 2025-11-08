//
//  backgroundColorTemplate.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/9/25.
//

import SwiftUI

struct BackgroundColorTemplate : View{
    
    var body: some View {
        
        ZStack {
            // Fondo base suave
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 250/255, green: 250/255, blue: 255/255),
                    Color(red: 230/255, green: 236/255, blue: 255/255)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 🔵 Azul translúcido arriba a la izquierda
            Circle()
                .fill(Color.blue.opacity(0.50))
                .frame(width: 360, height: 360)
                .blur(radius: 105)
                .offset(x: -180, y: -250)
            
            // 🔴🎨 Magenta rojizo intensificado arriba a la derecha
            Circle()
                .fill(Color(red: 255/255, green: 100/255, blue: 140/255).opacity(0.42)) // más rojo y saturado
                .frame(width: 330, height: 330)
                .blur(radius: 95)
                .offset(x: 170, y: -220)

            // 🟪 Violeta pálido en medio a la derecha
            Circle()
                .fill(Color.purple.opacity(0.36))
                .frame(width: 340, height: 340)
                .blur(radius: 100)
                .offset(x: 220, y: 180)

            // 🔵 Azul frío abajo al centro
            Circle()
                .fill(Color(red: 180/255, green: 215/255, blue: 255/255).opacity(0.32))
                .frame(width: 400, height: 400)
                .blur(radius: 120)
                .offset(x: 0, y: 450)

            // 🔮 Violeta suave abajo a la izquierda
            Circle()
                .fill(Color(red: 190/255, green: 160/255, blue: 255/255).opacity(0.30))
                .frame(width: 330, height: 330)
                .blur(radius: 100)
                .offset(x: -200, y: 400)
        }
    }
    
}
