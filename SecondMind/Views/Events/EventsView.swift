import SwiftUI
import SwiftData

struct EventsView: View {
  
        
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

                            // ——— Cuerpo: TaskMark ocupa todo el espacio que queda ———
                            EventMark()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                        
                    }
                   
                    .ignoresSafeArea(edges: .bottom)  // si necesitas cubrir hasta el fondo
                    
                }
          
            }
           
        }
        
        
        
    }
