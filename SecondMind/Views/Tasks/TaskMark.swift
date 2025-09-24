import SwiftUI
import SwiftData

struct TaskMark: View {
    
    @EnvironmentObject var navModel: SelectedViewList
    @EnvironmentObject var utilFunctions: generalFunctions
    @Environment(\.modelContext) private var context
    
    @State var listTask: [TaskItem] = []
    @State private var readyToShowTasks: Bool = false
    @State private var usableSize: CGSize = .zero
    @State private var selectedData: Date = Date()
    private let accentColor = Color.taskButtonColor
    
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundColorTemplate()
            
            VStack(spacing: 20) {
                headerCard(title: "Tareas")
                    .padding(.top, 16)
                pickerBard
                
                ScrollView {
                    VStack(spacing: 20) {
                        if navModel.selectedTab == 1 && showCal {
                            calendarCard(selectedDate: $selectedData)
                        }
                        else if navModel.selectedTab == 1 && !showCal {
                            TaskCard
                        }
                        else if navModel.selectedTab == 2 {
                            TaskCard
                        } else {
                            TaskCard
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
            .safeAreaInset(edge: .bottom) {
                // 👇 Botón flotante bien colocado, no tapa el contenido
                HStack {
                    Spacer()
                    buttonControlMark
                }
                .padding(.trailing, 16)
                .padding(.bottom, 80)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    
    // MARK: – Segment Button
    
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (navModel.selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) { navModel.selectedTab = tag }
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
    
    
    // MARK: – Botón flotante (+ y calendario)
    
    private var buttonControlMark: some View {
        HStack(spacing: 10) {
            if navModel.selectedTab == 1 {
                if #available(iOS 26.0, *) {
                    Button(action: {
                        withAnimation(.easeInOut) { showCal.toggle() }
                        print(showCal, navModel.selectedTab)
                    }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.taskButtonColor)
                            .padding(16)
                    }
                    .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                    .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                } else {
                    Button(action: {
                        withAnimation(.easeInOut) { showCal.toggle() }
                        print(showCal, navModel.selectedTab)
                    }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.taskButtonColor.opacity(0.9))
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                    }
                }
            }
            
            // ✅ BOTÓN +
            if #available(iOS 26.0, *) {
                Button(action: {
                    showAddTaskView = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.taskButtonColor)
                        .padding(16)
                }
                .glassEffect(.clear.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                .sheet(isPresented: $showAddTaskView, onDismiss: {
                    if navModel.selectedTab == 1 {
                        listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
                    } else {
                        listTask = HomeApi.fetchNoDateTasks(context: context)
                    }
                }) {
                    CreateTask() // 👈 sigue igual
                }
            } else {
                Button(action: {
                    showAddTaskView = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.taskButtonColor.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                }
                .sheet(isPresented: $showAddTaskView, onDismiss: {
                    if navModel.selectedTab == 1 {
                        listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
                    } else {
                        listTask = HomeApi.fetchNoDateTasks(context: context)
                    }
                }) {
                    CreateTask() // 👈 sigue igual
                }
            }
        }
        .padding(10)
        .padding(.bottom, 60)
    }
    
    
    // MARK: – Task Card
    
    private var TaskCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if navModel.selectedTab == 0 {
                    Text("Tareas de hoy")
                        .foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                } else if navModel.selectedTab == 1 {
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
                if navModel.selectedTab == 2 {
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
            switch navModel.selectedTab {
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
                        Image(systemName: "checklist")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(task.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                if let due = task.endDate {
                                    Label {
                                        Text(utilFunctions.extractHour(due))
                                    } icon: {
                                        Image(systemName: "clock")
                                    }
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(accentColor)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 10)
                                    .background(accentColor.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            task.completeDate = Date()
                            task.status = .off
                            do {
                                try context.save()
                                listTask.removeAll { $0.id == task.id }
                            } catch {
                                print("❌ Error al guardar: \(error)")
                            }
                        }) {
                            Image(systemName: "circle")
                                .font(.system(size: 21))
                                .foregroundColor(Color.gray)
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
                                    Text(due.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                do {
                                    try context.delete(task)
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
