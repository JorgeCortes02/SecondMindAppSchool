//
//  Project.swift
//  SecondMind
//
//  Created by Jorge Cortés on 17/6/25.
//

import SwiftUI


struct ProjectView: View {
    
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        
            
           
            
            NavigationStack {
              
                ZStack{
                    BackgroundColorTemplate()
                    VStack(alignment: .leading, spacing: 0) {
                        // ——— Header externo (idéntico en ambas pantallas) ———
                        Header()
                            .frame(height: 40)
                            .padding(.horizontal)
                            .padding(.top, 10)    // 📌 Mismo padding top que en EventsView
                            .padding(.bottom, 5)

                        if hSizeClass == .regular {
                         ProjectMark()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                        } else {
                            // ——— Cuerpo: TaskMark ocupa todo el espacio que queda ———
                            ProjectMark()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                        }
                    }
                   
                    .ignoresSafeArea(edges: .bottom)  // si necesitas cubrir hasta el fondo
                }
            }
        
     
    }
    
    
    
}
