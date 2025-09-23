import SwiftUI
import SwiftData
import Foundation

struct EventMark: View {
  
    @Environment(\.modelContext) private var context
    @EnvironmentObject var  utilFunctions : generalFunctions

    @StateObject var modelView : EventMarkModelView
    
    init() {
           // aquí todavía NO tienes acceso al @Environment,
           // así que necesitas inicializarlo vacío
           _modelView = StateObject(wrappedValue: EventMarkModelView())
       }
    @State private var selectedData: Date = Date()
   
    private let accentColor = Color.eventButtonColor
    
    @State private var readyToShowTasks: Bool = false
    @State private var showCal: Bool = false
    @State private var showAddTaskView: Bool = false
   
    
    
    
    var body: some View {
        
       
            
            ZStack(alignment: .bottomTrailing) {
              
              
                            
            
                VStack(spacing: 20) {
                    headerCard(title:"Eventos").padding(.top, 16)
                    pickerBard
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            if modelView.selectedTab == 0 && showCal {
                                calendarCard(selectedDate: $selectedData)
                                
                            }
                            else if modelView.selectedTab == 0 && !showCal {
                                TaskCard
                                
                            } else if modelView.selectedTab == 1 && showCal {
                                calendarCard(selectedDate: $selectedData)
                                
                            }else if modelView.selectedTab == 1 && !showCal {
                                TaskCard
                            }}
                        .padding(.vertical, 16)
                        
                        
                        } // Espacio para la TabBar
                        .onChange(of: modelView.selectedTab) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCal = false
                              
                            }
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
                    
            }.onAppear{
                
                modelView.setContext(context: context)
            }
        
            
        
        
    }


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
    
    
    // MARK: – Tarjeta con el DatePicker
  
    
    private var pickerBard : some View {
        // — Segmented control personalizado —
        HStack(spacing: 10) {
            
            segmentButton(title: "Agendados", tag: 0)
            segmentButton(title: "Finalizados", tag: 1)
        }.padding(15) .background(Color.cardBackground)
            
            .cornerRadius(40)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
        
        
    }
    
    private var buttonControlMark: some View {
        
        HStack(spacing: 10) {
           
                
                   if modelView.selectedTab == 0 {
                       if #available(iOS 26.0, *) {
                           Button(action: {
                               showCal.toggle()
                           }) {
                               Image(systemName: "calendar")
                                   .font(.system(size: 28, weight: .bold))
                                   .foregroundColor(.eventButtonColor)
                                   .padding(16)
                           }
                           .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                           .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4)
                       } else {
                           // Fallback para versiones anteriores
                           Button(action: {
                               showCal.toggle()
                           }) {
                               Image(systemName: "calendar")
                                   .font(.system(size: 28, weight: .bold))
                                   .foregroundColor(.white)
                                   .padding(16)
                                   .background(Circle().fill(Color.eventButtonColor.opacity(0.9)))
                                   .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                           }
                       }
            }
            if #available(iOS 26.0, *) {
                Button(action: {
                    showAddTaskView = true                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.eventButtonColor)
                        .padding(16)
                }
                .glassEffect(.regular.tint(Color.white.opacity(0.1)).interactive(), in: .circle)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 0, y: 4) .sheet(isPresented: $showAddTaskView, onDismiss: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        modelView.loadEvents(date: selectedData)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                readyToShowTasks = true
                            }
                            
                        }}
                }){
                    CreateEvent()
                }
                
            } else {
                // Fallback para versiones anteriores
                Button(action: {
                 
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.eventButtonColor.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
                        )
                } .sheet(isPresented: $showAddTaskView, onDismiss: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        
                        modelView.loadEvents(date: selectedData)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                readyToShowTasks = true
                                debugPrint(modelView.events)
                            }
                            
                        }}
                }){
                    CreateEvent()
                    
                }
                
            }
            
        
            
        }.padding(10)
            
            .padding(.bottom, 60)
        
    }
    
    private var TaskCard: some View {
        
        
        
        
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                
                
                if modelView.selectedTab == 0 {
                    Text(utilFunctions.formattedDate(selectedData)).foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }else{
                    Text("Eventos finalizados").foregroundColor(.primary)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                Text("\(modelView.events.count)")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            Rectangle()
                .fill(Color.primary.opacity(0.1))
                .frame(height: 1)
            if modelView.events.isEmpty {
                emptyEventsList()
                
            }else if readyToShowTasks {
                    // Uso de ScrollView + LazyVStack en lugar de List para más control visual
                
                if modelView.selectedTab == 0 {
                    
                    eventsListToDo()
                    
                }else if modelView.selectedTab == 1 {
                    
                    
                    endEventsList()
                }
            
             
                   
                        }
                    }.onChange(of: modelView.selectedTab) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            switch modelView.selectedTab {
                            case 0:
                                modelView.loadEvents(date: selectedData)
                                break;
                            case 1:
                                modelView.loadEvents()
                                
                                break;
                                    
                            default:
                                break;
                            }
                           
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    readyToShowTasks = true
                                }
                                
                            }}
                    }.onAppear {
                        switch modelView.selectedTab {
                        case 0:
                            modelView.loadEvents(date: selectedData)
                            break;
                        case 1:
                            modelView.loadEvents()
                            break;
                                
                        default:
                            break;
                        }
                        utilFunctions.pastEvent(eventList: &modelView.events, context: context)
                       
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                readyToShowTasks = true
                }
                    
                }
            
        }.padding(.vertical, 8)
        
        // o lo que estimes conveniente
            .animation(.easeOut(duration: 0.35), value: modelView.events)
        .background(Color.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)}
        
    private func calendarCard(selectedDate: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selecciona fecha")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            DatePicker(
                "",
                selection: $selectedData,
                in: Date()...,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding(.horizontal, 20).onChange(of: selectedData) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showCal = false
                    readyToShowTasks = true
                    modelView.loadEvents(date : selectedData)
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
    
    
    private func emptyEventsList() -> some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundColor(accentColor.opacity(0.7))
            
            Text("No hay eventos disponibles")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }  .frame(maxWidth: .infinity, minHeight: 150)
            .padding(20)
    }

    private func eventsListToDo() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(modelView.events, id: \.id) { event in
                NavigationLink(destination: EventDetall(editableEvent:event)) {
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .foregroundColor(accentColor)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 8) {
                            // Título + hora
                            HStack(alignment: .center, spacing: 8) {
                                Text(event.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Spacer()

                                Label {
                                    Text(utilFunctions.extractHour(event.endDate))
                                } icon: {
                                    Image(systemName: "clock")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(accentColor)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(accentColor.opacity(0.12))
                                .clipShape(Capsule())
                            }

                            // Descripción
                            if let description = event.descriptionEvent,
                               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            } else {
                                Text("No hay descripción")
                                    .font(.system(size: 14).italic())
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .lineLimit(2)
                            }

                            // Proyecto
                            if let project = event.project?.title,
                               !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder")
                                        .font(.system(size: 13))
                                        .foregroundColor(.purple)

                                    Text(project)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.purple)
                                        .lineLimit(1)
                                }
                                .padding(.top, 4)
                            } else {
                                HStack(spacing: 6) {
                                    Image(systemName: "folder.badge.questionmark")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.6))

                                    Text("Sin proyecto")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                .padding(.top, 4)
                            }
                        }

                        Spacer()
                    }
                    .padding(12).overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                    )
                  
                   
                   
                    
                }
                
                
            }
        }
        .padding(.vertical, 8)
        
        // o lo que estimes conveniente
       
        .padding(.horizontal, 16)
    }
    
    private func endEventsList() -> some View {
        
        let groupedEvents = Dictionary(grouping: modelView.events) { event in
            Calendar.current.startOfDay(for: event.endDate)
        }
        let sortedGroups = groupedEvents
            .map { (date: $0.key, events: $0.value) }
            .sorted { $0.date >= $1.date }
        
      return  LazyVStack(spacing: 12) {
            
       
            
            ForEach(sortedGroups, id: \.date) { event in
                
                VStack{
                    
                    Text("\(utilFunctions.formattedDate(event.date))").font(.title3.weight(.bold))
                        .foregroundColor(.primary).padding().background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.75, opacity: 0.8),
                                    Color(red: 1.0, green: 0.78, blue: 0.65, opacity: 0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(20)
                    
                    ForEach(event.events, id: \.id) { event in
                        NavigationLink(destination: EventDetall(editableEvent:event)) {
                            
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(accentColor)
                                    .padding(.top, 4)

                                VStack(alignment: .leading, spacing: 8) {
                                    // Título + hora
                                    HStack(alignment: .center, spacing: 8) {
                                        Text(event.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)

                                        Spacer()

                                        Label {
                                            Text(utilFunctions.extractHour(event.endDate))
                                        } icon: {
                                            Image(systemName: "clock")
                                        }
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(accentColor)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 10)
                                        .background(accentColor.opacity(0.12))
                                        .clipShape(Capsule())
                                    }

                                    // Descripción
                                    if let description = event.descriptionEvent,
                                       !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text(description)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    } else {
                                        Text("No hay descripción")
                                            .font(.system(size: 14).italic())
                                            .foregroundColor(.secondary.opacity(0.6))
                                            .lineLimit(2)
                                    }

                                    // Proyecto
                                    if let project = event.project?.title,
                                       !project.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "folder")
                                                .font(.system(size: 13))
                                                .foregroundColor(.purple)

                                            Text(project)
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.purple)
                                                .lineLimit(1)
                                        }
                                        .padding(.top, 4)
                                    } else {
                                        HStack(spacing: 6) {
                                            Image(systemName: "folder.badge.questionmark")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray.opacity(0.6))

                                            Text("Sin proyecto")
                                                .font(.system(size: 13))
                                                .foregroundColor(.gray.opacity(0.6))
                                        }
                                        .padding(.top, 4)
                                    }
                                }

                                Spacer()
                            }
                            .padding(12).overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 0.5)
                            )
                            
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                            
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                            
                        }}
                }
                .padding(.vertical, 8)
                
                // o lo que estimes conveniente
               
                .padding(.horizontal, 16)
                
                
                
            }
                    
                    
                }
                
                
                
            }
            
  
    
    

        }
        
        
       
       
       
