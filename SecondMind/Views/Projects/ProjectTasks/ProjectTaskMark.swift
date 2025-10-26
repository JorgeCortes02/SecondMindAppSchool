//
//  ProjectTaskMask.swift
//  SecondMind
//
//  Created by Jorge Cortes on 20/9/25.
//

import SwiftUI
import SwiftData
import Foundation

struct ProjectTaskMark: View {
    
    @StateObject var modelView = TaskMarkProjectDetallModelView()
    @EnvironmentObject var  utilFunctions : generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass   // ← añadido: para layout iPad/iPhone
    
    
    @Bindable var project: Project
    @State private var usableSize: CGSize = .zero
    @State private var selectedData: Date = Date()
    private let accentColor = Color.taskButtonColor
    
    
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    @State private var isSyncing = false                        // ← añadido: estado para botón sync
    @State private var refreshID = UUID()                       // ← añadido: para refrescar ScrollView
    
    
    var body: some View {
        
        ZStack{
            
            VStack(spacing: 20) {
                // TÍTULO ADAPTADO: nombre del proyecto
                headerCard(title: "Tareas de \(project.title)").padding(.top, 16)
                PickerBar(options: ["Sin fecha", "Agendadas", "Finalizadas"], selectedTab: $modelView.selectedTab)
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // ===========================
                        //   iPad (2 columnas, 800px)
                        // ===========================
                        if sizeClass == .regular {
                            
                            // Sin fecha
                            if modelView.selectedTab == 0 {
                                sectionNoDate_iPad()
                            }
                            
                            // Agendadas (DatePicker + grid)
                            else if modelView.selectedTab == 1 {
                                sectionScheduled_iPad()
                            }
                            
                            // Finalizadas
                            else {
                                sectionCompleted_iPad()
                            }
                        }
                        
                        // ===========================
                        //   iPhone (flujo original)
                        // ===========================
                        else {
                            if modelView.selectedTab == 1 && showCal {
                                calendarCard(selectedDate: $selectedData)
                                
                            } else {
                                TaskCard
                            }
                        }
                        
                    }
                    .padding(.vertical, 16)
                }
                .id(refreshID)
                .refreshable {
                    Task {
                        isSyncing = true
                        await SyncManagerDownload.shared.syncTasks(context: context)
                        switch modelView.selectedTab {
                        case 0:
                            modelView.loadEvents()
                        case 1:
                            modelView.loadEvents(selectedData: selectedData)
                        default:
                            modelView.loadEvents()
                        }
                        withAnimation(.easeOut(duration: 0.3)) {
                            isSyncing = false
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                // 👇 Botón flotante bien colocado, no tapa el contenido
                HStack {
                    Spacer()
                    buttonControlMark
                }
            }
            .ignoresSafeArea(.keyboard)
            .onAppear {
                modelView.setParameters(context: context, project: project)
                
                // 👇 Carga inicial de tareas al abrir la vista
                switch modelView.selectedTab {
                case 0:
                    modelView.loadEvents()
                case 1:
                    modelView.loadEvents(selectedData: selectedData)
                default:
                    modelView.loadEvents()
                }
            }.sheet(isPresented: $showAddTaskView, onDismiss: {
                
                switch modelView.selectedTab
                {
                case 0 :
                    modelView.loadEvents()
                case 1 :
                    modelView.loadEvents(selectedData: selectedData)
                default:
                    break;
                }
                
            }){
                CreateTask(project: project)
            }
        }
    }
    
    
    
    
    
    // MARK: – Botonera inferior (ampliada con Sync en iPad, mantiene tu lógica iPhone)
    private var buttonControlMark: some View {
        
        
        glassButtonBar(funcAddButton: {showAddTaskView = true},
                       funcSyncButton: {
            Task {
                isSyncing = true
                await SyncManagerDownload.shared.syncEvents(context: context)
                withAnimation(.easeOut(duration: 0.3)) {
                    refreshID = UUID()
                    isSyncing = false
                }
            }
        },
                       funcCalendarButton: {withAnimation(.easeInOut) { showCal.toggle() }}
                       , color: accentColor, selectedTab: $modelView.selectedTab, isSyncing: $isSyncing)
        
        
    }
    
    // ============================================================
    //  iPad – Secciones con grid 2 columnas (máx. 800 px)
    // ============================================================
    
    // SIN FECHA (iPad)
    private func sectionNoDate_iPad() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sin fecha")
                    .foregroundColor(.primary)
                    .font(.title2.weight(.bold))
                Spacer()
                Text("\(modelView.tasks.filter { $0.endDate == nil && $0.status == .on }.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            let tasks = modelView.tasks.filter { $0.endDate == nil && $0.status == .on }
            if tasks.isEmpty {
                emptyTaskList
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(tasks, id: \.id) { task in
                        TaskCardExpanded(task: task)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: 800)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // AGENDADAS (iPad) → DatePicker + grid
    private func sectionScheduled_iPad() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(utilFunctions.formattedDate(selectedData))
                    .foregroundColor(.primary)
                    .font(.title2.weight(.bold))
                Spacer()
                let count = modelView.tasks.filter {
                    if let due = $0.endDate {
                        return Calendar.current.isDate(due, inSameDayAs: selectedData) && $0.status == .on
                    }
                    return false
                }.count
                Text("\(count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            // DatePicker centrado y con marco
            HStack {
                Spacer()
                DatePicker(
                    "",
                    selection: $selectedData,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.taskButtonColor.opacity(0.4), lineWidth: 1)
                        )
                )
                .frame(maxWidth: 300)
                Spacer()
            }
            .padding(.vertical, 8)
            .onChange(of: selectedData) {
                modelView.loadEvents(selectedData: selectedData)
            }
            
            let datedTasks = modelView.tasks.filter {
                if let due = $0.endDate {
                    return Calendar.current.isDate(due, inSameDayAs: selectedData) && $0.status == .on
                }
                return false
            }
            if datedTasks.isEmpty {
                emptyTaskList
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(datedTasks, id: \.id) { task in
                        TaskCardExpanded(task: task)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: 800)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // FINALIZADAS (iPad)
    private func sectionCompleted_iPad() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tareas finalizadas")
                    .foregroundColor(.primary)
                    .font(.title2.weight(.bold))
                Spacer()
                Text("\(modelView.tasks.filter { $0.status == .off }.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            let completedTasks = modelView.tasks.filter { $0.completeDate != nil }
            if completedTasks.isEmpty {
                emptyTaskList
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(completedTasks, id: \.id) { task in
                        TaskCardExpanded(task: task)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: 800)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    // Tarjeta expandida (estilo TaskMark iPad)
    private func TaskCardExpanded(task: TaskItem) -> some View {
        NavigationLink(destination: TaskDetall(editableTask: task)) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    // ✅ Icono principal y título
                    HStack(spacing: 8) {
                        Image(systemName: task.endDate == nil ? "checklist" : "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                        
                        Text(task.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                    
                    // ✅ Botón de completar
                    if task.status == .on {
                        Button(action: {
                            task.completeDate = Date()
                            task.status = .off
                            do {
                                Task{
                                    await SyncManagerUpload.shared.uploadTask(task: task)
                                }
                                try context.save()
                                withAnimation(.easeOut(duration: 0.25)) {
                                    modelView.tasks.removeAll { $0.id == task.id }
                                }
                            } catch {
                                print("❌ Error al marcar tarea como completa: \(error)")
                            }
                        }) {
                            Image(systemName: "circle")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                    }
                }
                
                // 📁 Proyecto
                Label(project.title, systemImage: "folder")
                    .font(.caption)
                    .foregroundColor(.purple)
                
                // 📅 Evento
                if let event = task.event {
                    Label(event.title, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(Color.eventButtonColor)
                } else {
                    Label("Sin evento", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                // ⏰ Hora (si tiene fecha)
                if let due = task.endDate {
                    HStack {
                        Image(systemName: "clock")
                        Text(utilFunctions.extractHour(due))
                    }
                    .font(.caption)
                    .foregroundColor(accentColor)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    
    private var TaskCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                
                if modelView.selectedTab == 0 {
                    Text("Tareas de hoy")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }else if modelView.selectedTab == 1 {
                    Text(utilFunctions.formattedDate(selectedData)).foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }else{
                    Text("Tareas finalizadas").foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                Text("\(modelView.tasks.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            if modelView.tasks.isEmpty {
                
                emptyTaskList
                
            } else if modelView.readyToShowTasks {
                
                if modelView.selectedTab == 2 {
                    endTaskList
                }else{
                    
                    taskListToDo
                }
                
                
                
                
            }
        }
        
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            
            if modelView.selectedTab == 1 {
                
                modelView.loadEvents(selectedData: selectedData)
                
            }else{
                
                modelView.loadEvents()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    modelView.readyToShowTasks = true
                }
            }
            
        }
        
    }
    
    private func calendarCard(selectedDate: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona fecha")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            DatePicker(
                "",
                selection: selectedDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(.horizontal, 20).onChange(of: selectedData) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    modelView.readyToShowTasks = true
                    print(selectedData)
                    modelView.loadEvents(selectedData: selectedData)
                }
                
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        modelView.readyToShowTasks = true
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardBG)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    
    private var emptyTaskList: some View {
        
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "checkmark.seal.text.page")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 90)
                .foregroundColor(accentColor.opacity(0.7))
            
            Text("No hay tareas disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .padding(20)
    }
    
    
    private var taskListToDo: some View {
        LazyVStack(spacing: 12) {
            ForEach(modelView.tasks, id: \.id) { task in
                NavigationLink(destination: TaskDetall(editableTask: task)) {
                    HStack(spacing: 12) {
                        // Icono inicial
                        Image(systemName: "checklist")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                        
                        // Texto principal (título)
                        Text(task.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer() // 🔹 empuja hora + botón al final
                        
                        // Hora pegada al botón
                        if let due = task.endDate {
                            Label {
                                Text(utilFunctions.extractHour(due))
                            } icon: {
                                Image(systemName: "clock")
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(accentColor.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        
                        // Botón de completar
                        Button(action: {
                            task.completeDate = Date()
                            task.status = .off
                            do {
                                Task{
                                    
                                    await SyncManagerUpload.shared.uploadTask(task: task)
                                    
                                }
                                try context.save()
                                modelView.tasks.removeAll { $0.id == task.id }
                            } catch {
                                print("❌ Error al guardar: \(error)")
                            }
                        }) {
                            Image(systemName: "circle")
                                .font(.system(size: 21))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }}
        }
        .padding(.vertical, 8)
        
        // o lo que estimes conveniente
        .animation(.easeOut(duration: 0.35), value: modelView.tasks)
    }
    
    private var endTaskList : some View {
        
        
        
        let completedTasks = modelView.tasks.filter { $0.completeDate != nil }
        
        let groupTaskByDate = Dictionary(grouping: completedTasks) { task in
            Calendar.current.startOfDay(for: task.completeDate!)
        }
        
        let groupTaskByDateOrdered = groupTaskByDate
            .map { (date: $0.key, task: $0.value) }
            .sorted { $0.date > $1.date }
        
        return LazyVStack(spacing: 12) {
            
            ForEach(groupTaskByDateOrdered, id: \.date){ tasks in
                
                Text("\(utilFunctions.formattedDate(tasks.date))").font(.title3.weight(.bold))
                    .foregroundColor(.primary).padding().background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 0.8),
                                Color(red: 0.90, green: 0.90, blue: 0.93, opacity: 0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )    .cornerRadius(20)
                    )
                
                ForEach(tasks.task, id: \.id) { task in
                    NavigationLink(destination: TaskDetall(editableTask: task)) {
                        
                        HStack(spacing: 12) {
                            Image(systemName: "checklist")
                                .font(.system(size: 20))
                                .foregroundColor(accentColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary).lineLimit(1)             // Limita a una línea
                                    .truncationMode(.tail)
                                if let due = task.endDate {
                                    Text(utilFunctions.formattedDate(due))
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            
                            Button(action: {
                                
                                
                                
                                do {
                                    try context.delete(task)
                                    withAnimation {
                                        modelView.tasks.removeAll { $0.id == task.id }
                                    }
                                } catch {
                                    print("❌ Error al guardar: \(error)")
                                }
                                
                                
                            }) {
                                
                                Image(systemName: "trash")
                                    .font(.system(size: 21))
                                    .foregroundColor(Color.red)
                            }
                            
                        }
                        .padding(12)
                        
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        
                    }}            }
            
        }
        .padding(.vertical, 8)
        
        // o lo que estimes conveniente
        .animation(.easeOut(duration: 0.35), value: modelView.tasks
                   
        )
    }
}
