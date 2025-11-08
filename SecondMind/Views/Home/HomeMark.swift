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

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(alignment: .center, spacing: 24) {
                        
                        if hSizeClass == .regular {
                            // 📱 iPad o pantallas grandes
                            VStack(spacing: 24) {
                                GreetingCard(name: loginVM.userSession.name)
                                TodayElementsView(todayTask: $homeVM.todayTask, todayEvent:  $homeVM.todayEvents)
                                
                                HStack(alignment: .top, spacing: 24) {
                                    TodayTaskView(todayTask: $homeVM.todayTask)
                                    TodayEventView(todayEvent: homeVM.todayEvents)
                                }
                                .frame(maxWidth: 800)
                            }
                            .padding(.vertical, 24)
                            
                        } else {
                            // 📱 iPhone
                            VStack(alignment: .leading, spacing: 18) {
                                GreetingCard(name: loginVM.userSession.name)
                                
                                TodayElementsView(todayTask: $homeVM.todayTask, todayEvent: $homeVM.todayEvents)
                                
                                TodayTaskView(todayTask: $homeVM.todayTask)
                                
                                TodayEventView(todayEvent: homeVM.todayEvents)
                            }
                            .padding(.vertical, 18)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 16)
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
                }
                .refreshable {
                    Task { await homeVM.refreshAll() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    ButtonCreateNew(
                        funcAddTask: {showAddTaskView = true },
                        funcAddEvent: { showAddEventView = true },
                        funcAddProject: { showAddProjectView = true },
                        funcAddNote: { showAddNoteView = true },
               
                      
                    )                }
            }
            .onAppear {
                homeVM.setContext(context: context)
                if !didInitialLoad {
                    didInitialLoad = true
                    Task { await homeVM.refreshAll() }
                }
            }
        }
    }
}

struct GreetingCard: View {
    let name: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Hola, \(name)! ")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.taskButtonColor)
        }
        .padding(.horizontal, 20)
    }
}
