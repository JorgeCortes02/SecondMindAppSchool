// ContentView.swift
// SecondMind

import SwiftUI
import SwiftData

// MARK: — Vista Principal con TabBar
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var navModel: SelectedViewList
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State var deletedTaskToday: Bool = false
   
    

 
    
 
    var body: some View {
        
        
        
        Group {
            if sizeClass == .compact {
                // iPhone o iPad Portrait: TabView normal
                TabView(selection: $navModel.selectedView) {
                    HomeView()
                        .tabItem { Label("Inicio", systemImage: "house.fill") }
                        .tag(0)
                    ProjectView()
                        .tabItem { Label("Proyectos", systemImage: "folder.fill") }
                        .tag(3)
                    TaskView()
                        .tabItem { Label("Tareas", systemImage: "checkmark.circle.fill") }
                        .tag(1)
                    EventsView()
                        .tabItem { Label("Eventos", systemImage: "calendar") }
                        .tag(2)
                    NotesView()
                        .tabItem { Label("Notas", systemImage: "square.and.pencil") }
                        .tag(4)
                }
                .accentColor(Color.taskButtonColor)
            } else {
                // iPad Landscape: Sidebar lateral colapsable
                ZStack(alignment: .topLeading) {
                
                    
                    // Contenido principal
                    VStack(spacing: 0) {
                      
                    
                 
                        
                        // Contenido de la vista
                        contentView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .gesture(
                        // Gesto global para abrir desde cualquier parte del borde izquierdo
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                // Solo activar si empieza desde el borde izquierdo
                                if !navModel.showSidebar && value.startLocation.x < 50 && value.translation.width > 50 {
                                    withAnimation {
                                        navModel.showSidebar = true
                                    }
                                }
                            }
                    )
                    
                    // Sidebar deslizable
                    if navModel.showSidebar {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center){
                                Spacer()
                                Text("Second")
                                    .font(.system(size: 35, weight: .semibold))
                                    .foregroundColor(.taskButtonColor)

                                Text("Mind")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(Color(red: 47 / 255, green: 129 / 255, blue: 198 / 255))
                                Button(action: {
                                    withAnimation {
                                        navModel.showSidebar.toggle()
                                    }
                                }){
                                    
                                    Image(systemName: "sidebar.left").foregroundStyle(Color.taskButtonColor)
                                        .font(.system(size: 20, weight: .medium))
                                        .frame(width: 28)
                                       
                                    
                                }
                                Spacer()
                            }
                            Divider()
                            
                            ScrollView {
                                VStack(spacing: 6) {
                                    sidebarButton(tag: 0, title: "Inicio", icon: "house.fill")
                                    sidebarButton(tag: 3, title: "Proyectos", icon: "folder.fill")
                                    sidebarButton(tag: 1, title: "Tareas", icon: "checkmark.circle.fill")
                                    sidebarButton(tag: 2, title: "Eventos", icon: "calendar")
                                    sidebarButton(tag: 4, title: "Notas", icon: "square.and.pencil")
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 8)
                            }
                            
                            Spacer()
                        }
                        .frame(width: 280)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 0)
                        .transition(.move(edge: .leading))
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    // Cerrar sidebar deslizando hacia la izquierda
                                    if value.translation.width < -50 {
                                        withAnimation {
                                            navModel.showSidebar = false
                                        }
                                    }
                                }
                        )
                    }
                    
                    // Indicador visual en el borde izquierdo
                    if !navModel.showSidebar {
                        HStack {
                            LinearGradient(
                                colors: [
                                    Color.taskButtonColor.opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 3)
                            .frame(maxHeight: .infinity)
                            .allowsHitTesting(false)
                            
                            Spacer()
                        }
                    }
                    
                    // Botón flotante semicircular pegado al borde
                    if !navModel.showSidebar {
                        HStack {
                            VStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        navModel.showSidebar.toggle()
                                    }
                                }) {
                                    HStack(spacing: 0) {
                                        // Parte visible del botón
                                        ZStack {
                                            // Semicírculo que sobresale
                                            Circle()
                                                .fill(Color.taskButtonColor)
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Image(systemName: "chevron.right")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.white)
                                                )
                                                .shadow(color: .black.opacity(0.2), radius: 8, x: 2, y: 0)
                                        }
                                        .offset(x: -25) // La mitad del círculo queda fuera del borde
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .allowsHitTesting(true)
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                if let lastUpdate = HomeApi.loadLastDeleteTaskDate(context: context) {
                 
                    if let lastUpdateDate = lastUpdate.date {
                        deletedTaskToday = todayDiferentLastUpdate(lastUpdateDate: lastUpdateDate)
                        print(deletedTaskToday)
                        if deletedTaskToday {
                            deleteOldTask()
                        }
                        
                        context.delete(lastUpdate)
                        context.insert(LastDeleteTask(date: Date()))
                    }
                }
                
            }
        }
    }
    
    // MARK: - Botón del sidebar (para landscape)
    private func sidebarButton(tag: Int, title: String, icon: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                navModel.selectedView = tag
                navModel.showSidebar = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .frame(width: 28)
                    .foregroundColor(navModel.selectedView == tag ? .white : .taskButtonColor)
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(navModel.selectedView == tag ? .white : .primary)
                
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(navModel.selectedView == tag ? Color.taskButtonColor : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Vista de contenido según la selección
    @ViewBuilder
    private var contentView: some View {
        switch navModel.selectedView {
        case 0:
            HomeView()
        case 1:
            TaskView()
        case 2:
            EventsView()
        case 3:
            ProjectView()
        case 4:
            NotesView()
        default:
            HomeView()
        }
    }
    
    private func deleteOldTask() {
        let oldTask: [TaskItem] = HomeApi.loadTasksEnd(context: context)
        let sevenDays: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
        for task in oldTask {
            if let completeDate = task.completeDate {
                if completeDate < sevenDays {
                    context.delete(task)
                }
            } else {
                print("⚠️ Tarea sin fecha, no se elimina")
            }
        }
    }
    
    private func todayDiferentLastUpdate(lastUpdateDate: Date) -> Bool {
        return !Calendar.current.isDateInToday(lastUpdateDate)
    }
}
