import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @EnvironmentObject var utilFunctions: generalFunctions
    @EnvironmentObject var loginVM: LoginViewModel
    
    @StateObject private var homeVM = HomeFilesModelView()
    @State private var didInitialLoad = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                
                // ⚙️ Menú de perfil con botón Liquid Glass
                Menu {
                    // 🔹 Opción de perfil
                    NavigationLink(destination: SettingView()) {
                        Label("Perfil", systemImage: "person.crop.circle")
                    }

                    Divider()

                    // 🔹 Cerrar sesión
                    Button(role: .destructive) {
                        loginVM.logout()
                    } label: {
                        Label("Cerrar sesión", systemImage: "arrow.backward.circle")
                    }

                } label: {
                    // 🧊 Botón estilo Liquid Glass
                    if #available(iOS 26.0, *) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.taskButtonColor)
                            .padding(16)
                            .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                            .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                    } else {
                        // 💧 Fallback para versiones anteriores sin glassEffect
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
                
                VStack(alignment: .leading) {
                    
                    Header()
                        .frame(height: 40)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        if hSizeClass == .regular {
                            VStack(spacing: 24) {
                                
                                TodayElementsView(todayTask: $homeVM.todayTask, todayEvent: $homeVM.todayEvents)
                                    .frame(maxWidth: 800)
                                
                                HStack(alignment: .top, spacing: 24) {
                                    TodayTaskView(todayTask: $homeVM.todayTask)
                                        .frame(maxWidth: 380)
                                    
                                    TodayEventView(todayEvent: homeVM.todayEvents)
                                        .frame(maxWidth: 380)
                                }
                                .frame(maxWidth: 800)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                headerCard
                                
                                TodayElementsView(todayTask: $homeVM.todayTask, todayEvent: $homeVM.todayEvents)
                                
                                TodayTaskView(todayTask: $homeVM.todayTask)
                                TodayEventView(todayEvent: homeVM.todayEvents)
                            }
                            .padding(.vertical, 16)
                        }
                    }
                    // 👇 Pull-to-refresh
                    .refreshable {
                        
                        Task{
                            await homeVM.refreshAll()
                        }
                    }
                }
                // 👇 Mensaje overlay de éxito
                .overlay(alignment: .top) {
                    if let msg = homeVM.updateMessage {
                        Text(msg)
                            .font(.callout)
                            .padding(8)
                            .background(Color.green.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.top, 50)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: msg)
                    }
                }.animation(.easeInOut, value: homeVM.updateMessage)
                .onAppear {
                    homeVM.setContext(context: context)
                    loginVM.isLoading = false
                    if !didInitialLoad {
                        didInitialLoad = true  // 👈 evita que se repita
                        Task {
                            print("🚀 Primera carga del Home: ejecutando refreshAll()")
                            await homeVM.refreshAll()
                            print("✅ Datos sincronizados correctamente")
                        }
                    }
                   
                }
            }
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Hola, \(loginVM.userSession.name)! ")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.taskButtonColor)
            }
            .padding(.horizontal, 20)
        }
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
}
