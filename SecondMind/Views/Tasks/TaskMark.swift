import SwiftUI
import SwiftData

struct TaskMark: View {
    
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var sizeClass
    @StateObject private var modelView: TaskViewModel
    @State private var refreshID = UUID()
    init() {
        _modelView = StateObject(wrappedValue: TaskViewModel())
    }

    @State var listTask: [TaskItem] = []
    @State private var readyToShowTasks: Bool = false
    @State private var usableSize: CGSize = .zero
    @State private var selectedData: Date = Date()
    @State private var isSyncing = false
    private let accentColor = Color.taskButtonColor
    
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    
   
    var body: some View {
        ZStack {
         
            
            VStack(spacing: 20) {
                headerCard(title: "Tareas")
                    .padding(.top, 16)
                
                // MARK: – Picker bar adaptado para iPad
                if sizeClass == .regular {
                    HStack(spacing: 10) {
                        segmentButton(title: "Activas", tag: 0)
                        segmentButton(title: "Finalizadas", tag: 1)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 40)
                            .fill(Color.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 40)
                                    .stroke(Color.taskButtonColor.opacity(0.4), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: 360) // 👈 ancho máximo, centrado y equilibrado
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                } else {
                    pickerBard
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: iPad Layout
                        if sizeClass == .regular {
                            if modelView.selectedTab == 0 {
                                // MARK: ACTIVA (Sin fecha + Agendadas)
                                VStack(spacing: 24) {
                                    
                                    // 🔹 SIN FECHA
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Sin fecha")
                                                .foregroundColor(.primary)
                                                .font(.title2.weight(.bold))
                                            Spacer()
                                            Text("\(HomeApi.fetchNoDateTasks(context: context).count)")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)
                                        
                                        Rectangle()
                                            .fill(Color.primary.opacity(0.1))
                                            .frame(height: 1)
                                        
                                        let noDateTasks = HomeApi.fetchNoDateTasks(context: context)
                                        if noDateTasks.isEmpty {
                                            emptyTaskList
                                        } else {
                                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                                ForEach(noDateTasks, id: \.id) { task in
                                                    TaskCardExpanded(task: task)
                                                }
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.bottom, 10)
                                        }
                                    }
                                    .frame(maxWidth: 800)
                                    .background(Color.cardBackground)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                                    
                                    // 🔹 AGENDADAS
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("Agendadas")
                                                .foregroundColor(.primary)
                                                .font(.title2.weight(.bold))
                                            Spacer()
                                            Text("\(HomeApi.fetchDateTasks(date: selectedData, context: context).count)")
                                                .font(.subheadline.weight(.medium))
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 16)
                                        
                                        Rectangle()
                                            .fill(Color.primary.opacity(0.1))
                                            .frame(height: 1)
                                        
                                        // ✨ DatePicker centrado con marco
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
                                            listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
                                        }
                                        
                                        let datedTasks = HomeApi.fetchDateTasks(date: selectedData, context: context)
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
                                    .background(Color.cardBackground)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                    .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity)
                                
                            } else {
                                // MARK: FINALIZADAS
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Finalizadas")
                                            .foregroundColor(.primary)
                                            .font(.title2.weight(.bold))
                                        Spacer()
                                        Text("\(HomeApi.loadTasksEnd(context: context).count)")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 16)
                                    
                                    Rectangle()
                                        .fill(Color.primary.opacity(0.1))
                                        .frame(height: 1)
                                    
                                
                                    
                                    let completedTasks = HomeApi.loadTasksEnd(context: context).filter {
                                        guard let date = $0.completeDate else { return false }
                                        return Calendar.current.isDate(date, inSameDayAs: selectedData)
                                    }
                                    
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
                                .background(Color.cardBackground)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                            }
                        } else {
                            // iPhone → tu flujo original
                            if modelView.selectedTab == 1 && showCal {
                                calendarCard(selectedDate: $selectedData)
                            } else if modelView.selectedTab == 1 && !showCal {
                                TaskCard
                            } else if modelView.selectedTab == 2 {
                                TaskCard
                            } else {
                                TaskCard
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }.id(refreshID)
                .refreshable {
                    Task {
                        await SyncManagerDownload.shared.syncTasks(context: context)
                        switch modelView.selectedTab {
                        case 0:
                            listTask = HomeApi.fetchNoDateTasks(context: context)
                        case 1:
                            listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
                        case 2:
                            listTask = HomeApi.loadTasksEnd(context: context)
                        default:
                            listTask = []
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                readyToShowTasks = true
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    buttonControlMark
                }.padding(.trailing, 30)
                    .padding(.bottom, sizeClass == .regular ? 90 :  150)
               
            }
            .ignoresSafeArea(.keyboard)
            .onAppear{
                modelView.setContext(context)
            }
        }
    }

    // MARK: - Tarjeta expandida para iPad
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
                                Task {
                                    await SyncManagerUpload.shared.uploadTask(task: task)
                                }
                                try context.save()
                                
                                withAnimation(.easeOut(duration: 0.25)) {
                                    listTask.removeAll { $0.id == task.id }
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
                        .padding(.leading, 6)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(accentColor)
                            .padding(.leading, 6)
                    }
                }
                
                // 📁 Proyecto
                if let project = task.project {
                    Label(project.title, systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.purple) // 💜 Color para proyectos
                } else {
                    Label("Sin proyecto", systemImage: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                
                // 📅 Evento
                if let event = task.event {
                    Label(event.title, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(Color.eventButtonColor) // 🎨 Color para eventos
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
    
    // MARK: – Segment Button
    
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (modelView.selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) { modelView.selectedTab = tag }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .blue)
                .frame(maxHeight: 36)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    
    // MARK: – Picker bar
    
    private var pickerBard: some View {
        HStack(spacing: 10) {
            segmentButton(title: "Sin fecha", tag: 0)
            segmentButton(title: "Agendadas", tag: 1)
            segmentButton(title: "Finalizadas", tag: 2)
        }
        .padding(15)
        .background(Color.cardBackground)
        .cornerRadius(40)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
    }
    
    
    // MARK: – Botonera inferior (iPad: 🔄 + ➕ | iPhone: 📅 + ➕)
    private var buttonControlMark: some View {
        HStack(spacing: 14) {
            Spacer()
            
            // MARK: 💻 iPad (regular width)
            if sizeClass == .regular {
                if #available(iOS 26.0, *) {
                    // 🔄 Actualizar (iPad)
                    Button(action: {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncTasks(context: context)
                            withAnimation(.easeOut(duration: 0.3)) {
                                refreshID = UUID()
                                isSyncing = false
                            }
                        }
                    }) {
                        ZStack {
                            if isSyncing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.taskButtonColor)
                                    .scaleEffect(1.1)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.taskButtonColor)
                            }
                        }
                        .frame(width: 58, height: 58)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                    .disabled(isSyncing)
                    
                    // ➕ Añadir (iPad)
                    Button(action: {
                        showAddTaskView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.taskButtonColor)
                            .frame(width: 58, height: 58)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
                } else {
                    // 💧 Versiones anteriores → liquidGlass
                    Button(action: {
                        Task {
                            isSyncing = true
                            await SyncManagerDownload.shared.syncTasks(context: context)
                            withAnimation(.easeOut(duration: 0.3)) {
                                refreshID = UUID()
                                isSyncing = false
                            }
                        }
                    }) {
                        ZStack {
                            if isSyncing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.taskButtonColor)
                                    .scaleEffect(1.1)
                            } else {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.taskButtonColor)
                            }
                        }
                        .frame(width: 58, height: 58)
                    }
                   
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 3)
                    .disabled(isSyncing)

                    Button(action: {
                        showAddTaskView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.taskButtonColor)
                            .frame(width: 58, height: 58)
                    }
                   
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 3)
                }
            }

            // MARK: 📱 iPhone (compact width)
            else {
                // 🗓️ Calendario (solo iPhone)
                if modelView.selectedTab == 1 {
                    if #available(iOS 26.0, *) {
                        Button(action: {
                            withAnimation(.easeInOut) { showCal.toggle() }
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.taskButtonColor)
                                .padding(14)
                        }
                        .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                        .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                    } else {
                        Button(action: {
                            withAnimation(.easeInOut) { showCal.toggle() }
                        }) {
                            Image(systemName: "calendar")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.taskButtonColor.opacity(0.9))
                                        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                                )
                        }
                    }
                }

                // ➕ Añadir (iPhone)
                if #available(iOS 26.0, *) {
                    Button(action: {
                        showAddTaskView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.taskButtonColor)
                            .padding(16)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.15)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.35), radius: 5, x: 0, y: 3)
                } else {
                    Button(action: {
                        showAddTaskView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(Color.taskButtonColor.opacity(0.9))
                                    .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 3)
                            )
                    }
                }
            }
        }
        // 📏 Alineación con el bloque de tareas
     
        .sheet(isPresented: $showAddTaskView, onDismiss: {
            guard let contextTask = try? context.fetch(FetchDescriptor<TaskItem>()) else { return }

            if let lastTask = contextTask.sorted(by: { $0.createDate ?? Date() > $1.createDate ?? Date() }).first {
                if lastTask.status == .off {
                    listTask = HomeApi.loadTasksEnd(context: context)
                } else if lastTask.endDate == nil {
                    listTask = HomeApi.fetchNoDateTasks(context: context)
                } else {
                    listTask = HomeApi.fetchDateTasks(date: lastTask.endDate!, context: context)
                }
            }
            refreshID = UUID()
        }) {
            CreateTask()
        }
    }
    // MARK: – Task Card
    
    private var TaskCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if modelView.selectedTab == 0 {
                    Text("Sin fecha")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else if modelView.selectedTab == 1 {
                    Text(utilFunctions.formattedDate(selectedData))
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else {
                    Text("Tareas finalizadas")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                }
                
                Spacer()
                Text("\(listTask.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            
            if listTask.isEmpty {
                emptyTaskList
            } else if readyToShowTasks {
                if modelView.selectedTab == 2 {
                    endTaskList
                } else {
                    taskListToDo
                }
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            switch modelView.selectedTab {
            case 0:
                listTask = HomeApi.fetchNoDateTasks(context: context)
            case 1:
                listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
            case 2:
                listTask = HomeApi.loadTasksEnd(context: context)
            default:
                listTask = []
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    readyToShowTasks = true
                }
            }
        }
    }
    
    
    // MARK: – Calendar Card
    
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
            .padding(.horizontal, 20)
            .onChange(of: selectedData) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    readyToShowTasks = true
                    listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) {
                        readyToShowTasks = true
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    
    // MARK: – Empty state
    
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
    
    
    // MARK: – Task list ToDo
    
    private var taskListToDo: some View {
        LazyVStack(spacing: 12) {
            ForEach(listTask, id: \.id) { task in
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
                                listTask.removeAll { $0.id == task.id }
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
                }            }
        }
        .padding(.vertical, 8)
        .animation(.easeOut(duration: 0.35), value: listTask)
    }
    
    
    // MARK: – End Task list
    
    private var endTaskList: some View {
        let tasksWithDate = listTask.filter { $0.completeDate != nil }
        let groupTaskByDate = Dictionary(grouping: tasksWithDate) { task in
            Calendar.current.startOfDay(for: task.completeDate!)
        }
        let groupTaskByDateOrdered = groupTaskByDate
            .map { (date: $0.key, task: $0.value) }
            .sorted { $0.date > $1.date }
        
        return LazyVStack(spacing: 12) {
            ForEach(groupTaskByDateOrdered, id: \.date) { tasks in
                Text("\(utilFunctions.formattedDate(tasks.date))")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.95, green: 0.95, blue: 0.97, opacity: 0.8),
                                Color(red: 0.90, green: 0.90, blue: 0.93, opacity: 0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(20)
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
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                if let due = task.endDate {
                                    Text(utilFunctions.formattedDateShort(due))
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                do {
                                    try context.delete(task)
                                    Task{
                                       await SyncManagerUpload.shared.deleteTask(task: task)
                                    }
                                    withAnimation {
                                        listTask.removeAll { $0.id == task.id }
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
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .animation(.easeOut(duration: 0.35), value: listTask)
    }
}
