//
//  ProjectTaskView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 20/9/25.
//

// MARK: – TaskView.swift

import SwiftUI
import SwiftData

struct ProjectTaskView: View {
    
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Bindable var project: Project
    var body: some View {
        NavigationStack {
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
                    ProjectTaskMark(project : project)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                      
                }
            }
            .ignoresSafeArea(edges: .bottom)  // si necesitas cubrir hasta el fondo
        }
        
    }
    
    
    
}
