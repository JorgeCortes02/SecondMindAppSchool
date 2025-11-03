//
//  EmptyList.swift
//  SecondMind
//
//  Created by Jorge Cortés on 31/10/25.
//

import SwiftUI

struct EmptyList: View {
    
    var color: Color
    var textIcon: String
    
    
    var body: some View {
      
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: textIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(color.opacity(0.7))
            
            Text("No hay nada que mostrar")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
        
        
    }
}

