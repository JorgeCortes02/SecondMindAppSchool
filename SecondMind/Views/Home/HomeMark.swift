import SwiftUI
import SwiftData

struct HomeMark: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var utilFunctions: generalFunctions
    @EnvironmentObject var loginVM: LoginViewModel
    
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    @StateObject private var homeVM = HomeFilesModelView()
    @State private var didInitialLoad = false
    @State private var isSyncing = false
    @State private var showAddTaskView: Bool = false
    @State private var showAddEventView: Bool = false
    @State private var showAddProjectView: Bool = false
    @State private var showAddNoteView: Bool = false

    // 🎨 Colores consistentes
    private let purpleAccent = Color(red: 176/255, green: 133/255, blue: 231/255)
    private let cardStroke = Color(red: 176/255, green: 133/255, blue: 231/255).opacity(0.15)
    private let fieldBG = Color(red: 248/255, green: 248/255, blue: 250/255)
    
    var body: some View {
        if hSizeClass == .regular {
            // iPad: sin GeometryReader, se ajusta al contenido
            iPadView
        } else {
            // iPhone: con GeometryReader para ocupar toda la pantalla
            iPhoneView
        }
    }
    
    // Vista para iPad
    private var iPadView: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 26) {
                    Header()
                        .frame(height: 40)
                        .padding(.horizontal)
                        .padding(.top, 18 + 26)
                      
                    ScrollView {
                        
                        VStack(spacing: 26) {
                            greetingCard
                                
                            TodayElementsView(todayTask: $homeVM.todayTask, todayEvent: $homeVM.todayEvents)
                            
                            HStack(alignment: .top, spacing: 24) {
                                TodayTaskView(todayTask: $homeVM.todayTask)
                                TodayEventView(todayEvent: homeVM.todayEvents)
                            }
                            .frame(maxWidth: 800)
                        }
                        .padding(.bottom, 26)
                    }
                    .frame(maxHeight: 600) // ← Limita la altura máxima del ScrollView
                    .clipShape(RoundedRectangle(cornerRadius: 36))
                    .refreshable {
                        Task { await homeVM.refreshAll() }
                    }
                }
                .frame(maxWidth: 1200)
                .background(
                    RoundedRectangle(cornerRadius: 36)
                        .fill(Color(red: 0.97, green: 0.96, blue: 1.0))
                        .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 36)
                        .stroke(cardStroke, lineWidth: 1)
                )
                .padding(.horizontal, 10)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                Spacer() // ← Empuja el contenido hacia arriba
            }
            .sheet(isPresented: $showAddEventView, onDismiss: {
                homeVM.todayEvents = HomeApi.fetchTodayEvents(context: context)
            }) {
                CreateEvent()
            }
            .sheet(isPresented: $showAddTaskView, onDismiss: {
                homeVM.todayTask = HomeApi.fetchTodayTasks(context: context)
            }) {
                CreateTask()
            }
            .sheet(isPresented: $showAddProjectView) {
                CreateProject()
            }
            .onAppear {
                homeVM.setContext(context: context)
                if !didInitialLoad {
                    didInitialLoad = true
                    Task { await homeVM.refreshAll() }
                }
            }
            
            // Botón flotante sobre el contenido
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ButtonCreateNew(
                        funcAddTask: { showAddTaskView = true },
                        funcAddEvent: { showAddEventView = true },
                        funcAddProject: { showAddProjectView = true },
                        funcAddNote: { showAddNoteView = true }
                    )
                }
            }
        }
    }
    // Vista para iPhone
    private var iPhoneView: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 26) {
                        GeometryReader { scrollGeo in
                            ScrollView {
                                greetingCard
                                    .padding(.top, 26)
                                VStack(spacing: 26) {
                                    TodayElementsView(todayTask: $homeVM.todayTask, todayEvent: $homeVM.todayEvents)
                                    
                                    VStack(alignment: .leading, spacing: 22) {
                                        TodayTaskView(todayTask: $homeVM.todayTask)
                                        TodayEventView(todayEvent: homeVM.todayEvents)
                                    }
                                    
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: scrollGeo.size.height, alignment: .top)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 36))
                            .refreshable {
                                Task { await homeVM.refreshAll() }
                            }
                        }
                    }
                    .frame(maxWidth: 800)
                    .background(
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color(red: 0.97, green: 0.96, blue: 1.0))
                            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(cardStroke, lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                }
                .frame(maxHeight: .infinity)
                .padding(.bottom, geo.safeAreaInsets.bottom + 100)
                .ignoresSafeArea(edges: .bottom)
                .sheet(isPresented: $showAddEventView, onDismiss: {
                    homeVM.todayEvents = HomeApi.fetchTodayEvents(context: context)
                }) {
                    CreateEvent()
                }
                .sheet(isPresented: $showAddTaskView, onDismiss: {
                    homeVM.todayTask = HomeApi.fetchTodayTasks(context: context)
                }) {
                    CreateTask()
                }
                .sheet(isPresented: $showAddProjectView) {
                    CreateProject()
                }
                .onAppear {
                    homeVM.setContext(context: context)
                    if !didInitialLoad {
                        didInitialLoad = true
                        Task { await homeVM.refreshAll() }
                    }
                }
                
                // Botón flotante sobre el contenido
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ButtonCreateNew(
                            funcAddTask: { showAddTaskView = true },
                            funcAddEvent: { showAddEventView = true },
                            funcAddProject: { showAddProjectView = true },
                            funcAddNote: { showAddNoteView = true }
                        )
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    // 🟥 Cabecera estilizada dentro de la tarjeta
    private var greetingCard: some View {
        HStack(spacing: 10) {
            if hSizeClass == .compact {
                // iPhone: alineado a la izquierda
                Image(systemName: "hand.wave")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(purpleAccent)
                Text("Hola, \(loginVM.userSession.name)!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            } else {
                // iPad: centrado
                Spacer()
                Image(systemName: "hand.wave")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(purpleAccent)
                Text("Hola, \(loginVM.userSession.name)!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
}
