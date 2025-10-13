//
//  ProjectEventView.swift
//  SecondMind
//
//  Created by Jorge Cortes on 20/9/25.
//

import SwiftUI
import SwiftData

struct ProjectEventsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Bindable var project: Project

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColorTemplate()

                VStack(alignment: .leading, spacing: 0) {
                    // ——— Header externo (idéntico en ambas pantallas) ———
                    Header()
                        .frame(height: 40)
                        .padding(.horizontal)
                        .padding(.top, 10)    // 📌 Igual que en EventsView
                        .padding(.bottom, 5)

               
                        // ——— Cuerpo: ProjectEventMark ocupa todo el espacio ———
                        ProjectEventMark(project: project)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
