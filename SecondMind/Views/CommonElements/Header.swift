//
//  Header.swift
//  SecondMind
//
//  Created by Jorge Cortés on 5/6/25.
//
import SwiftUI

 struct Header: View {
    var  body: some View{
      
            HStack(spacing: 5) {
                Text("Second")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.taskButtonColor)

                Text("Mind")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundColor(Color(red: 47 / 255, green: 129 / 255, blue: 198 / 255))
            }
            .frame(maxWidth: .infinity)
        
    }
}
