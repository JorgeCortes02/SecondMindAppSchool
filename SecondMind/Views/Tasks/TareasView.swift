// MARK: – TaskView.swift

import SwiftUI
import SwiftData

struct TaskView: View {
    
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        NavigationStack {
            ZStack{
                
                BackgroundColorTemplate()
                VStack(alignment: .leading, spacing: 0) {
                    
                    if hSizeClass == .compact {
                        Header()
                            .frame(height: 40)
                            .padding(.horizontal)
                            .padding(.top, 10)    // 📌 Mismo padding top que en EventsView
                            .padding(.bottom, 5)
                    }
                    // ——— Header externo (idéntico en ambas pantallas) ———
                    
                        TaskMark()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                          
                    
                }
                .ignoresSafeArea(edges: .bottom)  // si necesitas cubrir hasta el fondo
            }
        }
        
    }
    
    
    
}
