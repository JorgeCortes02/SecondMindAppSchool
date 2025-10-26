//
//  IndependentButtonAction.swift
//  SecondMind
//
//  Created by Jorge Cortés on 26/10/25.
//
import SwiftUI

struct BaseActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        
        if #available(iOS 26.0, *)
        {
            Button(action: {action()}) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 58, height: 58)
            }
            .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
        }else{
            
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(color.opacity(0.9))
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                    )
            }
          
            
        }
    }
}
