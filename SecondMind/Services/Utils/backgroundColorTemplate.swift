//
//  backgroundColorTemplate.swift
//  SecondMind
//
//  Created by Jorge Cortés on 11/9/25.
//

import SwiftUI

struct BackgroundColorTemplate : View{
    
   var body: some View {
        
       ZStack{
           LinearGradient(
               gradient: Gradient(colors: [
                   Color(red: 250/255, green: 250/255, blue: 255/255),
                   Color(red: 235/255, green: 240/255, blue: 255/255)
               ]),
               startPoint: .topLeading,
               endPoint: .bottomTrailing
           )
           .ignoresSafeArea()
           
           Circle()
               .fill(Color.blue.opacity(0.5))
               .frame(width: 350, height: 350)
               .blur(radius: 90)
               .offset(x: -180, y: -200)
           
           Circle()
               .fill(Color.pink.opacity(0.45))
               .frame(width: 320, height: 320)
               .blur(radius: 100)
               .offset(x: 200, y: 250)
           
           Circle()
               .fill(Color.purple.opacity(0.4))
               .frame(width: 300, height: 300)
               .blur(radius: 100)
               .offset(x: 0, y: 500)
       }
      
       
        
        
    }
    
    
}
