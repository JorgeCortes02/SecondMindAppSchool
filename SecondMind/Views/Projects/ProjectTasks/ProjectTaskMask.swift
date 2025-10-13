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
 
    
    @Bindable var project: Project
    @State private var usableSize: CGSize = .zero
    @State private var selectedData: Date = Date()
    private let accentColor = Color.taskButtonColor
    
    
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
    
    
    var body: some View {
        
        ZStack{
            BackgroundColorTemplate()
            
            VStack(spacing: 20) {
                headerCard(title: "Tareas").padding(.top, 16)
                pickerBard
                
                ScrollView {
                    VStack(spacing: 20) {
                        if modelView.selectedTab == 1 && showCal {
                            calendarCard(selectedDate: $selectedData)
                            
                        }
                        else if modelView.selectedTab == 1 && !showCal {
                            TaskCard
                            
                        }  else if modelView.selectedTab == 2{
                            
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
            .onAppear {
                modelView.setParameters(context: context, project: project)
            }
        }
    }
    
    
    
    // MARK: – Botón para cada segmento
    private func segmentButton(title: String, tag: Int) -> some View {
        let isSelected = (modelView.selectedTab == tag)
        return Button(action: {
            withAnimation(.easeInOut) {
                modelView.selectedTab = tag
            }
        }) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : .taskButtonColor)
                .frame( maxHeight: 36).frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.taskButtonColor)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                            
                            
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: – Tarjeta con el DatePicker
    
    
    private var pickerBard : some View {
        // — Segmented control personalizado —
        HStack(spacing: 10) {
            segmentButton(title: "Sin fecha", tag: 0)
            segmentButton(title: "Agendadas", tag: 1)
            segmentButton(title: "Finalizadas", tag: 2)
        }.padding(15) .background(Color.cardBackground)
        
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        
        
    }
    
    private var buttonControlMark: some View {
        
        HStack(spacing: 10) {
            if modelView.selectedTab == 1 {
                if #available(iOS 26.0, *) {
                    Button(action: {
                        withAnimation(.easeInOut) { showCal.toggle() }
                      
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
                        print(showCal, modelView.selectedTab)
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
                    }}
            }
            
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
                    
                switch modelView.selectedTab
                    {
                        
                        case 0 :
                            
                            modelView.loadEvents()
                            break;
                        case 1 :
                            modelView.loadEvents(selectedData: selectedData)
                            break;
                        default:
                            break;
                    }
                        
                }){
                    CreateTask(project: project)
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
                }.sheet(isPresented: $showAddTaskView, onDismiss: {
                    switch modelView.selectedTab
                        {
                            
                            case 0 :
                                
                                modelView.loadEvents()
                                break;
                            case 1 :
                                modelView.loadEvents(selectedData: Date())
                                break;
                            default:
                                break;
                        }
                }){
                    CreateTask(project: project)
                }}
        }.padding(10)
        .padding(.bottom, 60)
    
         
            
            
        
        
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

           .background(Color.cardBackground)
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
        .background(Color.cardBackground)
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
        
        
       
       
       
