//
//  EventTaskView.swift
//  SecondMind
//
//  Created by Jorge Cortés on 10/11/25.
//


import SwiftUI
import SwiftData

struct EventTaskView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Bindable var event: Event
    
    var body: some View {
        NavigationStack {
            ZStack{
                
                BackgroundColorTemplate()
                
                VStack(alignment: .leading, spacing: 0) {
                    if hSizeClass == .compact{
                        Header()
                            .frame(height: 40)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                
                    // ——— Cuerpo: EventTaskMark ocupa todo el espacio que queda ———
                    EventTaskMark(event: event)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
