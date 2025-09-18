// ContentView.swift
// SecondMind

import SwiftUI
import SwiftData

// MARK: — Vista Principal con TabBar
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var  navModel : SelectedViewList
    
    @State var deletedTaskToday : Bool = false
 
   

    var body: some View {
        
       
        
        TabView(selection : $navModel.selectedView) {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }.tag(0)
            ProjectView()
                .tabItem { Label("Proyectos", systemImage: "folder.fill")}.tag(3)
            TaskView()
                .tabItem { Label("Tareas", systemImage: "checkmark.circle.fill") }.tag(1)
            EventsView().tabItem { Label("Eventos", systemImage: "calendar")}.tag(2)
           
           
        }
        .accentColor(Color.taskButtonColor)
   
        .onAppear{
        
          
                
                DispatchQueue.main.async {
                    
                      if let lastUpdate = HomeApi.loadLastDeleteTaskDate(context: context) {
                          print(lastUpdate)
                          if let lastUpdateDate = lastUpdate.date{
                              deletedTaskToday = todayDiferentLastUpdate(lastUpdateDate: lastUpdateDate)
                              print(deletedTaskToday)
                              if deletedTaskToday {
                                 deleteOldTask()
                              }
                              DataSeeder.seed(in: context)
                              context.delete(lastUpdate)
                              context.insert(lastDeleteTask(date:Date()))
                          }
                    }
                
            }
           
            
            
        }
     
    }

    
    private func deleteOldTask(){
        
        let oldTask : [TaskItem] = HomeApi.loadTasksEnd(context: context)
        let sevenDays : Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        
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
        // Devolver true si NO es el mismo día (es decir, sí hay diferencia)
        return !Calendar.current.isDateInToday(lastUpdateDate)
    }

    
    
}

