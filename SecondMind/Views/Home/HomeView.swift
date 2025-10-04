import SwiftUI
import SwiftData

struct HomeView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @EnvironmentObject var utilFunctions: generalFunctions
    @EnvironmentObject var loginVM: LoginViewModel
    
    @StateObject private var homeVM = HomeFilesModelView()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                
                // ⚙️ Menú de perfil
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
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.taskButtonColor)
                                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                        .foregroundColor(.white)
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
                }
                .onAppear {
                    homeVM.setContext(context: context)
                    loginVM.isLoading = false
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
