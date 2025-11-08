import Foundation
import SwiftData
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    
   
    @Published var listTask: [TaskItem] = []
    @Published var listTaskCalendarIpad: [TaskItem] = []
    @Published var readyToShowTasks: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var selectedTab: Int = 0
    @Published var selectedData: Date = Date()
    @Published var showCal: Bool = false
    @Published var showAddTaskView: Bool = false
    @Published var sizeClass: enumSizeClass.UserInterfaceType = .compact

    private var context: ModelContext?
    func setContext(context: ModelContext) {
        self.context = context
    }
    func setParameters(_ context: ModelContext, _ sizeClass: enumSizeClass.UserInterfaceType) {
        self.context = context
  
        self.sizeClass = sizeClass
    }

    func loadTasks() {
        guard let context else { return }
        // 🔥 Siempre limpias.
           
               
               readyToShowTasks = false
           

        if sizeClass == .compact{
            switch selectedTab {
                
                
            case 0:
                listTask = HomeApi.fetchNoDateTasks(context: context)
                break;
            case 1:
                listTask = HomeApi.fetchDateTasks(date: selectedData, context: context)
            case 2:
                listTask = HomeApi.loadTasksEnd(context: context)
                
            default:
                listTask = []
                break
            }
        }else{
            
            switch selectedTab {
                
                
            case 0:
                listTask = HomeApi.fetchNoDateTasks(context: context)
                listTaskCalendarIpad = HomeApi.fetchDateTasks(date: selectedData, context: context)
                break;
            case 1:
            
                listTask = HomeApi.loadTasksEnd(context: context)
                break;
            default:
                listTask = []
                break
            }
        }

        

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.readyToShowTasks = true
            }
        }
    }
    

    

    func markAsCompleted(_ task: TaskItem) {
        guard let context else { return }
        task.completeDate = Date()
        task.status = .off
        do {
            try context.save()
            Task { await SyncManagerUpload.shared.uploadTask(task: task) }
            listTask.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al guardar: \(error)")
        }
    }

    func deleteTask(_ task: TaskItem) {
        guard let context else { return }
        do {
            try context.delete(task)
            try context.save()
            Task { await SyncManagerUpload.shared.deleteTask(task: task) }
            listTask.removeAll { $0.id == task.id }
        } catch {
            print("❌ Error al borrar: \(error)")
        }
    }
    
    
}


extension TaskViewModel: BaseTaskViewModel {}
