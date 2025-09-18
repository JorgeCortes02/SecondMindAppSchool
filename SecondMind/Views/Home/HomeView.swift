import SwiftUI
import SwiftData

struct HomeView: View {
    
    
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @EnvironmentObject var  utilFunctions : generalFunctions
    @State private var todayEvents: [Event] = []
    @State private var todayTask: [TaskItem] = []
    @EnvironmentObject var loginVM: LoginViewModel
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing){
                
                
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
                                .fill(Color.taskButtonColor) // Azul intenso
                                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                        .foregroundColor(.white) // ⚙️ en blanco
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
                            // iPad: centrar el contenido y usar anchos máximos para no dejar tanto espacio vacío
                            VStack(spacing: 24) {
                                TodayElementsView(todayTask: $todayTask, todayEvent: $todayEvents)
                                    .frame(maxWidth: 800)
                                
                                HStack(alignment: .top, spacing: 24) {
                                    TodayTaskView(todayTask: $todayTask)
                                        .frame(maxWidth: 380)
                                    
                                    TodayEventView(todayEvent: todayEvents)
                                        .frame(maxWidth: 380)
                                }
                                .frame(maxWidth: 800)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                        } else {
                            // iPhone: diseño original
                            VStack(alignment: .leading, spacing: 10) {
                                headerCard
                                
                                TodayElementsView(todayTask: $todayTask, todayEvent: $todayEvents)
                                
                                TodayTaskView(todayTask: $todayTask)
                                TodayEventView(todayEvent: todayEvents)
                                                 }
                            .padding(.vertical, 16)
                        }
                    }
                    
                }.onAppear
                    {
                        loginVM.isLoading = false
                       todayTask = HomeApi.fetchTodayTasks(context: context)
                        todayEvents = HomeApi.fetchTodayEvents(context: context)
                    }
                

                
                
            }
        }
        
        
    }
    
    private var headerCard: some View {
        VStack(spacing: 10) {
            // — Título y botón “+” —
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

