// MARK: – HomeView.swift

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @EnvironmentObject var utilFunctions: generalFunctions
    @EnvironmentObject var loginVM: LoginViewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                
                // ⚙️ Menú de perfil con botón Liquid Glass
                Menu {
                    NavigationLink(destination: SettingView()) {
                        Label("Perfil", systemImage: "person.crop.circle")
                    }

                    Divider()

                    Button(role: .destructive) {
                        loginVM.logout()
                    } label: {
                        Label("Cerrar sesión", systemImage: "arrow.backward.circle")
                    }
                } label: {
                    if #available(iOS 26.0, *) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.taskButtonColor)
                            .padding(16)
                            .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                            .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                    } else {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.9))
                                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            )
                    }
                }
                .padding(.top, 5)
                .padding(.trailing, 25)
                .zIndex(1000)
                
                BackgroundColorTemplate()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    if hSizeClass == .compact {
                        Header()
                            .frame(height: 40)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                    }
                    
                    
                  
                    
                    HomeMark() // ✅ Tu nuevo contenedor con scroll y botonera
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}
