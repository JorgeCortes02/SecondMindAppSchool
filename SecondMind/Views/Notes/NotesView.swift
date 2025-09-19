//
//  NotesView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 18/9/25.
//

import SwiftUI
import SwiftData

struct NotesView: View {
  
        
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
                            Text("Vista para iPad pendiente")
                                .padding()
                        } else {
                            // ——— Cuerpo: TaskMark ocupa todo el espacio que queda ———
                          NoteMark()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                        }
                    }
                   
                    .ignoresSafeArea(edges: .bottom)  // si necesitas cubrir hasta el fondo
                    
                }
          
            }
           
        }
        
        
        
    }
